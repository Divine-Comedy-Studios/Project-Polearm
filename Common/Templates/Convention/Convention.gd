extends Node
# For nodes with extreme custom functionality, assign them a class name and add the class 
# to the scene tree instead of attaching a script. This also supports type safety
class_name Convention


##### Spaces, comments and regions
# 1. Region order may not be changed and MUST follow below order
# 2. Regions must use below names with little exceptions
# 3. Always leave two spaces between the top of the file and the first reagion
# 3.1. Always leave two sapces between two regions
# 3.2. Always leave one space between the top and bottom of a region and its code
# 4. Files <20 lines do not need regions
# 5. Never add comments describing regions
# 6. There should be no place in the file with more than two spaces
# 7. When a comment comments an entire, unspaced block of code, don't leave a space to the code and one space above
# 7.1. When a comment comments a spaced block of code, leave one space to the code and two spaces above


##### Code style
# 1. Type everything as precicely as possible, avoid ambiguous types
# 2. Always default initialize variables
# 3. When naming variables, try to to it in the order of category + postfix


#region Enums

# Only class names, inner class names and enum names should be in PascalCase

enum Enum {
	enumsShouldBeInCamelCase,
	enumsAreAlwaysMultiline,
	alwaysAddACommaAfterTheLastElement,
}

#endregion


#region Helper classes

class FakeEnum:
	const rule1 := &"Follow the enum rules"
	const rule2 := &"All tags should have the same types"
	const rule3 := &"Tags must be constant, therefore their types must be simple, comparable built-in types"


class DataStructure:
	# For class members, define their type explicitly for readability
	var foo : float = 0.0
	var bar : Vector2 = Vector2.ZERO

	# Avoid putting complex functionality into inner classes. Simple functions like reset/clear are fine
	func clear() -> void:
		pass

#endregion


#region Signals

signal signalsInCamelCase(val : float)

#endregion


#region Constants

const CONSTANTS_IN_SCREAMING_SNAKE_CASE : float = 0.0

#endregion


#region Exported variables

@export_group("When you have > 3 export variables which are responsible for different behavior, add export groups")
@export var collisionSetting : float = 0.0
@export var hitboxSetting : bool = false

@export_group("Always use @export_group instead of @export_category")
@export var animationConfig : Resource = null

#endregion


#region Scene members



#endregion


#region Member variables

var _member

#endregion


#region Built-in funcitons



#endregion


#region Override functions



#endregion


#region Public funcitons



#endregion


#region Private functions



#endregion


#region Pick the one that fits the most: Implementation functions; Virtual functions; Implementation and virtual functions



#endregion


#region Signal functions



#endregion
