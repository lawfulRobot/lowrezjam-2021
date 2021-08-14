extends KinematicBody2D
class_name Taxi

signal received_payment
signal picked_up_passenger
signal dropped_off_passenger

onready var destination_hint = $"../DestinationHint"
onready var animation_player = $AnimationPlayer
onready var payment_popup = $"../PaymentPopup"
onready var balance_label = $"../UI/BalanceLabel"
onready var tilemap = $"../LevelTileMap"

var max_speed : float = 35
var speed_damp : float = 0.0167
var speed : float = 0
var boost_mult : float = 1
var boost_duration : float = 1.9
var turn_rate : float = 2
var motion : Vector2 = Vector2(0,0)
var turn_inverter : int = 1
var is_moving : bool = false
var has_passenger : bool = false
var passenger = null
var destination : Vector2 = Vector2(0,0)
var balance : int = 0

var acceleration : float = 1
var wish_direction : float = 0


func _ready():
	#warning-ignore:RETURN_VALUE_DISCARDED
	connect("received_payment", payment_popup, "on_received_payment")
	#warning-ignore:RETURN_VALUE_DISCARDED
	connect("received_payment", balance_label, "on_received_payment")

func _physics_process(delta):
	wish_direction = lerp(wish_direction, Input.get_action_strength("brake") - Input.get_action_strength("accelerate"), delta * acceleration)
	# snap wish_direction to 0 which then causes motion to become 0,0 and
	# let is_moving become false which lets passengers enter and exit the car
	# I do this because lerp takes forever to get the number to 0 and also 
	# doesn't get it exactly 0 so the motion != Vector2.ZERO check doesn't work
	if abs(wish_direction) < 0.1 && Input.get_action_strength("brake") - Input.get_action_strength("accelerate") == 0:
		wish_direction = 0
	motion = transform.y
	speed = max_speed * wish_direction
	
	motion = (motion.normalized() * speed) * boost_mult
	if motion != Vector2.ZERO:
		is_moving = true
		#warning-ignore:NARROWING_CONVERSION
		turn_inverter = clamp(motion.dot(transform.y), -1, 1) * -1
		rotation_degrees += (turn_rate * (Input.get_action_strength("turnright") - Input.get_action_strength("turnleft"))) * turn_inverter * abs(wish_direction)
	else:
		is_moving = false
	
		
	var collision_info = move_and_collide(motion * speed_damp)
	if collision_info:
		wish_direction *= 0.5
#	motion = move_and_slide(motion)


func set_destination_and_passenger(d, p):
	destination = d
	passenger = p
	has_passenger = true
	play_door_open_animation(p.global_position)
	enable_destination_markers()
	emit_signal("picked_up_passenger")

func enable_destination_markers():
	destination_hint.global_position = destination
	destination_hint.show()

func arrived_at_destination():
	play_door_open_animation(destination)
	passenger.arrived_at_destination(destination)
	get_payment()
	has_passenger = false
	emit_signal("dropped_off_passenger")
	

func get_payment():
	var amount = int(passenger.distance_to_destination / 10)
	balance += amount
	payment_popup.rect_position = global_position
	emit_signal("received_payment", amount, balance)

func play_door_open_animation(compare_position):
	var side_of_taxi = ""
	if abs(transform.y.dot(Vector2.UP)) > abs(transform.y.dot(Vector2.LEFT)):
		# up or down
		if transform.y.dot(Vector2.UP) < 0:
			#facing up
			if compare_position.x > global_position.x:
				side_of_taxi = "R"
			elif compare_position.x < global_position.x:
				side_of_taxi = "L"
		elif transform.y.dot(Vector2.UP) > 0:
			#facing down
			if compare_position.x > global_position.x:
				side_of_taxi = "L"
			elif compare_position.x < global_position.x:
				side_of_taxi = "R"
	elif abs(transform.y.dot(Vector2.UP)) < abs(transform.y.dot(Vector2.LEFT)):
		if transform.y.dot(Vector2.LEFT) < 0:
			#facing left
			if compare_position.y > global_position.y:
				side_of_taxi = "L"
			elif compare_position.y < global_position.y:
				side_of_taxi = "R"
		elif transform.y.dot(Vector2.LEFT) > 0:
			#facing right
			if compare_position.y > global_position.y:
				side_of_taxi = "R"
			elif compare_position.y < global_position.y:
				side_of_taxi = "L"
	open_door(side_of_taxi)

func open_door(side):
	animation_player.play("open_door_%s" % side)

func boost():
	boost_mult = 1.6
	yield(get_tree().create_timer(boost_duration),"timeout")
	boost_mult = 1
