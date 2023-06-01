extends Node3D

@export_range(0,100) var amount : int = 10
@export_range(0,100) var spawn_radius : float = 10

func _ready():
	spawn_a_bunch_of_cubes()


func spawn_a_bunch_of_cubes():
	for i in range(amount):
		var new_cube = MeshInstance3D.new()
		new_cube.mesh = BoxMesh.new()
		(new_cube.mesh as BoxMesh).size = Vector3(0.5,0.5,0.5) 
		add_child(new_cube)
		new_cube.position = Vector3(randf()-.5,0,randf()-.5).normalized()*randf_range(0,spawn_radius)
		new_cube.position += Vector3.UP*.25
