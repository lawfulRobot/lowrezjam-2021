extends Control

onready var label : Label = $Label
onready var animation_player : AnimationPlayer = $AnimationPlayer


func on_received_payment(amt, _total):
	label.text = "+%s$" % amt
	animation_player.play("upnout")
