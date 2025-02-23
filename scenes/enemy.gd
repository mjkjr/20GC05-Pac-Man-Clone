class_name Enemy
extends CharacterBody2D

const SPEED: float = 10_000.0

# debug tile location in the TileMapLayer
# TODO: create and move this into a TileMapLayer scene
const DEBUG_TILE = Vector2i(7, 3)

enum Mode { SCATTER, CHASE, FLEE }

var mode: Mode = Mode.SCATTER
var mode_changed: bool = false
var direction: Vector2i = Vector2i.RIGHT

# store time so it can be paused by FLEE mode
var current_wave_timer: SceneTreeTimer


func _ready() -> void:
	current_wave_timer = get_tree().create_timer(7.0)
	current_wave_timer.timeout.connect(
		func():
			mode = Mode.CHASE
			mode_changed = true
			current_wave_timer = get_tree().create_timer(20)
			current_wave_timer.timeout.connect(
				func():
					mode = Mode.SCATTER
					mode_changed = true
					current_wave_timer = get_tree().create_timer(7)
					current_wave_timer.timeout.connect(
						func():
							mode = Mode.CHASE
							mode_changed = true
							current_wave_timer = get_tree().create_timer(20)
							current_wave_timer.timeout.connect(
								func():
									mode = Mode.SCATTER
									mode_changed = true
									current_wave_timer = get_tree().create_timer(5)
									current_wave_timer.timeout.connect(
										func():
											mode = Mode.CHASE
											mode_changed = true
											current_wave_timer = get_tree().create_timer(20)
											current_wave_timer.timeout.connect(
												func():
													mode = Mode.SCATTER
													mode_changed = true
													current_wave_timer = get_tree().create_timer(5)
													current_wave_timer.timeout.connect(
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
