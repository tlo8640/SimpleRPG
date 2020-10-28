extends KinematicBody2D

# Player movemet speed
export var speed = 75

func _physics_process(delta):
	# get Player input
	var direction: Vector2
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# for diagonal input normalize input for constant speed
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
		
	# apply movement
	var movement = speed * direction * delta
	move_and_collide(movement)
