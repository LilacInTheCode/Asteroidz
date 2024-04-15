extends Timer

const ASTEROID = preload("res://scenes/entities/asteroid.tscn")

signal wave_complete

enum {STATE_SPAWNING, STATE_PAUSED, STATE_STOPPED}
enum {SPAWN_LEFT, SPAWN_TOP, SPAWN_RIGHT, SPAWN_BOTTOM}

@export var spawn_timer_base: float = 10.0
@export var spawn_timer_erosion: float = 0.9
@export var spawn_burst: int = 2
@export var spawn_reset: float = 10.0
@export var spawn_cap: int = 5

var spawners: Array[Line2D] = []
var spawned_in_burst: int = 0
var spawned_in_total: int = 0
var state: int = STATE_PAUSED

func _init():
	one_shot = false
	autostart = false
	wait_time = spawn_timer_base
	
	connect("timeout", _on_spawn_timer)
	
	for s in range(4):
		var spawner = Line2D.new()
		spawners.append(spawner)

func _ready():
	for s in spawners:
		add_child(s)

func _on_spawn_timer():
	if state == STATE_SPAWNING:
		wait_time *= spawn_timer_erosion
		
		var asteroid = ASTEROID.instantiate()
		var spawn_at = random_point()
		var aim_toward = random_point()
		var course = (spawn_at.direction_to(aim_toward)).normalized() * 0.5
		
		asteroid.position = spawn_at
		#asteroid.set_course(course)
		#get_parent().add_child(asteroid)
		
		spawned_in_burst += 1
		spawned_in_total += 1
		#xsprint(spawned_in_total)
		if spawned_in_burst >= spawn_burst:
			state = STATE_PAUSED
			spawned_in_burst = 0
			wait_time = spawn_reset
	
	if state == STATE_PAUSED:
		wait_time = spawn_timer_base
		state = STATE_SPAWNING
	
	if spawned_in_total >= spawn_cap:
		emit_signal("wave_complete")
		stop()
		state = STATE_STOPPED

func surround(area: Rect2, buffer: float):
	if spawners.size() < 4:
		return
	
	for s in spawners:
		s.clear_points()
	
	var left_bound = area.position.x - buffer
	var right_bound = area.position.x + area.size.x + buffer
	var top_bound = area.position.y - buffer
	var bottom_bound = area.position.y + area.size.y + buffer
	
	spawners[SPAWN_LEFT].add_point(Vector2(left_bound, top_bound + buffer))
	spawners[SPAWN_LEFT].add_point(Vector2(left_bound, bottom_bound - buffer))
	
	spawners[SPAWN_TOP].add_point(Vector2(left_bound + buffer, top_bound))
	spawners[SPAWN_TOP].add_point(Vector2(right_bound - buffer, top_bound))
	
	spawners[SPAWN_RIGHT].add_point(Vector2(right_bound, top_bound + buffer))
	spawners[SPAWN_RIGHT].add_point(Vector2(right_bound, bottom_bound - buffer))
	
	spawners[SPAWN_BOTTOM].add_point(Vector2(left_bound + buffer, bottom_bound))
	spawners[SPAWN_BOTTOM].add_point(Vector2(right_bound - buffer, bottom_bound))
	

func random_point() -> Vector2:
	var spawn_point: Vector2 = Vector2(0, 0)
	
	var spawn_area: Line2D = spawners[randi_range(0, spawners.size() - 1)]
	var limit_points: Array[Vector2] = [spawn_area.get_point_position(0), spawn_area.get_point_position(1)]
	#print("Spawning from " + spawn_area.to_string())
	if limit_points[0].x == limit_points[1].x:
		spawn_point = Vector2(limit_points[0].x, randf_range(limit_points[0].y, limit_points[1].y))
	else:
		spawn_point = Vector2(randf_range(limit_points[0].x, limit_points[1].x) ,limit_points[0].y)
	#print("Spawn point:" + str(spawn_point))
	
	return spawn_point
