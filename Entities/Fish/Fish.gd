extends KinematicBody2D

# node refernce to player
var player

# random number generator
var rng = RandomNumberGenerator.new()

# movement variables
export var speed = 25
var direction : Vector2
var last_direction = Vector2(0,1)
var bounce_countdown = 0

func _ready():
	player = get_tree().root.get_node("Root/Player")
	rng.randomize()
	
func _process(delta):
	pass


func _on_Timer_timeout():
	# calculatate fish position relative to player postition
	# (later we have to calculate relative to player fishing rod)
	var player_relative_position = player.position - position
	
	if player_relative_position.length() <= 16:
		# player is near, don't move, but turn to it
		direction = Vector2.ZERO
		last_direction = player_relative_position.normalized()
	elif player_relative_position.length() <= 200 and bounce_countdown == 0:
		# player is within range, move to player
		direction = player_relative_position.normalized()
	elif bounce_countdown == 0:
		# if player is too far away, decide randomly wether to stand still or move
		var random_number = rng.randf()
		if random_number < 0.01:
			direction = Vector2.ZERO
		elif random_number < 0.1:
			direction = Vector2.DOWN.rotated(rng.randf() * 2 * PI)
			
	# update bounce_countdown
	if bounce_countdown > 0:
		bounce_countdown -= 1
		
func _physics_process(delta):
	var movement = direction * speed * delta
	
	var collision = move_and_collide(movement)
	
	if collision != null:
		direction = direction.rotated(rng.randf_range(PI/4, PI/2))
		bounce_countdown = rng.randi_range(2, 5)
	animates_fish(direction)
		
func get_animation_direction(direction: Vector2):
	var norm_direction = direction.normalized()
	if norm_direction.y >= 0.707:
		return "down"
	elif norm_direction.y <= -0.707:
		return "up"
	elif norm_direction.x >= 0.707:
		return "right"
	elif norm_direction.x <= -0.707:
		return "left"
	return "down"

func animates_fish(direction: Vector2):
	if direction != Vector2.ZERO:
		last_direction = direction
		
		var animation = get_animation_direction(last_direction)
		$AnimatedSprite.play(animation)
	else:
		var animation = get_animation_direction(last_direction)
		$AnimatedSprite.play(animation)
	
