extends Node

@onready var ui = $"../UI"
@onready var _input_emitter = $"../InputEmitter"

var _active_character: Character
var _characters: Array[Character]
var _board: Board
var _active_index := 0
var _active_player: Player
const MODE := Enums.MODE

signal mode_updated(mode: int)

# -----------------------
# -- GETTERS / SETTERS --
# -----------------------

var active_character: Character:
	get: return _active_character
	set(value):
		_active_character = value
		_active_character.reset_state()
		_active_character.activate()
		active_player = _active_character.player
		ui.update_character_info(_active_character)
		emit_signal("mode_updated", MODE.IDLE)

var characters: Array[Character]:
	get: return _characters

var board: Board:
	get: return _board

var active_index: int:
	get: return _active_index
	set(value): _active_index = value

var active_player: Player:
	get: return _active_player
	set(value): _active_player = value
# --------------------^
# -- INITIALIZATION --
# --------------------

func _init(turn_board: Board, character_list: Array[Character]):
	_board = turn_board
	_characters = character_list

func _ready():
	_input_emitter.end_turn.connect(end_turn)

# ---------------
# -- TURN LOOP --
# ---------------

func end_turn():
	active_character.deactivate()
	board.clear_highlight()
	board.reset_turn_data()
	start_turn()

func start_turn():
	active_index = (active_index + 1) % characters.size()
	active_character = characters[active_index]
	LogManager.add_entry("Tour de : " + active_character.job_name)
	LogManager.add_entry("Joueur : " + active_player.nickname)

# ----------------------
# -- ACTIONS HANDLERS --
# ----------------------

func handle_attack(cell: Vector2i):
	var target_character = _character_at_cell(cell)
	if target_character and target_character != active_character:
		active_character.attack(target_character)
		idle_or_end_turn()
		
func handle_move(cell: Vector2i):
	if active_character.can_move_to(cell) and _is_empty_cell(cell):
		emit_signal("mode_updated", MODE.MOVING)
		await active_character.move_along_path(board.travel_path)
		idle_or_end_turn()
			
func idle_or_end_turn():
	if can_attack_someone() or active_character.movements > 0:
		emit_signal("mode_updated", MODE.IDLE)
	else:
		end_turn()

# -----------
# -- UTILS --
# -----------

func _character_at_cell(cell: Vector2i):
	for character in characters:
		if character.current_cell == cell:
			return character
	return null

func _is_empty_cell(cell: Vector2i):
	for character in characters:
		if character.current_cell == cell:
			return false
	return true

func can_attack_someone():
	if active_character.action_points < active_character.attack_cost:
		return false

	for character in characters:
		if active_character == character:
			continue

		var distance = Helpers.distance(active_character.current_cell, character.current_cell)
		if distance <= active_character.attack_range:
			print("can attack someone at distance: ", distance)
			return true

	return false
