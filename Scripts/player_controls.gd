extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func getFunction(x: float) -> float:
	var A = $HBoxContainer/Amplitude.value
	var W = $HBoxContainer/VBoxContainer/Wavelength.value
	var O = -$HBoxContainer/VBoxContainer/Offset.value
	return A * sin(W * x + O)

func reset() -> void:
	$HBoxContainer/Amplitude.value = ($HBoxContainer/Amplitude.max_value + $HBoxContainer/Amplitude.min_value) / 2
	$HBoxContainer/VBoxContainer/Wavelength.value = ($HBoxContainer/VBoxContainer/Wavelength.max_value + $HBoxContainer/VBoxContainer/Wavelength.min_value) / 2
	$HBoxContainer/VBoxContainer/Offset.value = ($HBoxContainer/VBoxContainer/Offset.max_value + $HBoxContainer/VBoxContainer/Offset.min_value) / 2
