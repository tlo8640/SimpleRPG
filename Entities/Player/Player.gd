extends KinematicBody2D

signal player_stats_changed
signal player_level_up

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

# Player inventory
enum Potion { HEALTH, MANA }
var health_potions = 0
var mana_potions = 0

# attack variables
var attack_cooldown_time = 1000
var next_attack_time = 0
var attack_damage = 30

# fireball variables
var fireball_damage = 50
var fireball_cooldown_time = 1000
var next_fireball_time = 0
var fireball_scene = preload("res://Entities/Fireball/Fireball.tscn")

# player level and xp
var xp = 0
var xp_next_level = 100
var level = 1

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
				if target.name.find("Skeleton") >= 0:
					# hit skeleton
					target.hit(attack_damage)
				if target.is_in_group("NPCs"):
					# talk
					target.talk()
					return
				if target.name == "Bed":
					# Sleep
					$AnimationPlayer.play("Sleep")
					yield(get_tree().create_timer(1), "timeout")
					health = health_max
					mana = mana_max
					emit_signal("player_stats_changed", self)
					return
			attack_playing = true
			var animation = get_aninmation_direction(last_direction) + "_attack"
			$Sprite.play(animation)
			# play attack sound
			$SoundAttack.play()
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
			# play fireball sound
			$SoundFireball.play()
			# add cooldown_time
			next_fireball_time = now + fireball_cooldown_time
	elif event.is_action_pressed("drink_health"):
		if health_potions > 0:
			health_potions -= 1
			health = min(health + 50, health_max)
			emit_signal("player_stats_changed", self)
			# play sound
			$SoundObject.play()
	elif event.is_action_pressed("drink_mana"):
		if mana_potions > 0:
			mana_potions -= 1
			mana = min(mana + 50, mana_max)
			emit_signal("player_stats_changed", self)
			# play sound
			$SoundObject.play()


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
		$Music.stop()
		$MusicGameOver.play()
	else:
		$AnimationPlayer.play("Hit")

func add_potion(type):
	if type == Potion.HEALTH:
		health_potions += 1
	if type == Potion.MANA:
		mana_potions += 1
	emit_signal("player_stats_changed", self)
	# play sound
	$SoundObject.play()

func add_xp(value):
	xp += value
	# enough xp for level up?
	if xp >= xp_next_level:
		level += 1
		xp_next_level = xp_next_level * 2
		emit_signal("player_level_up")
	emit_signal("player_stats_changed", self)
	
func to_dictionary():
	return {
		"position" : [position.x, position.y ],
		"health" : health,
		"health_max" : health_max,
		"mana" : mana,
		"mana_max" : mana_max,
		"xp" : xp,
		"xp_next_level" : xp_next_level,
		"level" : level,
		"health_potions" : health_potions,
		"mana_potions" : mana_potions
	}

func from_dictionary(data):
	position = Vector2(data.position[0], data.position[1])
	health = data.health
	health_max = data.health_max
	mana = data.mana
	mana_max = data.mana_max
	xp = data.xp
	xp_next_level = data.xp_next_level
	level = data.level
	health_potions = data.health_potions
	mana_potions = data.mana_potions
	
	
