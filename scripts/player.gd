extends CharacterBody2D

const SPEED = 700.0
const JUMP_VELOCITY = -2252.0  # Very high jump velocity for a fast, short jump
const GRAVITY = 4000.0  # Strong gravity to pull the player down fast
const FAST_GRAVITY = 6000.0  # Even stronger gravity for quick landing
const JUMP_ANIMATION_SPEED = 0.2  # Speed multiplier for faster, snappy jump animation
const AIR_CONTROL = 0.0  # No horizontal control in the air for a quick, straight jump
var health=GameData.health
const MAX_JUMPS = 2
var health_max=10
var dead=false
var coins=GameData.coins
var direction =null
@onready var animated_sprite = $AnimatedSprite2D
var is_attacking = false  # Flag to track whether the player is attacking
var is_fast_jumping = false  # Flag to check if the player is performing a fast jump
var jump_count = 0
@onready var coincount = $"CanvasLayer/CoinContainer/Label"
var last_save_point: Vector2 = Vector2(-4150, 906)

func _ready() -> void:
	position=GameData.save_point
	GameData.coins=0
	GameData.health=5
	$"CanvasLayer/HealthContainer".update_items(health)
	coincount.text=str(coins)

	$AttackArea/CollisionShape2D.disabled = true # Ensure the attack collision is not active at the start
	animated_sprite.play("idle")
func take_damage(amount: int) -> void:
	health-=amount
	if health<0:
		health=0
	print("Player health:", health)
	var heart=$HealthContainer
	$"CanvasLayer/HealthContainer".update_items(health)
	GameData.health=health
	velocity.x= direction * SPEED
	if health==0:
		dead=true
		print("restarting")
		print('YOU LOOSE')
		GameData.health=5
		position=GameData.save_point
		health=5
		$"CanvasLayer/HealthContainer".update_items(health)
		
func _on_save_point_activated(position: Vector2):
	last_save_point = position
	print("Save point activated at: ", position)
func heal(amount: int):
	if health < health_max:
		health+=amount
		$"CanvasLayer/HealthContainer".update_items(health)
	
		
func count_coin(inc: int):
	coins=coins+1
	coincount.text=str(coins)
	GameData.coins=coins
	print(GameData.coins)

func _physics_process(delta: float) -> void:
	velocity.x=0
	if not is_on_floor():
		if is_fast_jumping:
			# Apply fast gravity when in fast jump state (rapid falling)
			velocity.y += FAST_GRAVITY * delta
		else:
			# Normal gravity
			velocity.y += GRAVITY * delta
			
	# Reset jump count when the player is on the floor
	if is_on_floor():
		jump_count = 0
		is_fast_jumping = false
		animated_sprite.speed_scale = 1.0  # Reset animation speed to normal

	# Handle attack input
	if Input.is_action_just_pressed("attack") and not is_attacking:
		velocity.x = 0
		print("attack just pressed")
		animated_sprite.stop()
		is_attacking = true
		animated_sprite.play("attack")  # Play attack animation
		print(animated_sprite.animation)
		$AttackArea/CollisionShape2D.disabled = false
		return  # Skip the movement logic during attack

	# Check if the attack animation has finished
	if is_attacking and not animated_sprite.is_playing():
		$AttackArea/CollisionShape2D.disabled = true
		is_attacking = false  # Reset attack flag after animation finishes

	# Handle jump input
	if Input.is_action_just_pressed("jump") and jump_count < MAX_JUMPS:
		# Initiate fast jump and animation
		is_fast_jumping = true
		velocity.y = JUMP_VELOCITY  # Apply the fast, sharp jump velocity
		jump_count += 1  # Increment the jump count

	# Get horizontal input direction: -1, 0, 1
	direction = Input.get_axis("move_left", "move_right")
	
	# Flip the player (sprite)
	if direction > 0:
		animated_sprite.flip_h = false
		$AttackArea.position.x = abs($AttackArea.position.x)
	elif direction < 0:
		animated_sprite.flip_h = true
		$AttackArea.position.x = -abs($AttackArea.position.x)

	# Play movement animations when not attacking
	if not is_attacking:
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
				#velocity.x = 0  # Idle animation
			else:
				animated_sprite.play("walk")  # Walk animation

	# Horizontal movement logic (disabled during attack)
	if not is_attacking:
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)

	# No air control (quick jump with no horizontal movement control)
	# Air control set to 0 to make the player feel more like "The Flash"

	# Move the character and handle collisions
	move_and_slide()
