extends CharacterBody2D

@export var tile_size := 32
@export var move_speed := 200.0

@export var data: Resource # Player Resource
@export var combat_scene: PackedScene # Harci jelenet (.tscn)

var target_position: Vector2
var moving := false
var combat_triggered := false

func _ready():
	target_position = global_position.snapped(Vector2(tile_size, tile_size))
	global_position = target_position


func _physics_process(delta):
	if moving:
		global_position = global_position.move_toward(
			target_position,
			move_speed * delta
		)

		if global_position == target_position:
			moving = false

		return

	var direction := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	if direction == Vector2.ZERO:
		combat_triggered = false
		return

	if abs(direction.x) > abs(direction.y):
		direction = Vector2(sign(direction.x), 0)
	else:
		direction = Vector2(0, sign(direction.y))

	var motion := direction * tile_size

	var collision := KinematicCollision2D.new()
	if not test_move(global_transform, motion, collision):
		target_position = global_position + motion
		moving = true
		combat_triggered = false
	else:
		var collider := collision.get_collider()
		if collider is CharacterBody2D and not combat_triggered:
			combat_triggered = true
			# A call_deferred biztosítja, hogy a fizikai lépés után váltsunk jelenetet
			start_combat.call_deferred(collider)


func start_combat(enemy_body: CharacterBody2D) -> void:
	if not combat_scene:
		push_error("Nincs beállítva a combat_scene a játékoson!")
		return

	var tree := get_tree()
	var world_scene := tree.current_scene
	var combat_instance = combat_scene.instantiate()

	# Adatok átadása a harci jelenetnek
	if data is Player:
		combat_instance.player = data

	if "data" in enemy_body and enemy_body.data is Enemy:
		combat_instance.enemy = enemy_body.data.duplicate()

	# Feliratkozunk a harc végét jelző signalra
	combat_instance.combat_finished.connect(
		func(player_won: bool):
			# 1. Visszatesszük az eredeti pályát a jelenetfába
			tree.root.add_child(world_scene)
			tree.current_scene = world_scene
			
			# 2. Ha a játékos nyert, megszüntetjük az ellenfelet
			if player_won and is_instance_valid(enemy_body):
				enemy_body.collision_layer = 0 # Azonnal kikapcsoljuk a hitboxát
				enemy_body.queue_free()
			
			# 3. Töröljük a harci jelenetet és visszaállítjuk a mozgást
			combat_instance.queue_free()
			combat_triggered = false
	)

	# Kivesszük a pályát a fából (a memóriában megmarad!), és betöltjük a harcot
	tree.root.remove_child(world_scene)
	tree.root.add_child(combat_instance)
	tree.current_scene = combat_instance
