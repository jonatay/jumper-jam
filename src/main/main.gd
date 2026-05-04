extends Node
class_name Main

@onready var screens: Screens = $Screens
@onready var game: Game = $Game

func _ready() -> void:
	screens.new_game.connect(game.new_game)
	screens.start_game.connect(game.start_game)
	game.game_over.connect(screens.game_over)
	screens.reset_game.connect(game.reset_game)
