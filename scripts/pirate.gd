extends Node2D

var dead = false
var player_position = null  # Can hold null or Vector2
var is_attacking = false
var is_running = false
var speed = 500
var heilth=3
var direction = 1
@onready var ray_cast_right= $RayCastRight
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea

func _process(delta: float) -> void:

	if ray_cast_right.is_colliding():
		var collider = ray_cast_right.get_collider()
		if collider and collider.is_class("TileMap"):
			if direction == -1:
				direction = 1
				scale.x=1
			elif direction == 1:
				direction = -1
				scale.x=-1
		elif collider and collider.is_class("CharacterBody2D"):
			is_running = false
			is_attacking = true

	if dead:
		return
	if is_attacking:
		for body in detection_area.get_overlapping_bodies():
			if body.is_in_group("player"):
				player_position=body.global_position
				flip_towards_player()
				animated_sprite_2d.speed_scale=0.7
				animated_sprite_2d.play("attack")

	elif is_running:
		var detection_area=detection_area
		for body in detection_area.get_overlapping_bodies():
			#print(body)
			if body is CharacterBody2D:
				player_position=body.position
				flip_towards_player()
				move_toward_player(delta)
			else:
				is_running=false
	else:

		if(animated_sprite_2d.animation != "attack"):
			position.x+= direction * speed * delta
			animated_sprite_2d.speed_scale=speed/166.67
			animated_sprite_2d.speed_scale=1
			animated_sprite_2d.play("idle")

func flip_towards_player() -> void:
	if player_position.x > global_position.x:
		scale.x = 1  # Face right
	else:
		scale.x = -1  # Face left

func move_toward_player(delta: float) -> void:
	if player_position:
		direction = (player_position.x - global_position.x)
		direction = direction / abs(direction) if direction != 0 else 0  # Normalize
		global_position.x += direction * speed * delta
		animated_sprite_2d.speed_scale=1.5
		animated_sprite_2d.play("run")  # Play walk animation when moving

func knockback(direction: Vector2) -> void:
	var slide_time = 0.2  # Duration of slide effect (in seconds)
	var slide_distance = 50  # Distance to slide back
	var slide_speed = slide_distance / slide_time

	# Determine slide-back position
	var start_position = global_position
	var target_position = global_position + direction.normalized() * slide_distance

	# Tween for smooth movement
	var tween = create_tween()
	#tween.tween_property(self, "global_position", target_position, slide_time, Tween.TransitionType.QUAD, Tween.EaseType.OUT)
	#tween.tween_callback(self, Callable(self, "_on_knockback_end"))

func _on_detection_area_body_entered(body: CharacterBody2D) -> void:
	animated_sprite_2d.stop()
	is_running = true
	is_attacking = false

func _on_detection_area_body_exited(body: CharacterBody2D) -> void:
	is_running = false
	is_attacking = false
	player_position = null  # Clear player position

func _on_attack_area_body_entered(player: CharacterBody2D) -> void:
	pass

func _on_attack_area_body_exited(player) -> void:
	pass

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group('sword'):
		heilth-=1
		if heilth==0:
			dead = true
			animated_sprite_2d.play("die")

func _on_animated_sprite_2d_animation_finished() -> void:
	var detection_area=detection_area
	for body in detection_area.get_overlapping_bodies():
			player_position=body.global_position
	if animated_sprite_2d.animation == 'attack':
		print("attackanimation finished")
		var attack_area=attack_area
		var temp = null
		for body in attack_area.get_overlapping_bodies():
			player_position=body.position
			if body.is_in_group("player"):
				temp = true
				body.take_damage(1)
		if temp != true:
			is_attacking=false
			is_running=true
		print(is_attacking)
	if animated_sprite_2d.animation == 'die':
		queue_free()
