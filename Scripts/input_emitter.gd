extends Node
class_name InputEmitter

@onready var ui = $"../UI"

const MODE := Enums.MODE

signal left_click()
signal right_click()
signal mouse_over()
signal mode_updated(mode: int)
signal end_turn()

func _ready():
	ui.attack_btn_pressed.connect(_on_attack_btn_clicked)
	ui.end_turn_btn_pressed.connect(_on_end_turn_btn_clicked)

# ----------------------
# -- UI INPUTS --
# ----------------------

func _on_attack_btn_clicked():
	emit_signal("mode_updated", MODE.ATTACK)

func _on_end_turn_btn_clicked():
	emit_signal("end_turn")

# --------------------
# -- DEVICE INPUTS --
# --------------------

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT: emit_signal("left_click")
			MOUSE_BUTTON_RIGHT: emit_signal("right_click")
			MOUSE_BUTTON_XBUTTON1: emit_signal("end_turn")
			MOUSE_BUTTON_XBUTTON2: emit_signal("mode_updated", MODE.ATTACK)
	elif event is InputEventMouseMotion:
		emit_signal("mouse_over")
	elif event.is_action_pressed("end_turn"):
		emit_signal("end_turn")
