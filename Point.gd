extends Area3D



func _on_body_entered(body):
	ScoreKeeper.score += 1
	queue_free()
