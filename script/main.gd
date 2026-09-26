extends Control

@export var player: Player
@export var enemy: Enemy

@onready var player_hp_label = $Player/hp
@onready var enemy_hp_label = $Enemy/hp
@onready var player_name_label = $Player/name
@onready var enemy_name_label = $Enemy/name

@onready var turn_n_label = $turn_n
@onready var act_p_n_label = $act_p_n
@onready var win_label = $win_label
@onready var win_label_text = $win_label/win_label
@onready var log_label = $Log

# Megakadályozza, hogy a játékos támadjon, amíg az ellenfél köre (az 1 mp-es szünetekkel) tart
var is_enemy_turn: bool = false

var current_turn: int = 1:
	set(value):
		current_turn = value
		if is_node_ready():
			turn_n_label.text = str(current_turn)

func _ready() -> void:
	if not player:
		player = Player.new()
	if not enemy:
		enemy = Enemy.new()
		
	player.init_entity()
	enemy.init_entity()
	
	# Jelzések összekötése a UI-jal
	player.hp_changed.connect(_on_player_hp_changed)
	player.ap_changed.connect(_on_player_ap_changed)
	player.log_message.connect(_append_log)
	
	enemy.hp_changed.connect(_on_enemy_hp_changed)
	enemy.log_message.connect(_append_log)
	
	# Kezdeti UI szövegek beállítása
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

# --- UI frissítő függvények ---

func _on_player_hp_changed(new_hp: int) -> void:
	player_hp_label.text = str(new_hp)

func _on_enemy_hp_changed(new_hp: int) -> void:
	enemy_hp_label.text = str(new_hp)

func _on_player_ap_changed(new_ap: int) -> void:
	act_p_n_label.text = str(new_ap)

func _append_log(text: String) -> void:
	log_label.text += text

# --- Harci vezérlés ---

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
	# Ha épp az ellenfél támad, vagy már vége a játéknak, ne csináljon semmit a gomb
	if is_enemy_turn or check_winner():
		return
		
	if player.try_attack(enemy):
		if check_winner():
			return
			
		# Automata körléptetés, ha elfogyott az akciópont
		if player.auto_end_turn and player.current_action_points <= 0:
			_on_turn_end_pressed()

func _on_turn_end_pressed() -> void:
	if is_enemy_turn or check_winner():
		return
		
	is_enemy_turn = true
	
	# Megvárjuk, amíg az ellenfél végrehajtja az összes támadását (1 mp-es szünetekkel)
	await enemy.execute_turn(player)
	
	if check_winner():
		is_enemy_turn = false
		return
		
	# Új kör indítása és a játékos AP-jának visszatöltése
	current_turn += 1
	_append_log("Turn " + str(current_turn) + "\n")
	player.reset_action_points()
	is_enemy_turn = false
