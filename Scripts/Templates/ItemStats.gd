extends Resource

class_name ItemResource

export var name : String
export var stackable : bool = false
export var max_count : int = 1

enum ItemType {
	USABLE, 
	CONSUMABLE, 
	DUNGEON_ITEM,
	}
export(ItemType) var type

export(String, MULTILINE) var description = "Enter notes of item description here"

export var texture : Texture
