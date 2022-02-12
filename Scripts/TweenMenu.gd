#Tweening menu script written by Peter Rowe @playerpeter1231

extends Control

# Menu variables
export(String, MULTILINE) var paused_text
export(String) var open_key_name
export(bool) var pauses_game
export(bool) var controllable
var tweens_playing = false
var menu_open = false


# Tween variables. 

# step_names are the corresponding Node Properties lined up with the coord values
export(Array,String) var step_names
# all_steps is a 2d array of EVERY coordinate on the variables change
export(Array,Array,float) var all_steps
# step_durations are the times each tween takes. First value always needs to be 0
export(Array,float) var step_durations
# Where the TweenBox Tween is located in the node tree
export(NodePath) var tween_path
onready var tween_node = get_node(tween_path)
# Easy pickable translation and ease values
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
export(Array,trans) var trans_names

enum eases{
	EASE_IN = 0,
	EASE_OUT = 1,
	EASE_IN_OUT = 2,
	EASE_OUT_IN = 3
	} 
export(Array,eases) var ease_names
# Mark true if the Tween needs to be reversed every following play_tweens()
export var reversable = true


#Menu functions
func _ready():
	if not open_key_name:
		controllable = false
	
	$MenuText.text = paused_text


func _unhandled_input(_event):
	# Pause or unpause the SceneTree based on whether the button is
	# toggled on or off.
	if controllable:
		if Input.is_action_just_pressed(open_key_name):
			open_menu()
		

func open_menu():
	if not tweens_playing:
		visible = true
		if not tweens_playing:
			menu_open = !menu_open
			if pauses_game:
				GameManager.paused_state = true
			tweens_playing = true
			play_tweens()


func _on_Tween_tween_all_completed():
	if not menu_open:
		GameManager.paused_state = false
		visible = false
	tweens_playing = false

# Tween functions
func play_tweens():
	if not tween_node.is_active():
		unwrap_tween_data(all_steps, reversable)
		tween_node.start()

# Function for containing all tween function calls. Is passed tween node tween_name
#  and all steps to be loaded in array called tween_values
func unwrap_tween_data(all_tween_values, backwards):
	# Load each a tween command for every set of variables in the array
	for index in range(all_tween_values.size()):
		load_tween_values(all_tween_values[index], step_names[index])
	
	# Invert at end of iteration
	if backwards:
		for a in all_tween_values:
			a.invert()
		trans_names.invert()
		ease_names.invert()
		# Little extra work to make sure 0 stays in front without cpu effort
		step_durations.push_back(0)
		step_durations.invert()
		step_durations.pop_back()


# Function that loads tweens with tween_name, tween_value array,
#  and backwards bool for direction. If fresh tween, needs tween cleared
#  before being called the first time. Uses string value_name to choose node property
func load_tween_values(tween_values, value_name):
	# Print command for testing purposes
	#print(value_name)
	
	var cumulative_delay = 0
	# Save value_len for comparing index so loop doesn't iterate past end of array
	var tween_value_len = len(tween_values) - 1
	for index in tween_values.size():
		# Increases delay each iteration to time each step correctly
		cumulative_delay += step_durations[index]
		
		if index != tween_value_len:
			# If values are duplicates, than no need to make a tween command
			if tween_values[index] != tween_values[index+1]:
				# Print command that will read off entire tween command for testing
				#print(value_name,tween_values[index]," ",tween_values[index+1],
				#" ",step_durations[index]," ",step_durations[index-1])
				
				tween_node.interpolate_property(
					self,
					value_name,
					tween_values[index],
					tween_values[index+1],
					step_durations[index+1],
					trans_names[index],
					ease_names[index],
					cumulative_delay)

func _on_RestartLevel_button_up():
	print("Restarting level")
	GameManager.paused_state = false
	GameManager.curr_health = GameManager.max_health
	get_tree().reload_current_scene()


func _on_ReturnMenu_button_up():
	pass # Replace with function body.
