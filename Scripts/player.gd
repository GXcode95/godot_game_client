extends Node
class_name Player

var nickname: String
var characters: Array[Character] = []

func _init(p_nickname: String):
  nickname = p_nickname

func add_character(character: Character) -> void:
  characters.append(character)

func remove_character(character: Character) -> void:
  characters.erase(character)

func has_characters() -> bool:
  return characters.size() > 0