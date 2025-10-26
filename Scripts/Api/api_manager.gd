# Autoloaded
extends Node

const BASE_URL := "http://localhost:3000/api/v1"

signal lobbies_received(lobbies: Array)
signal lobby_received(lobby: Dictionary, host: Dictionary, guest: Dictionary)
signal lobby_created(lobby: Dictionary)
signal lobby_joined()

# -----------------------
# -- LOBBIES REQUESTS --
# -----------------------

# -- GET LOBBIES [INDEX] --
func get_lobbies() -> void:
	var http := HTTPRequest.new()
	add_child(http)
	var token = AuthManager.bearer_token
	var headers = [
		"Content-Type: application/json",
		"Authorization: %s" % token
	]
	http.request(BASE_URL + "/lobbies", headers, HTTPClient.METHOD_GET)
	http.request_completed.connect(_on_get_lobbies_response)

func _on_get_lobbies_response(result, response_code, _headers, body):
	var sucess = result == OK and response_code == 200
	var data = ApiHelper.parse_body(body)
	if sucess:		
		lobbies_received.emit(data.get("lobbies", []))
	else:
		_build_and_push_error(data, response_code, "Failed to get lobbies")

# -- GET LOBBY [SHOW] --
func get_lobby(lobby_id: int) -> void:
	var http := HTTPRequest.new()
	add_child(http)
	var token = AuthManager.bearer_token
	var headers = [
		"Content-Type: application/json",
		"Authorization: %s" % token
	]
	http.request(BASE_URL + "/lobbies/" + str(lobby_id), headers, HTTPClient.METHOD_GET)
	http.request_completed.connect(_on_get_lobby_response)

func _on_get_lobby_response(result, response_code, _headers, body):
	var sucess = result == OK and response_code == 200
	var data = ApiHelper.parse_body(body)
	if sucess:
		var lobby = data.get("lobby", {})
		if lobby.get("guest", null) == null:
			lobby["guest"] = {}
		emit_signal("lobby_received", lobby)
	else:
		_build_and_push_error(data, response_code, "Failed to get lobby")

# -- CREATE LOBBY [CREATE] --
func create_lobby() -> void:
	var http := HTTPRequest.new()
	add_child(http)
	var token = AuthManager.bearer_token
	var headers = [
		"Content-Type: application/json",
		"Authorization: %s" % token
	]
	var body = {
		"lobby": {
			"host_id": AuthManager.user["id"]
		}
	}
	http.request(
		BASE_URL + "/lobbies",
		headers,
		HTTPClient.METHOD_POST,
		JSON.stringify(body)
	)
	http.request_completed.connect(_on_create_lobby_response)

func _on_create_lobby_response(result, response_code, _headers, body):
	var sucess = result == OK and response_code == 201
	var data = ApiHelper.parse_body(body)
	if sucess:
		AuthManager.user["lobby_id"] = data.get("lobby", {}).get("id")
		emit_signal("lobby_created")
	else:
		_build_and_push_error(data, response_code, "Failed to create lobby")
		
# -- JOIN LOBBY [UPDATE] --
func join_lobby(lobby_id: int) -> void:
	var http := HTTPRequest.new()
	add_child(http)
	var token = AuthManager.bearer_token
	var headers = [
		"Content-Type: application/json",
		"Authorization: %s" % token
	]
	var body = {
		"lobby": {
			"guest_id": AuthManager.user["id"]
		}
	}
	http.request(
		BASE_URL + "/lobbies/" + str(lobby_id),
		headers,
		HTTPClient.METHOD_PATCH,
		JSON.stringify(body)
	)
	http.request_completed.connect(_on_join_lobby_response)
	
func _on_join_lobby_response(result, response_code, _headers, body):
	var sucess = result == OK and response_code == 200
	var data = ApiHelper.parse_body(body)
	if sucess:
		AuthManager.user["lobby_id"] = data.get("lobby", {}).get("id")
		emit_signal("lobby_joined")
	else:
		_build_and_push_error(data, response_code, "Failed to join lobby")

# -------------
# -- HELPERS --
# -------------
func _build_and_push_error(data: Dictionary, response_code: int, message: String) -> void:
	var errors = data.get("errors", [])
	push_error(message + " " + str(response_code) + "\n" + str(errors))