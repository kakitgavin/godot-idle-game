extends Node2D

@onready var player: Entity = $Player
@onready var enemy_location: Marker2D = $EnemyLocation
@onready var backpack_manager: Control = %BackpackManager
@onready var next_level_btn: Button = $CanvasLayer/NextLevelBtn


#implement dictionary to init preload texture in the future
const orc = preload('res://scenes/entities/orc.tscn')
const skeletonSoldier = preload('res://scenes/entities/skeleton_soldier.tscn')
const slime = preload('res://scenes/entities/slime.tscn')
const golbin = preload('res://scenes/entities/goblin.tscn')
const hitEffect_1 = preload('res://scenes/vfx/hit_effect_1.tscn')
const darkBolt = preload('res://scenes/vfx/dark_bolt.tscn')

enum GameState {COMBAT, UPGRADE}
var currentGameState: GameState = GameState.COMBAT
var enemy: Entity
var entityArray: Array = [orc, skeletonSoldier, slime, golbin]
var enemiesRemaining = 1
var level = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	next_level_btn.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match currentGameState:
		GameState.COMBAT:
			#add enemy when the current enemy dies
			if !enemy and enemiesRemaining != 0:
				var i = randi_range(0, entityArray.size() - 1)
				enemy = entityArray[i].instantiate()
				enemy.enemy_defeated.connect(_on_enemy_defeated)
				enemy.position = enemy_location.position
				add_child(enemy)
				#reset player attack timer after adding an enemy
				player.attack_timer.start(1/player.attackSpeed)
			
			if player.currentHealth <= 0:
				get_tree().reload_current_scene()
			
			#enter upgrade state
			if enemiesRemaining <= 0:
				currentGameState = GameState.UPGRADE
				backpack_manager.spawnItem()
				
		GameState.UPGRADE:
			next_level_btn.visible = true

func _on_enemy_defeated():
	enemiesRemaining -= 1

func _on_entity_attack_timer_timeout(entity, attackPower):
	if player and enemy:
		if entity == 'Player':
			#handle player attack here
			player.attack()
			var itemStats = 0
			#calculate stats modify from backpack
			for item in backpack_manager.itemInBackpack:
				if item.weaponStats:
					itemStats += item.weaponStats.attackDamage
			enemy.currentHealth -= attackPower + itemStats
			var vfx = hitEffect_1.instantiate()
			vfx.position = enemy.position
			add_child(vfx)
		else:
			#handle enemy attack here
			enemy.attack()
			player.currentHealth -= attackPower
			var vfx = hitEffect_1.instantiate()
			vfx.position = player.position
			add_child(vfx)

func _on_next_level_btn_pressed() -> void:
	level += 1
	enemiesRemaining = level
	currentGameState = GameState.COMBAT
	next_level_btn.visible = false
