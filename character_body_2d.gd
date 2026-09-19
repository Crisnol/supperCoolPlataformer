extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -350.0

# Ajustes de gravedad y pared
const GRAVITY_SCALE = 0.3
const MAX_FALL_SPEED = 500.0
const WALL_SLIDE_SPEED = 100.0

func _physics_process(delta: float) -> void:
	var on_wall = is_on_wall() and not is_on_floor()

	# Aplica la caída según el estado del personaje
	if not is_on_floor():
		if on_wall:
			# Agarre/deslizamiento en pared
			velocity.y = move_toward(velocity.y, WALL_SLIDE_SPEED, get_gravity().y * delta)
		else:
			# Caída estilo flotación espacial
			velocity.y += get_gravity().y * GRAVITY_SCALE * delta
			velocity.y = min(velocity.y, MAX_FALL_SPEED)

	# Manejo del salto (suelo y pared)
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif on_wall:
			# Salta alejándose de la pared usando la normal de la superficie
			var wall_normal = get_wall_normal()
			velocity.x = wall_normal.x * SPEED
			velocity.y = JUMP_VELOCITY

	# Movimiento horizontal
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Revisa todos los choques ocurridos en el fotograma actual
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		# Si colisiona con el nodo del pasto
		if collider is TileMapLayer and collider.name == "TileMapLayer3":
			get_tree().call_deferred("reload_current_scene")
			return

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is TileMapLayer:
			if collider.name == "TileMapLayer3":
				get_tree().call_deferred("reload_current_scene")
				return
			elif collider.name == "TileMapLayer4":
				get_tree().quit()
				return
			
	
