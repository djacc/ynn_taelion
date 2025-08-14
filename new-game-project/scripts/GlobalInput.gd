extends Node

func _input(event):
	if event.is_action_pressed("cancel"):
		get_tree().quit()
	elif event.is_action_pressed("reload"):
		get_tree().reload_current_scene() 
