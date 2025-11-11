extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func getFunction(x: float) -> float:
	var A = $HBoxContainer/Amplitude.value
	var W = max($HBoxContainer/VBoxContainer/Wavelength.max_value - $HBoxContainer/VBoxContainer/Wavelength.value, $HBoxContainer/VBoxContainer/Wavelength.min_value)
	var O = -$HBoxContainer/VBoxContainer/Offset.value
	return A * sin(W * x + O)

func reset() -> void:
	var xyz = getSliderCenters()
	$HBoxContainer/Amplitude.value = xyz.x
	$HBoxContainer/VBoxContainer/Wavelength.value = xyz.y
	$HBoxContainer/VBoxContainer/Offset.value = xyz.z

func lerpSliders(t: float = 0.1) -> void:
	var xyz = getSliderCenters()
	$HBoxContainer/Amplitude.value = lerp($HBoxContainer/Amplitude.value, xyz.x, t)
	$HBoxContainer/VBoxContainer/Wavelength.value = lerp($HBoxContainer/VBoxContainer/Wavelength.value, xyz.y, t)
	$HBoxContainer/VBoxContainer/Offset.value = lerp($HBoxContainer/VBoxContainer/Offset.value, xyz.z, t)

func lerpAmplitude(t: float = 0.1) -> void:
	var xyz = getSliderCenters()
	$HBoxContainer/Amplitude.value = lerp($HBoxContainer/Amplitude.value, xyz.x, t)

func lerpWavelength(t: float = 0.1) -> void:
	var xyz = getSliderCenters()
	$HBoxContainer/VBoxContainer/Wavelength.value = lerp($HBoxContainer/VBoxContainer/Wavelength.value, xyz.y, t)

func lerpOffset(t: float = 0.1) -> void:
	var xyz = getSliderCenters()
	$HBoxContainer/VBoxContainer/Offset.value = lerp($HBoxContainer/VBoxContainer/Offset.value, xyz.z, t)

func getSliderCenters() -> Vector3:
	var x = ($HBoxContainer/Amplitude.max_value + $HBoxContainer/Amplitude.min_value) / 2.0
	var y = ($HBoxContainer/VBoxContainer/Wavelength.max_value + $HBoxContainer/VBoxContainer/Wavelength.min_value) / 2.0
	var z = ($HBoxContainer/VBoxContainer/Offset.max_value + $HBoxContainer/VBoxContainer/Offset.min_value) / 2.0
	return Vector3(x,y,z)
