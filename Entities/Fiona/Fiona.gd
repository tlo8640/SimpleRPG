extends StaticBody2D

enum QuestStatus { NOT_STARTED, STARTED, COMPLETED }
var quest_status = QuestStatus.NOT_STARTED
var dialogue_state = 0
var necklace_found = false

var dialoguePopup
var player

enum Potion { HEALTH, MANA }

func _ready():
	dialoguePopup = get_tree().root.get_node("Root/CanvasLayer/DialoguePopup")
	player = get_tree().root.get_node("Root/Player")
	
func talk(answer = ""):
	# set animation to "talk"
	$AnimatedSprite.play("talk")
	
	# set dialogue popup npc to fiona
	dialoguePopup.npc = self
	dialoguePopup.npc_name = "Fiona"
	
	# show current dialogue
	match quest_status:
		QuestStatus.NOT_STARTED:
			match dialogue_state:
				0: 
					# update dialogue tree state
					dialogue_state = 1
					# show dialogue popup
					dialoguePopup.dialogue = "Hello adventurer! I lost my necklase, can you find it for me?"
					dialoguePopup.answers = "[A] Yes [B] No"
					dialoguePopup.open()
				1:
					match answer:
						"A":
							# update dialogue tree state
							dialogue_state = 2
							# show dialogue popup
							dialoguePopup.dialogue = "Thank You!"
							dialoguePopup.answers = "[A] Bye"
							dialoguePopup.open()
						"B":
							# update dialogue tree state
							dialogue_state = 3
							# show dialogue popup
							dialoguePopup.dialogue = "If you change your mind, you will find me here."
							dialoguePopup.answers = "[A] Bye"
							dialoguePopup.open()
				2:
					# update dialogue tree state
					dialogue_state = 0
					quest_status = QuestStatus.STARTED
					# close dialogue popup
					dialoguePopup.close()
					# set fionas animation to idle
					$AnimatedSprite.play("idle")
				3:
					# update dialogue tree state
					dialogue_state = 0
					# close dialogue popup
					dialoguePopup.close()
					# set fionas animation to idle
					$AnimatedSprite.play("idle")
		QuestStatus.STARTED:
			match dialogue_state:
				0:
					# update dialogue tree state
					dialogue_state = 1
					# show dialogue popup
					dialoguePopup.dialogue = "Did you find my necklace?"
					if necklace_found:
						dialoguePopup.answers = "[A] Yes [B] No"
					else:
						dialoguePopup.answers = "[A] No"
					dialoguePopup.open()
				1:
					if necklace_found and answer == "A":
						# update dialogie tree state
						dialogue_state = 2
						dialoguePopup.dialogue = "You are my hero! Please take this potion as a sign of my gratitude!"
						dialoguePopup.answers = "[A] Thank You!"
						dialoguePopup.open()
					else:
						# update dialogue tree state
						dialogue_state = 3
						dialoguePopup.dialogue = "Please, find it!"
						dialoguePopup.answers = "[A] I will!"
						dialoguePopup.open()
				2:
					# update dialogue tree state
					dialogue_state = 0
					quest_status = QuestStatus.COMPLETED
					# close dialogue popup
					dialoguePopup.close()
					# set fionas animation to idle
					$AnimatedSprite.play("idle")
					# add potion and xp to player
					# little time out added in case level up popup wil appear
					yield(get_tree().create_timer(0.5), "timeout")
					player.add_potion(Potion.HEALTH)
					player.add_xp(50)
				3:
					# update dialogie tree state
					dialogue_state = 0
					# close popup
					dialoguePopup.close()
					# fiona animation to idle
					$AnimatedSprite.play("idle")
		QuestStatus.COMPLETED:
			match dialogue_state:
				0:
					# update dialogue tree state
					dialogue_state = 1
					# show dialogue popup
					dialoguePopup.dialogue = "Thanks again for your help!"
					dialoguePopup.answers = "[A] Bye"
					dialoguePopup.open()
				1:
					# update dilogue tree state
					dialogue_state = 0
					# close popup
					dialoguePopup.close()
					# animation to idle
					$AnimatedSprite.play("idle")
					
func to_dictionary():
	return {
		"quest_status" : quest_status,
		"necklace_found" : necklace_found
	}

func from_dictionary(data):
	quest_status = int(data.quest_status)
	necklace_found = data.necklace_found
