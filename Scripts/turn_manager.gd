extends Node

var _active_character: Character
var _characters: Array[Character]
var _board: Board
var _active_index := 0

signal turn_started(character: Character)
signal turn_ended()
signal mode_updated(mode: String)

# -----------------------
# -- GETTERS / SETTERS --
# -----------------------

var active_character: Character:
	get: return _active_character
	set(value): _active_character = value

var characters: Array[Character]:
	get: return _characters

var board: Board:
	get: return _board

var active_index: int:
	get: return _active_index
	set(value): _active_index = value

# --------------------
# -- INITIALIZATION --
# --------------------

func _init(turn_board: Board, character_list: Array[Character]):
	_board = turn_board
	_characters = character_list

# ---------------
# -- TURN LOOP --
# ---------------

func end_turn():
	active_character.deactivate()
	emit_signal("turn_ended")	

func start_turn():
	active_index = (active_index + 1) % characters.size()
	active_character = characters[active_index]
	LogManager.add_entry("Tour de : " + active_character.job_name)
	active_character.reset_state()
	active_character.activate()
	emit_signal("turn_started", active_character)

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
		emit_signal("mode_updated", "moving")
		await active_character.move_along_path(board.travel_path)
		idle_or_end_turn()
			
func idle_or_end_turn():
	if can_attack_someone() or active_character.movements > 0:
		emit_signal("mode_updated", "idle")
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
