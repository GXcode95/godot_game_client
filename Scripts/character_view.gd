extends Node2D
class_name CharacterView

@onready var _animation_player: AnimationPlayer = $CharacterAnimationPlayer
@onready var _animation_sprites := {
	Character.AnimationType.IDLE_UP_LEFT: $IdleUpLeft,
	Character.AnimationType.IDLE_UP_RIGHT: $IdleUpRight,
	Character.AnimationType.IDLE_DOWN_RIGHT: $IdleDownRight,
	Character.AnimationType.IDLE_DOWN_LEFT: $IdleDownLeft,
	Character.AnimationType.WALK_UP_LEFT: $WalkUpLeft,
	Character.AnimationType.WALK_UP_RIGHT: $WalkUpRight,
	Character.AnimationType.WALK_DOWN_RIGHT: $WalkDownRight,
	Character.AnimationType.WALK_DOWN_LEFT: $WalkDownLeft,
}
@onready var _animation_names := {
	Character.AnimationType.IDLE_UP_LEFT: "idle_up_left",
	Character.AnimationType.IDLE_UP_RIGHT: "idle_up_right",
	Character.AnimationType.IDLE_DOWN_RIGHT: "idle_down_right",
	Character.AnimationType.IDLE_DOWN_LEFT: "idle_down_left",
	Character.AnimationType.WALK_UP_LEFT: "walk_up_left",
	Character.AnimationType.WALK_UP_RIGHT: "walk_up_right",
	Character.AnimationType.WALK_DOWN_RIGHT: "walk_down_right",
	Character.AnimationType.WALK_DOWN_LEFT: "walk_down_left",
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
		Character.Orientation.DOWN_LEFT: _animation_sprites[Character.AnimationType.IDLE_DOWN_LEFT].visible = true
		Character.Orientation.DOWN_RIGHT: _animation_sprites[Character.AnimationType.IDLE_DOWN_RIGHT].visible = true
		Character.Orientation.UP_LEFT: _animation_sprites[Character.AnimationType.IDLE_UP_LEFT].visible = true
		Character.Orientation.UP_RIGHT: _animation_sprites[Character.AnimationType.IDLE_UP_RIGHT].visible = true
