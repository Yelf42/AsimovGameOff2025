extends Control


var root

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	root = get_tree().current_scene


func _on_play_pressed() -> void:
	root.startGame()
	self.hide()
