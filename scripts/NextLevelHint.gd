extends Area2D

export var required_balance_for_next_level = 500
var is_next_level_unlocked : bool = false

func _ready():
	#warning-ignore:RETURN_VALUE_DISCARDED
	$"../Car".connect("received_payment", self, "on_received_payment")
	$Label.text = "%s$ required\nto unlock" % required_balance_for_next_level

func on_received_payment(_amt, balance):
	if !is_next_level_unlocked:
		if balance >= required_balance_for_next_level:
			$Pointer.show()
			is_next_level_unlocked = true

func _on_body_entered(body):
	if body.is_in_group("Player") && is_next_level_unlocked:
		#warning-ignore:RETURN_VALUE_DISCARDED
		get_tree().change_scene("res://scenes/Level2.tscn")
