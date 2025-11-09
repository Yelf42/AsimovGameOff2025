extends Control


var root

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	root = get_tree().current_scene

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$WaveCount.text = str(root.waveCount)
	$TotalDropped.text = str(root.totalPackagesDropped)
	$DropLimit.text = str(root.dropLimit)
	$TotalIntercepted.text = str(root.totalPackagesEaten)
