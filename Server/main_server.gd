extends SceneTree

var server := WebSocketMultiplayerPeer.new()
var peer_ids: Array = []

func _initialize() -> void:
  var err = server.create_server(8080)
  if err != OK:
    push_error("Failed to start WebSocket server on port 8080")
    return
  print("WebSocket server running on port 8080")

  while true:
    server.poll()

    # check new packets
    while server.get_available_packet_count() > 0:
      var peer_id = server.get_packet_peer()
      var packet = server.get_packet()
      var text = packet.get_string_from_utf8()
      if not peer_ids.has(peer_id):
        peer_ids.append(peer_id)
        print("New peer added to list: ", peer_id)
      print("Received: ", text, " from peer ", peer_id)
      _on_message(text, peer_id)

    OS.delay_msec(50) # avoid 100% CPU

# ---------------------------
# -- MESSAGE HANDLER --
# ---------------------------

func _on_message(msg: String, from_peer: int) -> void:
  print("Handling message from ", from_peer, ": ", msg)

  var parsed = JSON.parse_string(msg)
  if typeof(parsed) == TYPE_DICTIONARY and parsed.has("action"):
    match parsed["action"]:
      "ping":
        print("PING action")
        var response = {
          "action": "pong",
          "msg": "Hello from server!"
        }
        _send_to_peer(response, from_peer)
      _:
        print("Unknown action: ", parsed["action"])

# -----------------------
# -- SEND TO PEERS --
# -----------------------

func _send_to_peer(response: Dictionary, peer_id: int) -> void:
  if not peer_ids.has(peer_id):
    print("Peer ", peer_id, " not in peer_ids, skipping send")
    return
  var msg_bytes = JSON.stringify(response).to_utf8_buffer()
  server.set_target_peer(peer_id)
  var err = server.put_packet(msg_bytes)
  if err != OK:
    push_error("Failed to send to peer %s, err=%s" % [peer_id, err])
  else:
    print("Sent to peer ", peer_id, ": ", response)

func _broadcast_to_all(response: Dictionary) -> void:
  for pid in peer_ids:
    _send_to_peer(response, pid)