extends ReferenceRect

var slotID
enum States {DEFAULT, TAKEN, FREE}
var state = States.DEFAULT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	setColor(state)


func setColor(_state = States.DEFAULT) -> void:
	match _state:
		States.DEFAULT:
			border_color = Color(Color.WHITE, 0.2)
		States.TAKEN:
			border_color = Color(Color.RED, 0.2)
		States.FREE:
			border_color = Color(Color.GREEN, 1.0)
