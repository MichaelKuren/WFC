extends CharacterBody3D

@onready var camera_root: Marker3D = $CameraRoot
@onready var camera: Camera3D = $CameraRoot/Camera3D

var SPEED = 5.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta: float) -> void:
	camera_root.global_transform = global_transform

	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_forward"):
		direction += -camera.global_transform.basis.z
	if Input.is_action_pressed("move_backward"):
		direction += camera.global_transform.basis.z
	if Input.is_action_pressed("move_left"):
		direction += -transform.basis.x
	if Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	if Input.is_action_pressed("move_up"):
		direction += Vector3.UP
	if Input.is_action_pressed("move_down"):
		direction += -Vector3.UP

	if direction.length_squared() > 0:
		direction = direction.normalized()

	velocity = direction * SPEED
	
	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			camera.rotation.x -= deg_to_rad(event.relative.y * 0.15)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
			rotation.y -= deg_to_rad(event.relative.x * 0.15)

		if Input.is_action_pressed("quit"):
			get_tree().quit()
