extends Control

# UI referenciák (csak a megjelenítésért felelnek)
@onready var player_hp_label: Label = $Player/hp
@onready var enemy_hp_label: Label = $Enemy/hp
@onready var player_name_label: Label = $Player/name
@onready var enemy_name_label: Label = $Enemy/name

@onready var turn_n_label: Label = $turn_n
@onready var act_p_n_label: Label = $act_p_n
@onready var win_label: Control = $win_label
@onready var win_label_text: Label = $win_label/win_label
@onready var log_label: TextEdit = $Log

# Tiszta, UI-független adatosztályok példányai
var player: Player
var enemy: Enemy

var current_turn: int = 1:
	set(value):
		current_turn = value
		if is_node_ready():
			turn_n_label.text = str(current_turn)

func _ready() -> void:
	# 1. Létrehozzuk a két példányt kódból: (Név, Max HP, Max AP)
	player = Player.new("Hero", 12, 1)
	enemy = Enemy.new("Goblin", 8)
	
	# 2. Rákötjük a jelzéseiket (signal) a UI-frissítő függvényekre
	player.hp_changed.connect(_on_player_hp_changed)
	player.ap_changed.connect(_on_player_ap_changed)
	player.log_message.connect(_append_log)
	
	enemy.hp_changed.connect(_on_enemy_hp_changed)
	enemy.log_message.connect(_append_log)
	
	# 3. Kezdőértékek kiírása a UI-ra
	player_name_label.text = player.entity_name
	player_hp_label.text = str(player.current_hp)
	act_p_n_label.text = str(player.current_action_points)
	
	enemy_name_label.text = enemy.entity_name
	enemy_hp_label.text = str(enemy.current_hp)
	
	current_turn = 1
	turn_n_label.text = str(current_turn)
	_append_log("Turn 1\n")

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		log_label.visible = true

# --- UI frissítő függvények (automatikusan lefutnak, ha változik az adat) ---

func _on_player_hp_changed(new_hp: int) -> void:
	player_hp_label.text = str(new_hp)

func _on_enemy_hp_changed(new_hp: int) -> void:
	enemy_hp_label.text = str(new_hp)

func _on_player_ap_changed(new_ap: int) -> void:
	act_p_n_label.text = str(new_ap)

func _append_log(text: String) -> void:
	log_label.text += text

# --- Játékmenet vezérlés ---

func check_winner() -> bool:
	if not enemy.is_alive():
		win_label_text.text = player.entity_name + " Win!"
		win_label.visible = true
		return true
	elif not player.is_alive():
		win_label_text.text = enemy.entity_name + " Win!"
		win_label.visible = true
		return true
	return false

func _on_attack_pressed() -> void:
	if player.try_attack(enemy):
		check_winner()

func _on_turn_end_pressed() -> void:
	if check_winner():
		return
		
	enemy.execute_turn(player)
	
	if check_winner():
		return
		
	current_turn += 1
	_append_log("Turn " + str(current_turn) + "\n")
	player.reset_action_points()
