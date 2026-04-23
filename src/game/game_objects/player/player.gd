extends CharacterBody2D
class_name Player


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var viewport_size := get_viewport_rect().size
@onready var diag_label: Label = $Node2D/DiagLabel

@export var margin: int = 20
@export var speed: float = 300.0
@export var gravity: float = 15.0
@export var max_fall_velocity: float = 1000.0
@export var jump_velocity: float = -800.0

func _process(_delta: float) -> void:
	if velocity.y < 0:
		if animation_player.current_animation != "jump":
			animation_player.play("jump")
	else:
		if animation_player.current_animation != "fall":
			animation_player.play("fall")

func _physics_process(_delta: float) -> void:
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

	diag_label.text = "Y: %s" % add_commas_to_number(int(-position.y))


func jump() -> void:
	velocity.y = jump_velocity


func add_commas_to_number(input_number: int) -> String:
	var number_as_string: String = str(input_number)
	var output_string: String = ""
	var last_index: int = number_as_string.length() - 1
	#For each digit in the number...
	for index in range(number_as_string.length()):
		#add that digit to the output string, and then...
		output_string = output_string + number_as_string.substr(index, 1)
		#if the index is at the thousandths, millions, billionths place, etc.
		#i.e. where you would put a comma, then insert a comma after that digit.
		if (last_index - index) % 3 == 0 and index != last_index:
			output_string = output_string + ","
	return output_string
