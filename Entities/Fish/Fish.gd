extends KinematicBody2D

# random number generator
var rng = RandomNumberGenerator.new()

# movement variables
export var speed = 25
var direction : Vector2
var last_direction = Vector2(0,1)

func _ready():
	rng.randomize()
	
func _process(delta):
	
