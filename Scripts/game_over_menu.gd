extends Control
class_name GameOverMenu

const MainMenuScene = preload("res://Scenes/main_menu.tscn")

@onready var main_menu_button := $Buttons/MainMenuButton
@onready var quit_button := $Buttons/QuitButton

func _ready():
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_packed(MainMenuScene)

func _on_quit_button_pressed():
	get_tree().quit()
