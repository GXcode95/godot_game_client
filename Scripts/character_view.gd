extends Node2D
class_name CharacterView

const ANIMATION_TYPE := Enums.ANIMATION_TYPE
const ORIENTATION := Enums.ORIENTATION

@onready var _animation_player: AnimationPlayer = $CharacterAnimationPlayer
@onready var _animation_sprites := {
	ANIMATION_TYPE.IDLE_UP_LEFT: $IdleUpLeft,
	ANIMATION_TYPE.IDLE_UP_RIGHT: $IdleUpRight,
	ANIMATION_TYPE.IDLE_DOWN_RIGHT: $IdleDownRight,
	ANIMATION_TYPE.IDLE_DOWN_LEFT: $IdleDownLeft,
	ANIMATION_TYPE.WALK_UP_LEFT: $WalkUpLeft,
	ANIMATION_TYPE.WALK_UP_RIGHT: $WalkUpRight,
	ANIMATION_TYPE.WALK_DOWN_RIGHT: $WalkDownRight,
	ANIMATION_TYPE.WALK_DOWN_LEFT: $WalkDownLeft,
}
@onready var _animation_names := {
	ANIMATION_TYPE.IDLE_UP_LEFT: "idle_up_left",
	ANIMATION_TYPE.IDLE_UP_RIGHT: "idle_up_right",
	ANIMATION_TYPE.IDLE_DOWN_RIGHT: "idle_down_right",
	ANIMATION_TYPE.IDLE_DOWN_LEFT: "idle_down_left",
	ANIMATION_TYPE.WALK_UP_LEFT: "walk_up_left",
	ANIMATION_TYPE.WALK_UP_RIGHT: "walk_up_right",
	ANIMATION_TYPE.WALK_DOWN_RIGHT: "walk_down_right",
	ANIMATION_TYPE.WALK_DOWN_LEFT: "walk_down_left",
}

# --------------------
# -- INITIALIZATION --
# --------------------

#func _ready():

func connect_to_character(character: Character):
	character.animation_changed.connect(_play_animation)
	character.stopped.connect(_stop_and_idle)

# ----------------
# -- ANIMATIONS --
# ----------------

func _hide_all_sprites():
	for sprite in _animation_sprites.values():
		sprite.visible = false

func _play_animation(animation_type: int):
	_hide_all_sprites()
	if _animation_sprites.has(animation_type):
		var sprite = _animation_sprites[animation_type]
		sprite.visible = true
		_animation_player.play(_animation_names[animation_type])

func _stop_and_idle(orientation: int):
	_animation_player.stop()
	_hide_all_sprites()

	match orientation:
		ORIENTATION.DOWN_LEFT: _animation_sprites[ANIMATION_TYPE.IDLE_DOWN_LEFT].visible = true
		ORIENTATION.DOWN_RIGHT: _animation_sprites[ANIMATION_TYPE.IDLE_DOWN_RIGHT].visible = true
		ORIENTATION.UP_LEFT: _animation_sprites[ANIMATION_TYPE.IDLE_UP_LEFT].visible = true
		ORIENTATION.UP_RIGHT: _animation_sprites[ANIMATION_TYPE.IDLE_UP_RIGHT].visible = true
