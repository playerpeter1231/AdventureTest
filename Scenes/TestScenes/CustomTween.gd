#Tweening script written by Peter Rowe @playerpeter1231

extends Control

export(Array,Array,float) var all_steps
export(Array,String) var step_names
export(Array,float) var step_durations
export(NodePath) var tween_path
onready var tween_node = get_node(tween_path)
enum trans{
	TRANS_LINEAR = 0,
	TRANS_SINE = 1,
	TRANS_QUINT = 2,
	TRANS_QUART = 3,
	TRANS_QUAD = 4,
	TRANS_EXPO = 5,
	TRANS_ELASTIC = 6,
	TRANS_CUBIC = 7,
	TRANS_CIRC = 8,
	TRANS_BOUNCE = 9,
	TRANS_BACK = 10
	}
export(trans) var trans_name

enum eases{
	EASE_IN = 0,
	EASE_OUT = 1,
	EASE_IN_OUT = 2,
	EASE_OUT_IN = 3
	} 
export(eases) var ease_name

export var reversable = true


func _ready():
	if reversable:
		for i in all_steps:
			i = i.invert()


func play_tweens():
	unwrap_tween_data(all_steps, reversable)
	tween_node.start()

# Function for containing all tween function calls. Is passed tween node tween_name
#  and all steps to be loaded in array called tween_values
func unwrap_tween_data(all_tween_values, backwards):
	if backwards:
		for a in all_tween_values:
			a = a.invert()
	
	for index in range(all_tween_values.size()):
		load_tween_values(all_tween_values[index], step_names[index])


# Function that loads tweens with tween_name, tween_value array,
#  and backwards bool for direction. If fresh tween, needs tween cleared
#  before being called the first time. Uses string value_name to choose node property
func load_tween_values(tween_values, value_name):
	#print(value_name)
	var tween_value_len = len(tween_values) - 1
	for index in tween_values.size():
		if index != tween_value_len:
			if tween_values[index] != tween_values[index+1]:
				#print(value_name,tween_values[index]," ",tween_values[index+1],
				#" ",step_durations[index]," ",step_durations[index-1])
				tween_node.interpolate_property(
					self,
					value_name,
					tween_values[index],
					tween_values[index+1],
					step_durations[index+1],
					trans_name,
					ease_name,
					step_durations[index])
	pass
