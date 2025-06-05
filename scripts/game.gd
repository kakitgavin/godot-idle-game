extends Node2D

@onready var player_attack_timer: Timer = $PlayerAttackTimer
@onready var player: Entity = $Player

@onready var enemy_location: Node2D = $EnemyLocation

@onready var enemy_attack_timer: Timer = $EnemyAttackTimer

@onready var gold_label: Label = $GoldLabel

#implement dictionary to init preload texture in the future
const orc = preload('res://scenes/entities/orc.tscn')
const skeletonSoldier = preload('res://scenes/entities/skeleton_soldier.tscn')
const slime = preload('res://scenes/entities/slime.tscn')
const golbin = preload('res://scenes/entities/goblin.tscn')

const hitEffect_1 = preload('res://scenes/vfx/hit_effect_1.tscn')
const darkBolt = preload('res://scenes/vfx/dark_bolt.tscn')

var enemy: Entity
var entityArray: Array = [orc, skeletonSoldier, slime, golbin]

var gold: int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player_attack_timer.start(1)
	enemy_attack_timer.start(5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !enemy:
		var i = randi_range(0, entityArray.size() - 1)
		enemy = entityArray[i].instantiate()
		enemy.enemy_defeated.connect(_on_enemy_defeated)
		enemy.position = enemy_location.position
		add_child(enemy)

	gold_label.text = str(gold)


func _on_player_attack_timer_timeout() -> void:
	if enemy and player:
		player.attack(enemy)
		var vfx = hitEffect_1.instantiate()
		vfx.position = enemy.position
		add_child(vfx)


func _on_enemy_attack_timer_timeout() -> void:
	if enemy and player:
		enemy.attack(player)
		var vfx = darkBolt.instantiate()
		vfx.position = player.position
		add_child(vfx)

func _on_enemy_defeated():
	gold += 1
