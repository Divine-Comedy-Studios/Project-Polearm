extends Node
class_name PlayerInputManager


# Input data container
class Data extends RefCounted:
	var cameraDirection : Vector2

	var inputDirection : Vector2
	var inputMagnitude : float

	var direction : Vector2

	var actions : Array[StringName]
	var modifiers : Array[StringName]
	
	func reset() -> void:
		inputDirection = Vector2.ZERO
		inputMagnitude = 0.0
		direction = Vector2.ZERO

		actions.clear()
		modifiers.clear()


#region Exported variables

@export_group("Config")


#endregion


#region Scene members

@export_group("Scene members")
@export var cameraManager : PlayerCameraManager

#endregion


#region Member variables

var inputs : Data = Data.new()

#endregion


#region Built-in functions

func _ready() -> void:
	assert(cameraManager != null, "PlayerInputManager._ready(): Camera manager was not assigned!")


func _physics_process(_delta : float) -> void:
	inputs.reset()

	# Add default options
	inputs.actions.append(PlayerAction.Type.idle)

	# Input processing
	_processMovementDirection()
	_processMovementActions()

#endregion


#region Private functions

func _processMovementDirection() -> void:
	inputs.cameraDirection = cameraManager.cameraPlaneDirection()
	inputs.inputDirection = Input.get_vector("Move left", "Move right", "Move forwards", "Move backwards")

	if inputs.inputDirection == Vector2.ZERO:
		return

	inputs.actions.append(PlayerAction.Type.move)

	inputs.inputMagnitude = inputs.inputDirection.length()
	inputs.inputDirection /= inputs.inputMagnitude


	# The code below is a transformation of the input direction by the angle the camera is currently pointing in
	#
	# First, to rotate the vector, we need the right instead of the forward vector of the camera. Hence, we rotate
	# the camera by -90 degrees. This is given by the transformation [0 1, -1 0] * [x_c y_c] = [y_c -x_c]
	#
	# As the camera direction has already been normalized, the final rotation matrix is given by [-y_c -x_c, x_c -y_c]
	# The transformation [y_c x_c, -x_c y_c] * [x y] = [(y_c * x + x_c * y) (-x_c * x + y_c * y)]
	# This can be rearranged as y_c * [x y] + x_c * [y -x]

	inputs.direction = Vector2( \
		inputs.inputDirection * inputs.cameraDirection.y \
		 + Vector2(inputs.inputDirection.y, -inputs.inputDirection.x) * inputs.cameraDirection.x \
	).normalized()

func _processMovementActions():
	if Input.is_action_just_pressed("Jump"):
		inputs.actions.append(PlayerAction.Type.jumpStart)
	if Input.is_action_pressed("Jump"):
		inputs.modifiers.append(PlayerAction.Type.jump)

	if Input.is_action_just_pressed("Dash"):
		inputs.actions.append(PlayerAction.Type.dashStart)
	if Input.is_action_pressed("Dash"):
		inputs.modifiers.append(PlayerAction.Type.sprint)

	if Input.is_action_just_pressed("Light attack"):
		inputs.actions.append(PlayerAction.Type.lightAttack)
	if Input.is_action_just_pressed("Heavy attack"):
		inputs.actions.append(PlayerAction.Type.heavyAttack)

#endregion
