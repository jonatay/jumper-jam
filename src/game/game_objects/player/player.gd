extends CharacterBody2D
class_name Player

signal player_died

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var viewport_size := get_viewport_rect().size
@onready var diag_label: Label = $Node2D/DiagLabel
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var margin: int = 20
@export var speed: float = 300.0
@export var accelerometer_speed: float = 100.0
@export var gravity: float = 15.0
@export var max_fall_velocity: float = 1000.0
@export var jump_velocity: float = -800.0

var use_acceletometer: bool = false
var dead: bool = false


func _ready() -> void:
	var os_name = OS.get_name()
	if os_name == "Android" or os_name == "iOS":
		use_acceletometer = true

func _process(_delta: float) -> void:
	if velocity.y < 0:
		if animation_player.current_animation != "jump":
			animation_player.play("jump")
	else:
		if animation_player.current_animation != "fall":
			animation_player.play("fall")

func _physics_process(_delta: float) -> void:
	if !dead:
		if use_acceletometer:
			var accel_vector := Input.get_accelerometer()
			#print(accel_vector)
			velocity.x = accel_vector.x * accelerometer_speed
		else:
			var input_vector := Input.get_axis("move_left", "move_right")
			if input_vector:
				velocity.x = input_vector * speed
			else:
				velocity.x = move_toward(velocity.x, 0, speed)

		#gravity
		velocity.y = min(velocity.y + gravity, max_fall_velocity)

	move_and_slide()

	#wrap player around the screen
	if position.x < -margin:
		position.x = viewport_size.x + margin
	elif position.x > viewport_size.x + margin:
		position.x = - margin

	# diag_label.text = "Y: %s" % UtlFunc.add_commas_to_number(int(-position.y))


func jump() -> void:
	velocity.y = jump_velocity
	SoundFX.play_sound("JUMP")
	# UtlLogger.log_message("Jumped! Current height: %s" % UtlFunc.add_commas_to_number(int(-position.y)))


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	die()


func die() -> void:
	SoundFX.play_sound("FALL")
	if not dead:
		dead = true
		collision_shape_2d.set_deferred("disabled", true)
		player_died.emit()

func ressurect() -> void:
	dead = false
	collision_shape_2d.disabled = false
