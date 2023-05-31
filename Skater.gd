extends CharacterBody3D
class_name Skater



var left_skate : Skate
var right_skate : Skate


enum DIRECTIONS{LEFT_HOR, LEFT_VER, RIGHT_HOR, RIGHT_VER}

# Desired push with joypad axis directions as keys
var desired_push = {
	DIRECTIONS.LEFT_HOR:0.0,
	DIRECTIONS.LEFT_VER:0.0,
	DIRECTIONS.RIGHT_HOR:0.0,
	DIRECTIONS.RIGHT_VER:0.0,
}

## Button map for raising axis of each skate, initialized in _ready()
var raise_axis = {}
## Button map for pushing down axis of each skate, initialized in _ready()
var press_stick = {}
## Button map for rotating axis of each skate, initialized in _ready()
var rotate_button = {}
## Angle for rotation of each skate, initialized in _ready()
var rotate_angle = {}
## Default position for each skate
var default_position


## Initializes each skate to get starting value from physical objects
func _ready():
	right_skate = $"../RightSkate"
	left_skate = $"../LeftSkate"
	raise_axis = {
			JOY_AXIS_TRIGGER_LEFT : left_skate,
			JOY_AXIS_TRIGGER_RIGHT : right_skate,
		}
	press_stick = {
		JOY_BUTTON_LEFT_STICK : left_skate,
		JOY_BUTTON_RIGHT_STICK : right_skate,
	}
	rotate_button = {
		JOY_BUTTON_LEFT_SHOULDER : left_skate,
		JOY_BUTTON_RIGHT_SHOULDER : right_skate,
	}
	rotate_angle = {
		left_skate : PI/4,
		right_skate : -PI/4
	}
	default_position = {
		left_skate : left_skate.position,
		right_skate : right_skate.position
	}
	

@export var mass : float = 10.0
@export var max_push_force : float = 10.0
@export_range(0,100) var push_strength : float = 10.0
func _physics_process(delta):
	
	# Create and clamp desired left position vector
	var desired_left_position = Vector3(desired_push[DIRECTIONS.LEFT_HOR],0,desired_push[DIRECTIONS.LEFT_VER])
	desired_left_position = clamp_magnitude(desired_left_position, 1.0)

	# Create and clamp desired right position vector
	var desired_right_position = Vector3(desired_push[DIRECTIONS.RIGHT_HOR],0,desired_push[DIRECTIONS.RIGHT_VER])
	desired_right_position = clamp_magnitude(desired_right_position, 1.0)
#
#	left_skate.position.x = desired_left_position.x + left_skate.starting_position.x
#	left_skate.position.z = desired_left_position.z + left_skate.starting_position.z
#	right_skate.position.x = desired_right_position.x + right_skate.starting_position.x
#	right_skate.position.z = desired_right_position.z + right_skate.starting_position.z


	var left_skate_force = left_skate.push_towards(desired_left_position, push_strength)
	var right_skate_force = right_skate.push_towards(desired_right_position, push_strength)

	var total_force = left_skate_force + right_skate_force + Vector3.DOWN*10
	var acceleration = total_force/mass
	
	velocity += acceleration*delta
	move_and_slide()

	for skate in [left_skate, right_skate]:
		skate.default_position = default_position[skate]
	clamp_skate_positions()

## Prevent skates from leaving range
func clamp_skate_positions():
	for object in [left_skate, right_skate]:
		var skate : Skate = object as Skate
		var skate_offset = skate.position - (default_position[skate]+self.position)
		skate.position = clamp_magnitude(skate_offset,1.) + default_position[skate]


func _input(event):
	# Rotating the skates with bumpers
	if event is InputEventJoypadButton:
		if event.button_index in rotate_button.keys():
			var skate : Skate = rotate_button[event.button_index]
			var angle : float = rotate_angle[skate]
			return
		
		if event.button_index in press_stick.keys():
			var skate : Skate = press_stick[event.button_index]
			skate.press() if event.pressed else skate.unpress()
		

	# Getting desired push direction
	if event is InputEventJoypadMotion:
		

		if (event as InputEventJoypadMotion).axis in desired_push.keys():
			desired_push[event.axis] = event.axis_value
			return

		elif (event as InputEventJoypadMotion).axis in raise_axis.keys():
			var skate : Skate = raise_axis[event.axis]
			skate.lower() if event.axis_value < 0.5 else skate.raise()



## Takes a Vector3 and clamp its length so it does not exceed value
func clamp_magnitude(vector : Vector3, value : float):
	return vector if vector.length() < value else vector.normalized() * value 
