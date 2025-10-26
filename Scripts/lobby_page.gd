extends Control

@onready var _host_label := $VBox/HostLabel
@onready var _guest_label := $VBox/GuestLabel
@onready var _start_btn := $StartBtn

var _host := {}
var _guest := {}

var host:
	get: return _host
	set(value):
		_host = value
		_host_label.text = "Player 1: %s" % _host.get("nickname")

var guest:
	get: return _guest
	set(value):
		_guest = value
		_guest_label.text = "Player 2: %s" % value.get("nickname", "En attente ...")
		_start_btn.visible = true

func _ready() -> void:
	ApiManager.get_lobby(AuthManager.user["lobby_id"])
	ApiManager.lobby_received.connect(_on_lobby_received)
	_start_btn.pressed.connect(_on_start_btn_pressed)
	
	
	
	var lobby_ws := LobbyWS.new()
	add_child(lobby_ws)
	lobby_ws.connect_to_lobby(AuthManager.user["lobby_id"])
	lobby_ws.lobby_received.connect(_on_lobby_received)
	lobby_ws.lobby_playing.connect(_on_lobby_playing)

func _on_lobby_received(lobby: Dictionary) -> void:
	host = lobby.get("host", {})
	guest = lobby.get("guest", {})
	
func _on_start_btn_pressed() -> void:
	ApiManager.play_lobby(AuthManager.user["lobby_id"])
	
func _on_lobby_playing() -> void:
	get_tree().change_scene_to_file(Scenes.PATH.GAME)
