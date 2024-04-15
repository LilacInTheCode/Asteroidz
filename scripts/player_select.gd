class_name PlayerSelect
extends Control

@onready var player_boxes: Array = [
	$Menu/VBoxContainer/MenuGrid/Player1Box,
	$Menu/VBoxContainer/MenuGrid/Player2Box,
	$Menu/VBoxContainer/MenuGrid/Player3Box,
	$Menu/VBoxContainer/MenuGrid/Player4Box]

func select_player(player_number: int, selected: bool = true):
	if selected:
		player_boxes[player_number].modulate = Color8(255, 255, 255)
	else:
		player_boxes[player_number].modulate = Color8(100, 100, 100)

func populate(maximum: int):
	for i in range(0, maximum):
		player_boxes[i].visible = true
