extends CharacterBody2D

const SPEED = 100
const knockback = 500
const knockback_dur = 0.5
@onready var target = $"../player"

@onready var healthBar = $enemy/ProgressBar
var got_hit = false
@onready var _animation = $enemy/AnimatedSprite2D
const max_health = 3
var health = max_health
signal enemy_death(drops: int)
const gold_drop = 1

func update_health():
	healthBar.max_value = max_health
	healthBar.value = health
	if healthBar.value <= 0:
		queue_free()
		print("gold")
		enemy_death.emit(gold_drop)

func _physics_process(_delta):
	var direction =  (target.global_position - position).normalized()
	
	if got_hit:
		direction =  -1 * (target.global_position - position).normalized()
		velocity = SPEED * direction
	
	velocity = SPEED * direction
	
	if velocity.x < 0:
		$enemy/AnimatedSprite2D.flip_h = true;
	elif velocity.x > 0:
		$enemy/AnimatedSprite2D.flip_h = false
	move_and_slide()

func _ready() -> void:
	_animation.play("idle")
	update_health()

func _on_player_enemy_take_damage() -> void:
	got_hit = true
	health -= 1
	print("hit")
	update_health()
	await get_tree().create_timer(knockback_dur).timeout
	got_hit = false
