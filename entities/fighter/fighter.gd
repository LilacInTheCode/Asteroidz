extends Area2D
class_name Fighter

@export_category("Fighter")
@export var primary_attack: Array[RemoteTransform2D]
@export var secondary_attack: Array[RemoteTransform2D]

@export var primary_fire: PackedScene

@onready var sprite = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
