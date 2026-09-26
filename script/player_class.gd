class_name Player
extends Entity

signal ap_changed(new_ap: int)

var max_action_points: int
var current_action_points: int:
	set(value):
		current_action_points = maxi(0, value)
		ap_changed.emit(current_action_points)

func _init(p_name: String = "Player", p_max_hp: int = 10, p_max_ap: int = 1) -> void:
	super._init(p_name, p_max_hp) # Meghívja az Entity konstruktorát
	max_action_points = p_max_ap
	current_action_points = p_max_ap

func reset_action_points() -> void:
	current_action_points = max_action_points

func try_attack(target: Entity) -> bool:
	if current_action_points <= 0:
		return false
		
	log_message.emit(entity_name + "\n")
	attack(target)
	current_action_points -= 1
	return true
