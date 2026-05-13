extends Node
class_name IAPManager

signal unlock_new_skin

func purchase_skin() -> void:
	# Simulate a purchase process
	#  await get_tree().create_timer(1.0).timeout
	unlock_new_skin.emit()
