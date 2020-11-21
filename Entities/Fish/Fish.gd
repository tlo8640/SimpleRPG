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
	pass # Replace with function body.
