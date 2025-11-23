extends Slider

var speed := 0.0
var timer := 0.0

var min_tick_interval := 0.08
var max_tick_interval := 0.3
var speed_sensitivity := 200.0

var prevValNorm: float = 0.5

# tuning thresholds
const DIFF_DEADZONE := 0.00001
const SPEED_ZERO_THRESHOLD := 0.0005
const PLAY_SPEED_THRESHOLD := 0.001 

func _process(delta: float) -> void:
	var norm = (self.value - self.min_value) / (self.max_value - self.min_value)
	var diff = abs(norm - prevValNorm)
	
	if diff > DIFF_DEADZONE:
		prevValNorm = norm
	else:
		diff = 0.0
	
	speed = lerp(speed, diff, 0.25)
	
	if speed < SPEED_ZERO_THRESHOLD:
		speed = 0.0
		timer = 0.0
	
	var t = clamp(speed * speed_sensitivity, 0.0, 1.0)
	var tick_interval = lerp(max_tick_interval, min_tick_interval, t)
	
	if speed > 0.0:
		timer += delta
		if timer >= tick_interval:
			timer = 0.0
			if speed > PLAY_SPEED_THRESHOLD:
				$AudioStreamPlayer.play()
	else:
		timer = 0.0
