extends ColorRect

func _input(_event):
	if Input.is_action_just_pressed("open_menu"):
		$Control.play_tweens()
