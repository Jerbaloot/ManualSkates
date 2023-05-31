extends CharacterBody3D
class_name Skater

class Skate:
	var default_pos : Vector3
	var skate_object : Node3D
	var angle : float = 0 
	const rotate_angle : float = PI/4
	var raised = false
	var pressed = false
	
	func _init(skate_object : Node3D):
		self.default_pos = skate_object.position
		self.skate_object = skate_object
		self.angle = 0
	
	## Returns the resisted direction
	func move(offset : Vector3) -> Vector3:
		var original_position = skate_object.position
		skate_object.position.x = default_pos.x + offset.x
		skate_object.position.z = default_pos.z + offset.z
		var change = skate_object.position - original_position
		return change
	
	func raise(amount):
		skate_object.position.y += amount
		raised = true
	
	func lower(amount):
		skate_object.position.y -= amount
		raised = false
	
	func rotate(amount):
		self.angle += amount
		skate_object.rotation.y = self.angle
	
	func press():
		pressed = true
	
	func unpress():
		pressed = false


var left_skate : Skate
var right_skate : Skate


enum DIRECTIONS{LEFT_HOR, LEFT_VER, RIGHT_HOR, RIGHT_VER}

var desired_push = {
	DIRECTIONS.LEFT_HOR:0.0,
	DIRECTIONS.LEFT_VER:0.0,
	DIRECTIONS.RIGHT_HOR:0.0,
	DIRECTIONS.RIGHT_VER:0.0,
}

var raise_axis = {}
var press_stick = {}

## Initializes each skate to get starting value from physical objects
func _ready():
	right_skate = Skate.new($RightFoot)
	left_skate = Skate.new($LeftFoot)
	raise_axis = {
			JOY_AXIS_TRIGGER_LEFT : left_skate,
			JOY_AXIS_TRIGGER_RIGHT : right_skate,
		}
	press_stick = {
		JOY_BUTTON_LEFT_STICK : left_skate,
		JOY_BUTTON_RIGHT_STICK : right_skate,
	}

@export var mass : float = 10.0
@export var max_push_force : float = 10.0

func _physics_process(delta):
	
	# Create and clamp desired left position vector
	var desired_left_position = Vector3(desired_push[DIRECTIONS.LEFT_HOR],0,desired_push[DIRECTIONS.LEFT_VER])
	desired_left_position = clamp_magnitude(desired_left_position, 1.0)

	# Create and clamp desired right position vector
	var desired_right_position = Vector3(desired_push[DIRECTIONS.RIGHT_HOR],0,desired_push[DIRECTIONS.RIGHT_VER])
	desired_right_position = clamp_magnitude(desired_right_position, 1.0)



	var left_return_force = left_skate.move(desired_left_position)
	var right_return_force = right_skate.move(desired_right_position)

	velocity += (left_return_force + right_return_force)/mass


func _input(event):
	# Rotating the skates with bumpers
	if event is InputEventJoypadButton:
		var rotate_button = {
			9 : left_skate,
			10 : right_skate
		}
		var rotate_angle = {
			left_skate : PI/4,
			right_skate : -PI/4
		}
		if event.button_index in rotate_button.keys():
			var skate : Skate = rotate_button[event.button_index]
			var angle : float = rotate_angle[skate]
			skate.rotate(angle) if event.pressed else skate.rotate(-angle)
			return

	# Getting desired push direction
	if event is InputEventJoypadMotion:
		

		if (event as InputEventJoypadMotion).axis in desired_push.keys():
			desired_push[event.axis] = event.axis_value
			return

		elif (event as InputEventJoypadMotion).axis in raise_axis.keys():
			var skate : Skate = raise_axis[event.axis]
			skate.lower(.2) if event.axis_value < 0.5 else skate.raise(.2)
			print(event.axis_value)



## Takes a Vector3 and clamp its length so it does not exceed value
func clamp_magnitude(vector : Vector3, value : float):
	return vector if vector.length() < value else vector.normalized() * value 
