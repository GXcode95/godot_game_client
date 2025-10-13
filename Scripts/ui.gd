extends CanvasLayer
class_name UI

@onready var name_label = $CharacterInfoPanel/NameLabel
@onready var hp_label = $CharacterInfoPanel/HpBar/HpLabel
@onready var hp_bar = $CharacterInfoPanel/HpBar
@onready var movements_label = $CharacterInfoPanel/Movements/Value
@onready var attack_btn = $CharacterInfoPanel/Container/Button
@onready var end_turn_btn = $CharacterInfoPanel/Container/Button2
@onready var log_panel_text = $LogPanel/RichTextLabel

signal attack_btn_pressed()
signal end_turn_btn_pressed()

func _ready():
	print("UI ready")
	LogManager.log_updated.connect(_on_log_updated)
	attack_btn.pressed.connect(_on_attack_btn_pressed)
	end_turn_btn.pressed.connect(_on_end_turn_btn_pressed)
	
# ----------------------
# -- SIGNALS HANDLERS --
# ----------------------

func _on_end_turn_btn_pressed():
	print("End turn button pressed")
	emit_signal("end_turn_btn_pressed")

func _on_attack_btn_pressed():
	print("Attack button pressed")
	emit_signal("attack_btn_pressed")

func on_turn_started(character: Character):
	update_character_info(character)

func _on_log_updated(new_entry: String):
	log_panel_text.text += new_entry + "\n"
# ------------
# -- UPDATE --
# ------------

func update_character_info(character: Character):
	name_label.text = character.job_name
	hp_label.text = str(character.hp) + "/" + str(character.max_hp)
	hp_bar.value = character.hp
	movements_label.text = str(character.movements)
