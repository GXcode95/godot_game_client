extends Control
class_name MainMenu

const GAME_SCENE_FILE_PATH = "res://Scenes/main.tscn"

@onready var play_button := $Buttons/PlayButton
@onready var quit_button := $Buttons/QuitButton

func _ready():
	play_button.pressed.connect(_on_play_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_play_button_pressed():
	get_tree().change_scene_to_file(GAME_SCENE_FILE_PATH)

func _on_quit_button_pressed():
	get_tree().quit()
