extends Control
class_name MainMenu

@onready var play_button := $Buttons/PlayButton
@onready var quit_button := $Buttons/QuitButton
@onready var title_label := $TitleLabel

func _ready():
	play_button.pressed.connect(_on_play_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	if not AuthManager.connected:
		call_deferred("_go_to_auth_page")
	else:
		title_label.text = "Bienvenue %s" % AuthManager.user.get("nickname", "")


func _on_play_button_pressed():
	get_tree().change_scene_to_file(Scenes.PATH.GAME)

func _on_quit_button_pressed():
	get_tree().quit()
	
func _go_to_auth_page():
	get_tree().change_scene_to_file(Scenes.PATH.AUTH)
