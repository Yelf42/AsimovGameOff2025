extends Node2D


var blocker = preload("res://Scenes/blocker_glitch.tscn")

var active: bool = false

# WARNING: IF YOU CHANGE THIS, UPDATE ARRAY SIZE IN THE SHADER
const MAX_BLOCKERS: int = 5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if (canSpawnBlocker()):
		$Timer.start(randf_range(1,3))
	$Shader.material.set_shader_parameter("numBlockers", $Blockers.get_child_count())
	$Shader.material.set_shader_parameter("blockerData", getShaderData())

func canSpawnBlocker() -> bool:
	return active and $Timer.is_stopped() and $Blockers.get_child_count() < MAX_BLOCKERS

func resetGlitches() -> void:
	active = false

func _on_timer_timeout() -> void:
	var b = blocker.instantiate()
	$Blockers.add_child(b)

func getShaderData() -> PackedVector3Array:
	var result: PackedVector3Array;
	for blk in $Blockers.get_children():
		result.append(blk.getShaderData());
	return result
	
