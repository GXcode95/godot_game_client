extends Node2D
class_name Game

const CharacterScene = preload(Scenes.PATH.CHARACTER)
const GameOverMenuScene = preload(Scenes.PATH.GAME_OVER)
const TurnManager = preload("res://Scripts/turn_manager.gd")

@export var redfox_data: JobData
@export var orangefox_data: JobData

@onready var _input_emitter := $InputEmitter
@onready var board := $Board
@onready var ui := $UI

const MODE := Enums.MODE

var _players: Array[Player] = []
var _turn_manager: TurnManager
var _characters : Array[Character] = []
var _selected_character : Character
var _mode := MODE.IDLE
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
			MODE.ATTACK:
				attack_mode()
			MODE.MOVING:
				moving_mode()
			MODE.IDLE:
				idle_mode()

var players:
	get: return _players
# --------------------
# -- INITIALIZATION --
# --------------------

func _ready():
	_input_emitter.left_click.connect(_on_left_click)
	_input_emitter.mouse_over.connect(_on_mouseover)
	_input_emitter.mode_updated.connect(_on_mode_updated)
	_input_emitter.right_click.connect(_on_right_click)

	_spawn_players()

	_turn_manager = TurnManager.new(board, characters)
	add_child(turn_manager)
	turn_manager.mode_updated.connect(_on_mode_updated)
	turn_manager.start_turn()

func _spawn_players():
	_players.append(Player.new("Player 1"))
	_players.append(Player.new("Player 2"))
	
	var redfox = _spawn_character(Vector2i(5, 9), redfox_data, players[0])
	var orangefox = _spawn_character(Vector2i(5, 0), orangefox_data, players[1])
	players[0].add_character(redfox)
	players[1].add_character(orangefox)

func _spawn_character(cell: Vector2i, job_data: JobData, player: Player) -> Character:
	var character = CharacterScene.instantiate()

	character.build(cell, job_data, player)
	characters.append(character)
	add_child(character)
	board.add_entity(character, cell)
	character.died.connect(_on_character_died)
	return character

# --------------------
# -- SIGNALS --
# --------------------

func _on_left_click():
	var cell = board.get_mouse_cell()
	if not cell or not board.is_inside(cell):
		return

	board.selected_cell = cell
	match mode:
		MODE.ATTACK: 
			turn_manager.handle_attack(cell)
		MODE.IDLE:
			turn_manager.handle_move(cell)
		MODE.MOVING:
			pass

func _on_right_click():
	mode = MODE.IDLE

func _on_mouseover():
	var cell = board.get_mouse_cell()
	if not cell or not board.is_inside(cell) or board.hovered_cell == cell:
		return
		
	#print("mouseover -> ", cell)
	board.hovered_cell = cell

	match mode:	
		MODE.MOVING:
			pass
		MODE.IDLE:
			var active_character = turn_manager.active_character
			var active_character_cell = active_character.current_cell
			var movements = active_character.movements
			if active_character.can_move_to(cell):
				board.display_path_between(active_character_cell, cell, movements)
			else:
				board.reset_and_clear_travel_path()
				board.hovered_cell = cell
		MODE.ATTACK:
			pass

func _on_mode_updated(new_mode: int):
	mode = new_mode

func _on_character_died(character: Character):
	characters.erase(character)
	character.queue_free()
	if characters.size() <= 1:
		game_over()

# --------------------
# -- MODES HANDLERS --
# --------------------

func idle_mode():
	var character = turn_manager.active_character
	board.reset_travel_path()
	board.display_move_range(character.movements, character.current_cell)
	if character.can_move_to(board.hovered_cell):
		board.display_path_between(character.current_cell, board.hovered_cell, character.movements)

func moving_mode():
	board.clear_highlight()

func attack_mode():
	if turn_manager.active_character.attack_cost > turn_manager.active_character.action_points:
		return
	board.display_attack_range(turn_manager.active_character.attack_range, turn_manager.active_character.current_cell)

# ---------------
# -- GAME OVER --
# ---------------

func game_over():
	get_tree().change_scene_to_packed(GameOverMenuScene)