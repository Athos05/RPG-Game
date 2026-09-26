class_name Enemy
extends Entity

func _init(p_name: String = "Enemy", p_max_hp: int = 10) -> void:
	super._init(p_name, p_max_hp)

func execute_turn(target: Entity) -> void:
	log_message.emit(entity_name + "\n")
	attack(target)
