## Keeps track of the game state and player controllers
##
## This is the Node that sits above the gameplay and menus to control the flow of execution
class_name GameState
extends Node

const PLAYER_SELECT = preload("res://scenes/interface/player_select.tscn")
const PLAYFIELD = preload("res://scenes/entities/playfield.tscn")
const PLAYER_CONTROLLER = preload("res://scenes/gameplay/player_state.tscn")
const PILOT_INFO = preload("res://scenes/interface/pilot_profile.tscn")

const FIRE_BINDINGS = ["FireStarboard", "FireForward", "FirePort"]

@export var PLAYER_COLORS: Array[Color] = [
	Color8(100, 100, 255),
	Color8(255, 100, 100),
	Color8(180, 255, 100),
	Color8(180, 100, 180)]

@onready var game_interface = $GameInterface/InterfaceMargins2
@onready var pilot_row = $GameInterface/InterfaceMargins2/PilotDock/PilotRow

## Numer of ships that each player starts with
@export var starting_ship_count = 3
var current_level = 0

## Currently active playfield
var playfield: Playfield = null

## PlayerControllers hashed by Player ID
var players: Dictionary = {}

## Respawn Timers hashed by Player ID
var respawn_queue: Dictionary = {}

## Player info UI hashed by Player ID
var player_ui: Dictionary = {}

## Maximum number of players
@export var max_players = 4

func add_player(player_id: int):
	if players.size() >= max_players:
		return
	
	players[player_id] = PlayerState.new()
	players[player_id].player_id = player_id

func _ready():
	var devices = Input.get_connected_joypads()
	for d in devices:
		print(Input.get_joy_name(d))
	
	pilot_row.visible = false
	var player_select = PLAYER_SELECT.instantiate()
	game_interface.add_child(player_select)
	player_select.add_to_group("player_select")
	player_select.populate(devices.size())
	

func begin_play():
	pilot_row.visible = true
	for p: PlayerState in players.values():
		add_child(p)
		p.set_ship_count(starting_ship_count)
		p.set_fire_bindings(FIRE_BINDINGS)
		p.profile_color = PLAYER_COLORS[p.player_id]
		p.connect("player_died", _on_ship_destroyed)
		
		var ui_widget = PILOT_INFO.instantiate()
		p.connect("profile_changed", ui_widget.update_pilot)
		p.connect("energy_changed", ui_widget.update_energy)
		p.connect("energy_set", ui_widget.set_energy)
		p.connect("shield_changed", ui_widget.update_shield)
		player_ui[p.player_id] = ui_widget
		pilot_row.add_child(ui_widget)
		
		p.refresh()
		
		print(JSON.stringify(self))
	
	_on_level_completed()

func _on_level_completed():
	if playfield:
		playfield.queue_free()
		playfield = null
	
	current_level += 1
	playfield = PLAYFIELD.instantiate()
	add_child(playfield)
	
	playfield.connect("stage_complete", _on_level_completed)	
	#playfield.interface.update_stage(current_level)
	#playfield.interface.set_ship_count(current_ship_count)
	var enable_stripes: bool = players.keys().size() > 1
	for p in players.keys():
		playfield.spawn_ships(players.values(), enable_stripes)

func _on_ship_destroyed(_position: Vector2, player_id: int):
	playfield.ships.erase(player_id)
	player_ui[player_id].lost_contact()
	
	var respawn_timer: Timer = Timer.new()
	respawn_timer.one_shot = true
	respawn_timer.autostart = true
	respawn_timer.wait_time = 3
	respawn_timer.connect("timeout", _on_ready_respawn)
	respawn_queue[player_id] = respawn_timer
	add_child(respawn_timer)

func _on_ready_respawn():
	var player_id: int = -1
	for id in respawn_queue.keys():
		if respawn_queue[id].is_stopped():
			player_id = id
			break
	
	if player_id != -1:
		respawn_queue[player_id].queue_free()
		respawn_queue.erase(player_id)
		
		
	var destroyed_player: PlayerState = players.get(player_id, null)
	if destroyed_player:
		destroyed_player.adj_ship_count(-1)
		playfield.spawn_ship(playfield.get_playfield_center(), destroyed_player)
		player_ui[player_id].lost_contact(false)

func _input(event):
	if event.is_action_pressed("DropOut"):
		get_tree().quit()
	
	if current_level == 0:
		if event.is_action_released("FireForward") && players.size() > 0:
			get_tree().get_first_node_in_group("player_select").queue_free()
			begin_play()
			return
		
		if event.get_class() == "InputEventJoypadButton":
			var player_select = get_tree().get_first_node_in_group("player_select")
			
			if event.is_pressed():
				add_player(event.device)
				player_select.select_player(players.size() - 1)
			else:
				Input.start_joy_vibration (event.device, 1, 1, 0.1)
			
		return
	
	var input_player: PlayerState = players.get(event.device, null)
	#print(event.to_string() + " Player " + str(event.device))
	if input_player:
		if event.is_action("Thrust"):
			var strength = event.get_action_strength("Thrust")
			if(strength > 0.1):
				input_player.update_thrust_strength(strength)
			else:
				input_player.update_thrust_strength(0)
		if event.is_action("RotateLeft") || event.is_action("RotateRight"):
			var strength = event.get_action_strength("RotateRight") - event.get_action_strength("RotateLeft")
			if(absf(strength) > 0.1):
				input_player.update_rotation_axis(strength)
			else:
				input_player.update_rotation_axis(0)
		for action in input_player.fire_bindings.keys():
			if event.is_action_pressed(action):
				input_player.set_charge(action)
			if event.is_action_released(action):
				input_player.set_fire(action)
			
