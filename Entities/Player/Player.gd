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

# attack variables
var attack_cooldown_time = 1000
var next_attack_time = 0
var attack_damage = 30

# fireball variables
var fireball_damage = 50
var fireball_cooldown_time = 1000
var next_fireball_time = 0
var fireball_scene = preload("res://Entities/Fireball/Fireball.tscn")

func _ready():
	emit_signal("player_stats_changed", self)
	$Sprite.set_modulate(Color(1,1,1,1))

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
	# point raycast2d towards player movement direction
	if direction != Vector2.ZERO:
		$RayCast2D.cast_to = direction.normalized() * 8

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
		var now = OS.get_ticks_msec()
		if now >= next_attack_time:
			# if something to attack?
			var target = $RayCast2D.get_collider()
			if target != null:
				if target.name.find("skeleton"):
					# hit skeleton
					target.hit(attack_damage)
			attack_playing = true
			var animation = get_aninmation_direction(last_direction) + "_attack"
			$Sprite.play(animation)
			# add cooldown time
			next_attack_time = now + attack_cooldown_time
	elif event.is_action_pressed("fireball"):
		var now = OS.get_ticks_msec()
		if mana >= 25 and now >= next_fireball_time:
			mana = mana - 25
			emit_signal("player_stats_changed", self)
			attack_playing = true
			var animation = get_aninmation_direction(last_direction) + "_fireball"
			$Sprite.play(animation)
			# add cooldown_time
			next_fireball_time = now + fireball_cooldown_time

func _on_Sprite_animation_finished():
	attack_playing = false
	# instantiate Fireball
	if $Sprite.animation.ends_with("_fireball"):
		var fireball = fireball_scene.instance()
		fireball.attack_damage = fireball_damage
		fireball.direction = last_direction.normalized()
		fireball.position = position + last_direction.normalized() * 4
		get_tree().root.get_node("Root").add_child(fireball)
	
	
func hit(damage):
	health -= damage
	emit_signal("player_stats_changed", self)
	if health <= 0:
		set_process(false)
		$AnimationPlayer.play("Game Over")
	else:
		$AnimationPlayer.play("Hit")
		
	

