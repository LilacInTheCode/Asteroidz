extends RigidBody2D

const ASTEROID = preload("res://scenes/entities/asteroid.tscn")
const DEBRIS = preload("res://scenes/entities/debris.tscn")

@export var hp_range = [Vector2(1, 1), Vector2(2, 2), Vector2(3, 3)]
@export var coll_radius = [1.0, 2.0, 3.0]
@export var coll_position = [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]

@onready var sprite = $AsteroidSprite
@onready var collision = $AsteroidCollision

enum {SIZE_SM, SIZE_LG, SIZE_XL}

var size_sprite = ["res://assets/2d/asteroid_sm.png", "res://assets/2d/asteroid_lg.png", "res://assets/2d/asteroid_xl.png"]
var frag_num = [0, 3, 2]
var debris_num = [5, 4, 3]
var debris_scale = [0.3, 0.7, 0.5]

var size_class = SIZE_XL
var current_hp = 1
var course_vector = Vector2(0, 0)

func set_size_class(size: int = SIZE_SM):
	current_hp = randi_range(hp_range[size].x, hp_range[size].y)
	size_class = size

func _ready():
	sprite.texture = load(size_sprite[size_class])
	collision.shape.radius = coll_radius[size_class]
	collision.position = coll_position[size_class]
	add_to_group("destructables")
	add_to_group("incoming")

func impact(damage: int = 0, _impact_vector: Vector2 = Vector2(0, 0)):
	current_hp -= damage

func set_course(course: Vector2):
	course_vector = course.normalized()
	linear_velocity = course

func reduce():
	var frag = frag_num[size_class]
	var debris = debris_num[size_class]
	var angle_inc = 270.0 / (frag + debris)
	var frag_freq = 0
	if frag > 0:
		frag_freq = (frag + debris) / frag
	for f in range(frag + debris):
		var new_trajectory = Vector2(coll_radius[size_class - 1], 0).rotated(angle_inc * f)
		if frag != 0 && f % frag_freq == 0:
			var fragment = ASTEROID.instantiate()
			fragment.set_size_class(size_class - 1)
			fragment.position = position + new_trajectory
			fragment.set_course(new_trajectory.normalized() * linear_velocity * 1.25)
			get_parent().add_child(fragment)
		else:
			var debris_ = DEBRIS.instantiate()
			debris_.create(size_sprite[size_class], debris_scale[size_class], new_trajectory, 1.0)
			debris_.position = position
			get_parent().add_child(debris_)

func _physics_process(delta):
	if current_hp <= 0:
		destroy()
		return
	
	rotation += linear_velocity.length() * delta
	move_and_collide(linear_velocity)

func destroy(instant: bool = false):
	if !instant:
		reduce()
	remove_from_group("destructables")
	queue_free()
