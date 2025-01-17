extends Area2D



var breaked=false
func _on_area_entered(body: Node2D) -> void:
	if not breaked:
		if body.is_in_group("sword"):
			$AnimatedSprite2D.play("breaking ")
			breaked=true
