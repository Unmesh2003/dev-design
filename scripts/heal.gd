extends Area2D


# Called when the node enters the scene tree for the first time.


func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		body.heal(1)
		queue_free()
