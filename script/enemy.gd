class_name Enemy
extends Entity

@export var xp_reward: int = 10

func execute_turn(target: Entity) -> void:
	reset_action_points()
	
	# Addig támad a körében, amíg van akciópontja és mindketten élnek
	while current_action_points > 0 and is_alive() and target.is_alive():
		try_attack(target)
