extends Node2D

func _on_PlayButton_pressed():
	#warning-ignore:RETURN_VALUE_DISCARDED
	get_tree().change_scene("res://scenes/Node2D.tscn")
