# Autoloaded
extends Node

const BASE_URL := "http://localhost:3000/api/v1"
var _bearer_token: String = ""
var _connected: bool = false

var connected:
	get: return _connected
	set(value): 
		_connected = value
		logged_in.emit()

var _user := {}

var user:
	get: return _user

var bearer_token:
	get: return _bearer_token

signal logged_in(bearer_token: String)

# --------------
# -- REQUESTS --
# --------------

func signup(email: String, password: String, nickname: String) -> void:
	var body = {
		"email": email,
		"password": password,
		"nickname": nickname
	}
	var http := _send_request("/auth", HTTPClient.METHOD_POST, body)
	http.request_completed.connect(_on_login_response)

func login(email: String, password: String) -> void:
	var body = {
		"email": email,
		"password": password
	}
	var http := _send_request("/auth/sign_in", HTTPClient.METHOD_POST, body)
	http.request_completed.connect(_on_login_response)

# -----------------------
# -- RESPONSE HANDLERS --
# -----------------------

func _on_login_response(result, response_code, headers, body):
	var d_headers = ApiHelper._headers_to_dict(headers)
	var	sucess = result == OK and (response_code == 200 || response_code == 201)
	if sucess:
		_bearer_token = d_headers["authorization"]
		_user = ApiHelper.parse_body(body).get("user", {})
		connected = true
	else:
		push_error("Login failed: ", result, response_code, headers, body)

# -----------
# -- UTILS --
# -----------

func _send_request(path: String, method: int, body: Dictionary = {}) -> HTTPRequest:
	var http := HTTPRequest.new()
	add_child(http)

	var headers = ["Content-Type: application/json"]
	if _bearer_token != "":
		headers.append("Authorization: %s" % _bearer_token)

	var json_body = JSON.stringify(body)
	http.request(BASE_URL + path, headers, method, json_body)
	return http
