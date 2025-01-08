extends CharacterBody2D

# Constants
const SPEED = 700.0
const JUMP_VELOCITY = -2252.0
const GRAVITY = 4000.0
const FAST_GRAVITY = 6000.0
const JUMP_ANIMATION_SPEED = 1.5
const MAX_JUMPS = 2
const HEALTH_MAX = 10

# Variables
var health = GameData.health
var coins = GameData.coins
var dead = false
var direction = 0
var jump_count = 0
var is_attacking = false
var is_fast_jumping = false
var last_save_point: Vector2 = Vector2(-4150, 906)

# Nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var coincount = $"CanvasLayer/CoinContainer/Label"
@onready var health_container = $"CanvasLayer/HealthContainer"
@onready var attack_area = $AttackArea/CollisionShape2D

func _ready() -> void:
	# Initialize game state
	position = GameData.save_point
	health = 5
	coins = 0
	GameData.health = health
	GameData.coins = coins
	health_container.update_items(health)
	coincount.text = str(coins)
	
	attack_area.disabled = true
	animated_sprite.play("idle")

func take_damage(amount: int) -> void:
	health -= amount
	health = max(health, 0)
	health_container.update_items(health)
	GameData.health = health
	print("Player health:", health)
	
	if health == 0:
		die()

func heal(amount: int) -> void:
	if health < HEALTH_MAX:
		health += amount
		health = min(health, HEALTH_MAX)
		health_container.update_items(health)

func count_coin(amount: int) -> void:
	coins += amount
	coincount.text = str(coins)
	GameData.coins = coins
	print("Coins collected:", coins)

func _on_save_point_activated(position: Vector2) -> void:
	last_save_point = position
	print("Save point activated at:", position)

func die() -> void:
	dead = true
	print("Player died. Restarting...")
	health = 5
	position = GameData.save_point
	GameData.health = health
	health_container.update_items(health)
	animated_sprite.play("idle")

func _physics_process(delta: float) -> void:
	velocity.x = 0

	if not is_on_floor():
		velocity.y += (FAST_GRAVITY if is_fast_jumping else GRAVITY) * delta
	else:
		jump_count = 0
		is_fast_jumping = false
		animated_sprite.speed_scale = 1.0

	# Handle attack
	if Input.is_action_just_pressed("attack") and not is_attacking:
		perform_attack()
		return  # Skip movement during attack

	# Handle jump
	if Input.is_action_just_pressed("jump") and jump_count < MAX_JUMPS:
		perform_jump()

	# Get horizontal input
	direction = Input.get_axis("move_left", "move_right")

	# Flip sprite and adjust attack area
	adjust_sprite_orientation()

	# Play animations
	update_animations()

	# Handle horizontal movement
	if not is_attacking and direction != 0:
		velocity.x = direction * SPEED

	move_and_slide()

func perform_jump() -> void:
	is_fast_jumping = true
	velocity.y = JUMP_VELOCITY
	jump_count += 1
	animated_sprite.play("jump")
	animated_sprite.speed_scale = JUMP_ANIMATION_SPEED

func perform_attack() -> void:
	velocity.x = 0
	animated_sprite.stop()
	is_attacking = true
	animated_sprite.play("attack")
	attack_area.disabled = false

func adjust_sprite_orientation() -> void:
	if direction > 0:
		animated_sprite.flip_h = false
		$AttackArea.position.x = abs($AttackArea.position.x)
	elif direction < 0:
		animated_sprite.flip_h = true
		$AttackArea.position.x = -abs($AttackArea.position.x)

func update_animations() -> void:
	if is_attacking:
		if not animated_sprite.is_playing():
			attack_area.disabled = true
			is_attacking = false
	elif is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("walk")
