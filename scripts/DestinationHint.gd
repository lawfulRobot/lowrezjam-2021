extends Area2D

var start_position : Vector2
onready var taxi : Taxi = $"../Car"

func _ready():
	start_position = global_position
	set_physics_process(false)
	#warning-ignore:RETURN_VALUE_DISCARDED
	taxi.connect("dropped_off_passenger", self, "on_taxi_dropped_off_passenger")

func _physics_process(_delta):
	if !taxi.is_moving:
		taxi.arrived_at_destination()
		global_position = start_position
		set_physics_process(false)

func on_taxi_dropped_off_passenger():
	hide()

func _onbody_entered(body):
	if body.is_in_group("Player"):
		set_physics_process(true)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		set_physics_process(false)
