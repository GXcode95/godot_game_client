extends Control

@onready var _host_label := $VBox/HostLabel
@onready var _guest_label := $VBox/GuestLabel

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


func _ready() -> void:
	ApiManager.get_lobby(AuthManager.user["lobby_id"])
	ApiManager.lobby_received.connect(_on_lobby_received)
	
	var lobby_ws := LobbyWS.new()
	add_child(lobby_ws)
	lobby_ws.connect_to_lobby(AuthManager.user["lobby_id"])
	lobby_ws.lobby_received.connect(_on_lobby_received)
	

func _on_lobby_received(lobby: Dictionary) -> void:
	host = lobby.get("host", {})
	guest = lobby.get("guest", {})
	