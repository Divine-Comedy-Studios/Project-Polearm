/**
 * The architectual decisions and structure are heavily guided by:
 *
 * https://github.com/Gab-ani/Godot_Universal-Controller-tutorial/
 *
 * and it's accompanying YouTube tutorial series. Implementation details are customized. 
 * Other state machines in the project are also inspired on this specific implementation
 **/

using Godot;


[GlobalClass] public partial class Player : FloatingBody {
	#region Scene Members

	private PlayerCameraManager m_cameraManager = null;

	#endregion


	#region Member variables

	// @onready var profile := PlayerProfile.new()

	#endregion


	#region Built-in functions

	public override void _Ready() {
		Init();

		m_cameraManager = GetNode<PlayerCameraManager>("CameraManager");
		m_cameraManager.SetFollowTarget(this);
	}

	#endregion
}
