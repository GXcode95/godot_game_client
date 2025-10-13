extends Node
class_name Helpers


static func distance(origin_cell: Vector2i, target_cell: Vector2i):
	return abs(origin_cell.x - target_cell.x) + abs(origin_cell.y - target_cell.y)

