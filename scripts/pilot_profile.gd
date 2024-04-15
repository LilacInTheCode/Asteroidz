class_name PilotProfile
extends MarginContainer

@onready var pilot_id: Label = $PilotProfile/PilotID
@onready var shield_power: ProgressBar = $PilotProfile/PowerIndicator/ShieldPower
@onready var total_power: ProgressBar = $PilotProfile/PowerIndicator/TotalPower
@onready var power_indicator: PanelContainer = $PilotProfile/PowerIndicator

var cached_pilot: String = ""
var cached_color = Color8(255, 255, 255)
var cached_shield: int = 0
var cached_energy: int = 0

func lost_contact(engage: bool = true):
	if engage:
		power_indicator.visible = false
		pilot_id.text = "[Lost Contact]"
		pilot_id.modulate = Color8(255, 180, 180)
	else:
		power_indicator.visible = true
		pilot_id.text = cached_pilot
		pilot_id.modulate = cached_color

func _ready():
	shield_power.value = 0
	total_power.value = 0

func update_pilot(pilot: String, color: Color = Color8(255, 255, 255, 255)):
	cached_pilot = pilot
	cached_color = color
	pilot_id.text = pilot
	pilot_id.modulate = color

func set_energy(power: int):
	shield_power.max_value = power
	total_power.max_value = power

func update_shield(power: int):
	cached_shield = power

func update_energy(power: int):
	cached_energy = power

func update_power_indicator():
	total_power.value = cached_energy
	shield_power.value = cached_shield

func _process(_delta):
	update_power_indicator()
