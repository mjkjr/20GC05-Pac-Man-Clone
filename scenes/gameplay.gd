extends Node2D

var score: int = 0
var lives: int = 2


func _ready() -> void:
	%Lives.text = str(lives)
	$Player.died.connect(_on_player_died)


# triggered when a pellet tile is collided
func _on_pickup_body_entered(_body: Node2D) -> void:
	
	var cell = %Pickups.local_to_map(%Pickups.to_local($Player.global_position))

	var data = %Pickups.get_cell_tile_data(cell)
	var points: int = 0
	if data:
		points = data.get_custom_data("points")
		
		# remove tile from cell
		%Pickups.set_cell(cell)
		
		if points > 0:
			scored(points)
			check_win_condition()
		else:
			# ATTENTION: if a second powerup is consumed before the timer runs out should it be
			# restarted or have time added to the current time remaining?
			$Enemy1.trigger_flee_mode()
			#$Enemy2.trigger_flee_mode()
			#$Enemy3.trigger_flee_mode()
			#$Enemy4.trigger_flee_mode()


func scored(amount: int) -> void:
	score += amount
	%Score.text = str(score)


func check_win_condition() -> void:
	var won = true
	var cells = %Pickups.get_used_cells()
	for cell in cells:
		var data = %Pickups.get_cell_tile_data(cell)
		if data:
			if data.get_custom_data("points") > 0:
				won = false
				break
	if won:
		print("TODO: Winner!")


func _on_player_died() -> void:
	lives -= 1
	$UI/Lives.text = str(lives)
	if lives == 0:
		print("TODO: Game over.")
