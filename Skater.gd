extends CharacterBody3D
class_name Skater

class Skate:
	var default_pos : Vector3
	var skate_object : Node3D
	var angle : float = 0 :
		set(value):
			angle = value
			skate_object.rotation.y = value

	const rotate_angle : float = PI/4
	var rotated = false
	var raised = true
	var pressed = false
	var mass = 40
	var tween : Tween
	
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
		var parallel_change = skate_object.transform.basis.z * change.dot(skate_object.transform.basis.z)
		var perpendicular_change = change - parallel_change
		return perpendicular_change
	
	func get_rolling_friction(velocity : Vector3, facing_direction : Vector3):
		if raised: return Vector3.ZERO
		var global_basis = skate_object.global_transform.basis
		var parallel_velocity = skate_object.transform.basis.z * velocity.dot(skate_object.transform.basis.z)
		return -parallel_velocity.normalized()*parallel_velocity.length_squared()*.1
	
	func get_sliding_friction(velocity : Vector3, facing_direction : Vector3):
		if raised: return Vector3.ZERO
		var parallel_velocity = skate_object.transform.basis.z * velocity.dot(skate_object.transform.basis.z)
		var perpendicular_velocity = velocity-parallel_velocity
		return -perpendicular_velocity.normalized()*perpendicular_velocity.length_squared()*50
	
	func raise(amount = .2):
		skate_object.position.y += amount
		raised = true
	
	func lower():
		skate_object.position.y = 0
		raised = false
	
	func press():
		pressed = true
	
	func unpress():
		pressed = false


var left_skate : Skate
var right_skate : Skate
var skates : Array[Skate] = []

var left_skate_angle = 0 :
	set(value):
		if left_skate:
			left_skate.angle = value
			left_skate_angle = value
var right_skate_angle = 0 :
	set(value):
		if right_skate:
			right_skate.angle = value
			right_skate_angle = value


enum DIRECTIONS{LEFT_HOR, LEFT_VER, RIGHT_HOR, RIGHT_VER}

var desired_push = {
	DIRECTIONS.LEFT_HOR:0.0,
	DIRECTIONS.LEFT_VER:0.0,
	DIRECTIONS.RIGHT_HOR:0.0,
	DIRECTIONS.RIGHT_VER:0.0,
}

var raise_axis = {}
var press_stick = {}

var tweens = {}
## Initializes each skate to get starting value from physical objects
func _ready():
	right_skate = Skate.new($RightFoot)
	left_skate = Skate.new($LeftFoot)
	
	tweens = {
		left_skate:get_tree().create_tween(),
		right_skate:get_tree().create_tween()
	}
	
	skates = [left_skate, right_skate]
	raise_axis = {
			JOY_AXIS_TRIGGER_LEFT : left_skate,
			JOY_AXIS_TRIGGER_RIGHT : right_skate,
		}
	press_stick = {
		JOY_BUTTON_LEFT_STICK : left_skate,
		JOY_BUTTON_RIGHT_STICK : right_skate,
	}
	update_moment()


@export var mass : float = 10.0
var moment
@export var max_push_force : float = 10.0
@export var locked_position = false
@export var locked_rotation = false
var skate_velocities = {}
var facing_directions = {}


func move_and_get_offset():
		# Create and clamp desired left position vector
	var desired_left_position = Vector3(desired_push[DIRECTIONS.LEFT_HOR],0,desired_push[DIRECTIONS.LEFT_VER])
	desired_left_position = clamp_magnitude(desired_left_position, 1.0)

	# Create and clamp desired right position vector
	var desired_right_position = Vector3(desired_push[DIRECTIONS.RIGHT_HOR],0,desired_push[DIRECTIONS.RIGHT_VER])
	desired_right_position = clamp_magnitude(desired_right_position, 1.0)


	return {
		left_skate:left_skate.move(desired_left_position),
		right_skate:right_skate.move(desired_right_position)
	}

func update_moment():
	var moment_of_body = 2/5 * mass * 1
	
	var left_skate_moment = (left_skate.skate_object.position*Vector3(1,0,1)).length_squared()*left_skate.mass
	var right_skate_moment = (right_skate.skate_object.position*Vector3(1,0,1)).length_squared()*right_skate.mass
	
	moment = moment_of_body + left_skate_moment + right_skate_moment

func _physics_process(delta):
	if Input.is_key_pressed(KEY_SPACE):
		velocity += Vector3.FORWARD
	
	var offsets = move_and_get_offset()
	for skate in offsets:
		offsets[skate] = (offsets[skate] as Vector3).rotated(Vector3.UP,rotation.y)

	
	var global_velocity = velocity.rotated(Vector3.UP, rotation.y+PI)
	
	facing_directions = {
		right_skate:right_skate.skate_object.transform.basis.z.rotated(Vector3.UP,rotation.y+PI),
		left_skate:left_skate.skate_object.transform.basis.z.rotated(Vector3.UP,rotation.y+PI)
	}
	
	skate_velocities = {
		left_skate:offsets[left_skate]/delta+global_velocity,
		right_skate:offsets[right_skate]/delta+global_velocity,
	}
	
	var friction = {
		right_skate:right_skate.get_rolling_friction(skate_velocities[right_skate], facing_directions[right_skate]) + right_skate.get_sliding_friction(global_velocity+skate_velocities[right_skate], facing_directions[right_skate]),
		left_skate:left_skate.get_rolling_friction(skate_velocities[left_skate], facing_directions[left_skate]) + left_skate.get_sliding_friction(global_velocity+skate_velocities[left_skate], facing_directions[left_skate])
	}

	skate_forces = friction

	if not locked_position: apply_linear_motion(friction, delta)
	if not locked_rotation: apply_angular_motion(friction, delta)

## Angular global_velocity of the skater as a float with the direction being upwards
var angular_velocity = 0

var skate_forces = {}

func apply_angular_motion(friction : Dictionary, delta : float):
	var torque = Vector3.ZERO
	
	for skate in skates:
		var r = skate.skate_object.position
		var skate_torque = r.cross(friction[skate])
		torque -= skate_torque

	var angular_acceleration = torque.dot(Vector3.UP)/moment/10
	
	angular_velocity += angular_acceleration*delta
	rotation.y += angular_acceleration*delta

func apply_linear_motion(friction : Dictionary, delta : float):
	var drag_forces : Vector3 = (friction[right_skate] as Vector3) + (friction[left_skate] as Vector3)
	var acceleration : Vector3 = drag_forces/self.mass
	velocity += acceleration*delta
	move_and_slide()


## Receives controller input to control each skate
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
			skate.angle = angle if event.pressed else 0

			print("playing")

		var press_button = {
				JOY_BUTTON_LEFT_STICK : left_skate,
				JOY_BUTTON_RIGHT_STICK : right_skate
			}
			
		if event.button_index in press_button.keys():
			var skate : Skate = press_button[event.button_index]
			skate.lower() if event.pressed else skate.raise()
			return

	# Getting desired push direction
	if event is InputEventJoypadMotion:
		if (event as InputEventJoypadMotion).axis in desired_push.keys():
			desired_push[event.axis] = event.axis_value
			return


## Takes a Vector3 and clamp its length so it does not exceed value
func clamp_magnitude(vector : Vector3, value : float):
	return vector if vector.length() < value else vector.normalized() * value 
