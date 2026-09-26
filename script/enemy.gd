class_name Enemy
extends Entity

# Hány másodpercet várjon az ellenfél az egyes támadásai között (Inspectorban állítható)
@export var action_delay: float = 1.0
@export var xp_reward: int = 10

func execute_turn(target: Entity) -> void:
	reset_action_points()
	
	# Addig támad, amíg van akciópontja és mindketten élnek
	while current_action_points > 0 and is_alive() and target.is_alive():
		# Várakozás a megadott másodpercig (alapból 1.0 mp)
		await Engine.get_main_loop().create_timer(action_delay).timeout
		
		if is_alive() and target.is_alive():
			try_attack(target)
