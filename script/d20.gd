extends Control
var rng = RandomNumberGenerator.new()

@onready var player_hp = $Player/hp
@onready var enemy_hp = $Enemy/hp
@onready var turn_n = $turn_n
@onready var act_p_n = $act_p_n

@onready var player_name = $Player/name
@onready var enemy_name = $Enemy/name

@onready var win_label = $win_label
@onready var win_label_text = $win_label/win_label

@onready var log = $Log

func d20():
	var d20
	d20 = rng.randi_range(1, 20)
	log.text = log.text + "d20 =" + str(d20) + "
"
	return(d20)
	
func d4():
	var d4
	d4 = rng.randi_range(1, 4)
	log.text = log.text + "d4 =" + str(d4) + "
"
	return(d4)
	
func attack(target , entity_hp):
	var hp = int(target.text)
	log.text = log.text + "Start attack:
"
	if d20() > 10 && int(entity_hp.text) > 0:
		hp -= d4()
		if hp > 0:
			target.text = str(hp)
		else:
			target.text = "0"
	log.text = log.text + "End attack
	
"

func _ready():
	log.text = log.text + "Turn 1
"
	pass # Replace with function body.

func _process(delta):
	
	if Input.is_action_just_pressed("ui_accept") == true:
		log.visible = true
	pass

func _on_turn_end_pressed():
	if enemy_hp.text == "0":
		win_label_text.text = player_name.text + " Win!"
		win_label.visible = true
	else:
		if player_hp.text == "0":
			win_label_text.text = enemy_name.text + " Win!"
			win_label.visible = true
		else:
			log.text = log.text + "Enemy
"
			attack(player_hp ,enemy_hp)
			#turn num write
			var turn_num
			turn_num = int(turn_n.text)
			turn_num += 1
			turn_n.text = str(turn_num)
			log.text = log.text + "Turn" + str(turn_num) + "
"	
			#reset action point
			act_p_n.text = "2"
			pass # Replace with function body.

func _on_attack_pressed():
	var action_point = int(act_p_n.text)
	if action_point > 0:
		log.text = log.text + "Player
"
		attack(enemy_hp ,player_hp)
		action_point -= 1
		act_p_n.text = str(action_point)
	pass # Replace with function body.
