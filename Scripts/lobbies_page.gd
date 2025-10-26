extends Control

const LobbyRowScene := preload(Scenes.PATH.LOBBY_ROW)

@onready var _lobbies_list := $List
@onready var _refresh_btn := $RefreshBtn

var _rows := []

func _ready() -> void:
	ApiManager.lobbies_received.connect(_on_lobbies_received)
	ApiManager.lobby_joined.connect(_on_lobby_joined)
	ApiManager.get_lobbies()
	_refresh_btn.pressed.connect(_on_refresh_btn_pressed)

func _on_refresh_btn_pressed() -> void:
	for row in _rows:
		row.queue_free()
	_rows.clear()
	ApiManager.get_lobbies()

func _on_lobbies_received(lobbies: Array) -> void:
	for lobby in lobbies:
		var lobby_row = LobbyRowScene.instantiate()
		_rows.append(lobby_row)
		_lobbies_list.add_child(lobby_row)
		lobby_row.lobby_id = lobby["id"]

func _on_lobby_joined() -> void:
	get_tree().change_scene_to_file(Scenes.PATH.LOBBY_PAGE)
