using Godot;
using System.Diagnostics;
using System.Linq;


public partial class FloatingBody : CharacterBody3D {
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

		STEP_MAX_HEIGHT_VEC = new Vector3(0, STEP_MAX_HEIGHT, 0);

		m_bodyColliderShape = (CapsuleShape3D)bodyCollider.Shape;
		m_groundCastShape = (SphereShape3D)groundCast.Shape;

		m_groundedData = m_groundData; // Reference to the current ground data which is grounded

		// Init hitboxes
		_configureHitboxes();
	}

	public void tick(float delta) => Tick(delta);
	public void Tick(float delta) {
		_processCollisions();
		_calculateVelocity(delta);
		MoveAndSlide();
	}


	// Movement functions

	// Velocity based movement

	public void move(Vector3 velocity) => Move(velocity);
	public void Move(Vector3 velocity) {
		m_targetVelocity += velocity;
	}

	public void moveFlat3(Vector3 velocity) => MoveFlat(new Vector2(velocity.X, velocity.Z));
	public void MoveFlat3(Vector3 velocity) => MoveFlat(new Vector2(velocity.X, velocity.Z));
	public void moveFlat(Vector2 velocity) => MoveFlat(velocity);
	public void MoveFlat(Vector2 velocity) {
		m_targetVelocity.X += velocity.X;
		m_targetVelocity.Z += velocity.Y;
	}

	public void moveVertical(float velocity) => MoveVertical(velocity);
	public void MoveVertical(float velocity) {
		m_targetVelocity.Y += velocity;
	}


	public void setMovement(Vector3 velocity) => SetMovement(velocity);
	public void SetMovement(Vector3 velocity) {
		m_targetVelocity = velocity;
	}

	public void setMovementFlat3(Vector3 velocity) => SetMovementFlat(new Vector2(velocity.X, velocity.Z));
	public void SetMovementFlat3(Vector3 velocity) => SetMovementFlat(new Vector2(velocity.X, velocity.Z));
	public void setMovementFlat(Vector2 velocity) => SetMovementFlat(velocity);
	public void SetMovementFlat(Vector2 velocity) {
		m_targetVelocity.X = velocity.X;
		m_targetVelocity.Z = velocity.Y;
	}
	public void setMovementVertical(float velocity) => SetMovementVertical(velocity);
	public void SetMovementVertical(float velocity) {
		m_targetVelocity.Y = velocity;
	}


	// Acceleration based movement

	public void accelerate(Vector3 target, float accelerationDt) => Accelerate(target, accelerationDt);
	public void Accelerate(Vector3 target, float accelerationDt) {
		m_targetVelocity = m_targetVelocity.MoveToward(target, accelerationDt);
	}

	public void accelerateFlat3(Vector3 target, float accelerationDt) => AccelerateFlat(new Vector2(target.X, target.Z), accelerationDt);
	public void AccelerateFlat3(Vector3 target, float accelerationDt) => AccelerateFlat(new Vector2(target.X, target.Z), accelerationDt);
	public void accelerateFlat(Vector2 target, float accelerationDt) => AccelerateFlat(target, accelerationDt);
	public void AccelerateFlat(Vector2 target, float accelerationDt) {
		m_targetVelocity.X = Mathf.MoveToward(m_targetVelocity.X, target.X, accelerationDt);
		m_targetVelocity.Z = Mathf.MoveToward(m_targetVelocity.Z, target.Y, accelerationDt);
	}

	public void accelerateVertical(float target, float accelerationDt) => AccelerateVertical(target, accelerationDt);
	public void AccelerateVertical(float target, float accelerationDt) {
		m_targetVelocity.Y = Mathf.MoveToward(m_targetVelocity.Y, target, accelerationDt);
	}


	// Get velocity

	public Vector3 movement() => Movement();
	public Vector3 Movement() {
		return m_targetVelocity;
	}

	// Get last valid velocity
	public Vector3 lastMovement() => LastMovement();
	public Vector3 LastMovement() {
		return m_lastNonZeroDir;
	}


	public Vector2 flatVelocity() => FlatVelocity();
	public Vector2 FlatVelocity() {
		return new Vector2(Velocity.X, Velocity.Z);
	}
	public Vector3 flatVelocity3() => FlatVelocity3();
	public Vector3 FlatVelocity3() {
		return new Vector3(Velocity.X, 0.0f, Velocity.Z);
	}


	// Ground functions

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

		m_groundData.Clear();
		m_footData.Clear();

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

	public bool slopeWalkable(Vector3 normalized) => SlopeWalkable(normalized);
	public bool SlopeWalkable(Vector3 normalized) {
		return normalized.Y > SLOPE_MAX_ANGLE_COS;
	}


	// Transformation getters

	public Vector3 forward() => Forward();
	public Vector3 Forward() {
		return -Transform.Basis.Column2;
	}


	// Called on default if not defined otherwise

	public override void _Ready() {
		Init();
	}

	public override void _PhysicsProcess(double delta) {
		Tick((float)delta);
	}
}
