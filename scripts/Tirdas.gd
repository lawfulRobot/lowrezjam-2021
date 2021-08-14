extends StaticBody2D

onready var taxi = $"../Car"
var is_taxi_in_range : bool = false

func _ready():
	set_physics_process(false)

func _physics_process(_delta):
	if is_taxi_in_range && taxi.has_passenger && !taxi.is_moving:
		taxi.arrived_at_destination()
		$AnimationPlayer.play("tirdas_fade_out")

func _on_body_entered(body):
	if body.is_in_group("Player"):
		is_taxi_in_range = true
		set_physics_process(true)

func _on_body_exited(body):
	if body.is_in_group("Player"):
		is_taxi_in_range = false
		set_physics_process(false)

func disable_collision():
	$Area2D/CollisionShape2D.disabled = true
	$CollisionShape2D.disabled = true

func delete():
	queue_free()
