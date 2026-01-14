extends Area2D

@onready var _animation = $AnimatedSprite2D
@onready var healthBar = $ProgressBar

const max_health = 3
var health = max_health
signal enemy_death(drops: int)
const gold_drop = 1

# Called when the node enters the scene tree for the first time.
func update_health():
	healthBar.max_value = max_health
	healthBar.value = health
	if healthBar.value <= 0:
		$"..".queue_free()
		print("gold")
		enemy_death.emit(gold_drop)
		
func _ready() -> void:
	_animation.play("idle")
	update_health()
	enemy_death.emit(gold_drop)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_player_enemy_take_damage() -> void:
	health -= 1
	print("hit")
	update_health()
