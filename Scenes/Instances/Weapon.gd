extends Area2D

signal attack_finished

enum weapon_types {
	SWORD,
	PICKAXE,
	HAMMER,
	BOW
}
export(weapon_types) var weapon = weapon_types.SWORD

var orig_rot

func use_item():

	$AnimationPlayer.play("SwordSwing")
	pass


func _on_AnimationPlayer_animation_finished(_anim_name):
	$WeaponSprites.rotation_degrees = 45.0
	emit_signal("attack_finished")
	pass
