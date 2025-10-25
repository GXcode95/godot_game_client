extends Control
class_name AuthPage

@onready var submit_button := $VBox/SubmitButton
@onready var swap_button := $VBox/SwapButton
@onready var swap_label := $VBox/SwapLabel
@onready var name_label := $VBox/NameLabel
@onready var name_input := $VBox/NameInput
@onready var email_input := $VBox/EmailInput
@onready var password_input := $VBox/PasswordInput

enum State {
	LOGIN,
	REGISTER
}

var state := State.REGISTER

func _ready():
	AuthManager.logged_in.connect(_on_logged_in)
	submit_button.pressed.connect(_on_submit)
	swap_button.pressed.connect(_on_swap_button_pressed)
	_swap_state()


func _swap_state():
	match state:
		State.LOGIN:
			state = State.REGISTER
			swap_label.text = "Déjà un compte ?"
			swap_button.text = "Se connecter"
			name_label.visible = true
			name_input.visible = true
		State.REGISTER:
			state = State.LOGIN
			swap_label.text = "Pas encore de compte ?"
			swap_button.text = "Créez-en un !"
			name_label.visible = false
			name_input.visible = false

func _on_swap_button_pressed():
	_swap_state()

func _on_submit():
	var email = email_input.text
	var password = password_input.text
	if email == "" or password == "":
		return
	if state == State.LOGIN:
		AuthManager.login(email, password)
	else:
		var nickname = name_input.text
		if nickname == "":
			return
		AuthManager.signup(email, password, nickname)

func _on_logged_in():
	print(AuthManager.user)
	get_tree().change_scene_to_file(Scenes.PATH.MAIN)
