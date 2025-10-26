extends Node

func handle_action(client_id: int, data: Dictionary) -> Dictionary:
  match data.get("action", ""):
    "ping":
      return {"event": "pong", "from": client_id}
    "join_lobby":
      return {"event": "joined", "lobby_id": 1, "player_id": client_id}
    _:
      return {"error": "unknown_action", "data": data}