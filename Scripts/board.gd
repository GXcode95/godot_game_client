extends Node2D
class_name Board

@onready var world_layer := $World
@onready var highlight_layer := $Highlight
@onready var selected_layer := $Selected
@onready var game_node := $".."

const CELL_TILE_IDS := {
	'path': 0,
	'move': 1,
	'hover': 2,
	'attack': 3,
}

var _selected_cell := Vector2i(-999, -999)
var _hovered_cell :=Vector2i(-999, -999)
var _travel_path: Array[Vector2i] = []

# -----------------------
# -- GETTERS / SETTERS --
# -----------------------

var travel_path: Array[Vector2i]:
	get: return _travel_path
	set(value): _travel_path = value
	
var selected_cell: Vector2i:
	get: return _selected_cell
	set(value): _selected_cell = value

var hovered_cell: Vector2i:
	get: return _hovered_cell
	set(value): 
		_hovered_cell = value
		selected_layer.clear()
		selected_layer.set_cell(value, 0, Vector2(0,0), 0)

				
# ---------------------
# -- HIGHLIGHT LAYER --
# ---------------------

func _highlight_cell(cell: Vector2i , tile_id: int):
	if not is_inside(cell):
		return
	highlight_layer.set_cell(cell, tile_id, Vector2(0,0), 0)

func clear_highlight():
	highlight_layer.clear()

# ------------------
# -- WORLD LAYER  --
# ------------------

func is_inside(cell: Vector2i) -> bool:
	var rect: Rect2i = world_layer.get_used_rect()
	return rect.has_point(cell)
	
func get_mouse_cell():
	var mouse_pos = world_layer.get_local_mouse_position()
	var cell = world_layer.local_to_map(mouse_pos)
	if is_inside(cell):
		return cell

	return null

# -----------------
# -- PATHFINDING --
# -----------------

func _find_path(start: Vector2i, goal: Vector2i, max_range: int) -> Array[Vector2i]:
	if start == goal:
		return []

	var frontier: Array[Vector2i] = [start]
	var came_from := {}
	came_from[start] = null

	while frontier.size() > 0:
		var current = frontier.pop_front()

		# stop when goal is reached
		if current == goal:
			break

		for neighbor in _get_neighbors(current):
			if not came_from.has(neighbor):
				# limit the max distance (to avoid going out of the character's range)
				if abs(neighbor.x - start.x) + abs(neighbor.y - start.y) <= max_range:
					came_from[neighbor] = current
					frontier.append(neighbor)

	# rebuild the path
	var path: Array[Vector2i] = []
	var cur = goal
	while cur != null and came_from.has(cur):
		if cur != start:
			path.push_front(cur)
		cur = came_from[cur]

	return path
	
func _get_neighbors(cell: Vector2i) -> Array[Vector2i]:
	var dirs = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
	var neighbors: Array[Vector2i] = []
	for d in dirs:
		var n = cell + d
		if is_inside(n):
			neighbors.append(n)
	return neighbors

# -------------------
# -- DATA HANDLING --
# -------------------

func reset_selected_cell():
	selected_cell = Vector2i(-999, -999)

func reset_turn_data():
	travel_path = []

func reset_travel_path():
	travel_path = []

# ---------------------
# -- DISPLAY / HIDE  --
# ---------------------

func display_attack_range(max_range: int, center: Vector2i):
	highlight_layer.clear()
	for x in range(-max_range, max_range + 1):
		for y in range(-max_range, max_range + 1):
			var cell = center + Vector2i(x, y)
			if cell == center:
				highlight_layer.erase_cell(cell)
			elif abs(x) + abs(y) <= max_range:
				_highlight_cell(cell, CELL_TILE_IDS['attack'])

func display_move_range(movements: int, center: Vector2i):
	highlight_layer.clear()
	for x in range(-movements, movements + 1):
		for y in range(-movements, movements + 1):
			var cell = center + Vector2i(x, y)
			if cell == center:
				highlight_layer.erase_cell(cell)
			elif abs(x) + abs(y) <= movements:
				_highlight_cell(cell, CELL_TILE_IDS['move']) 

func display_path_between(start: Vector2i, goal: Vector2i, max_range: int):
	var path = _find_path(start, goal, max_range)
	display_travel_path(path)

func display_travel_path(new_path: Array[Vector2i]):
	for cell in travel_path:
		_highlight_cell(cell, CELL_TILE_IDS['move'])
	travel_path = new_path
	for cell in travel_path:
		var tile_id = highlight_layer.get_cell_source_id(cell)
		if CELL_TILE_IDS['move'] == tile_id:
			_highlight_cell(cell, CELL_TILE_IDS['path'])

func reset_and_clear_travel_path():
	for cell in travel_path:
		_highlight_cell(cell, CELL_TILE_IDS['move'])
	travel_path = []
