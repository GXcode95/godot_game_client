extends Control
class_name MainMenu


@onready var create_lobby_button := $Buttons/CreateLobbyBtn
@onready var lobbies_button := $Buttons/LobbiesBtn
@onready var quit_button := $QuitBtn
@onready var title_label := $TitleLabel

func _ready():
	create_lobby_button.pressed.connect(_on_create_lobby_button_pressed)
	lobbies_button.pressed.connect(_on_lobbies_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)
	if not AuthManager.connected:
		call_deferred("_go_to_auth_page")
	else:
		title_label.text = "Bienvenue %s" % AuthManager.user.get("nickname", "")
		ApiManager.lobby_created.connect(_on_lobby_created)


func _on_create_lobby_button_pressed():
	ApiManager.create_lobby()
	
func _on_lobbies_button_pressed():
	get_tree().change_scene_to_file(Scenes.PATH.LOBBIES)

func _on_quit_button_pressed():
	get_tree().quit()
	
func _go_to_auth_page():
	get_tree().change_scene_to_file(Scenes.PATH.AUTH)

func _on_lobby_created():
	get_tree().change_scene_to_file(Scenes.PATH.LOBBY_PAGE)