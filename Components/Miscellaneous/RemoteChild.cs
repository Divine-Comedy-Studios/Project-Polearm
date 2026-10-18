using Godot;


[GlobalClass] public partial class RemoteChild : Node3D {
	private Node3D m_remoteParent = null;

	public override void _PhysicsProcess(double delta) {
		if (m_remoteParent != null)
			GlobalPosition = m_remoteParent.GlobalPosition;
	}

	public void SetRemoteParent(Node3D node) {
		m_remoteParent = node;
	}
	public Node3D GetRemoteParent() {
		return m_remoteParent;
	}

	public void Reset() {
		m_remoteParent = null;
		GlobalPosition = Vector3.Zero;
	}
}
