extends Node
class_name MovementComponent

@export_category("Movement")
@export var top_acceleration: float = 1.0
@export var rotation_rate: float = 2.0
@export var base_thrust: float = 0.1

var current_velocity: float = 0.0
