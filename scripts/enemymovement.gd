extends CharacterBody2D


const SPEED = 100
const knockback = 500
const knockback_dur = 0.5
@onready var target = $"../player"
var got_hit = false

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


func _on_player_enemy_take_damage() -> void:
	got_hit = true
	await get_tree().create_timer(knockback_dur).timeout
	got_hit = false
