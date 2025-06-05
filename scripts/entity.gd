class_name Entity

extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_bar: ProgressBar = $HealthBar
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var size: float
@export var max_hp: float
@export var attackPower: float

var currentHealth

signal enemy_defeated

func _ready() -> void:
	sprite_2d.transform.x = Vector2(size, 0)
	sprite_2d.transform.y = Vector2(0, size)
	
	if health_bar:
		currentHealth = max_hp
		health_bar.max_value = max_hp

func _process(delta: float) -> void:
	if health_bar:
		health_bar.value = currentHealth
	if currentHealth <= 0:
		die()

func attack(entity: Entity):
	print(name + ' Attacked!')
	animation_player.play('attack')
	entity.currentHealth -= attackPower

func die():
	enemy_defeated.emit()
	print(name + ' is defeated')
	queue_free()
