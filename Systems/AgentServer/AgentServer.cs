using Godot;
using System;


[GlobalClass] public partial class AgentServer : Node {
	public enum AgentType {
		dummy,
		basic,
		fighter,
		flanker,
		circler,
		ranged,
		boss,
	}
}
