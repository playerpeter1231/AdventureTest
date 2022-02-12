extends Node

export var paused_state = false
export var max_health = 3
export var curr_health : int

func _ready():
	curr_health = max_health
