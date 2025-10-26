extends Node
class_name LobbyWS

const URL := "ws://127.0.0.1:3000/cable"

var _ws := WebSocketPeer.new()
var lobby_id: int

signal lobby_received(lobby: Dictionary)
signal connected
signal disconnected
signal lobby_playing

func connect_to_lobby(lobby_id_: int) -> void:
	lobby_id = lobby_id_
	
	var result = _ws.connect_to_url(URL)
	if result != OK:
		push_error("Failed to connect to WebSocket: %s" % result)
	else:
		print("Attempting to connect to WebSocket…")

func disconnect_ws() -> void:
	if _ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		_ws.close()
		print("Closing WebSocket")

# called automatically by Godot if ws is added to scene tree
func _process(_delta: float) -> void:
	_ws.poll()
	if _ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		_on_data()

func _on_data() -> void:
	while _ws.get_available_packet_count() > 0:
		var pkt = _ws.get_packet().get_string_from_utf8()
		var parsed = ApiHelper._fix_numbers(JSON.parse_string(pkt))

		if parsed == null:
			print("Can't parse packet: ", pkt)
			continue

		if parsed.has("type"):
			_handle_action_cable_type(parsed)
		elif parsed.has("identifier") and parsed.has("message"):
			match parsed["message"].get("event", ""):
				"playing":
					emit_signal("lobby_playing")
				"updated":
					var lobby_str = parsed["message"].get("lobby")
					print("=================== updated: ", lobby_str)
					var lobby = ApiHelper._fix_numbers(JSON.parse_string(lobby_str))
					emit_signal("lobby_received", lobby)
					

func _handle_action_cable_type(parsed: Dictionary) -> void:
	var type = parsed.get("type", "")
	match type:
		"welcome":
			print("Connected to WebSocket (welcome)")
			emit_signal("connected")
			# Subscribe to channel after welcome
			var identifier = {"channel": "LobbyChannel", "id": lobby_id}
			var msg = {
				"command": "subscribe",
				"identifier": JSON.stringify(identifier)
			}
			_ws.send_text(JSON.stringify(msg))
		"ping":
			pass
		"confirm_subscription":
			print("Subscription confirmed to channel: ", parsed.get("identifier", ""))
		"disconnect":
			print("Disconnected from WebSocket by server")
			emit_signal("disconnected")
		_:
			# Other types not explicitly handled
			pass
