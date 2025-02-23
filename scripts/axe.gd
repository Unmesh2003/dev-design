extends Node2D



@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		audio_stream_player_2d.play()
		body.take_damage(2)
