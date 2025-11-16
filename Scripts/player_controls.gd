extends Node2D

var canEditAmplitude: bool = true
var canEditWavelength: bool = true
var canEditOffset: bool = true

var lerpAmplitudeGlitch: bool = false
var lerpWavelengthGlitch: bool = false
var lerpOffsetGlitch: bool = false
var lerpAmount: float = 0.0

func _process(_delta: float) -> void:
	if (lerpAmplitudeGlitch): lerpAmplitude(lerpAmount)
	if (lerpWavelengthGlitch): lerpWavelength(lerpAmount)
	if (lerpOffsetGlitch): lerpOffset(lerpAmount)

func getFunction(x: float) -> float:
	var A = $HBoxContainer/Amplitude.value
	#var W = max($HBoxContainer/VBoxContainer/Wavelength.max_value - $HBoxContainer/VBoxContainer/Wavelength.value, $HBoxContainer/VBoxContainer/Wavelength.min_value)
	var W = $HBoxContainer/VBoxContainer/Wavelength.value
	var O = -$HBoxContainer/VBoxContainer/Offset.value
	return A * sin(W * x + O)

func reset() -> void:
	var xyz = getSliderCenters()
	$HBoxContainer/Amplitude.value = xyz.x
	$HBoxContainer/VBoxContainer/Wavelength.value = xyz.y
	$HBoxContainer/VBoxContainer/Offset.value = xyz.z

func resetGlitches() -> void:
	lerpAmplitudeGlitch = false
	lerpWavelengthGlitch = false
	lerpOffsetGlitch = false
	lerpAmount = 0.0

func lerpSliders(t: float = 0.01) -> void:
	var xyz = getSliderCenters()
	$HBoxContainer/Amplitude.value = move_toward($HBoxContainer/Amplitude.value, xyz.x, t)
	$HBoxContainer/VBoxContainer/Wavelength.value = move_toward($HBoxContainer/VBoxContainer/Wavelength.value, xyz.y, t)
	$HBoxContainer/VBoxContainer/Offset.value = move_toward($HBoxContainer/VBoxContainer/Offset.value, xyz.z, t)

func lerpAmplitude(t: float = 0.01) -> void:
	if (!canEditAmplitude): return
	var xyz = getSliderCenters()
	$HBoxContainer/Amplitude.value = move_toward($HBoxContainer/Amplitude.value, xyz.x, t)

func lerpWavelength(t: float = 0.01) -> void:
	if (!canEditWavelength): return
	var xyz = getSliderCenters()
	$HBoxContainer/VBoxContainer/Wavelength.value = move_toward($HBoxContainer/VBoxContainer/Wavelength.value, xyz.y, t)

func lerpOffset(t: float = 0.01) -> void:
	if (!canEditOffset): return
	var xyz = getSliderCenters()
	$HBoxContainer/VBoxContainer/Offset.value = move_toward($HBoxContainer/VBoxContainer/Offset.value, xyz.z, t)

func getSliderCenters() -> Vector3:
	var x = ($HBoxContainer/Amplitude.max_value + $HBoxContainer/Amplitude.min_value) / 2.0
	var y = ($HBoxContainer/VBoxContainer/Wavelength.max_value + $HBoxContainer/VBoxContainer/Wavelength.min_value) / 2.0
	var z = ($HBoxContainer/VBoxContainer/Offset.max_value + $HBoxContainer/VBoxContainer/Offset.min_value) / 2.0
	return Vector3(x,y,z)





func _on_amplitude_drag_started() -> void:
	canEditAmplitude = false
func _on_amplitude_drag_ended(_value_changed: bool) -> void:
	canEditAmplitude = true

func _on_wavelength_drag_started() -> void:
	canEditWavelength = false
func _on_wavelength_drag_ended(_value_changed: bool) -> void:
	canEditWavelength = true

func _on_offset_drag_started() -> void:
	canEditOffset = false
func _on_offset_drag_ended(_value_changed: bool) -> void:
	canEditOffset = true
