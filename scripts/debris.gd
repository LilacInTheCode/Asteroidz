extends Sprite2D

var timer = Timer.new()

var linear_velocity: Vector2 = Vector2(0, 0)
var total_lifespan: float = 1.0

func create(image: String, scale_factor: float = 1.0, course: Vector2 = Vector2(0, 0), lifespan: float = 0.5):
	texture = load(image)
	scale = Vector2(scale_factor, scale_factor)
	linear_velocity = course
	total_lifespan = lifespan
	timer.wait_time = lifespan
	timer.one_shot = true
	timer.autostart = true

func _ready():
	add_child(timer)

func _physics_process(delta):
	rotation += linear_velocity.length() * 0.05 * delta
	position += linear_velocity * delta
	modulate.a = timer.time_left / total_lifespan
	
	if timer.time_left <= 0:
		queue_free()
