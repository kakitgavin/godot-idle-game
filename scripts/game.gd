extends Node2D

@onready var player: Entity = $Player

@onready var enemy_location: Node2D = $EnemyLocation

@onready var gold_label: Label = $Control/GoldLabel
@onready var enemies_count_label: Label = $Control/EnemiesCountLabel

#implement dictionary to init preload texture in the future
const orc = preload('res://scenes/entities/orc.tscn')
const skeletonSoldier = preload('res://scenes/entities/skeleton_soldier.tscn')
const slime = preload('res://scenes/entities/slime.tscn')
const golbin = preload('res://scenes/entities/goblin.tscn')

const hitEffect_1 = preload('res://scenes/vfx/hit_effect_1.tscn')
const darkBolt = preload('res://scenes/vfx/dark_bolt.tscn')

const itemKey = preload("res://scenes/item_key.tscn")

var enemy: Entity
var entityArray: Array = [orc, skeletonSoldier, slime, golbin]

var gold: int = 10
var enemiesRemaining = 1
var level = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !enemy and enemiesRemaining != 0:
		var i = randi_range(0, entityArray.size() - 1)
		enemy = entityArray[i].instantiate()
		enemy.enemy_defeated.connect(_on_enemy_defeated)
		enemy.position = enemy_location.position
		add_child(enemy)
		#reset player attack timer after adding an enemy
		player.attack_timer.start(1/player.attackSpeed)

	gold_label.text = str(gold)
	enemies_count_label.text = 'Enemies Remaining: ' + str(enemiesRemaining)
		
	if player.currentHealth <= 0:
		get_tree().reload_current_scene()

func _on_enemy_defeated():
	gold += 1
	enemiesRemaining -= 1

func _on_entity_attack_timer_timeout(entity, attackPower):
	if player and enemy:
		if entity == 'Player':
			player.attack()
			enemy.currentHealth -= attackPower
			var vfx = hitEffect_1.instantiate()
			vfx.position = enemy.position
			add_child(vfx)
		else:
			enemy.attack()
			player.currentHealth -= attackPower
			var vfx = darkBolt.instantiate()
			vfx.position = player.position
			add_child(vfx)
