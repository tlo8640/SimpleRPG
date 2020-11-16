extends Node2D

var selected_menu = 0

func change_menu_color():
	$NewGame.color =  Color.gray
	$LoadGame.color = Color.gray
	$QuitGame.color = Color.gray
	
	match selected_menu:
		0:
			$NewGame.color = Color.greenyellow
		1:
			$LoadGame.color = Color.greenyellow
		2:
			$QuitGame.color = Color.greenyellow

func _ready():
	change_menu_color()
	
func _input(event):
	if Input.is_action_just_pressed("ui_down"):
		selected_menu = (selected_menu + 1) % 3
		change_menu_color()
	elif Input.is_action_just_pressed("ui_up"):
		if selected_menu > 0:
			selected_menu -= 1
		else:
			selected_menu = 3
		change_menu_color()
	elif Input.is_action_just_pressed("attack"):
		match selected_menu:
			0:
				# new game
				get_tree().change_scene("res://Scenes/Main.tscn")
			1:
				# load game
				var next_level_resource = load("res://Scenes/Main.tscn")
				var next_level = next_level_resource.instance()
				next_level.load_saved_game = true
				get_tree().root.call_deferred("add_child", next_level)
				queue_free()
			2:
				# quit game
				get_tree().quit()
