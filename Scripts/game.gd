extends Node2D
class_name Game

const CharacterScene = preload("res://Scenes/character.tscn")
const TurnManager = preload("res://Scripts/turn_manager.gd")

@export var redfox_data: JobData
@export var orangefox_data: JobData

@onready var _input_manager := $InputManager
@onready var board := $Board
@onready var ui := $UI

var _turn_manager: TurnManager
var _characters : Array[Character] = []
var _selected_character : Character
var _mode : String = "idle"

# -----------------------
# -- GETTERS / SETTERS --
# -----------------------

var turn_manager:
	get: return _turn_manager

var characters:
	get: return _characters
	
var selected_character:
	get: return _selected_character
	set(value): _selected_character = value
	
var mode:
	get: return _mode
	set(value):
		_mode = value
		match _mode:
			'attack':
				attack_mode()
			'moving':
				moving_mode()
			'idle':
				idle_mode()

# --------------------
# -- INITIALIZATION --
# --------------------

func _ready():
	_input_manager.left_click.connect(_on_left_click)
	_input_manager.mouse_over.connect(_on_mouseover)
	_input_manager.mode_updated.connect(_on_mode_updated)
	_input_manager.end_turn.connect(_on_turn_ended)
	_input_manager.right_click.connect(_on_right_click)
		
	_spawn_character(Vector2i(5, 9), redfox_data)
	_spawn_character(Vector2i(5, 0), orangefox_data)

	_turn_manager = TurnManager.new(board, characters)
	add_child(turn_manager)
	turn_manager.turn_started.connect(_on_turn_started)
	turn_manager.turn_ended.connect(_on_turn_ended)
	turn_manager.mode_updated.connect(_on_mode_updated)
	turn_manager.start_turn()

func _spawn_character(cell: Vector2i, job_data: JobData):
	var character = CharacterScene.instantiate()
	character.build(cell, job_data)
	characters.append(character)
	add_child(character)
	board.add_entity(character, cell)
	character.died.connect(_on_character_died)

# --------------------
# -- SIGNALS --
# --------------------

func _on_left_click(cell: Vector2i):
	board.selected_cell = cell
	match mode:
		'attack': 
			turn_manager.handle_attack(cell)
		'idle':
			turn_manager.handle_move(cell)
		'moving':
			pass

func _on_right_click():
	mode = 'idle'

func _on_mouseover(cell: Vector2i):
	if board.hovered_cell == cell:
		return
		
	#print("mouseover -> ", cell)
	board.hovered_cell = cell

	match mode:	
		'moving':
			pass
		'idle':
			var active_character = turn_manager.active_character
			var active_character_cell = active_character.current_cell
			var movements = active_character.movements
			if active_character.can_move_to(cell):
				board.display_path_between(active_character_cell, cell, movements)
			else:
				board.reset_and_clear_travel_path()
				board.hovered_cell = cell
		'attack':
			pass

func _on_mode_updated(new_mode: String):
	mode = new_mode

func _on_turn_started(character: Character):
	board.print_present_entities()
	print(turn_manager.active_character.current_cell)
	
	mode = 'idle'
	ui.update_character_info(character)
	board.display_move_range(character.movements, character.current_cell)
	if character.can_move_to(board.hovered_cell):
		board.display_path_between(character.current_cell, board.hovered_cell, character.movements)

func _on_turn_ended():
	board.clear_highlight()
	board.reset_turn_data()
	turn_manager.start_turn()

func _on_character_died(character: Character):
	characters.erase(character)
	character.queue_free()
	if characters.size() <= 1:
		game_over()

# --------------------
# -- MODES HANDLERS --
# --------------------

func idle_mode():
	board.reset_travel_path()
	board.display_move_range(turn_manager.active_character.movements, turn_manager.active_character.current_cell)

func moving_mode():
	board.clear_highlight()

func attack_mode():
	board.display_attack_range(turn_manager.active_character.attack_range, turn_manager.active_character.current_cell)

func game_over():
	var msg = "===========================\n======== GAME OVER ========\n==========================="
	LogManager.add_entry(msg)
	print(msg)