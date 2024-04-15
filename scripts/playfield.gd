class_name Playfield
extends Node2D

enum {STATE_PREPARE, STATE_SPAWNING, STATE_CLEANUP, STATE_COMPLETED}

const SPACESHIP = preload("res://scenes/entities/spaceship.tscn")

const SPAWN_BUFFER = 32

signal stage_prepared
signal stage_complete

@onready var backdrop: Polygon2D = $Backdrop
@onready var camera: Camera2D = $Camera2D
@onready var spawner: Timer = $SpawnTimer

var limit_left = 0
var limit_right = 0
var limit_top = 0
var limit_bottom = 0

var stripes_enabled: bool = false

var state = STATE_SPAWNING

var ships: Dictionary = {}

func get_playfield_bounds() -> Rect2:
	var vp: Vector2 = camera.get_viewport_rect().size
	return Rect2(camera.position, vp)

func get_playfield_center() -> Vector2:
	return get_playfield_bounds().get_center()

func spawn_ship(at: Vector2 = Vector2(0, 0), player_state: PlayerState = null):
	if !player_state:
		return
	if(ships.get(player_state.player_id, null)):
		return
	
	var ship = SPACESHIP.instantiate()
	ship.position = at
	ship.attach_player(player_state)
	ships[player_state.player_id] = ship
	add_child(ship)
	
	if stripes_enabled:
		ship.set_player_color(player_state.profile_color)
	
func spawn_ships(player_states: Array, enable_stripes: bool = false):
	var spawn_points: Array[Vector2] = []
	if player_states.size() < 1:
		return
	
	stripes_enabled = enable_stripes
	
	var center = get_playfield_bounds().get_center()
	if player_states.size() == 1:
		spawn_points.append(center)
	elif player_states.size() == 2:
		spawn_points. append_array([
			center - Vector2(SPAWN_BUFFER, 0),
			center + Vector2(SPAWN_BUFFER, 0)
		])
	elif player_states.size() == 3:
		spawn_points. append_array([
			center - Vector2(0, SPAWN_BUFFER),
			center + Vector2(-SPAWN_BUFFER, SPAWN_BUFFER),
			center + Vector2(SPAWN_BUFFER, SPAWN_BUFFER)			
		])
	elif player_states.size() == 4:
		spawn_points. append_array([
			center - Vector2(SPAWN_BUFFER, SPAWN_BUFFER),
			center - Vector2(-SPAWN_BUFFER, SPAWN_BUFFER),
			center + Vector2(-SPAWN_BUFFER, SPAWN_BUFFER),
			center + Vector2(SPAWN_BUFFER, SPAWN_BUFFER)			
		])
	
	for sp_index in range(spawn_points.size()):
		spawn_ship(spawn_points[sp_index], player_states[sp_index])

func _ready():
	var bounds = get_playfield_bounds()
	limit_left = bounds.position.x
	limit_top = bounds.position.y
	limit_right = bounds.position.x + bounds.size.x
	limit_bottom = bounds.position.y + bounds.size.y
	
	var top_left = bounds.position
	var top_right = Vector2(limit_right, bounds.position.y)
	var bottom_right = Vector2(limit_right, limit_bottom)
	var bottom_left = Vector2(bounds.position.x, limit_bottom)
	
	backdrop.polygon.clear()
	backdrop.polygon = [top_left, top_right, bottom_right, bottom_left]
	
	spawner.surround(bounds, SPAWN_BUFFER)
	spawner.connect("wave_complete", _on_wave_complete)
	spawner.start()
	

func _physics_process(_delta):
	var incoming_asteroids = get_tree().get_nodes_in_group("incoming")
	for i: Node2D in incoming_asteroids:
		if get_viewport_rect().encloses(Rect2(i.position, Vector2(10, 10))):
			i.remove_from_group("incoming")
			i.add_to_group("wraparound")
	var wraping_entities = get_tree().get_nodes_in_group("wraparound")
	for e in wraping_entities:
		if e.position.x < limit_left - e.collision.shape.radius * 2:
			e.position.x = limit_right  + e.collision.shape.radius * 0.5
		elif e.position.x > limit_right + e.collision.shape.radius * 2:
			e.position.x = limit_left  - e.collision.shape.radius * 0.5
		
		if e.position.y < limit_top - e.collision.shape.radius * 2:
			e.position.y = limit_bottom + e.collision.shape.radius * 0.5
		elif e.position.y > limit_bottom + e.collision.shape.radius * 2:
			e.position.y = limit_top - e.collision.shape.radius * 0.5
	
	var active_projectiles = get_tree().get_nodes_in_group("active_projectiles")
	for p in active_projectiles:
		if p.current_state == 2:
			if p.position.x < limit_left || p.position.x > limit_right:
				p.destroy(true)
			if p.position.y < limit_top || p.position.y > limit_bottom:
				p.destroy(true)
	
	var active_asteroids = get_tree().get_nodes_in_group("destructables")
	#print("Active asteroids: " + str(active_asteroids.size()))
	
	if state == STATE_CLEANUP:
		for a in active_asteroids:
			if a.position.x < limit_left - a.collision.shape.radius * 2:
				a.destroy(true)
			elif a.position.x > limit_right + a.collision.shape.radius * 2:
				a.destroy(true)
			
			if a.position.y < limit_top - a.collision.shape.radius * 2:
				a.destroy(true)
			elif a.position.y > limit_bottom + a.collision.shape.radius * 2:
				a.destroy(true)
		if active_asteroids.size() == 0:
			state = STATE_COMPLETED
	if state == STATE_COMPLETED:
		emit_signal("stage_complete")

func _on_wave_complete():
	#print("Entering cleanup")
	state = STATE_CLEANUP
