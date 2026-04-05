using Godot;
using System;
using System.Diagnostics.Tracing;


public partial class BasicEntityAction<ActionType> : Node
	where ActionType : Enum
{
	#region Exported variables

	[Export] public int PRIORITY = 0;

	#endregion


	#region Public functions

	public void Enter() { }
	public void Exit() { }

	public bool interrupt(ActionType type, bool forced) => Interrupt(type, forced);
	public bool Interrupt(ActionType type, bool forced) { return false; }

	public bool hasHigherPriority(BasicEntityAction<ActionType> other) => HasHigherPriority(other);
	public bool HasHigherPriority(BasicEntityAction<ActionType> other) {
		return HasHigherPriority(this, other);	
	}

	public static bool hasHigherPriority(BasicEntityAction<ActionType> first, BasicEntityAction<ActionType> second) => HasHigherPriority(first, second);
	public static bool HasHigherPriority(BasicEntityAction<ActionType> first, BasicEntityAction<ActionType> second) {
		return first.PRIORITY > second.PRIORITY;
	}

	#endregion
}
