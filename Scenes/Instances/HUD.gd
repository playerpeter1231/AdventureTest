extends Control

func _process(_delta):
	$CurrentHealth.text = "Health: " + str(GameManager.curr_health)
