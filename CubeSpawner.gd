extends Node3D

@export_range(0,100) var amount : int = 10
@export_range(0,100) var spawn_radius : float = 10

@onready var point_scene = preload("res://Point.tscn")

func _ready():
	spawn_a_bunch_of_cubes()


func spawn_a_bunch_of_cubes():
	for i in range(amount):
		print('lol')
		var new_point = point_scene.instantiate()
		print(new_point)
		add_child(new_point)
		new_point.position = Vector3(randf()-.5,0,randf()-.5).normalized()*randf_range(0,spawn_radius)
		new_point.position += Vector3.UP*1.5

func respawn():
	for child in get_children():
		child.queue_free()
	spawn_a_bunch_of_cubes()
