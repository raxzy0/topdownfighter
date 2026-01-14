extends Node2D


const max_health = 3
var health = max_health
var gold = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_health()
	$PauseMenu.hide()

func update_health():
	$healthBar.max_value = max_health
	$healthBar/healthLabel.text = "health: %s" % health
	$healthBar.value = health
	$healthBar/goldLabel.text = "gold: %s" % gold
	if health <= 0:
		get_tree().paused = true
		$PauseMenu.show()

func _on_player_player_take_damage() -> void:
	health -=1
	update_health()

func _on_basic_enemy_enemy_death(drops: int) -> void:
	gold += drops
	update_health()
