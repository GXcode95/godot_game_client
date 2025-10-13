extends Node
class_name InputManager

@onready var board = $"../Board"
@onready var game = $".."
@onready var ui = $"../UI"

signal left_click()
signal mouse_over()
signal mode_updated()
signal end_turn()

func _ready():
	print("ui ", ui)
	ui.attack_btn_pressed.connect(_on_attack_btn_clicked)
	ui.end_turn_btn_pressed.connect(_on_end_turn_btn_clicked)

# ----------------------
# -- SIGNALS HANDLERS --
# ----------------------

func _on_attack_btn_clicked():
	emit_signal("mode_updated", "attack")

func _on_end_turn_btn_clicked():
	emit_signal("end_turn")

# --------------------
# -- EVENT HANDLERS --
# --------------------

func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("end_turn"):
		_handle_end_turn()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_left_click()
	elif event is InputEventMouseMotion:
		_handle_mouse_over()

func _handle_left_click():
	var cell = board.get_mouse_cell()
	if board.is_inside(cell):
		emit_signal("left_click", cell)
	
func _handle_mouse_over():
	var cell = board.get_mouse_cell()
	if cell != null and board.is_inside(cell):
		emit_signal("mouse_over", cell)
	
func _handle_end_turn():
	emit_signal("end_turn")
