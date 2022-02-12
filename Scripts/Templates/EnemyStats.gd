extends Resource

class_name EnemyResource

export var name : String
export var hp : int
export var damage : int
export var poisons : bool
enum attacks {
	NONE,
	SWORD,
	STAFF,
}
export(attacks) var attack_type

export var multi_directional : bool
export var sprite_frames : SpriteFrames
export(String, MULTILINE) var description = "Enter notes of item description here"
