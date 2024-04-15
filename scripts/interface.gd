extends Control

enum {ARM_STARBOARD, ARM_FORWARD, ARM_PORT}

@onready var ship_count = $ShipLoadout/ShipCount
@onready var stage_counter = $LevelState/StageCounter

var arms: Array[Label] = [null, null, null]

func _ready():
	arms[ARM_STARBOARD] = $ShipLoadout/StarboardArm
	arms[ARM_FORWARD] = $ShipLoadout/ForwardArm
	arms[ARM_PORT] = $ShipLoadout/PortArm

func set_arm(arm: int, type_name: String):
	arms[arm].text = type_name

func set_ship_count(count: int):
	ship_count.text = "x" + str(count)

func update_stage(stage_number: int):
	stage_counter.text = "Stage " + str(stage_number)
