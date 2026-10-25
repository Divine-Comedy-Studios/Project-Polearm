using Godot;
using System.Diagnostics;


public partial class FloatingBody : CharacterBody3D {
	// Initialization functions

	private void _configureHitboxes() {
		m_rayQuery = PhysicsRayQueryParameters3D.Create(Vector3.Zero, Vector3.Zero, 0);
		m_rayQuery.CollisionMask = groundCast.CollisionMask;

		groundCast.MaxResults = MAX_GROUND_COLLISIONS;

		m_bodyColliderShape.Radius = BODY_COLLIDER_RADIUS;
		_floatingCollider();

		m_collisionProbeShape = PhysicsServer3D.CapsuleShapeCreate();
		PhysicsServer3D.ShapeSetData(m_collisionProbeShape, new Godot.Collections.Dictionary<string, float> {
			{ "height", BODY_COLLIDER_HEIGHT },
			{ "radius", BODY_COLLIDER_RADIUS }
		});

		m_collisionProbeBody = PhysicsServer3D.BodyCreate();
		PhysicsServer3D.BodySetMode(m_collisionProbeBody, PhysicsServer3D.BodyMode.Static);
		PhysicsServer3D.BodySetCollisionMask(m_collisionProbeBody, CollisionMask);
		PhysicsServer3D.BodySetSpace(m_collisionProbeBody, GetWorld3D().Space);

		m_motionParameters = new PhysicsTestMotionParameters3D();
	}

	private void _floatingCollider() {
		bodyCollider.Position = new Vector3(0, BODY_COLLIDER_POSITION, 0);
		m_bodyColliderShape.Height = BODY_COLLIDER_HEIGHT;

		m_groundCastShape.Radius = GROUND_CAST_RADIUS;
	}

	private void _standingCollider() {
		bodyCollider.Position = new Vector3(0, CHARACTER_POSITION_BUFFERED, 0);
		m_bodyColliderShape.Height = CHARACTER_HEIGHT_BUFFERED;
	}


	// Physics functions

	private void _processCollisions() {
		if (!m_collisionProcessingEnabled) return;

		// If the foot data from last frame was not grounded and the player is floating a considerable distance,
		// above gorund, the distance leniency in the collision check is removed by setting grounded to false
		if (m_grounded && !m_footData.Grounded && m_groundData.Offset > GROUND_DISTANCE_BUFFER)
			m_distanceBufferEnabled = false;
		
		bool lastForwardProbeGrounded = m_footData.Grounded;


		// First we check for ground collisions

		_processGroundCollisionData();
		_processFootCollisionData();

		if (m_groundData.Grounded || m_footData.Grounded || lastForwardProbeGrounded) {
			if (!m_grounded)
				AttachGround();
		} else {
			DetachGround();
			return;
		}

		if (m_grounded)
			m_distanceBufferEnabled = true;
		

		// Movement collision checks

		m_noFlatVelocity = Mathf.IsZeroApprox(PPUtil.Math.FlatLengthSquared(m_targetVelocity));

		if (m_noFlatVelocity) { // Stepping collision checks
			_calculateStepWallProbeQuery(GlobalPosition, m_groundData.Point);

			if (!_checkStepDown())
				_checkStepUp();
		} else {
			m_lastNonZeroDir = new Vector3(m_targetVelocity.X, 0, m_targetVelocity.Z).Normalized();

			// If we are moving, we calculate a point in the direction the player is moving 
			// slightly behind the edge of the player hitbox. This allows us to perform smoothing
			_probePointInDirection(GlobalPosition, m_lastNonZeroDir);
		}
	}


	private void _calculateVelocity(float delta) {
		const float COLLISION_EPSILON_SQARED = COLLISION_EPSILON * COLLISION_EPSILON;

		if (!m_grounded) { // Flying ignores all below calculations
			Velocity = m_targetVelocity;
			return;
		}

		// Directly adapted from godot source code
		Vector3 groundVelocity = Vector3.Zero;
		if (m_groundState != null)
			groundVelocity = m_groundState.GetVelocityAtLocalPosition(GlobalTransform.Origin - m_groundState.Transform.Origin);


		Vector3 correctionVelocity = Vector3.Zero;
		Vector3 targetVelocity = m_targetVelocity;

		bool lastFrameStill = Mathf.IsZeroApprox(PPUtil.Math.FlatLengthSquared(Velocity));

		if (!m_noFlatVelocity) {
			if (Mathf.Abs(m_groundData.Offset) < COLLISION_EPSILON) {
				Position += Vector3.Down * m_groundData.Offset;
				m_groundData.Offset = 0.0f;
			}

			Vector3 line = GlobalPosition - m_footData.Point;
			line.Y += m_groundData.Offset / VELOCITY_VERTICAL_OVERCORRECTION_FACTOR;

			Vector3 vel = new Vector3(targetVelocity.X, 0.0f, targetVelocity.Z);
			if (PPUtil.Math.FlatLengthSquared(line) < COLLISION_EPSILON_SQARED) { // If the horizontal component of line is too small
				vel = PPUtil.Math.RotateVectorOntoPlane(vel, m_groundData.Normal);
			} else { // The two cross products produce the final slope vector to rotate velocity by
				vel = PPUtil.Math.RotateVectorOntoPlane(vel, line.Cross(m_footData.Normal).Cross(line).Normalized());
			}
			targetVelocity = new Vector3(vel.X, vel.Y + targetVelocity.Y, vel.Z);
		}

		if ((lastFrameStill || m_noFlatVelocity) && m_groundedData.Grounded) {
			float absOffset = Mathf.Abs(m_groundedData.Offset);

			if (absOffset > STEP_MAX_HEIGHT)
				m_stepState = StepState.None;
			else if (absOffset < COLLISION_EPSILON) {
				m_stepState = StepState.None;

				Position += Vector3.Down * m_groundedData.Offset;
			} else correctionVelocity.Y = -m_groundedData.Offset / delta * STEP_SPEED_FACTOR;
		}


		Velocity = targetVelocity + correctionVelocity + groundVelocity;
	}


