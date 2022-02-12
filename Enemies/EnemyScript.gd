extends KinematicBody2D

onready var parent = get_parent()
export var movement_speed = 100
export (int) var detection_radius = 4.0
export(Resource) var enemy_stat_block
onready var max_health = enemy_stat_block.hp
onready var curr_health = max_health

enum enemy_states {
	PATROL,
	CHASE,
	ATTACK,
	DEAD
}
var enemy_state = enemy_states.PATROL

var chase_target = null
var target_pos = null
#var velocity = Vector2(movement_speed,0)
var velocity = Vector2.ZERO


func _ready():
	var circle = CircleShape2D.new()
	$DetectionRange/CollisionShape2D.shape = circle
	$DetectionRange/CollisionShape2D.shape.radius = detection_radius

	

func _process(delta):
	if not GameManager.paused_state:
		velocity = Vector2.ZERO
		match enemy_state:
			
			enemy_states.DEAD:
				pass
			
			enemy_states.PATROL:
				if parent is PathFollow2D:
					parent.set_offset(parent.get_offset() + movement_speed * delta)
					position = Vector2()
				else:
					# Can be used for other forms of movement
					pass
			
			enemy_states.CHASE:
				#chase_target = target_pos.position
				velocity = (target_pos.position - global_position).normalized() * movement_speed
				velocity = move_and_slide(velocity)
			
			enemy_states.ATTACK:
				pass


func kill_enemy():
	queue_free()


func _on_DetectionRange_body_entered(body):
	if body.name == "Player":
		enemy_state = enemy_states.CHASE
		target_pos = body


func _on_DetectionRange_body_exited(body):
	if body.name == "Player":
		enemy_state = enemy_states.PATROL
		target_pos = null


func _on_Hitbox_area_entered(area):
	if area.name == "Weapon":
		print("You got me! ", curr_health)
		curr_health -= 1
		if curr_health < 0:
			kill_enemy()
