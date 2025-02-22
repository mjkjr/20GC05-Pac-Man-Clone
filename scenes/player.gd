extends CharacterBody2D


const SPEED: float = 10_000.0
const FRICTION: float = 1_000.0

var previous_movement_direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	$AnimatedSprite2D.play("idle_down")


func _physics_process(delta: float) -> void:
	
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# store most recent movement direction to properly select idle animation later
	if direction != Vector2.ZERO:
		previous_movement_direction = direction
	
	# handle wrapping around the screen
	if %Player.position.x > get_viewport_rect().end.x + %Player/CollisionShape2D.shape.get_rect().end.x:
		%Player.position.x = get_viewport_rect().position.x - %Player/CollisionShape2D.shape.get_rect().end.x
	elif %Player.position.x < get_viewport_rect().position.x- %Player/CollisionShape2D.shape.get_rect().end.x:
		%Player.position.x = get_viewport_rect().end.x + %Player/CollisionShape2D.shape.get_rect().end.x
	
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
	
	# no direction buttons being pressed
	else:
		
		# apply friction
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		velocity.y = move_toward(velocity.y, 0, FRICTION * delta)
		
		# idle if not moving
		if velocity == Vector2.ZERO:
			if previous_movement_direction.x > 0:
				%Player/AnimatedSprite2D.play("idle_right")
			elif previous_movement_direction.x < 0:
				%Player/AnimatedSprite2D.play("idle_left")
			elif previous_movement_direction.y > 0:
				%Player/AnimatedSprite2D.play("idle_down")
			elif previous_movement_direction.y < 0:
				%Player/AnimatedSprite2D.play("idle_up")
	
	# do velocity-based movement and collision handling
	move_and_slide()


func _on_hit_box_body_entered(body: Node2D) -> void:
	print("Hitbox collision detected!")
