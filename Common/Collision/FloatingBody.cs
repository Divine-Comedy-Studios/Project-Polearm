using Godot;
using System;
using System.Diagnostics;
using System.Collections.Generic;
using System.Linq;


[GlobalClass] public partial class FloatingBody : CharacterBody3D {
	#region Helper classes

	private class GroundData {
		public Vector3 Point = Vector3.Zero;
		public Vector3 Normal = Vector3.Zero;
		public float Offset = 0;
		public bool Grounded = false;

		public void Clear() {
			Point = Vector3.Zero;
			Normal = Vector3.Zero;
			Offset = 0;
			Grounded = false;
		}
	}

	#endregion


	#region Enums

	private enum StepState {
		None,
		Up,
		Down,
	}

	#endregion


	#region Constants

	// Generall physics and collision settings

	private const int MAX_GROUND_COLLISIONS = 4;
	private const float COLLISION_EPSILON = 0.002f;
	private const float GROUND_DISTANCE_BUFFER = 0.1f;
	private const float MIN_STEP_SPEED = 0.1f;
	private const float VELOCITY_VERTICAL_OVERCORRECTION_FACTOR = 2.0f;


	// Raycast settings

	private const int STEP_RAY_SCALE_FACTOR = 4;
	private static readonly Vector3 DOWNWARDS_RAY_LENGTH = new Vector3(0.0f, 10.0f, 0.0f);


	// Hitbox configuration settings

	private const float COLLIDER_FALLING_RADIUS_FACTOR = 0.6f;
	private const float GROUND_CAST_DIST_TO_GROUND = 1.0f;
	private const float STEP_RAY_VERTICAL_OFFSET = 0.03f;

	#endregion


	#region Exported variables

	[ExportGroup("Collider settings")]
	[Export] public float CHARACTER_HEIGHT = 1.8f;
	[Export] public float BODY_COLLIDER_RADIUS = 0.3f;
	[Export] public float BODY_COLLIDER_FLOATING_HEIGHT = 0.3f;
	[Export] public float GROUND_CAST_RADIUS = 0.2f;

	[ExportGroup("Forward probe settings")]
	[Export] public float FORWARD_PROBE_DISTANCE = 0.4f;
	[Export] public int FORWARD_PROBE_COUNT = 4;

	[ExportGroup("Slope settings")]
	[Export(PropertyHint.Range, "-360, 360, 0.001, radians_as_degrees")] public float SLOPE_MAX_ANGLE = 0.786f;

	[ExportGroup("Step settings")]
	[Export] public float STEP_MAX_HEIGHT = 0.41f;
	[Export] public float STEP_MIN_DEPTH = 0.3f;
	[Export] public float STEP_SPEED_FACTOR = 0.4f;

	#endregion


	#region Scene Members

	[ExportGroup("Scene Members")]
	[Export] public CollisionShape3D bodyCollider = null;
	[Export] public ShapeCast3D groundCast = null;

	#endregion


	#region Member variables

	// References

	private float CHARACTER_HEIGHT_BUFFERED;
	private float CHARACTER_POSITION_BUFFERED;

	private float BODY_COLLIDER_HEIGHT;
	private float BODY_COLLIDER_POSITION;

	private float SLOPE_MAX_ANGLE_COS;

	private CapsuleShape3D m_bodyColliderShape;
	private SphereShape3D m_groundCastShape;


	// State

	private bool m_collisionProcessingEnabled = true;

	private bool m_grounded = true;
	private GroundData m_groundData = new GroundData();
	private GroundData m_footData = new GroundData();

	private GroundData m_groundedData; // Reference to the current ground data which is grounded
	private bool m_distanceBufferEnabled = true;

	private StepState m_stepState = StepState.None;
	private bool m_noFlatVelocity = true;

	private Vector3 m_lastNonZeroDir = Vector3.Zero;


	// Caching

	private Rid m_groundRID = new Rid();
	private PhysicsDirectBodyState3D m_groundState = null;

	private PhysicsRayQueryParameters3D m_rayQuery;
	private PhysicsTestMotionParameters3D m_motionParameters;

	private Rid m_collisionProbeBody;
	private Rid m_collisionProbeShape;

	#endregion


	#region Public functions

	public void init() => Init();
	public void Init() {
		Debug.Assert(bodyCollider != null, $"FloatingBody.Init(): Body collider is not assigned.");
    	Debug.Assert(groundCast != null, $"FloatingBody.Init(): Ground cast is not assigned.");


		// References

		CHARACTER_HEIGHT_BUFFERED = CHARACTER_HEIGHT - GROUND_DISTANCE_BUFFER;
		CHARACTER_POSITION_BUFFERED = CHARACTER_HEIGHT / 2;

		BODY_COLLIDER_HEIGHT = CHARACTER_HEIGHT - BODY_COLLIDER_FLOATING_HEIGHT;
		BODY_COLLIDER_POSITION = BODY_COLLIDER_HEIGHT / 2 + BODY_COLLIDER_FLOATING_HEIGHT;

		SLOPE_MAX_ANGLE_COS = Mathf.Cos(SLOPE_MAX_ANGLE);

		m_bodyColliderShape = (CapsuleShape3D)bodyCollider.Shape;
		m_groundCastShape = (SphereShape3D)groundCast.Shape;


		// State and caching

		m_groundedData = m_groundData; // Reference to the current ground data which is grounded

		m_rayQuery = PhysicsRayQueryParameters3D.Create(Vector3.Zero, Vector3.Zero, 0);
		m_motionParameters = new PhysicsTestMotionParameters3D();
	
		m_collisionProbeBody = PhysicsServer3D.BodyCreate();
		m_collisionProbeShape = PhysicsServer3D.CapsuleShapeCreate();


		// Init hitboxes
		_configureHitboxes();
	}

	public void tick(float delta) => Tick(delta);
	public void Tick(float delta) {
		_processCollisions();
		_moveAndSmooth(delta);
	}


	// Movement functions

	public void accelerateFlat(Vector3 target, float accelerationDt) => AccelerateFlat(new Vector2(target.X, target.Y), accelerationDt);
	public void AccelerateFlat(Vector3 target, float accelerationDt) =>AccelerateFlat(new Vector2(target.X, target.Y), accelerationDt);
	public void accelerateFlat(Vector2 target, float accelerationDt) => AccelerateFlat(target, accelerationDt);
	public void AccelerateFlat(Vector2 target, float accelerationDt) {
		Velocity = new Vector3(
			Mathf.MoveToward(Velocity.X, target.X, accelerationDt),
			Velocity.Y,
			Mathf.MoveToward(Velocity.Z, target.Y, accelerationDt)
		);
	}

	public void accelerateVertical(float target, float accelerationDt) => AccelerateVertical(target, accelerationDt);
	public void AccelerateVertical(float target, float accelerationDt) {
		Velocity = new Vector3(
			Velocity.X, 
			Mathf.MoveToward(Velocity.Y, target, accelerationDt), 
			Velocity.Z
		);
	}

	public void snapToFloor() => SnapToFloor();
	public void SnapToFloor() {
		Position = new Vector3(Position.X, Position.Y - m_groundData.Offset, Position.Z);
	}


	// State functions
	public void enableCollisionProcessing() => EnableCollisionProcessing();
	public void EnableCollisionProcessing()	{
		m_collisionProcessingEnabled = true;
	}

	public void disableCollisionProcessing() => DisableCollisionProcessing();
	public void DisableCollisionProcessing() {
		m_collisionProcessingEnabled = false;
	}

	public bool onGround() => OnGround();
	public bool OnGround() {
		return m_grounded;
	}

	public bool onlyOnGround() => OnlyOnGround();
	public bool OnlyOnGround() {
		return OnGround() && !IsOnCeiling() && !IsOnWall();
	}

	public bool onCeiling() => OnCeiling();
	public bool OnCeiling() {
		return IsOnCeiling();
	}

	public bool onlyOnCeiling() => OnlyOnCeiling();
	public bool OnlyOnCeiling() {
		return IsOnCeiling() && !OnGround() && !IsOnWall();
	}

	public bool onWall() => OnWall();
	public bool OnWall() {
		return IsOnWall();
	}

	public bool onlyOnWall() => OnlyOnWall();
	public bool OnlyOnWall() {
		return IsOnWall() && !IsOnCeiling() && !OnGround();
	}


	// Ground functions
	public Vector3 groundPoint() => GroundPoint();
	public Vector3 GroundPoint() {
		return m_groundedData.Point;
	}

	public Vector3 groundNormal() => GroundNormal();
	public Vector3 GroundNormal() {
		return m_groundedData.Normal;
	}

	public void detachGround() => DetachGround();
	public void DetachGround() {
		m_stepState = StepState.None;
		m_grounded = false;
		m_distanceBufferEnabled = false;

		m_groundRID = new Rid();
		m_groundState = null;

		_standingCollider();
	}

	public void attachGround() => AttachGround();
	public void AttachGround() {
		m_grounded = true;
		m_distanceBufferEnabled = true;

		_floatingCollider();
	}

	public void forceGroundDataUpdate() => ForceGroundDataUpdate();
	public void ForceGroundDataUpdate() {
		if (m_stepState == StepState.Down) {
			_processFootCollisionData();
		} else {
			groundCast.ForceShapecastUpdate();
			_processGroundCollisionData();
			m_groundedData = m_groundData;
		}
	}


	// Utility functions
	public bool slopeWalkable(Vector3 normalized) => SlopeWalkable(normalized);
	public bool SlopeWalkable(Vector3 normalized) {
		return normalized.Y > SLOPE_MAX_ANGLE_COS;
	}

	#endregion


	#region Private Functions

	// Initialization functions

	private void _configureHitboxes() {
		CollisionMask = groundCast.CollisionMask;
		m_rayQuery.CollisionMask = CollisionMask;

		groundCast.MaxResults = MAX_GROUND_COLLISIONS;

		m_bodyColliderShape.Radius = BODY_COLLIDER_RADIUS;
		_floatingCollider();

		PhysicsServer3D.ShapeSetData(m_collisionProbeShape, new Godot.Collections.Dictionary<string, float> {
			{ "height", BODY_COLLIDER_HEIGHT },
			{ "radius", BODY_COLLIDER_RADIUS }
		});
		PhysicsServer3D.BodySetCollisionMask(m_collisionProbeBody, CollisionMask);
		PhysicsServer3D.BodySetSpace(m_collisionProbeBody, GetWorld3D().Space);
		PhysicsServer3D.BodyAddShape(m_collisionProbeBody, m_collisionProbeShape);

		m_motionParameters.From = Transform3D.Identity;
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

		if (!m_groundData.Grounded && !m_footData.Grounded && !lastForwardProbeGrounded) {
			DetachGround();
			return;
		}

		if (m_grounded)
			m_distanceBufferEnabled = true;
		else
			attachGround();
		

		// Movement collision checks

		m_noFlatVelocity = Mathf.IsZeroApprox(Velocity.X * Velocity.X + Velocity.Z * Velocity.Z);

		if (m_noFlatVelocity) { // Stepping collision checks
			_calculateStepWallProbeQuery(GlobalPosition, m_groundData.Point);

			if (!_checkStepDown())
				_checkStepUp();

		} else {
			m_lastNonZeroDir = new Vector3(Velocity.X, 0, Velocity.Z).Normalized();

			// If we are moving, we calculate a point in the direction the player is moving 
			// slightly behind the edge of the player hitbox. This allows us to perform smoothing
			_probePointInDirection(GlobalPosition, m_lastNonZeroDir);
		}
	}


	private void _moveAndSmooth(float delta) {
		const float COLLISION_EPSILON_SQARED = COLLISION_EPSILON * COLLISION_EPSILON;

		if (!m_grounded) { // Flying ignores all below calculations
			MoveAndSlide();

			return;
		}

		// GD.Print(m_stepState);

		// Directly adapted from godot source code
		Vector3 groundVelocity = Vector3.Zero;
		if (m_groundState != null)
			groundVelocity = m_groundState.GetVelocityAtLocalPosition(GlobalTransform.Origin - m_groundState.Transform.Origin);


		if (!m_noFlatVelocity) {
			if (Mathf.Abs(m_groundData.Offset) < COLLISION_EPSILON) {
				Position += Vector3.Down * m_groundData.Offset;
				m_groundData.Offset = 0.0f;
			}

			Vector3 line = GlobalPosition - m_footData.Point;
			line.Y += m_groundData.Offset / VELOCITY_VERTICAL_OVERCORRECTION_FACTOR;

			// If the horizontal OR vertical component of line is too small
			if (Mathf.Abs(line.Y) < COLLISION_EPSILON || (line.X * line.X + line.Z * line.Z) < COLLISION_EPSILON_SQARED)
				Velocity = PPUtil_Math.RotateVectorOntoPlane(Velocity, m_groundData.Normal);
			else // The two cross products produce the final slope vector to rotate velocity by
				Velocity = PPUtil_Math.RotateVectorOntoPlane(Velocity, line.Cross(m_footData.Normal).Cross(line).Normalized());
		} else if (m_stepState != StepState.None) {
			float absOffset = Mathf.Abs(m_groundedData.Offset);

			if (absOffset > STEP_MAX_HEIGHT)
				m_stepState = StepState.None;
			else {
				absOffset = absOffset * STEP_SPEED_FACTOR / delta;

				if (absOffset < MIN_STEP_SPEED) {
					m_stepState = StepState.None;

					Velocity = new Vector3(Velocity.X, 0, Velocity.Z);
					Position += Vector3.Down * m_groundedData.Offset;
				} else {
					Velocity = new Vector3(
						Velocity.X, 
						-Mathf.Sign(m_groundedData.Offset) * absOffset,
						Velocity.Z
					);
				}
			}
		} else if (Mathf.IsZeroApprox(Velocity.Y)) {
			// When not moving and not stepping at all, the player is slowly readjusted to ground level

			float adjustVel = -m_groundData.Offset / delta * STEP_SPEED_FACTOR;

			if (Mathf.Abs(adjustVel) > COLLISION_EPSILON) {
				Velocity = new Vector3(
					groundVelocity.X, 
					groundVelocity.Y + adjustVel,
					groundVelocity.Z
				);
				MoveAndSlide();
				Velocity = Vector3.Zero;

				return;
			} else Position += Vector3.Down * m_groundData.Offset;
		}
		
		Velocity += groundVelocity;

		MoveAndSlide();
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

		for (int i = 0; i < FORWARD_PROBE_COUNT; i++) {
			pos += iterShift;

			Vector3 posOffset = new Vector3(0, STEP_MAX_HEIGHT, 0); // We make our ray slightly lower than the max step height to prevent stepping to high)

			_setRayQuery(pos + posOffset, pos - DOWNWARDS_RAY_LENGTH);
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

	/**
	 * This can return three values depending on the result
	 * 0: The probing was succesful
	 * 1: The probing failed before the wall has been checked
	 * 2: The probing failed during the wall check
	 **/
	private bool _checkStepDown() {
		if (m_stepState == StepState.Down ||
			!m_footData.Grounded ||
			m_footData.Offset < STEP_RAY_VERTICAL_OFFSET)
			return false;

		if (!_validateStepProbeQueryDirection(-m_lastNonZeroDir))
			return false;

		if (_probeStepWall()) { // We don't need to check if the distance is too large for us to step down, as it was already done for _probeData.grounded
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
		
		if (PhysicsServer3D.BodyTestMotion(m_collisionProbeBody, m_motionParameters))
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

	#endregion
}
