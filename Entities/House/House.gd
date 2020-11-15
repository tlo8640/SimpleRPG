extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_hideRoof_body_entered(body):
	if body.name == "Player":
		$Roof.hide()
	elif body.name.find("Skeleton") >= 0:
		body.direction = -body.direction
		body.bounce_countdown = 16

func _on_hideRoof_body_exited(body):
	if body.name == "Player":
		$Roof.show()
