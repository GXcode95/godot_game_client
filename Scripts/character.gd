extends CharacterBody2D
class_name Character

@onready var world_layer := $"../Board/World"
@onready var ui := $"../UI"

const ANIMATION_TYPE := Enums.ANIMATION_TYPE
const ORIENTATION := Enums.ORIENTATION

var _job_data: JobData
var _movements: int
var _move_range : int
var _is_moving: bool = false
var _is_active: bool = false
var _orientation: int
var _hp: int
var _max_hp: int
var _attack_range: int
var _attack_damage: int
var _action_points: int
var _max_action_points: int
var _attack_cost: int
var _current_cell: Vector2i
var _player: Player

signal animation_changed(new_animation: int)
signal stopped(orientation: int)
signal died(character: Character)
signal moved_to(cell: Vector2i)

# -----------------------
# -- GETTERS / SETTERS --
# -----------------------

var job_name: String:
	get: return _job_data.job_name

var movements: int:
	get: return _movements
	set(value): _movements = value

var is_moving: bool:
	get: return _is_moving
	set(value): _is_moving = value

var is_active: bool:
	get: return _is_active
	set(value): _is_active = value

var orientation: int:
	get: return _orientation
	set(value): _orientation = value if value in [ORIENTATION.DOWN_LEFT, ORIENTATION.DOWN_RIGHT, ORIENTATION.UP_LEFT, ORIENTATION.UP_RIGHT] else ORIENTATION.DOWN_LEFT

var hp: int:
	get: return _hp
	set(value):
		_hp = max(value, 0)
		if _hp == 0:
			die()

var max_hp: int:
	get: return _max_hp
	set(value): _max_hp = value

var move_range: int:
	get: return _move_range
	set(value): _move_range = value

var attack_range: int:
	get: return _attack_range
	set(value): _attack_range = value

var attack_damage: int:
	get: return _attack_damage
	set(value): _attack_damage = value

var action_points: int:
	get: return _action_points
	set(value): _action_points = value

var attack_cost: int:
	get: return _attack_cost

var max_action_points: int:
	get: return _max_action_points
	set(value): _max_action_points = value

var current_cell: Vector2i:
	get: return _current_cell
	set(value):
		_current_cell = value
		emit_signal("moved_to", self, value)

var player: Player:
	get: return _player

# --------------------
# -- INITIALIZATION --
# --------------------

func build(start_cell: Vector2i, data: JobData, c_player: Player) -> void:
	_job_data = data
	move_range = _job_data.move_range
	max_hp = _job_data.max_hp
	attack_range = _job_data.attack_range
	attack_damage = _job_data.attack_damage
	max_action_points = _job_data.action_points
	_attack_cost = _job_data.attack_cost
	_current_cell = start_cell
	hp = max_hp
	_player = c_player
	_connect_to_character_view()
	
func _connect_to_character_view() -> void:
	var character_view = _job_data.sprite_scene.instantiate()
	add_child(character_view)
	character_view.connect_to_character(self)

func _ready() -> void:
	if current_cell.y < 3:
		orientation = ORIENTATION.DOWN_LEFT
	elif current_cell.y > 6:
		orientation = ORIENTATION.UP_RIGHT
	emit_signal("stopped", orientation)
	position = world_layer.map_to_local(current_cell)

# ---------------
# -- MOVEMENTS --
# ---------------

func move_along_path(path: Array[Vector2i]) -> void:
	_is_moving = true
	for cell in path:
		var target = world_layer.map_to_local(cell)
		if cell == current_cell:
			continue
		elif cell.x > current_cell.x:
			orientation = ORIENTATION.DOWN_RIGHT
			emit_signal("animation_changed", ANIMATION_TYPE.WALK_DOWN_RIGHT)
		elif cell.x < current_cell.x:
			orientation = ORIENTATION.UP_LEFT
			emit_signal("animation_changed", ANIMATION_TYPE.WALK_UP_LEFT)
		elif cell.y > current_cell.y:
			orientation = ORIENTATION.DOWN_LEFT
			emit_signal("animation_changed", ANIMATION_TYPE.WALK_DOWN_LEFT)
		elif cell.y < current_cell.y:
			orientation = ORIENTATION.UP_RIGHT
			emit_signal("animation_changed", ANIMATION_TYPE.WALK_UP_RIGHT)
		
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", target, 0.3)
		movements -= 1
		ui.update_character_info(self)
		await tween.finished
		current_cell = cell

	activate()
	_is_moving = false
	
func can_move_to(cell: Vector2i) -> bool:
	if is_moving or movements == 0:
		return false

	return Helpers.distance(current_cell, cell) <= _movements

# -----------
# -- STATE --
# -----------

func reset_movements() -> void:
	movements = move_range
	
func reset_action_points() -> void:
	action_points = max_action_points

func activate() -> void:
	_is_active = true
	
	match orientation:
		ORIENTATION.DOWN_LEFT: emit_signal("animation_changed", ANIMATION_TYPE.IDLE_DOWN_LEFT)
		ORIENTATION.DOWN_RIGHT: emit_signal("animation_changed", ANIMATION_TYPE.IDLE_DOWN_RIGHT)
		ORIENTATION.UP_LEFT: emit_signal("animation_changed", ANIMATION_TYPE.IDLE_UP_LEFT)
		ORIENTATION.UP_RIGHT: emit_signal("animation_changed", ANIMATION_TYPE.IDLE_UP_RIGHT)

func deactivate() -> void:
	_is_active = false
	emit_signal("stopped", orientation)

func die() -> void:
	LogManager.add_entry(job_name + " est mort !")
	emit_signal("died", self)

func reset_state() -> void:
	reset_movements()
	reset_action_points()

# ----------------
# -- ATTACKING --
# ----------------

func can_attack_at(cell: Vector2i) -> bool:
	if action_points < attack_cost:
		return false
	return Helpers.distance(current_cell, cell) == attack_range
	
func attack(target: Character) -> void:
	LogManager.add_entry(job_name + " attaque " + target.job_name)
	action_points -= attack_cost
	ui.update_character_info(self)
	target.take_damage(50)

func take_damage(damage: int) -> void:
	LogManager.add_entry(job_name + " subit " + str(damage) + " dégâts")
	hp -= damage

# -----------
# -- UTILS --
# -----------

func class_info() -> String:
	return "Character: %s" % job_name