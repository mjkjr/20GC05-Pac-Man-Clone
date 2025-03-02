class_name Enemy
extends CharacterBody2D

# debug tile location in the TileMapLayer
# TODO: create and move this into a TileMapLayer scene
const DEBUG_TILE = Vector2i(7, 3)

enum Speed { NORMAL = 10_000, FLEE = 5_000 }

var direction: Vector2i = Vector2i.RIGHT

var flee_mode_warning: bool = false
var dead: bool = false


func _physics_process(delta: float) -> void:
	var speed: int = Speed.NORMAL
	
	if Global.mode == Global.Mode.FLEE:
		speed = Speed.FLEE
	
	# handle wrapping around the screen
	if position.x > get_viewport_rect().end.x + $CollisionShape2D.shape.get_rect().end.x:
		position.x = get_viewport_rect().position.x - $CollisionShape2D.shape.get_rect().end.x
	elif position.x < get_viewport_rect().position.x- $CollisionShape2D.shape.get_rect().end.x:
		position.x = get_viewport_rect().end.x + $CollisionShape2D.shape.get_rect().end.x
	
	var animation_modifier: String = ""
	if (
				Global.mode == Global.Mode.FLEE
				and not dead
		):
			if flee_mode_warning:
				animation_modifier = "_flee_warning"
			else:
				animation_modifier = "_flee"
	
	# apply velocity in the movement direction
	if direction.x > 0:
		$AnimatedSprite2D.play("move_right" + animation_modifier)
		velocity.x = direction.x * speed * delta
		velocity.y = 0

	elif direction.x < 0:
		$AnimatedSprite2D.play("move_left" + animation_modifier)
		velocity.x = direction.x * speed * delta
		velocity.y = 0
	
	elif direction.y > 0:
		$AnimatedSprite2D.play("move_down" + animation_modifier)
		velocity.x = 0
		velocity.y = direction.y * speed * delta
	
	elif direction.y < 0:
		$AnimatedSprite2D.play("move_up" + animation_modifier)
		velocity.x = 0
		velocity.y = direction.y * speed * delta
	
	move_and_slide()


func flee_warning() -> void:
	flee_mode_warning = true


func flee_done() -> void:
	flee_mode_warning = false


func kill() -> void:
	dead = true
