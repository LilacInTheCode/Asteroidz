class_name PlayerState
extends StateController

# Input signals
signal charge
signal fire

# Gameplay signals
signal profile_changed
signal energy_set
signal shield_set
signal shield_changed
signal energy_changed
signal player_died
signal game_over

# Input variables
var input_enabled: bool = false
var rotation_axis: float = 0.0
var thrust_strength: float = 0.0
var fire_bindings: Dictionary = {}
var fire_locks: Dictionary = {}

var test: ShipModule = ShipModule.new()

# Gameplay variables
@export_category("Gameplay")
@export var profile_name = "Player"
@export var profile_color = Color8(200, 200, 255)
@export var spawn_timer = 2
var timer = null
var player_id = -1
var current_ship_count: int = 1

@export var energy_max: int = 100
var energy_cur:int = 0
@export var shield_max:int = 10
var shield_cur: int = 0

func _ready():
	set_max_energy(energy_max, true)
	set_max_shield(shield_max, true)

func bound():
	input_enabled = true

func pawn_ready():
	enter_state(Play.SPAWN)
	if timer:
		timer.queue_free()
	timer = Timer.new()
	timer.autostart = true
	timer.one_shot = true
	timer.wait_time = spawn_timer
	timer.connect("timeout", _spawn_timer_complete)
	add_child(timer)

func _spawn_timer_complete():
	enter_state(Play.RUN)
	timer.queue_free()
	timer = null

func enter_state(new_state: int):
	current_state = new_state
	emit_signal("state_changed", current_state)

func impact(_source: StateController, _damage: int):
	if current_state != Play.RUN:
		return
	
	var overkill = update_shield(_damage)
	if overkill < 0:
		enter_state(Play.DESTROYED)
		if current_ship_count < 0:
			emit_signal("game_over")
		else:
			emit_signal("player_died", Vector2(0, 0), player_id)

## Set the name of the player profile
func set_player_profile(name: String):
	profile_name = name
	emit_signal("profile_changed", profile_name, profile_color)

func set_player_color(color: Color):
	profile_color = color
	emit_signal("profile_changed", profile_name, profile_color)

func set_max_shield(amount: int, refill: bool = false):
	shield_max = mini(amount, energy_max)
	if shield_cur > shield_max || refill:
		shield_cur = shield_max
	
	if shield_cur > shield_cur:
		shield_cur = shield_cur
	
	emit_signal("shield_set", shield_max)
	emit_signal("shield_changed", shield_cur)

func update_shield(amount: int) -> int:
	var over: int = 0
	var total = shield_cur + amount
	
	if amount > 0:
		shield_cur = mini(total, shield_max)
		if shield_cur == shield_max:
			over = total - shield_max
	else:
		shield_cur = maxi(total, 0)
		if shield_cur == 0:
			over = total
	
	emit_signal("shield_changed", shield_cur)
	return over

func set_max_energy(amount: int, refill: bool = false):
	energy_max = amount
	if energy_cur > energy_max || refill:
		energy_cur = energy_max
	
	emit_signal("energy_set", energy_max)
	emit_signal("energy_changed", energy_cur)

func update_energy(amount: int) -> int:
	var over: int = 0
	var total: int = energy_cur + amount
	
	if amount > 0:
		energy_cur = mini(total, energy_max)
		if energy_cur == energy_max:
			over = total - energy_max
	else:
		energy_cur = maxi(total, 0)
		if energy_cur == 0:
			over = total
	
	emit_signal("energy_changed", energy_cur)
	return over

func set_max_hp(amount: int, refill: bool = false):
	hp_max = amount
	if hp_cur > hp_max || refill:
		hp_cur = hp_max
	
	emit_signal("hp_set", hp_max)
	emit_signal("hp_changed", hp_cur)


func update_hp(amount: int):
	if amount > 0:
		hp_cur = mini(hp_cur + amount, hp_max)
	else:
		hp_cur = maxi(hp_cur + amount, 0)
	
	emit_signal("hp_changed", hp_cur)

func refresh():
	emit_signal("profile_changed", profile_name, profile_color)
	emit_signal("hp_set", hp_max)
	emit_signal("hp_changed", hp_cur)
	emit_signal("energy_set", energy_max)
	emit_signal("energy_changed", energy_cur)
	emit_signal("shield_set", shield_max)
	emit_signal("shield_changed", shield_cur)

## Sets the ship count for this Player (i.e. on starting the game)
func set_ship_count(count: int):
	current_ship_count = count

## Adjusts the ship counter up or down (i.e. in response to destruction or powerups)
func adj_ship_count(amount: int = -1):
	current_ship_count += amount

## Takes input dedicated to this player and caches it for rotational movement
func update_rotation_axis(axis_value: float):
	if input_enabled:
		rotation_axis = axis_value

## Returns cached rotational movement
func get_rotation_axis() -> float:
	return rotation_axis

## Takes input dedicated to this player and caches it for forward movement
func update_thrust_strength(thrust_value: float):
	if input_enabled:
		thrust_strength = thrust_value

## Returns cached forward movement
func get_thrust_strength() -> float:
	return thrust_strength

## Bind input actions for firing weapons to translation dictionary
func set_fire_bindings(input_action_bindings: Array):
	for b in input_action_bindings:
		fire_bindings[b] = ""

## Bind Spaceship armament to input translation dictionary
func map_fire_bindings(fire_points: Array):
	var map_length = mini(fire_bindings.size(), fire_points.size())
	for map in range(map_length):
		fire_bindings[fire_bindings.keys()[map]] = fire_points[map]

func set_charge(input_action: String):
	if fire_bindings.has(input_action):
		emit_signal("charge", fire_bindings[input_action])

func set_fire(input_action: String):
	if fire_bindings.has(input_action):
		emit_signal("fire", fire_bindings[input_action])
