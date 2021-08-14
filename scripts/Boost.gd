extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		if transform.y.dot(body.transform.y) > 0:
			body.boost()
