extends Resource
class_name ValueResource


#region Signals

signal valueChanged(newVal : float)
signal maxValueChanged(newMax : float)

#endregion


#region Member variables

@export var locked = false

@export var maxValue : float = 100.0:
	set(newMax):
		maxValue = newMax
		maxValueChanged.emit(newMax)

@export var value : float = 0.0:
	get:
		return value
	set(newVal):
		if not locked:
			value = clampf(newVal, 0.0, maxValue)
			valueChanged.emit(newVal)

#endregion
