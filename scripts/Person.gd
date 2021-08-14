extends Area2D

signal bye_bye
signal entered_taxi
onready var spritesheet = preload("res://sprites/lowrezjam/people_sheet.png")
onready var speech_bubble = $SpeechBubble

var is_taxi_in_range : bool = false
var is_taxi_in_hail_range : bool = false
var can_enter_taxi : bool = true
var is_at_destination : bool = false
onready var taxi : Taxi = $"../Car"
var destination_distance_threshold : float = 128
var distance_to_destination : float = 0

func _ready():
	set_physics_process(false)
	create_graphic()
	#warning-ignore:RETURN_VALUE_DISCARDED
	taxi.connect("picked_up_passenger", self, "hail_taxi", [true])
	#warning-ignore:RETURN_VALUE_DISCARDED
	taxi.connect("dropped_off_passenger", self, "on_taxi_dropped_off_passenger")

func create_graphic():
	var img = AtlasTexture.new()
	img.atlas = spritesheet
	var img_region = Rect2(Vector2(int(stepify(rand_range(0,12),3)),int(rand_range(0, 15))), Vector2(3,1))
	img.region = img_region
	$Sprite.texture = img

func _physics_process(_delta):
	if is_taxi_in_range && can_enter_taxi:
		if !taxi.is_moving && !taxi.has_passenger:
			enter_taxi()

func enter_taxi():
	can_enter_taxi = false
	taxi.set_destination_and_passenger(select_destination(), self)
	hide()
	emit_signal("entered_taxi", global_position)

func select_destination()-> Vector2:
	randomize()
	var destinations = $"../Destinations"
	var destination = destinations.get_child(rand_range(0, destinations.get_child_count())).global_position
	distance_to_destination = global_position.distance_to(destination)
	while distance_to_destination < destination_distance_threshold:
		destination = destinations.get_child(rand_range(0,destinations.get_child_count())).global_position
		distance_to_destination = global_position.distance_to(destination)
	return destination

func arrived_at_destination(d):
	global_position = d
	is_at_destination = true
	show()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		is_taxi_in_range = true
		set_physics_process(true)


func _on_body_exited(body):
	if body.is_in_group("Player"):
		is_taxi_in_range = false
		set_physics_process(false)


func _on_screen_exited():
	if is_at_destination:
		emit_signal("bye_bye")
		queue_free()


func hail_taxi(hide = false):
	if can_enter_taxi && !taxi.has_passenger:
		speech_bubble.show()
	if hide:
		speech_bubble.hide()


func _on_HailTaxiArea_body_entered(body):
	if body.is_in_group("Player"):
		is_taxi_in_hail_range = true
		hail_taxi()


func _on_HailTaxiArea_body_exited(body):
	if body.is_in_group("Player"):
		is_taxi_in_hail_range = false
		hail_taxi(true)

func on_taxi_dropped_off_passenger():
	if is_taxi_in_hail_range:
		hail_taxi()
