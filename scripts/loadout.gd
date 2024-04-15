class_name Loadout
extends Node

const LASER_BOLT = preload("res://scenes/entities/laser_bolt.tscn")
class ArmamentDescription:
	var type_name: String = "Generic Armament"
	var damage_range: Vector2 = Vector2(1, 1)
	var base_ammo_cost: int = 1
	var charge_ammo_cost = 1
	var charge_capacity = 1
	var charge_multiplier = 1
	var ammo_type: String = "energy"
	var color: Color = Color8(255, 255, 255)
	
	func _init(name: String, dmg: Vector2, ammo_cost: int, modulation: Color = Color8(255, 255, 255)):
		type_name = name
		damage_range = dmg
		base_ammo_cost = ammo_cost
		color = modulation

var armaments_database = {
	"laser_type2": ArmamentDescription.new("Type II Laser Cannon", Vector2(2, 4), 1, Color8(255, 150, 150, 255)),
	"laser_type3": ArmamentDescription.new("Type III Laser Cannon", Vector2(4, 8), 3, Color8(180, 180, 255, 255)),
}

var armaments_inventory = {}
var armaments_active = {}

func get_arms_db() -> Array:
	return armaments_database.keys()

func get_arms_info(entry: String) -> ArmamentDescription:
	return armaments_database.get(entry)

func get_arms_type_name(entry: String) -> String:
	var arm_name = "Not found"
	var entry_found = armaments_database.get(entry)
	if entry_found:
		arm_name = entry_found.type_name
	
	return arm_name

func instance_round(active_slot: Variant) -> RigidBody2D:
	var armament = armaments_active.get(active_slot, null)
	if !armament:
		return null
	var arm_info = get_arms_info(armament)
	if !arm_info:
		return null

	var laser_bolt: LaserBolt = LASER_BOLT.instantiate()
	laser_bolt.damage_range = arm_info.damage_range
	laser_bolt.modulate = arm_info.color
	
	return laser_bolt
