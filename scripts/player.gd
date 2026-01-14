extends CharacterBody2D

@export var walk_speed = 400
@export var run_speed = 600

@export var roll_speed = 1000
@export var roll_duration = 0.25  # How long the roll lasts
var rolling = false
var roll_direction = Vector2.ZERO

@export var attack_duration = 0.5

var attacking = false
var attackingUp = false
var attackingDown = false

@onready var _animated_sprite = $AnimatedSprite2D

func _physics_process(_delta):
	if not rolling:
		get_input()
	else:
		velocity = roll_direction * roll_speed
	move_and_slide()
	update_animation()

func get_input():
	# Check for roll input
	if Input.is_action_just_pressed("roll") and velocity.length() > 0:
		roll()
		return

	if Input.is_action_just_pressed("attack") and Input.is_action_pressed("up"):
		attackUp()
		return
	elif Input.is_action_just_pressed("attack") and Input.is_action_pressed("down"):
		attackDown()
		return
	elif Input.is_action_just_pressed("attack") and (Input.is_action_pressed("right") or Input.is_action_pressed("left")):
		attack()
		return

	var input_direction = Input.get_vector("left", "right", "up", "down")
	var current_speed = run_speed if Input.is_action_pressed("shift") else walk_speed
	velocity = input_direction * current_speed

func roll():
	rolling = true
	roll_direction = velocity.normalized()
	await get_tree().create_timer(roll_duration).timeout
	rolling = false

func attack():
	attacking = true
	await get_tree().create_timer(attack_duration).timeout
	attacking = false

func attackUp():
	attackingUp = true
	await get_tree().create_timer(attack_duration).timeout
	attackingUp = false
	
func attackDown():
	attackingDown = true
	await get_tree().create_timer(attack_duration).timeout
	attackingDown = false
	
func update_animation():
	if rolling:
		_animated_sprite.play("roll")
		return
		

	if attacking:
		_animated_sprite.play("attackSide")
		return
	elif attackingUp:
		_animated_sprite.play("attackUp")
		return
	elif attackingDown:
		_animated_sprite.play("attackDown")
		return

	var is_moving = velocity.length() > 0
	if is_moving:
		if velocity.x < 0:
			_animated_sprite.flip_h = true
		elif velocity.x > 0:
			_animated_sprite.flip_h = false
		if Input.is_action_pressed("shift"):
			_animated_sprite.play("run")
		else:
			_animated_sprite.play("walk")
	else:
		_animated_sprite.play("idle")
