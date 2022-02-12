extends KinematicBody2D
# signal hit

# Speed of character to next cell (pixels / second)
export var speed = 150
# Current screen size
var screen_size
# Current character direction name and which order pressed
var mov_last = "Walk_Down"
var mov_order = []

# Hurt animation variables
export(NodePath) var animation_node_path
onready var anim_node = get_node(animation_node_path)
onready var hurt_anim = anim_node.get_animation("Hurt")
onready var hurt_anim_idx = hurt_anim.find_track(".:animation")
var hurt_name

var weapon_rot = 180.0
var attacking = false
var attack_dir = "Attack_Down"

export(NodePath) var game_over_menu_path
var game_over_menu

enum p_states {
	MOVE,
	HURT,
	DEAD,
}
var play_state = p_states.MOVE

func _ready():
	screen_size = get_viewport_rect().size
	
	$AnimatedSprite.animation = "Walk_Down"
	$AnimatedSprite.stop()
	
	if game_over_menu_path:
		game_over_menu = get_node(game_over_menu_path)


func _process(delta):
	if not GameManager.paused_state:
		match play_state:
			p_states.MOVE:
				process_movement(delta)
			p_states.HURT:
				pass
			p_states.DEAD:
				pass
	else:
		$AnimatedSprite.stop()
		mov_order = []


func process_movement(delta):
	var velocity = Vector2.ZERO
	#var target_cell = Vector2.ZERO
	
	if Input.is_action_just_released("hold_direction"):
		mov_order = []
	
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
		if not mov_order.has("Walk_Up"):
			mov_order.append("Walk_Up")
		
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
		if not mov_order.has("Walk_Down"):
			mov_order.append("Walk_Down")
		
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
		if not mov_order.has("Walk_Right"):
			mov_order.append("Walk_Right")
		
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
		if not mov_order.has("Walk_Left"):
			mov_order.append("Walk_Left")
	
	if Input.is_action_just_pressed("hold_direction") and mov_order.size() == 0:
		mov_order.append(mov_last)
	
	if not Input.is_action_pressed("hold_direction"):
		if Input.is_action_just_released("move_up"):
			mov_order.erase("Walk_Up")
			mov_last = "Walk_Up"
			
		if Input.is_action_just_released("move_down"):
			mov_order.erase("Walk_Down")
			mov_last = "Walk_Down"
			
		if Input.is_action_just_released("move_right"):
			mov_order.erase("Walk_Right")
			mov_last = "Walk_Right"
			
		if Input.is_action_just_released("move_left"):
			mov_order.erase("Walk_Left")
			mov_last = "Walk_Left"


	
	if Input.is_action_just_pressed("use_item"):
		$Weapon.use_item()
		if not attacking:
			attacking = true
			$AnimatedSprite.animation = attack_dir
			$AnimatedSprite.play()
	
	#print(mov_order)
	# Check if moving for animation
	if velocity.length() > 0:
		$Weapon.scale.y = 0.85
		
		match mov_order[0]:
			"Walk_Up":
				$Weapon.rotation_degrees = 0.0
				attack_dir = "Attack_Up"
			"Walk_Down":
				$Weapon.rotation_degrees = 180.0
				attack_dir = "Attack_Down"
			"Walk_Right":
				$Weapon.rotation_degrees = 90.0
				attack_dir = "Attack_Right"
			"Walk_Left":
				$Weapon.rotation_degrees = 90.0
				$Weapon.scale.y = -0.85
				attack_dir = "Attack_Left"
				
		if not attacking:
			velocity = velocity.normalized() * speed
			velocity = move_and_slide(velocity*delta*speed)
			$AnimatedSprite.animation = mov_order[0]
			$AnimatedSprite.play()

	else:
		if not attacking:
			$AnimatedSprite.frame = 0
			$AnimatedSprite.stop()
	
	
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)


func _on_Hitbox_body_entered(body):
	if "enemy_stat_block" in body:
		var enemy_stats = body.enemy_stat_block
		GameManager.curr_health -= enemy_stats.damage
		
		if GameManager.curr_health > 0:
			match mov_last:
				"Walk_Up":
					hurt_name = "Hurt_Up"
				"Walk_Right":
					hurt_name = "Hurt_Right"
				"Walk_Down":
					hurt_name = "Hurt_Down"
				"Walk_Left":
					hurt_name = "Hurt_Left"
			if hurt_anim_idx != -1:
				hurt_anim.track_set_key_value(hurt_anim_idx,0,hurt_name)
				hurt_anim.track_set_key_value(hurt_anim_idx,1,mov_last)
			
			anim_node.play("Hurt")
		
		else:
			play_state = p_states.DEAD
			anim_node.play("Death")
			
	
	#print("Ouch! ", GameManager.curr_health)


func _on_Hitbox_body_exited(_body):
	pass # Replace with function body.


func _on_SpecialAnimations_animation_finished(anim_name):
	if anim_name == "Death" and game_over_menu:
		game_over_menu.open_menu()
	

func _on_Weapon_attack_finished():
	attacking = false
