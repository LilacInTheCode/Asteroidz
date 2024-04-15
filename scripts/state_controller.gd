class_name StateController
extends Node

enum Play {SPAWN, RUN, DAMAGED, DESTROYED, DESPAWN, UNDEFINED}
enum Influence{HARM, HEAL, TALK}

signal state_changed
signal hp_set
signal hp_changed
signal hp_out
signal despawned

@export_category("Gameplay")
@export var hp_max :int = 1
@onready var hp_cur: int = hp_max

var current_state = Play.UNDEFINED

var immune: bool = false
var colliding: bool = true

func influence(_source: StateController, _type: int, _amount: int):
	pass

func update_hp(_amount: int):
	pass

func enter_state(_new_state: int):
	pass
