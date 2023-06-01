extends Node3D

func _process(delta):
	var vel_raycast : RayCast3D = $RayCast3D
	var skater : Skater = $Skater
	
	vel_raycast.position = skater.position
	vel_raycast.target_position = skater.velocity

	var raycasts = {
		skater.left_skate:$LeftRayCast3D,
		skater.right_skate:$RightRayCast3D
	}
	
	var facing_raycasts = {
		skater.left_skate:$LeftRayCast3D2,
		skater.right_skate:$RightRayCast3D2
	}

	for skate in skater.skate_forces:
		var force : Vector3 = skater.skate_forces[skate]
		var raycast = raycasts[skate]
		raycast.position = (skate as Skater.Skate).skate_object.global_position
		raycast.target_position = force*delta
	
	for skate in skater.facing_directions:
		var facing_direction : Vector3 = skater.facing_directions[skate]
		var raycast = facing_raycasts[skate]
		raycast.position = (skate as Skater.Skate).skate_object.global_position
		raycast.target_position = facing_direction*10


func _on_reset_pressed():
	$CubeSpawner.respawn()
	ScoreKeeper.score = 0
	$Skater.position = Vector3.ZERO
	$Skater.velocity = Vector3.ZERO
