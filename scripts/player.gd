extends CharacterBody2D

@export var walk_speed = 300
@export var run_speed = 600

#rolling
@export var roll_speed = 1000
@export var roll_duration = 0.25 
var rolling = false
var roll_direction = Vector2.ZERO

#hits
var hit_dur = 0.4
var hit_direction = Vector2.ZERO
var hit_speed = 200

#attacks
@export var attack_duration = 0.5

var got_hit = false
var attacking = false
var attackingUp = false
var attackingDown = false

@onready var _animated_sprite = $AnimatedSprite2D

signal player_take_damage
signal enemy_take_damage
func _physics_process(_delta):
	if not rolling:
		get_input()
	elif rolling:
		velocity = roll_direction * roll_speed

	if got_hit:
		velocity = hit_direction * hit_speed
		
	move_and_slide()
	update_animation()

func get_input():

	if Input.is_action_just_pressed("roll") and velocity.length() > 0:
		roll()
		return
	if not (attacking or attackingDown or attackingUp):
		if Input.is_action_just_pressed("attack") and Input.is_action_pressed("up"):
			attackUp()
			return
		elif Input.is_action_just_pressed("attack") and Input.is_action_pressed("down"):
			attackDown()
			return
		elif Input.is_action_just_pressed("attack"):
			attack()
			return

	var input_direction = Input.get_vector("left", "right", "up", "down")
	var current_speed = run_speed if Input.is_action_pressed("shift") else walk_speed
	velocity = input_direction * current_speed
	return velocity

func roll():
	rolling = true
	roll_direction = velocity.normalized()
	await get_tree().create_timer(roll_duration).timeout
	rolling = false

func hit():
	got_hit = true
	player_take_damage.emit()
	if velocity == Vector2.ZERO:
		if _animated_sprite.flip_h == true:
			hit_direction = Vector2.RIGHT
		elif _animated_sprite.flip_h == false:
			hit_direction = Vector2.LEFT
	else:
		hit_direction = velocity.normalized() *-1
	await get_tree().create_timer(hit_dur).timeout
	got_hit = false
	
func attack():
	$attackHitBoxes/attackLeftHitbox.disabled = false
	if _animated_sprite.flip_h == true:
		$attackHitBoxes/attackLeftHitbox.disabled = false
	elif _animated_sprite.flip_h == false:
		$attackHitBoxes/attackRightHitbox.disabled = false
	attacking = true
	hit_direction = velocity.normalized() *-1
	await get_tree().create_timer(attack_duration).timeout
	$attackHitBoxes/attackLeftHitbox.disabled = true
	$attackHitBoxes/attackRightHitbox.disabled = true
	attacking = false

func attackUp():
	$attackHitBoxes/attackTopHitbox.disabled = false
	attackingUp = true
	hit_direction = velocity.normalized() *-1
	await get_tree().create_timer(attack_duration).timeout
	attackingUp = false
	$attackHitBoxes/attackTopHitbox.disabled = true

func attackDown():
	$attackHitBoxes/attackDownHitbox.disabled = false
	attackingDown = true
	hit_direction = velocity.normalized() *-1
	await get_tree().create_timer(attack_duration).timeout
	attackingDown = false
	$attackHitBoxes/attackDownHitbox.disabled = true
	
func update_animation():
	if rolling:
		_animated_sprite.play("roll")
		return
	if got_hit:
		_animated_sprite.play("takeDmg")
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


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		hit()


func _on_attack_hit_boxes_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		enemy_take_damage.emit()
