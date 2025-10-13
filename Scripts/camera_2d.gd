extends Node2D

@onready var camera = $"."

# Facteur de zoom (plus petit = zoom avant)
var zoom_step := 0.1
var min_zoom := 1
var max_zoom := 3.0

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			# Zoom avant
			camera.zoom -= Vector2(zoom_step, zoom_step)
			camera.zoom.x = clamp(camera.zoom.x, min_zoom, max_zoom)
			camera.zoom.y = clamp(camera.zoom.y, min_zoom, max_zoom)

		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			# Zoom arrière
			camera.zoom += Vector2(zoom_step, zoom_step)
			camera.zoom.x = clamp(camera.zoom.x, min_zoom, max_zoom)
			camera.zoom.y = clamp(camera.zoom.y, min_zoom, max_zoom)
