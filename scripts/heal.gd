extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.


func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("player"):
		collision_shape_2d.disabled=true
		animated_sprite_2d.visible=false
		audio_stream_player_2d.play()
		body.heal(1)
		#queue_free()


func _on_audio_stream_player_2d_finished() -> void:
	queue_free()
