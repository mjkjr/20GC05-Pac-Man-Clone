extends Node2D


func _ready() -> void:
	var timer = get_tree().create_timer(3)
	timer.timeout.connect(func(): Global.goto_scene("res://scenes/menus/main_menu.tscn"))
