extends Node
class_name Player

var nickname: String
var api_id: int
var characters: Array[Character] = []

func _init(nickname_: String, api_id_: int):
  nickname = nickname_
  api_id = api_id_

func add_character(character: Character) -> void:
  characters.append(character)

func remove_character(character: Character) -> void:
  characters.erase(character)

func has_characters() -> bool:
  return characters.size() > 0