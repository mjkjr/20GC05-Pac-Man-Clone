class_name Enemy
extends CharacterBody2D

const SPEED: float = 10_000.0

# debug tile location in the TileMapLayer
# TODO: create and move this into a TileMapLayer scene
const DEBUG_TILE = Vector2i(7, 3)

enum Mode { SCATTER, CHASE, FLEE }

var mode: Mode = Mode.SCATTER
var prior_mode: Mode = Mode.SCATTER
var mode_changed: bool = false
var direction: Vector2i = Vector2i.RIGHT

# store time so it can be paused by FLEE mode
var current_mode_timer: Timer
var flee_mode_timer: Timer


func _ready() -> void:
	flee_mode_timer = Timer.new()
	flee_mode_timer.one_shot = true
	add_child(flee_mode_timer)
	flee_mode_timer.timeout.connect(
		func():
			mode = prior_mode
			mode_changed = true
			%Mode.text = Mode.keys()[mode]
			current_mode_timer.paused = false
	)
	
	current_mode_timer = Timer.new()
	current_mode_timer.one_shot = true
	add_child(current_mode_timer)
	current_mode_timer.start(7.0)
	current_mode_timer.timeout.connect(
		func():
			mode = Mode.CHASE
			mode_changed = true
			%Mode.text = "CHASE (1)"
			current_mode_timer.start(20)
			current_mode_timer.timeout.connect(
				func():
					mode = Mode.SCATTER
					mode_changed = true
					%Mode.text = "SCATTER (2)"
					current_mode_timer.start(7)
					current_mode_timer.timeout.connect(
						func():
							mode = Mode.CHASE
							mode_changed = true
							%Mode.text = "CHASE (2)"
							current_mode_timer.start(20)
							current_mode_timer.timeout.connect(
								func():
									mode = Mode.SCATTER
									mode_changed = true
									%Mode.text = "SCATTER (3)"
									current_mode_timer.start(5)
									current_mode_timer.timeout.connect(
										func():
											mode = Mode.CHASE
											mode_changed = true
											%Mode.text = "CHASE (3)"
											current_mode_timer.start(20)
											current_mode_timer.timeout.connect(
												func():
													mode = Mode.SCATTER
													mode_changed = true
													%Mode.text = "SCATTER (4)"
													current_mode_timer.start(5)
													current_mode_timer.timeout.connect(
														func():
															mode = Mode.CHASE
															mode_changed = true
															%Mode.text = "CHASE (4)"
													)
											)
									)
							)
					)
			)
	)


func _physics_process(delta: float) -> void:
	
	# handle wrapping around the screen
	if position.x > get_viewport_rect().end.x + $CollisionShape2D.shape.get_rect().end.x:
		position.x = get_viewport_rect().position.x - $CollisionShape2D.shape.get_rect().end.x
	elif position.x < get_viewport_rect().position.x- $CollisionShape2D.shape.get_rect().end.x:
		position.x = get_viewport_rect().end.x + $CollisionShape2D.shape.get_rect().end.x
	
	# apply velocity in the movement direction
	if direction.x > 0:
		$AnimatedSprite2D.play("move_right")
		velocity.x = direction.x * SPEED * delta
		velocity.y = 0

	elif direction.x < 0:
		$AnimatedSprite2D.play("move_left")
		velocity.x = direction.x * SPEED * delta
		velocity.y = 0
	
	elif direction.y > 0:
		$AnimatedSprite2D.play("move_down")
		velocity.x = 0
		velocity.y = direction.y * SPEED * delta
	
	elif direction.y < 0:
		$AnimatedSprite2D.play("move_up")
		velocity.x = 0
		velocity.y = direction.y * SPEED * delta
	
	move_and_slide()


func _process(delta: float) -> void:
	if current_mode_timer.paused:
		%ModeTime.text = str(int(flee_mode_timer.time_left))
	else:
		%ModeTime.text = str(int(current_mode_timer.time_left))


func trigger_flee_mode() -> void:
	current_mode_timer.paused = true
	prior_mode = mode
	mode = Mode.FLEE
	mode_changed = true
	%Mode.text = "FLEE"
	flee_mode_timer.start(5)
	# TODO: change enemy appearance
