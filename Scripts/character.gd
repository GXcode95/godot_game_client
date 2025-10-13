extends CharacterBody2D
class_name Character

@onready var world_layer := $"../Board/World"
@onready var ui := $"../UI"

enum AnimationType {
	IDLE_UP_LEFT,
	IDLE_UP_RIGHT,
	IDLE_DOWN_RIGHT,
	IDLE_DOWN_LEFT,
	WALK_UP_LEFT,
	WALK_UP_RIGHT,
	WALK_DOWN_RIGHT,
	WALK_DOWN_LEFT,
}

enum Orientation {
	UP_LEFT,
	UP_RIGHT,
	DOWN_RIGHT,
	DOWN_LEFT,
}

var _job_data: JobData
var _start_cell: Vector2i
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
var _attack_cost: int

signal animation_changed(new_animation: int)
signal stopped(orientation: int)

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

var start_cell: Vector2i:
	get: return _start_cell
	set(value): _start_cell = value

var is_active: bool:
	get: return _is_active
	set(value): _is_active = value

var orientation: int:
	get: return _orientation
	set(value): _orientation = value if value in [Orientation.DOWN_LEFT, Orientation.DOWN_RIGHT, Orientation.UP_LEFT, Orientation.UP_RIGHT] else Orientation.DOWN_LEFT

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

# --------------------
# -- INITIALIZATION --
# --------------------

func build(cell: Vector2i, data: JobData):
	_job_data = data
	move_range = _job_data.move_range
	max_hp = _job_data.max_hp
	attack_range = _job_data.attack_range
	attack_damage = _job_data.attack_damage
	action_points = _job_data.action_points
	_attack_cost = _job_data.attack_cost
	print("attack cost: ", attack_cost, " / ",  _job_data.attack_cost)
	start_cell = cell
	hp = max_hp
	_connect_to_character_view()
	
func _connect_to_character_view():
	var character_view = _job_data.sprite_scene.instantiate()
	add_child(character_view)
	character_view.connect_to_character(self)

func _ready():
	if start_cell.y < 3:
		orientation = Orientation.DOWN_LEFT
	elif start_cell.y > 6:
		orientation = Orientation.UP_RIGHT
	emit_signal("stopped", orientation)
	position = world_layer.map_to_local(start_cell)

# ---------------
# -- MOVEMENTS --
# ---------------

func move_along_path(path: Array[Vector2i]):
	_is_moving = true
	for cell in path:
		var target = world_layer.map_to_local(cell)
		var curr_cell = get_current_cell()
		
		if cell == curr_cell:
			continue
		elif cell.x > curr_cell.x:
			orientation = Orientation.DOWN_RIGHT
			emit_signal("animation_changed", AnimationType.WALK_DOWN_RIGHT)
		elif cell.x < curr_cell.x:
			orientation = Orientation.UP_LEFT
			emit_signal("animation_changed", AnimationType.WALK_UP_LEFT)
		elif cell.y > curr_cell.y:
			orientation = Orientation.DOWN_LEFT
			emit_signal("animation_changed", AnimationType.WALK_DOWN_LEFT)
		elif cell.y < curr_cell.y:
			orientation = Orientation.UP_RIGHT
			emit_signal("animation_changed", AnimationType.WALK_UP_RIGHT)
		
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", target, 0.3)
		movements -= 1
		ui.update_character_info(self)
		await tween.finished
		
	activate()
	_is_moving = false
	
func can_move_to(cell: Vector2i):
	if is_moving or movements == 0:
		return false
		
	var curr = get_current_cell()
	return Helpers.distance(curr, cell) <= _movements

# -----------
# -- STATE --
# -----------

func get_current_cell() -> Vector2i:
	return world_layer.local_to_map(global_position)

func reset_movements():
	movements = move_range
	
func activate():
	_is_active = true
	match orientation:
		Orientation.DOWN_LEFT: emit_signal("animation_changed", AnimationType.IDLE_DOWN_LEFT)
		Orientation.DOWN_RIGHT: emit_signal("animation_changed", AnimationType.IDLE_DOWN_RIGHT)
		Orientation.UP_LEFT: emit_signal("animation_changed", AnimationType.IDLE_UP_LEFT)
		Orientation.UP_RIGHT: emit_signal("animation_changed", AnimationType.IDLE_UP_RIGHT)

func deactivate():
	_is_active = false
	emit_signal("stopped", orientation)

func die():
	LogManager.add_entry(job_name + " est mort !")
	queue_free()

# ----------------
# -- ATTACKING --
# ----------------

func can_attack_at(cell: Vector2i) -> bool:
	if action_points < attack_cost:
		return false
	var curr = get_current_cell()
	return Helpers.distance(curr, cell) == attack_range
	
func attack(target: Character):
	LogManager.add_entry(job_name + " attaque " + target.job_name)
	action_points -= attack_cost
	target.take_damage(50)

func take_damage(damage: int):
	LogManager.add_entry(job_name + " subit " + str(damage) + " dégâts")
	hp -= damage
