/**
 * This implementation was inspired by following sources:
 *
 * https://github.com/NoiRC256/SRMove
 * https://www.reddit.com/r/godot/comments/1nznsej/my_approach_to_stairs_dubbed_the_balloon/
 * https://www.youtube.com/watch?v=CdPYlj5uZeI
 *
 * A big thanks to the creators of these sources for their contributions,
 * as I would not have been able to come up with the solution myself!
 */

using Godot;


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
	private const float VELOCITY_VERTICAL_OVERCORRECTION_FACTOR = 2.0f;


	// Raycast settings

	private const int STEP_RAY_SCALE_FACTOR = 4;
	private static readonly Vector3 DOWNWARDS_RAY_LENGTH = new Vector3(0.0f, 10.0f, 0.0f);


	// Hitbox configuration settings

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
	[Export] public float STEP_SPEED_FACTOR = 0.3f;

	#endregion


	#region Scene members

	[ExportGroup("Scene members")]
	[Export] public CollisionShape3D bodyCollider = null;
	[Export] public ShapeCast3D groundCast = null;

	#endregion


	#region Member variables

	// References

	private float CHARACTER_HEIGHT_BUFFERED = 0.0f;
	private float CHARACTER_POSITION_BUFFERED = 0.0f;

	private float BODY_COLLIDER_HEIGHT = 0.0f;
	private float BODY_COLLIDER_POSITION = 0.0f;

	private float SLOPE_MAX_ANGLE_COS = 0.0f;

	private Vector3 STEP_MAX_HEIGHT_VEC = Vector3.Zero;

	private CapsuleShape3D m_bodyColliderShape = null;
	private SphereShape3D m_groundCastShape = null;


	// State

	private Vector3 m_targetVelocity = Vector3.Zero;

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
}
