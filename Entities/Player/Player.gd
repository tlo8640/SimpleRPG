extends KinematicBody2D

signal player_stats_changed

# Player movement speed
export var speed = 75

# initial values when instancing object
var last_direction = Vector2(0, 1)
var attack_playing = false

# player stats
var health = 100
var health_max = 100
var health_regeneration = 1
var mana = 100
var mana_max = 100
var mana_regenration = 2

func _ready():
	emit_signal("player_stats_changed", self)

func _process(delta):
	# regenerate mana
	var new_mana = min(mana + mana_regenration * delta, mana_max)
	if mana != new_mana:
		mana = new_mana
		emit_signal("player_stats_changed", self)
	var new_health = min(health + health_regeneration * delta, health_max)
	if health != new_health:
		health = new_health
		emit_signal("player_stats_changed", self)

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
	if attack_playing:
		movement = movement * 0.3
	move_and_collide(movement)
	# animate player
	if not attack_playing:
		animates_player(direction)

func animates_player(direction: Vector2):
	if direction != Vector2.ZERO:
		# update last direction ( and prevent analog stick "bouncing")
		last_direction = 0.5 * last_direction + 0.5 * direction
		# choose correct direction animation
		var animation = get_aninmation_direction(last_direction) + "_walk"
		# set frame from analog stick (has to be adjusted for keyboard input)
		#$Sprite.frames.set_animation_speed(animation, 2 + 8 * animation.length())
		$Sprite.play(animation)
	else:
		# choose right idle animation (based on last movement)
		var animation = get_aninmation_direction(last_direction) + "_idle"
		$Sprite.play(animation)

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

func _input(event):
	if event.is_action_pressed("attack"):
		attack_playing = true
		var animation = get_aninmation_direction(last_direction) + "_attack"
		$Sprite.play(animation)
	elif event.is_action_pressed("fireball"):
		if mana >= 25:
			mana = mana - 25
			emit_signal("player_stats_changed", self)
			attack_playing = true
			var animation = get_aninmation_direction(last_direction) + "_fireball"
			$Sprite.play(animation)

func _on_Sprite_animation_finished():
	attack_playing = false
	