	// Collision analysis functions

	private void _processGroundCollisionData() {
		m_groundData.Clear();

		if (!groundCast.IsColliding())
			return;

		m_groundData.Point = _highestGroundPointGlobal();
		m_groundData.Offset = _vertOffsetToPlayerGlobal(m_groundData.Point);
		if (m_groundData.Offset > _bufferedGroundMaxDistance())
			return;

		_setRayQuery(m_groundData.Point + Vector3.Up, m_groundData.Point - DOWNWARDS_RAY_LENGTH);
		var normalRayCollision = GetWorld3D().DirectSpaceState.IntersectRay(m_rayQuery);
		if (normalRayCollision.Count == 0)
			return;

		if (Mathf.Abs(m_groundData.Point.Y - ((Vector3)normalRayCollision["position"]).Y) > COLLISION_EPSILON)
			// If we can't hit the same point as the sphereCast, we assume for safety that we are not grounded
			return;

		_setGroundObject(normalRayCollision);

		m_groundData.Normal = (Vector3)normalRayCollision["normal"];
		if (m_groundData.Normal.Y > SLOPE_MAX_ANGLE_COS)
			// As the normal vector is normalized, its angle can be determined by simply checking for its height
			m_groundData.Grounded = true;
	}

	private void _processFootCollisionData() {
		m_footData.Clear();

		_setRayQuery(GlobalPosition + Vector3.Up, GlobalPosition - DOWNWARDS_RAY_LENGTH);
		var collision = GetWorld3D().DirectSpaceState.IntersectRay(m_rayQuery);

		if (collision.Count == 0)
			return;

		if (m_groundState == null)
			_setGroundObject(collision);

		m_footData.Point = (Vector3)collision["position"];
		m_footData.Offset = _vertOffsetToPlayerGlobal(m_footData.Point);
		m_footData.Normal = (Vector3)collision["normal"];

		if (m_footData.Offset <= _bufferedGroundMaxDistance() && m_footData.Normal.Y > SLOPE_MAX_ANGLE_COS)
			// As the normal vector is normalized, its angle can be determined by simply checking for its height
			m_footData.Grounded = true;
	}

	// Gives the farthest point on the line from startingPos towards direction
	private void _probePointInDirection(Vector3 startingPos, Vector3 direction) {
		bool skippedOnce = false; // This allows us to skip one false collision

		float iterDistance = FORWARD_PROBE_DISTANCE / FORWARD_PROBE_COUNT;
		Vector3 iterShift = new Vector3(direction.X, 0, direction.Z) * iterDistance;

		Vector3 pos = startingPos;
		Vector3 oldPos = Vector3.Zero;

		for (int i = 0; i < FORWARD_PROBE_COUNT; i++) {
			oldPos = pos;
			pos += iterShift;

			_setRayQuery(oldPos + STEP_MAX_HEIGHT_VEC, pos + STEP_MAX_HEIGHT_VEC);
			if (GetWorld3D().DirectSpaceState.IntersectRay(m_rayQuery).Count != 0) {
				return;
			}

			_setRayQuery(pos + STEP_MAX_HEIGHT_VEC, pos - DOWNWARDS_RAY_LENGTH);
			var collision = GetWorld3D().DirectSpaceState.IntersectRay(m_rayQuery);
			if (collision.Count == 0) {
				if (skippedOnce)
					return;

				skippedOnce = true;
				continue;
			}

			Vector3 collPos = (Vector3)collision["position"];
			Vector3 collNorm = (Vector3)collision["normal"];

			float dist = pos.Y - collPos.Y;
			if (dist > _bufferedGroundMaxDistance() || collNorm.Y <= SLOPE_MAX_ANGLE_COS) {
				if (skippedOnce)
					return;

				skippedOnce = true;
				continue;
			}
			
			skippedOnce = false; // We reset the skip so that we can skip again the next time

			m_footData.Point = collPos;
			m_footData.Offset = dist;
			m_footData.Normal = collNorm;
			m_footData.Grounded = true;

			pos.Y = m_footData.Point.Y; // We only shift the next detection point upwards if the point was on valid ground
		}
	}

