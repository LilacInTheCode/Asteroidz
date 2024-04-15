class_name LaserBolt
extends RigidBody2D

@onready var collision: CollisionShape2D = $LaserCollision
@onready var sprite: AnimatedSprite2D = $LaserSprite

enum {STATE_INACTIVE, STATE_CHARGE, STATE_TRAVEL, STATE_DESTROY}

var current_state = STATE_INACTIVE
var attach_target: Node2D

var type_name: String = "Generic Laser Weapon"
var damage_range: Vector2i = Vector2i(1, 1)
var base_ammo_cost: int = 1
var charge_ammo_cost = 1
var charge_capacity = 1
var charge_multiplier = 1
var ammo_type: String = "energy"

func _ready():
	visible = false
	collision.disabled = true
	add_to_group("active_projectiles")

func activate() -> NodePath:
	sprite.play("charging")
	visible = true
	current_state = STATE_CHARGE
	return get_path()

func fire():
	if(current_state != STATE_CHARGE):
		return
	
	current_state = STATE_TRAVEL
	sprite.play("traveling")
	collision.disabled = false
	linear_velocity = 10 * -transform.y

func destroy(silent: bool = false):
	if(silent == true):
		remove_from_group("active_projectiles")
		queue_free()
		return
	
	collision.disabled = true
	linear_velocity = Vector2(0, 0)
	sprite.play("destroy")
	current_state = STATE_DESTROY

func _physics_process(_delta):	
	if (current_state == STATE_TRAVEL):
		var hit = move_and_collide(linear_velocity)
		if hit:
			var object_hit = hit.get_collider()
			if(object_hit.has_method("impact")):
				object_hit.impact(randi_range(damage_range.x, damage_range.y), linear_velocity)
			destroy()
	
	if current_state == STATE_DESTROY && sprite.is_playing() == false:
		destroy(true)
