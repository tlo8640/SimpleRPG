extends StaticBody2D

enum QuestStatus { NOT_STARTED, STARTED, COMPLETED }
var quest_status = QuestStatus.NOT_STARTED
var dialogue_state = 0
var necklace_found = false
