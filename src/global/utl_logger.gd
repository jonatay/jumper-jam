extends Node

var console_log: Control
var log_label: Label

func _ready() -> void:
	console_log = get_tree().get_first_node_in_group("console_log")
	if console_log:
		log_label = console_log.find_child("LblLog")
		if log_label:
			var sys_datetime: Dictionary = Time.get_datetime_dict_from_system()
			log_label.text = "Start Log at %02d:%02d:%02d\n" % [sys_datetime.hour, sys_datetime.minute, sys_datetime.second]

func _exit_tree() -> void:
	if log_label:
		var sys_datetime: Dictionary = Time.get_datetime_dict_from_system()
		log_label.text += "End Log at %02d:%02d:%02d\n" % [sys_datetime.hour, sys_datetime.minute, sys_datetime.second]

func log_message(message: String) -> void:
	if log_label:
		print("LogEntry: ", message)
		log_label.text += message + "\n"
