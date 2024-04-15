class_name Spaceship
extends RigidBody2D

const ANIM_SPAWN = "spawning"
const ANIM_FLYING = "flying"
const ANIM_SHIELD = "shielding"
const ANIM_DESTROY = "exploding"

enum Arms {STARBOARD, FORWARD, PORT}
enum {CHARGE, FIRE}

signal spawned
signal impact
signal despawn

const TOP_ACCEL = 1
const ROT_VELOCITY = 2
const BASE_THRUST = 0.1
const THRUST_INTERVAL = 0.2

@onready var sprite = $ShipSprite
@onready var collision: CollisionShape2D = $ShipCollision
@onready var loadout: Loadout = $Loadout
@onready var player_stripe = $PlayerStripe

var player_controller: PlayerState = null

var last_thrust_timer = 0
var current_vector = Vector2(0, 0)

var active_arm: Array[RigidBody2D] = [null, null, null]
var arm_attach: Array[RemoteTransform2D] = [null, null, null]

var weapon_systems: Dictionary = {}

var arm_interface: Array[Label] = [null, null, null]

func _ready():
	arm_attach[Arms.STARBOARD] = $StarboardLaser
	arm_attach[Arms.FORWARD] = $ForwardLaser
	arm_attach[Arms.PORT] = $PortLaser
	
	var arms = loadout.get_arms_db()
	loadout.armaments_active[Arms.STARBOARD] = arms[0]
	loadout.armaments_active[Arms.PORT] = arms[0]
	loadout.armaments_active[Arms.FORWARD] = arms[1]
	
	add_to_group("wraparound")
	
	if player_controller:
		player_controller.pawn_ready()

func attach_player(controller: PlayerState):
	player_controller = controller
	
	if player_controller:
		player_controller.map_fire_bindings(Arms.values())
		player_controller.connect("charge", _begin_charge)
		player_controller.connect("fire", _release_fire)
		player_controller.connect("state_changed", _on_enter_state)
		player_controller.bound()

func _begin_charge(arm: int):
	if active_arm[arm]:
		return
	
	var laser_bolt = loadout.instance_round(arm)
	if !laser_bolt: return
	
	get_parent().add_child(laser_bolt)
	arm_attach[arm].remote_path = laser_bolt.activate()
	active_arm[arm] = laser_bolt

func _release_fire(arm: int):
	if arm < 0: return
	if arm < arm_attach.size():
		arm_attach[arm].remote_path = ""
	if arm < active_arm.size():
		if active_arm[arm]:
			active_arm[arm].fire()
			active_arm[arm] = null

func _physics_process(delta):
	player_stripe.position = position
	# Process rotation
	if player_controller:
		rotation += player_controller.get_rotation_axis() * ROT_VELOCITY * delta
		# Process thrust
		if player_controller.get_thrust_strength() && last_thrust_timer > THRUST_INTERVAL:
			linear_velocity += BASE_THRUST * -transform.y
			last_thrust_timer = 0
	
	if sprite.get_animation() == ANIM_FLYING:
		var hit_result = move_and_collide(linear_velocity)
		if hit_result:
			if hit_result.get_collider().has_method("destroy"):
				player_controller.impact(null, -2)
				apply_impulse(-linear_velocity * 0.5)
	
	elif sprite.get_animation() == ANIM_DESTROY:
		if !sprite.is_playing():
			emit_signal("despawn", player_controller.player_id)
			queue_free()
	last_thrust_timer += delta

func set_player_color(color: Color):
	player_stripe.visible = true
	player_stripe.modulate = color

func _on_enter_state(new_state: int):
	match new_state:
		player_controller.Play.SPAWN:
			sprite.play("spawning")
		player_controller.Play.RUN:
			sprite.play("flying")
		player_controller.Play.DAMAGED:
			sprite.play("shielding")
		player_controller.Play.DESTROYED:
			sprite.play("exploding")
		_:
			return
