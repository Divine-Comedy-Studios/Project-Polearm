using Godot;
using PhantomCamera;
using PhantomCamera.Manager;
using System;
using System.Data.Common;


[GlobalClass] public partial class PlayerCameraManager : Node {
	#region Helper classes

	public class CameraInputData {
		public float TargetDirection = 0.0f; // > 0 means targeting left, > 0 means targeting right
	}

	#endregion


	#region Exported variables

	[ExportGroup("Camera config")]
	[Export(PropertyHint.Range, "-360,360,0.1,radians_as_degrees")]
	public float MIN_PITCH = -0.9f;
	[Export(PropertyHint.Range, "-360,360,0.1,radians_as_degrees")]
	public float MAX_PITCH = 0.6f;
	[Export] public float ROTATION_LERP = 0.2f;

	[ExportGroup("Controls")]
	[Export] public float STICK_RELATIVE_DEADZONE = 0.3f;
	[Export] public float INVERT_VERTICAL = -1.0f; // Set to 1 to invert y axis
	[Export] public float CONTROLLER_SENSITIVITY = 0.1f;
	[Export] public float MOUSE_SENSITIVITY = 0.01f;

	[ExportGroup("AutoCam config")]
	[Export] public float TIME_UNTIL_AUTO_CAM = 3.0f;
	[Export] public float AUTO_CAM_SENSITIVITY = 0.1f;
	[Export] public float AUTO_CAM_VERTICAL_ANGLE = -0.1f;
	[Export] public float AUTO_CAM_SPEED = 2.0f;

	#endregion


	#region Scene members

	// Targets

	private RemoteChild m_followTarget = null;


	// Camera

	private PhantomCamera3D m_camera = null;

	#endregion


	#region Member variables

	// Input state

	public Vector2 Direction = Vector2.Zero;

	private bool m_heldTargetToggle = false;
	private bool m_isTargeting = false; // Only active if the above toggle is true

	private bool m_controllerActive = false;

	private float m_timeUntilAutoCam = 0.0f;

	#endregion


	#region Built-in functions

	public override void _Ready() {
		m_camera = GetNode<Node3D>("Camera").AsPhantomCamera3D();
		m_followTarget = GetNode<RemoteChild>("FollowTarget");
	}

	public override void _PhysicsProcess(double delta) {
		Direction = _processControllerInput(Input.GetVector("Camera left", "Camera right", "Camera down", "Camera up"));

		// Manual camera rotation

		if (Direction.LengthSquared() > 0.0) {
			m_timeUntilAutoCam = TIME_UNTIL_AUTO_CAM;

			m_controllerActive = true;

			_rotateTarget(m_camera.FollowTarget, new Vector2(
				Direction.Y * (float)delta * CONTROLLER_SENSITIVITY * INVERT_VERTICAL, 
				Direction.X * (float)delta * CONTROLLER_SENSITIVITY
			));
		} else m_controllerActive = false;


		// Automatic camera rotation

		if (m_timeUntilAutoCam <= 0.0f) {
			Vector3 target = new Vector3(AUTO_CAM_VERTICAL_ANGLE, m_followTarget.GetRemoteParent().Rotation.Y, 0.0f);
			float angleDiff = Mathf.Abs(Mathf.AngleDifference(m_camera.FollowTarget.Rotation.Y, target.Y));

			if (angleDiff > AUTO_CAM_SENSITIVITY) {
				float speed = AUTO_CAM_SPEED * (float) delta;

				m_camera.FollowTarget.Rotation = new Vector3(
					Mathf.RotateToward(m_camera.FollowTarget.Rotation.X, AUTO_CAM_VERTICAL_ANGLE, speed),
					Mathf.RotateToward(m_camera.FollowTarget.Rotation.Y, target.Y, speed * Mathf.Sqrt(angleDiff / Mathf.Pi)), // The further away, the faster the speed
					m_camera.FollowTarget.Rotation.Z
				);
			}
		} else
			m_timeUntilAutoCam -= (float) delta;

		_cameraRotationLerpToTarget();
	}


	public override void _Input(InputEvent inputEvent) {
		if (!m_controllerActive && Input.MouseMode == Input.MouseModeEnum.Captured) {
			if (inputEvent is InputEventMouseMotion mouse) {
				m_timeUntilAutoCam = TIME_UNTIL_AUTO_CAM;

				Vector2 mouseDelta = mouse.Relative * MOUSE_SENSITIVITY;

				_rotateTarget(m_camera.FollowTarget, new Vector2(-mouseDelta.Y * INVERT_VERTICAL, mouseDelta.X));
			}
		}
	}

	#endregion


	#region Public functions

	public void setFollowTarget(Node3D node) => SetFollowTarget(node);
	public void SetFollowTarget(Node3D node) {
		m_followTarget.SetRemoteParent(node);
	}


	// func setLockOnTarget(target : CharacterBody3D = null) -> void:
	//	pass

	// func clearLockOnTarget() -> void:
	//	pass


	public Vector2 cameraPlaneDirection() => CameraPlaneDirection();
	public Vector2 CameraPlaneDirection() {
		Vector3 direction = m_camera.FollowTarget.GlobalTransform.Basis.Z;
		return new Vector2(direction.X, direction.Z).Normalized();
	}

	#endregion


	#region Private functions

	// Manual input deadzone & directional snapping

	public Vector2 _processControllerInput(Vector2 inputVec) {
		if (Mathf.Abs(inputVec.Y / inputVec.X) < STICK_RELATIVE_DEADZONE)
			inputVec.Y = 0.0f;
		else if (Mathf.Abs(inputVec.X / inputVec.Y) < STICK_RELATIVE_DEADZONE)
			inputVec.X = 0.0f;

		inputVec.X *= Mathf.Abs(inputVec.X);
		inputVec.Y *= MathF.Abs(inputVec.Y);

		return inputVec.Normalized();
	}


	// Camera functions

	private void _rotateTarget(Node3D target, Vector2 angularVelocity) {
		Vector3 rotation = target.Rotation;

		rotation = new Vector3(
			Mathf.Clamp(rotation.X + angularVelocity.X, MIN_PITCH, MAX_PITCH),
			Mathf.Wrap(rotation.Y - angularVelocity.Y, -2.0f * Mathf.Pi, 2.0f * Mathf.Pi),
			rotation.Z
		);

		target.Rotation = rotation;
	}

	private void _cameraRotationLerpToTarget() {
		m_camera.SetThirdPersonQuaternion(
			m_camera.GetThirdPersonQuaternion().Slerp(m_camera.FollowTarget.Quaternion, ROTATION_LERP)
		);
	}

	#endregion
}
