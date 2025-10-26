# Autoloaded
extends Node

var client := WebSocketMultiplayerPeer.new()
var connected: bool = false
var server_address: String = "ws://127.0.0.1:8080"

signal server_pong(data: Dictionary)

func _ready() -> void:
	print("NetworkClient ready")
	connect_to_server()
	await get_tree().create_timer(1.0).timeout
	send_message({"action":"ping"})

# -----------------------
# -- SERVER CONNECTION --
# -----------------------

func connect_to_server() -> void:
	var err = client.create_client(server_address)
	if err != OK:
		push_error("Failed to connect to server at %s" % server_address)
	return

	print("Connecting to server...")

# --------------------
# -- SEND TO SERVER --
# --------------------

func send_message(data: Dictionary) -> void:
	if client.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		var json_text = JSON.stringify(data)
		client.put_packet(json_text.to_utf8_buffer())
		print("Sent: ", json_text)
	else:
		print("Not connected, cannot send")

# --------------------
# -- PROCESS LOOP --
# --------------------

func _process(_delta: float) -> void:
	client.poll()

	match client.get_connection_status():
		MultiplayerPeer.CONNECTION_CONNECTING:
			pass
		MultiplayerPeer.CONNECTION_CONNECTED:
			if not connected:
				connected = true
				print("Connected to server")
		MultiplayerPeer.CONNECTION_DISCONNECTED:
			if connected:
				connected = false
				print("Disconnected from server")

	while client.get_available_packet_count() > 0:
		var packet = client.get_packet().get_string_from_utf8()
		var data = JSON.parse_string(packet)
		print("Received from server: ", data)
		if typeof(data) == TYPE_DICTIONARY and data.has("action"):
			_handle_action(data)

# ------------------
# -- SEND TO GAME --
# ------------------

func _handle_action(data: Dictionary) -> void:
	match data["action"]:
		"pong":
			print("PONG received from server: ", data)
			emit_signal("server_pong", data)
		_:
			print("Unknown action: ", data["action"])
