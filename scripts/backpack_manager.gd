extends Control

@onready var slotScene = preload("res://scenes/slot.tscn")
@onready var grid_container: GridContainer = $PanelContainer/GridContainer
@onready var area_2d: Area2D = $PanelContainer/Area2D

const dagger = preload("res://scenes/items/dagger.tscn")
const spear = preload("res://scenes/items/spear.tscn")

var mouseCanDrag = false
var isDragging = false
var selectedItem: Control
var offset := Vector2(0, 0)
var originalPos: Vector2
var isSlotFree = false
var isInBoundary = false

var previewPosition: Vector2
var itemInBackpack = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(9):
		createSlot()
	# connect item signals
	for item:TextureRect in get_tree().get_nodes_in_group('item'):
		item.gui_input.connect(_cursor_in_item.bind(item))
		item.mouse_exited.connect(_cursor_exit_item)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#handle mouse drag and place logic
	if mouseCanDrag:
		if Input.is_action_just_pressed("mouseLeftClick"):
			isDragging = true
			offset = get_global_mouse_position() - selectedItem.global_position
			originalPos = selectedItem.global_position
		if Input.is_action_pressed("mouseLeftClick") and isDragging:
			selectedItem.global_position = get_global_mouse_position() - offset
		elif Input.is_action_just_released("mouseLeftClick"):
			isDragging = false
			if isSlotFree and isInBoundary:
				#selectedItem.global_position = previewPosition
				selectedItem.position = previewPosition
			else:
				selectedItem.global_position = originalPos
				
	#items inside backpack is stored in array
	var tempItemInBackpack = []
	for area in area_2d.get_overlapping_areas():
		tempItemInBackpack.append(area.get_parent())
		itemInBackpack = tempItemInBackpack

func _physics_process(delta: float) -> void:
	#check if item can be placed in backpack
	if selectedItem and isDragging:
		#previewPosition = selectedItem.global_position.snapped(Vector2(32, 32))
		previewPosition = selectedItem.position.snapped(Vector2(32, 32))
		print(previewPosition)
		
		var selectedItemRect: Rect2 = selectedItem.find_child('Area2D').get_child(0).get_shape().get_rect()
		selectedItemRect.position = previewPosition
		
		#check if selected item is inside backpack
		var backpackRect: Rect2 = area_2d.get_child(0).get_shape().get_rect()
		backpackRect.position = area_2d.position
		isInBoundary = backpackRect.encloses(selectedItemRect)
		
		#check collision between items
		isSlotFree = true #set to true first incase there is no item
		for item: TextureRect in get_tree().get_nodes_in_group('item'):
			if item != selectedItem:
				var itemToCheckRect: Rect2 = item.find_child('Area2D').get_child(0).get_shape().get_rect()
				itemToCheckRect.position = item.global_position
				isSlotFree = !selectedItemRect.intersects(itemToCheckRect)
				if isSlotFree == false:
					return
		
		print(isSlotFree)
		print(isInBoundary)
		print(area_2d.position)

func createSlot():
	var newSlot = slotScene.instantiate()
	grid_container.add_child(newSlot)

func _cursor_in_item(event: InputEvent, item: Control):
	if not isDragging:
		mouseCanDrag = true
		selectedItem = item

func _cursor_exit_item():
	if not isDragging:
		mouseCanDrag = false
		selectedItem = null

func spawnItem():
	var itemToAdd = dagger.instantiate()
	add_child(itemToAdd)
	itemToAdd.gui_input.connect(_cursor_in_item.bind(itemToAdd))
	itemToAdd.mouse_exited.connect(_cursor_exit_item)
