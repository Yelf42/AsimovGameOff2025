extends Node2D

@export var music_volume: float = -12.0
@export var paused_music_volume: float = -12.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (get_tree().paused):
		$Paused.volume_db = paused_music_volume
		$General.volume_db = -80.0
	else:
		$General.volume_db = music_volume
		$Paused.volume_db = -80.0
