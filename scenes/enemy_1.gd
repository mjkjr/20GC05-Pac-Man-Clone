extends Enemy

const SCATTER_TARGET: Vector2i = Vector2i(27, 0)

var previous_cell: Vector2i = Vector2i.ZERO


func _ready() -> void:
	super()
	previous_cell = %TileMapLayer.local_to_map(%TileMapLayer.to_local(global_position))


func _process(delta: float) -> void:
	var current_cell: Vector2i = %TileMapLayer.local_to_map(%TileMapLayer.to_local(global_position))
	
	# abort early if movement hasn't finished
	if current_cell == previous_cell: return
	previous_cell = current_cell
	print("current cell = %s" % current_cell)
	
	match mode:
		Mode.SCATTER:
			print("Scatter mode...")
			
			# sets a visible tile at the scatter target (for debugging)
			%TileMapLayer.set_cell(SCATTER_TARGET, 0, Vector2i(4, 1))
			
			# TODO
			# get neighbors of current cell
			# if number of traversable neighbors == 2:
			#	move toward the next traversable cell that != previous_cell
			#	done
			# if number of traversable neighbors > 2:
			#	for each traversable cell:
			#		if direction.x > 0:
			#			if cell.x < SCATTER_TARGET.x:
			#				move toward this cell
			#	etc....
			
			direction = Vector2(1, 0)
		Mode.CHASE:
			print("Chase mode...")
		Mode.FLEE:
			print("Flee mode...")
