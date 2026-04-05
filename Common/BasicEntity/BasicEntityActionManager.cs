using Godot;
using System;
using System.Collections.Generic;


public partial class BasicEntityActionManager<ActionType, ActionEnum> : Node
	where ActionType : BasicEntityAction<ActionEnum>
	where ActionEnum : Enum
{
	#region Public variables

	public ActionType CurrentAction = null;

	#endregion


	#region Public functions

	public void interrupt(ActionEnum type, bool forced = false) => Interrupt(type, forced);
	public void Interrupt(ActionEnum type, bool forced = false) {
		if (EqualityComparer<ActionEnum>.Default.Equals(type, default)) return;
		if (!CurrentAction.Interrupt(type, forced)) return;

		_ExitCurrentAction();
		_EnterAction(type);
	}

	public ActionType action(ActionEnum type) => action(type);
	public ActionType Action(ActionEnum type) {
		return m_actions[type];
	}

	public void hasHigherPriority(ActionEnum a, ActionEnum b) => HasHigherPriority(a, b);
	public bool HasHigherPriority(ActionEnum a, ActionEnum b) {
		return m_actions[a].HasHigherPriority(m_actions[b]);
	}

	#endregion


	#region Private functions

	private void _ExitCurrentAction() {
		CurrentAction.Exit();
	}

	private void _EnterAction(ActionEnum type) {
		CurrentAction = m_actions[type];
		CurrentAction.Enter();
	}

	#endregion


	#region Private variables

	private Dictionary<ActionEnum, ActionType> m_actions = new();

	#endregion
}
