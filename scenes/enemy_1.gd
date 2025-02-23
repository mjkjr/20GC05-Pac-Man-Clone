extends Enemy

const SCATTER_TARGET: Vector2i = Vector2i(27, 0)

enum Direction { RIGHT, DOWN, LEFT, UP }

var _target_cell: Vector2i = SCATTER_TARGET

var _current_cell: Vector2i = Vector2i.ZERO
var _previous_cell: Vector2i = Vector2i.ZERO


func _ready() -> void:
	super()
	$HitBox.body_entered.connect(_cell_entered)
	_previous_cell = %Maze.local_to_map(%Maze.to_local(global_position))
	_previous_cell.x -= 1


func _cell_entered(_body: Node2D) -> void:
	
	_current_cell = %Maze.local_to_map(%Maze.to_local(global_position))
	
	#print("Current Cell = %s\nPrevious Cell = %s" % [_current_cell, _previous_cell])
	
	# Determine target cell
	if mode_changed:
		# reverse direction on mode change
		_target_cell = _previous_cell
	else:
		match mode:
			Mode.SCATTER:
				_target_cell = SCATTER_TARGET
			Mode.CHASE:
				# player's current location
				_target_cell = %Maze.local_to_map(%Maze.to_local(%Player.global_position))
			Mode.FLEE:
				# No target; select at random which turns to take
				_target_cell = Vector2i.ZERO
	
	# FOR TESTING: sets the debug tile at the target cell
	#if _target_cell != Vector2i.ZERO:
		#%Maze.set_cell(_target_cell, 0, DEBUG_TILE)
		#if _target_cell != SCATTER_TARGET:
			#%Maze.set_cell(SCATTER_TARGET)
	
	# Navigation
	# Gets neighboring cells
	var neighbors: Array[Vector2i]
	neighbors.resize(Direction.size())
	neighbors[Direction.UP] = %Maze.get_neighbor_cell(_current_cell, TileSet.CELL_NEIGHBOR_TOP_SIDE)
	neighbors[Direction.DOWN] = %Maze.get_neighbor_cell(_current_cell, TileSet.CELL_NEIGHBOR_BOTTOM_SIDE)
	neighbors[Direction.LEFT] = %Maze.get_neighbor_cell(_current_cell, TileSet.CELL_NEIGHBOR_LEFT_SIDE)
	neighbors[Direction.RIGHT] = %Maze.get_neighbor_cell(_current_cell, TileSet.CELL_NEIGHBOR_RIGHT_SIDE)
	
	#print("Neighbors = %s" % [neighbors])
	
	# Get the possible routes (ordered per Direction enum)
	var routes: Array[bool] = [false, false, false, false]

	for i in Direction.values():
		# discard direction already traveled
		# except during a mode change
		if (
				neighbors[i] != _previous_cell
				or mode_changed
		):
			var cell_data = %Maze.get_cell_tile_data(neighbors[i])
			if cell_data:
				if (
					not (
						i == Direction.UP
						and cell_data.get_custom_data("one_way")
					)
				):
					routes[i] = cell_data.get_custom_data("traversable")
	
	# reset mode changed flag only after determing the available routes
	mode_changed = false
	
	var num_routes: int = routes.count(true)
	#print("%s Routes = %s" % [num_routes, routes])
	
	if num_routes == 1:
		match routes.find(true):
			Direction.LEFT:
				direction = Vector2i.LEFT
			Direction.RIGHT:
				direction = Vector2i.RIGHT
			Direction.UP:
				direction = Vector2i.UP
			Direction.DOWN:
				direction = Vector2i.DOWN
	elif num_routes > 1:
		# calculate route distances to target cell
		var distances: Array[float]
		distances.resize(Direction.size())
		for i in Direction.values():
			if routes[i]:
				distances[i] = neighbors[i].distance_to(_target_cell)
			else:
				distances[i] = 999
			#print("distances[%s] = %s" % [i, distances[i]])
		
		# choose the shortest distance route
		match distances.find(distances.min()):
			Direction.LEFT:
				direction = Vector2i.LEFT
			Direction.RIGHT:
				direction = Vector2i.RIGHT
			Direction.UP:
				direction = Vector2i.UP
			Direction.DOWN:
				direction = Vector2i.DOWN
	
	# update this last
	_previous_cell = _current_cell
