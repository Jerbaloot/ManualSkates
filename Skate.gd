extends CharacterBody3D
class_name Skate

var gravity = Vector3.DOWN * 10
var pressed = true
var raised = false
var mass = 1
var default_position : Vector3

func press():
	pressed = true

func unpress():
	pressed = false

func _ready():
	default_position = position

var applied_force = Vector3.ZERO
var previous_applied_force = Vector3.ZERO
func _physics_process(delta):
	velocity += gravity*delta if not raised else Vector3.ZERO
	velocity += applied_force/mass*delta
	previous_applied_force = applied_force
	applied_force = Vector3.ZERO
	
	if is_on_floor():
		var parallel_velocity = global_transform.basis.z*velocity.dot(global_transform.basis.z)
		var perpendicular_velocity = velocity-parallel_velocity
		if pressed:
			velocity = parallel_velocity
		else:
			velocity = parallel_velocity+perpendicular_velocity*(1-delta)
	
	move_and_slide()
	
	

var rotate_action = {
	KEY_LEFT:.5,
	KEY_RIGHT:-.5
}

func raise():
	position.y = default_position.y + .2
	raised = true

func lower():
	position.y = default_position.y
	raised = false

func push_towards(desired_position, strength):
	var displacement : Vector3 = desired_position - (position - default_position)
	var direction : Vector3 = displacement.normalized()
	var force : Vector3 = direction*strength*displacement.length()
	var parallel_force = global_transform.basis.z*force.dot(global_transform.basis.z)
	var perpendicular_force = force - parallel_force
	if pressed:
		applied_force += parallel_force
		return -perpendicular_force
	elif not pressed:
		applied_force += parallel_force + .5*perpendicular_force
		return .5*perpendicular_force



func _process(delta):
	for key in rotate_action:
		if Input.is_key_pressed(key):
			rotate_y(rotate_action[key]*delta)

func get_facing_direction() -> Vector3:
	return global_transform.basis.z
