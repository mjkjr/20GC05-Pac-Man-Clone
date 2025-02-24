class_name Enemy
extends CharacterBody2D

# debug tile location in the TileMapLayer
# TODO: create and move this into a TileMapLayer scene
const DEBUG_TILE = Vector2i(7, 3)

const FLEE_DURATION: int = 10

# TODO: Move Mode handling to the gameplay scene and call methods on the enemy
# scenes to trigger their behaviors
enum Mode { SCATTER, CHASE, FLEE }
enum Speed { NORMAL = 10_000, FLEE = 7_500 }

var mode: Mode = Mode.SCATTER
var prior_mode: Mode = Mode.SCATTER
var mode_changed: bool = false
var direction: Vector2i = Vector2i.RIGHT
var speed: int = Speed.NORMAL

# store time so it can be paused during FLEE mode
# TODO: keep track of "waves" so timer isn't reset if a power pellet is used after last "wave"
var current_mode_timer: Timer
var flee_mode_timer: Timer


func _ready() -> void:
	# TESTING: Print the current mode and time left
	get_tree().create_timer(0).timeout.connect(print_mode)

	flee_mode_timer = Timer.new()
	flee_mode_timer.one_shot = true
	add_child(flee_mode_timer)
	flee_mode_timer.timeout.connect(
		func():
			mode = prior_mode
			mode_changed = true
			current_mode_timer.paused = false
			speed = Speed.NORMAL
	)
	
	current_mode_timer = Timer.new()
	current_mode_timer.one_shot = true
	add_child(current_mode_timer)
	current_mode_timer.start(7.0)
	current_mode_timer.timeout.connect(
		func():
			mode = Mode.CHASE
			mode_changed = true
			current_mode_timer.start(20)
			current_mode_timer.timeout.connect(
				func():
					mode = Mode.SCATTER
					mode_changed = true
					current_mode_timer.start(7)
					current_mode_timer.timeout.connect(
						func():
							mode = Mode.CHASE
							mode_changed = true
							current_mode_timer.start(20)
							current_mode_timer.timeout.connect(
								func():
									mode = Mode.SCATTER
									mode_changed = true
									current_mode_timer.start(5)
									current_mode_timer.timeout.connect(
										func():
											mode = Mode.CHASE
											mode_changed = true
											current_mode_timer.start(20)
											current_mode_timer.timeout.connect(
												func():
													mode = Mode.SCATTER
													mode_changed = true
													current_mode_timer.start(5)
													current_mode_timer.timeout.connect(
														func():
															mode = Mode.CHASE
															mode_changed = true
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
		velocity.x = direction.x * speed * delta
		velocity.y = 0

	elif direction.x < 0:
		$AnimatedSprite2D.play("move_left")
		velocity.x = direction.x * speed * delta
		velocity.y = 0
	
	elif direction.y > 0:
		$AnimatedSprite2D.play("move_down")
		velocity.x = 0
		velocity.y = direction.y * speed * delta
	
	elif direction.y < 0:
		$AnimatedSprite2D.play("move_up")
		velocity.x = 0
		velocity.y = direction.y * speed * delta
	
	move_and_slide()


func flee() -> void:
	current_mode_timer.paused = true
	prior_mode = mode
	mode = Mode.FLEE
	mode_changed = true
	flee_mode_timer.start(FLEE_DURATION)
	speed = Speed.FLEE
	# TODO: change enemy appearance


# TESTING: Print the current mode and time left
func print_mode() -> void:
	var time_left: float
	
	if current_mode_timer.paused:
		time_left = flee_mode_timer.time_left
	else:
		time_left = current_mode_timer.time_left
	
	print("%s (%s)" % [Mode.keys()[mode], int(time_left)])
	get_tree().create_timer(1).timeout.connect(print_mode)
