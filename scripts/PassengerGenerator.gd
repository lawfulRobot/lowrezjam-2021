extends Node2D

onready var passenger_prefab = preload("res://scenes/Person.tscn")
onready var world = $".."
var max_waiting_passengers : int = 15
var passengers_waiting : int = 0
var spawnpoints = []
var occupied_spawnpoints = []

func _ready():
	spawnpoints = get_children()
	randomize()
	if spawnpoints.size() < max_waiting_passengers:
		max_waiting_passengers = spawnpoints.size()
	for _i in range(max_waiting_passengers):
		create_passenger()

func create_passenger():
	if passengers_waiting < max_waiting_passengers:
		var passenger = passenger_prefab.instance()
		var spawn_position = spawnpoints[rand_range(0, spawnpoints.size())].global_position
		
		while occupied_spawnpoints.has(spawn_position):
			spawn_position = spawnpoints[rand_range(0, spawnpoints.size())].global_position
		
		passenger.global_position = spawn_position
		occupied_spawnpoints.append(spawn_position)
		passenger.connect("bye_bye", self, "on_passenger_removed")
		passenger.connect("entered_taxi", self, "on_passenger_entered_taxi")
		passengers_waiting += 1
		world.call_deferred("add_child", passenger)

func on_passenger_entered_taxi(pos):
	occupied_spawnpoints.erase(pos)

func on_passenger_removed():
	passengers_waiting -= 1
	create_passenger()
