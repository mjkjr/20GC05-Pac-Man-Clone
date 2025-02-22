extends Node2D

var score = 0
var lives = 2


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Lives.text = str(lives)


# triggered when a pellet tile is collided
func _on_pickup_body_entered(_body: Node2D) -> void:
	
	var cell = $TileMapLayer.local_to_map($TileMapLayer.to_local($Player.global_position))

	var data = $TileMapLayer.get_cell_tile_data(cell)
	var points: int = 0
	if data:
		points = data.get_custom_data("points")
		
		# replace cell with an empty tile
		$TileMapLayer.set_cell(cell, 0, Vector2i(1, 1))
		
		if points > 0:
			scored(points)
			check_win_condition()
		else:
			%Powerup.visible = true
			# ATTENTION: if a second powerup is consumed before the timer runs out should it be
			# restarted or have time added to the current time remaining?
			get_tree().create_timer(5).timeout.connect(func(): %Powerup.visible = false)


func scored(amount: int) -> void:
	score += amount
	%Score.text = str(score)


func check_win_condition() -> void:
	var won = true
	var cells = $TileMapLayer.get_used_cells()
	for cell in cells:
		var data = $TileMapLayer.get_cell_tile_data(cell)
		if data:
			if data.get_custom_data("points") > 0:
				won = false
				break
	if won:
		print("Winner!")
