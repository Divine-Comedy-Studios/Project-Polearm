extends Resource
class_name IntegerResource


#region Signals

signal valueChanged(newVal : float)
signal maxValueChanged(newMax : float)

#endregion


#region Member variables

@export var locked = false

@export var maxValue : int = 100:
	set(newMax):
		maxValue = newMax
		maxValueChanged.emit(newMax)

@export var value : int = 0:
	get:
		return value
	set(newVal):
		if not locked:
			value = clampi(newVal, 0, maxValue)
			valueChanged.emit(newVal)

#endregion
