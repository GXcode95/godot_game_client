extends HBoxContainer

@onready var _lobby_name := $LobbyName
@onready var _join_btn := $JoinBtn

var _lobby_id: int

var lobby_id:
	get: return _lobby_id
	set(value):
		_lobby_id = value
		_lobby_name.text = "Lobby #" + str(value)

func _ready() -> void:
	_join_btn.pressed.connect(_on_join_btn_pressed)
	
func _on_join_btn_pressed() -> void:
	ApiManager.join_lobby(_lobby_id)
