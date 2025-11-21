extends Node2D

var canEditAmplitude: bool = true
var canEditWavelength: bool = true
var canEditOffset: bool = true

var lerpAmplitudeGlitch: bool = false
var lerpWavelengthGlitch: bool = false
var lerpOffsetGlitch: bool = false
var lerpAmount: float = 0.0

var amplitude
var wavelength
var offset

func _ready() -> void:
	amplitude = $HBoxContainer/Amplitude
	wavelength = $HBoxContainer/VBoxContainer/Wavelength
	offset = $HBoxContainer/VBoxContainer/Offset

func _process(_delta: float) -> void:
	if (lerpAmplitudeGlitch): lerpAmplitude(lerpAmount)
	if (lerpWavelengthGlitch): lerpWavelength(lerpAmount)
	if (lerpOffsetGlitch): lerpOffset(lerpAmount)
	
	$AmplitudeEmitter.global_position = getGrabberPosition(amplitude, false)
	$WavelengthEmitter.global_position = getGrabberPosition(wavelength, true)
	$OffsetEmitter.global_position = getGrabberPosition(offset, true)

func getFunction(x: float) -> float:
	var A = amplitude.value
	#var W = max(wavelength.max_value - wavelength.value, wavelength.min_value)
	var W = wavelength.value
	var O = -offset.value
	return A * sin(W * x + O)

func reset() -> void:
	var xyz = getSliderCenters()
	amplitude.value = xyz.x
	wavelength.value = xyz.y
	offset.value = xyz.z

func resetGlitches() -> void:
	lerpAmplitudeGlitch = false
	lerpWavelengthGlitch = false
	lerpOffsetGlitch = false
	lerpAmount = 0.0
	
	$AmplitudeEmitter.emitting = false
	$WavelengthEmitter.emitting = false
	$OffsetEmitter.emitting = false

func lerpSliders(t: float = 0.01) -> void:
	var xyz = getSliderCenters()
	amplitude.value = move_toward(amplitude.value, xyz.x, t)
	wavelength.value = move_toward(wavelength.value, xyz.y, t)
	offset.value = move_toward(offset.value, xyz.z, t)

func lerpAmplitude(t: float = 0.01) -> void:
	if (!canEditAmplitude): return
	$AmplitudeEmitter.emitting = true
	var xyz = getSliderCenters()
	amplitude.value = move_toward(amplitude.value, xyz.x, t)

func lerpWavelength(t: float = 0.01) -> void:
	if (!canEditWavelength): return
	$WavelengthEmitter.emitting = true
	var xyz = getSliderCenters()
	wavelength.value = move_toward(wavelength.value, xyz.y, t)

func lerpOffset(t: float = 0.01) -> void:
	if (!canEditOffset): return
	$OffsetEmitter.emitting = true
	var xyz = getSliderCenters()
	offset.value = move_toward(offset.value, xyz.z, t)

func getSliderCenters() -> Vector3:
	var x = (amplitude.max_value + amplitude.min_value) / 2.0
	var y = (wavelength.max_value + wavelength.min_value) / 2.0
	var z = (offset.max_value + offset.min_value) / 2.0
	return Vector3(x,y,z)

# WARNING: Magic numbers in the lerps correspond to the dimensions of the grabber texture
func getGrabberPosition(slider: Slider, horizontal: bool) -> Vector2:
	var t = (slider.value - slider.min_value) / (slider.max_value - slider.min_value)
	var res = Vector2.ZERO
	var start = slider.global_position
	if (horizontal):
		res.x = lerp(start.x + 21, start.x + slider.size.x - 21, t)
		res.y = start.y + slider.size.y / 2.0
	else:
		res.x = start.x + slider.size.x / 2.0
		res.y = lerp(start.y + slider.size.y - 23, start.y + 23, t)
	return res



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
