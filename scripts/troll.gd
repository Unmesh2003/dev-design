extends Node2D

var dead = false
var player_position = null
var is_attacking = false
var is_running = false
var speed = 500
var health = 1
var direction = 1

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var attack_area: Area2D = $AttackArea
@onready var detection_area: Area2D = $DetectionArea

func _process(delta: float) -> void:
	if dead:
		return
	
	if ray_cast_right.is_colliding():
		var collider = ray_cast_right.get_collider()
		if collider and collider.is_class("TileMap"):
			direction *= -1
			scale.x *= -1
		elif collider and collider.is_class("CharacterBody2D"):
			is_running = false
			is_attacking = true
	
	# Movement logic
	if not is_attacking:
		global_position.x += direction * speed * delta
		if is_running:
			if animated_sprite_2d.animation != "run":
				animated_sprite_2d.play("run")
		else:
			if animated_sprite_2d.animation != "walk":
				animated_sprite_2d.play("walk")
	else:
		if animated_sprite_2d.animation != "attack":
			animated_sprite_2d.play("attack")

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		speed = 1000
		is_running = true
		player_position = body.global_position
		direction = 1 if player_position.x > global_position.x else -1
		scale.x = direction

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		speed = 500
		is_running = false

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_attacking = true
		is_running = false

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "attack":
		for body in attack_area.get_overlapping_bodies():
			if body.is_in_group("player"):
				body.take_damage(1)
		is_attacking = false
		is_running = true

	if animated_sprite_2d.animation == "die":
		queue_free()

func _on_body_area_entered(area: Area2D) -> void:
	if area.is_in_group("sword"):
		health -= 1
		if health == 0:
			dead = true
			is_attacking = false
			is_running = false
			animated_sprite_2d.play("die")
