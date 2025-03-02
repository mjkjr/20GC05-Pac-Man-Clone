extends Node2D

var wave = 1
var mode_times: Dictionary = {}

var lives: int = 2


func _ready() -> void:
	%Lives.text = str(lives)
	mode_times[Global.Mode.SCATTER] = $Timers/Scatter.wait_time
	mode_times[Global.Mode.CHASE] = $Timers/Chase.wait_time
	mode_times[Global.Mode.FLEE] = $Timers/Flee.wait_time
	#_print_mode()


func _next_wave() -> void:
	wave += 1
	if wave == 3:
		mode_times[Global.Mode.SCATTER] -= 2
		mode_times[Global.Mode.CHASE] -= 2
		mode_times[Global.Mode.FLEE] -= 2
		$Timers/Scatter.wait_time = mode_times[Global.Mode.SCATTER]
		$Timers/Chase.wait_time = mode_times[Global.Mode.CHASE]
		$Timers/Flee.wait_time = mode_times[Global.Mode.FLEE]


func _on_scatter_timeout() -> void:
	Global.prior_mode = Global.mode
	Global.mode = Global.Mode.CHASE
	Global.mode_changed = true
	$Timers/Chase.start()


func _on_chase_timeout() -> void:
	Global.prior_mode = Global.mode
	_next_wave()
	if wave <= 4:
		Global.mode = Global.Mode.SCATTER
		Global.mode_changed = true
		$Timers/Scatter.start()
	else:
		$Timers/Chase.start()


func _on_flee_timeout() -> void:
	Global.mode = Global.prior_mode
	Global.prior_mode = Global.Mode.FLEE
	Global.mode_changed = true
	# reset flee timer in case multiple power pellets where activated
	$Timers/Flee.wait_time = mode_times[Global.Mode.FLEE]
	if Global.mode == Global.Mode.SCATTER:
		$Timers/Scatter.paused = false
	elif Global.mode == Global.Mode.CHASE:
		$Timers/Chase.paused = false


func _on_flee() -> void:
	if Global.mode == Global.Mode.FLEE:
		$Timers/Flee.start($Timers/Flee.time_left + mode_times[Global.Mode.FLEE])
	else:
		Global.prior_mode = Global.mode
		Global.mode = Global.Mode.FLEE
		Global.mode_changed = true
		if Global.prior_mode == Global.Mode.SCATTER:
			$Timers/Scatter.paused = true
		elif Global.prior_mode == Global.Mode.CHASE:
			$Timers/Chase.paused = true
		$Timers/Flee.start()
	
	# TODO: change enemy appearance during flee mode


# triggered when a pellet tile is collided
func _on_player_pickup() -> void:
	
	var cell = %Pickups.local_to_map(%Pickups.to_local($Player.global_position))

	var data = %Pickups.get_cell_tile_data(cell)
	var points: int = 0
	if data:
		points = data.get_custom_data("points")
		
		# remove tile from cell
		%Pickups.set_cell(cell)
		
		if points > 0:
			_on_score(points)
			_check_win_condition()
		
		if data.get_custom_data("power"):
			_on_flee()


func _on_score(amount: int) -> void:
	Global.score += amount
	%Score.text = str(Global.score)


func _check_win_condition() -> void:
	var won = true
	var cells = %Pickups.get_used_cells()
	for cell in cells:
		var data = %Pickups.get_cell_tile_data(cell)
		if data:
			if (
					data.get_custom_data("points") > 0
					and data.get_custom_data("power") == false
			):
				won = false
				break
	if won:
		print("TODO: Winner!")


func _on_player_died() -> void:
	lives -= 1
	$UI/Lives.text = str(lives)
	print("TODO: Lost a life!")
	if lives == 0:
		print("TODO: Game over!")


# TESTING: Print the current mode and time left
#func _print_mode() -> void:
	#var time_left: float
	#
	#if Global.mode == Global.Mode.SCATTER:
		#time_left = $Timers/Scatter.time_left
	#elif Global.mode == Global.Mode.CHASE:
		#time_left = $Timers/Chase.time_left
	#else:
		#time_left = $Timers/Flee.time_left
	#
	#print("Wave %s: %s (%ss)" % [wave, Global.Mode.keys()[Global.mode], int(time_left)])
	#get_tree().create_timer(1).timeout.connect(_print_mode)
