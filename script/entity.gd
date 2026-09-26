class_name Entity
extends RefCounted

signal hp_changed(new_hp: int)
signal log_message(text: String)

var entity_name: String
var max_hp: int
var current_hp: int:
	set(value):
		current_hp = clampi(value, 0, max_hp)
		hp_changed.emit(current_hp)

var rng := RandomNumberGenerator.new()

# Konstruktor: amikor létrehozzuk kódban (.new()), itt adjuk meg az alapértékeket
func _init(p_name: String = "Entity", p_max_hp: int = 10) -> void:
	entity_name = p_name
	max_hp = p_max_hp
	current_hp = p_max_hp

func is_alive() -> bool:
	return current_hp > 0

func roll_d20() -> int:
	var result := rng.randi_range(1, 20)
	log_message.emit("d20 = " + str(result) + "\n")
	return result

func roll_damage() -> int:
	var result := rng.randi_range(1, 4)
	log_message.emit("d4 = " + str(result) + "\n")
	return result

func attack(target: Entity) -> void:
	log_message.emit("Start attack:\n")
	if is_alive() and roll_d20() > 10:
		var dmg := roll_damage()
		target.take_damage(dmg)
	log_message.emit("End attack\n\n")

func take_damage(amount: int) -> void:
	current_hp -= amount
