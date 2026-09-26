extends CharacterBody2D

@export var tile_size := 32
@export var move_speed := 200.0

var target_position: Vector2
var moving := false

func _ready():
	target_position = global_position.snapped(Vector2(tile_size, tile_size))
	global_position = target_position


func _physics_process(delta):
	# Ha éppen mozgunk a következő tile felé
	if moving:
		global_position = global_position.move_toward(
			target_position,
			move_speed * delta
		)

		if global_position == target_position:
			moving = false

		return

	# Új irány lekérése
	var direction := Input.get_vector(
		"ui_left",
		"ui_right",
		"ui_up",
		"ui_down"
	)

	if direction == Vector2.ZERO:
		return

	# Csak egy irányt engedünk egyszerre (4 irányú mozgás)
	if abs(direction.x) > abs(direction.y):
		direction = Vector2(sign(direction.x), 0)
	else:
		direction = Vector2(0, sign(direction.y))

	# Mozgás vektor kiszámítása
	var motion := direction * tile_size

	# HITBOX ELLENŐRZÉS: Megnézzük, ütközne-e valamibe a karakter a célmezőn.
	# Csak akkor indulunk el, ha a test_move() hamisat (false) ad vissza.
	if not test_move(global_transform, motion):
		target_position = global_position + motion
		moving = true
