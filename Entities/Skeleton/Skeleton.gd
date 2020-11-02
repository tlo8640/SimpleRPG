extends KinematicBody2D

# Node reference
var player

# random number generator
var rng = RandomNumberGenerator.new()

# movement variables
export var speed = 25
var direction : Vector2
var last_direction = Vector2(0, 1)
var bounce_countdown = 0
var other_animation_playing = false

func _ready():
	player = get_tree().root.get_node("Root/Player")
	rng.randomize()
	
	

func _on_Timer_timeout():
	# calculate position in relation to player
	var player_relative_position = player.position - position
	
	if player_relative_position.length() <= 16:
		direction = Vector2.ZERO
		last_direction = player_relative_position.normalized()
	elif player_relative_position.length() <= 100 and bounce_countdown == 0:
		direction = player_relative_position.normalized()
	elif bounce_countdown == 0:
		# player too far
		var random_number = rng.randf()
		if random_number < 0.5:
			direction = Vector2.ZERO
		elif random_number < 0.1:
			direction = Vector2.DOWN.rotated(rng.randf() * 2 * PI)
			
	# update bounce_countdown
	if bounce_countdown > 0:
		bounce_countdown = bounce_countdown - 1

func _physics_process(delta):
	var movement = direction * speed * delta
	var collision = move_and_collide(movement)
	if collision != null and collision.collider.name != "Player":
		direction = direction.rotated(rng.randf_range(PI/4, PI/2))
		bounce_countdown = rng.randi_range(2, 5)
	if not other_animation_playing:
		animates_monster(direction)
		
func get_aninmation_direction(direction: Vector2):
	var norm_direction = direction.normalized()
	if norm_direction.y >= 0.707:
		return "down"
	elif norm_direction.y <= -0.707:
		return "up"
	elif norm_direction.x <= -0.707:
		return "left"
	elif norm_direction.x >= 0.707:
		return "right"
	return "down"

func animates_monster(direction: Vector2):
	if direction != Vector2.ZERO:
		last_direction = direction
		# choose correct direction animation
		var animation = get_aninmation_direction(last_direction) + "_walk"
		$AnimatedSprite.play(animation)
	else:
		# choose right idle animation (based on last movement)
		var animation = get_aninmation_direction(last_direction) + "_idle"
		$AnimatedSprite.play(animation)

func arise():
	other_animation_playing = true
	$AnimatedSprite.play("birth")


func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "birth":
		$AnimatedSprite.animation = "down_idle"
		$Timer.start()
	other_animation_playing = false