	private void _setGroundObject(Godot.Collections.Dictionary collision) {
		if (((Rid)collision["rid"]) != m_groundRID) { // Update the RID and physics body state of the current ground
			m_groundRID = (Rid)collision["rid"];
			m_groundState = PhysicsServer3D.BodyGetDirectState(m_groundRID);
		}
	}


	// Stepping functions

	private bool _checkStepDown() {
		if (m_stepState == StepState.Down ||
			!m_footData.Grounded ||
			m_footData.Offset < STEP_RAY_VERTICAL_OFFSET)
			return false;

		if (!_validateStepProbeQueryDirection(-m_lastNonZeroDir))
			return false;

		if (_probeStepWall()) { // We don't need to check if the distance is too large to step down, as it was already done for _probeData.grounded
			m_groundedData = m_footData;
			m_stepState = StepState.Down;
		}

		return true;
	}

	void _checkStepUp() {
		if (m_stepState == StepState.Up ||
			!m_groundData.Grounded ||
			m_groundData.Offset > -STEP_RAY_VERTICAL_OFFSET ||
			m_groundData.Offset < -STEP_MAX_HEIGHT)
			return;

		if (!_validateStepProbeQueryDirection(m_lastNonZeroDir))
			return;
		if (!_probeStepWall())
			return;

		m_motionParameters.From = new Transform3D(
			m_motionParameters.From.Basis,
			new Vector3(
				m_groundData.Point.X, 
				GlobalPosition.Y + STEP_MAX_HEIGHT + BODY_COLLIDER_POSITION, 
				m_groundData.Point.Z
			) - m_lastNonZeroDir * BODY_COLLIDER_RADIUS
		);
		m_motionParameters.Motion = m_lastNonZeroDir * STEP_MIN_DEPTH;

		PhysicsServer3D.BodyAddShape(m_collisionProbeBody, m_collisionProbeShape);
		bool testMotion = PhysicsServer3D.BodyTestMotion(m_collisionProbeBody, m_motionParameters);
		PhysicsServer3D.BodyRemoveShape(m_collisionProbeBody, 0);

		if (testMotion)
			return;

		m_groundedData = m_groundData;
		m_stepState = StepState.Up;
	}


	// Step validation functions

	// CAUTION: returns the non-globalized target position for usage in _validateStepProbeQueryDirection
	private void _calculateStepWallProbeQuery(Vector3 sourcePointGlobal, Vector3 targetPointGlobal) {
		_setRayQuery(
			new Vector3(sourcePointGlobal.X, targetPointGlobal.Y - STEP_RAY_VERTICAL_OFFSET, sourcePointGlobal.Z),
			new Vector3(targetPointGlobal.X - sourcePointGlobal.X, 0, targetPointGlobal.Z - sourcePointGlobal.Z) * STEP_RAY_SCALE_FACTOR
		);
	}

	// Checks if the wall of a step is actually a wall and not a slope
	private bool _probeStepWall() {
		m_rayQuery.To += m_rayQuery.From;
		var collision = GetWorld3D().DirectSpaceState.IntersectRay(m_rayQuery);
		return collision.Count > 0 && ((Vector3)collision["normal"]).Y <= SLOPE_MAX_ANGLE_COS;
	}

	// Check for a direction variable to prevent the body is moving in a direction incompatible with the step direction
	private bool _validateStepProbeQueryDirection(Vector3 direction) {
		return m_rayQuery.To.Dot(direction) >= 0;
	}


	// Utility functions

	// Also saves the index of the current point
	private Vector3 _highestGroundPointGlobal() {
		Debug.Assert(groundCast.IsColliding(), "PlayerPhysics._highestGroundPointGlobal(): The player ground detection cast is not colliding. Always check collisions first!");
	
		var result = groundCast.GetCollisionPoint(0);
		for (int i = 1; i < groundCast.GetCollisionCount(); i++) {
			var curr = groundCast.GetCollisionPoint(i);
			if (curr.Y > result.Y)
				result = curr;
		}

		return result;
	}

	private float _bufferedGroundMaxDistance() {
		return m_distanceBufferEnabled ? STEP_MAX_HEIGHT * (1 + GROUND_DISTANCE_BUFFER) : GROUND_DISTANCE_BUFFER;
	}

	// Returns a negative value if the point is above the player, and a positive one if the point is below the player
	private float _vertOffsetToPlayerGlobal(Vector3 globalPos) {
		return GlobalPosition.Y - globalPos.Y;
	}

	// Assign our cached ray cast query
	private void _setRayQuery(Vector3 from, Vector3 to) {
		m_rayQuery.From = from;
		m_rayQuery.To = to;
	}
}
