class_name Entity
extends Resource

signal hp_changed(new_hp: int)
signal ap_changed(new_ap: int)
signal log_message(text: String)

# Inspectorban szerkeszthető tulajdonságok (Player és Enemy is örökli)
@export var entity_name: String = "Entity"
@export var max_hp: int = 10
@export var armor: int = 10 # A fix 10 helyett mostantól ez a védőérték (AC)
@export var max_action_points: int = 1
@export var damage_dice: int = 4

var current_hp: int:
	set(value):
		current_hp = clampi(value, 0, max_hp)
		hp_changed.emit(current_hp)

var current_action_points: int:
	set(value):
		current_action_points = maxi(0, value)
		ap_changed.emit(current_action_points)

var rng := RandomNumberGenerator.new()

func init_entity() -> void:
	current_hp = max_hp
	reset_action_points()

func reset_action_points() -> void:
	current_action_points = max_action_points

func is_alive() -> bool:
	return current_hp > 0

func roll_d20() -> int:
	var result := rng.randi_range(1, 20)
	log_message.emit("d20 = " + str(result) + "\n")
	return result

func roll_damage() -> int:
	var result := rng.randi_range(1, damage_dice)
	log_message.emit("d" + str(damage_dice) + " = " + str(result) + "\n")
	return result

func attack(target: Entity) -> void:
	log_message.emit("Start attack (Target Armor: " + str(target.armor) + "):\n")
	# A támadó d20 dobását a célpont (target) armor értékével hasonlítjuk össze
	if is_alive() and roll_d20() > target.armor:
		var dmg := roll_damage()
		target.take_damage(dmg)
	else:
		log_message.emit("Miss!\n")
	log_message.emit("End attack\n\n")

func try_attack(target: Entity) -> bool:
	if current_action_points <= 0 or not is_alive():
		return false
		
	log_message.emit(entity_name + " (AP: " + str(current_action_points) + ")\n")
	attack(target)
	current_action_points -= 1
	return true

func take_damage(amount: int) -> void:
	current_hp -= amount
