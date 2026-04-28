using Godot;
using PhantomCamera;
using PhantomCamera.Manager;
using System;


[GlobalClass] public partial class PlayerCameraManager : Node {
	#region Helper classes

	public class CameraInputData {
       
        public float TargetDirection = 0.0f; // > 0 means targeting left, > 0 means targeting right
    }

	#endregion


	#region Exported variables

	[ExportGroup("Camera config")]
    [Export] public float MIN_PITCH = -80;
    [Export] public float MAX_PITCH = 30;

    [ExportGroup("Controls")]
    [Export] public float INVERT_VERTICAL = -1; // Set to 1 to invert y axis
    [Export] public float CONTROLLER_SENSITIVITY = 0.1f;
    [Export] public float MOUSE_SENSITIVITY = 0.1f;

	#endregion


	#region Scene members

	private PhantomCamera3D m_followCam = null;

	#endregion


	#region Member variables

	public Vector2 Direction = Vector2.Zero;

	private PhantomCamera3D m_activeCam = null;

    private bool m_heldTargetToggle = false;
    private bool m_isTargeting = false; // Only active if the above toggle is true

    private bool m_controllerActive = false;

	#endregion


	#region Built-in functions

	public override void _Ready() {
		m_followCam = GetNode<Node3D>("FollowCam").AsPhantomCamera3D();
	}

	public override void _PhysicsProcess(double delta) {
		Direction = Input.GetVector("Camera left", "Camera right", "Camera down", "Camera up").Normalized();

		if (Direction.LengthSquared() > 0) {
			m_controllerActive = true;

			_rotateCamera(m_followCam, new Vector2(
				Direction.Y * (float)delta * CONTROLLER_SENSITIVITY, 
				Direction.X * (float)delta * CONTROLLER_SENSITIVITY
			));
		} else m_controllerActive = false;
	}


	public override void _UnhandledInput(InputEvent inputEvent) {
		if (inputEvent is InputEventMouseMotion mouse && !m_controllerActive) { // && Input.MouseMode == Input.MouseModeEnum.Captured) {
			Vector2 mouseDelta = mouse.Relative * MOUSE_SENSITIVITY;

			_rotateCamera(m_followCam, new Vector2(-mouseDelta.Y, mouseDelta.X));
		}
	}

	#endregion


	#region Public functions

	public void setFollowTarget(Node3D node) => SetFollowTarget(node);
	public void SetFollowTarget(Node3D node) {
		m_followCam.FollowTarget = node;

		m_activeCam = m_followCam; /// @todo TEMPORARY;
	}


	// func setLockOnTarget(target : CharacterBody3D = null) -> void:
	//	pass

	// func clearLockOnTarget() -> void:
	//	pass


	public Vector2 cameraPlaneDirection() => CameraPlaneDirection();
	public Vector2 CameraPlaneDirection() {
		Vector3 direction = m_activeCam.Node3D.GlobalPosition - ((Vector3)m_activeCam.Node3D.Get("_follow_target_output_position")); /// @todo Private variable of PhantomCamera3D, maybe someday open PR to add a proper getter function
		return new Vector2(direction.X, direction.Z).Normalized();
	}

	#endregion


	#region Private functions

	// Camera functions

	private void _rotateCamera(PhantomCamera3D camera, Vector2 angle) {
		Vector3 cameraRotation = camera.GetThirdPersonRotationDegrees();

		cameraRotation = new Vector3(
			Mathf.Clamp(cameraRotation.X + angle.X * INVERT_VERTICAL, MIN_PITCH, MAX_PITCH),
			Mathf.Wrap(cameraRotation.Y - angle.Y, 0, 360),
			cameraRotation.Z
		);

		camera.SetThirdPersonRotationDegrees(cameraRotation);
	}

	#endregion
}
