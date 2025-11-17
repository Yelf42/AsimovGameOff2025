extends Node2D

# Array of waves
var targetWave: PackedVector3Array
# x -> Amplitude
# y -> Wavelength
# z -> X-Offset

@onready var player = get_node("Player")
@onready var drawer = get_node("WaveDrawer")
@onready var packages = get_node("Packages")
@onready var mouths = get_node("Mouths")
@onready var blocker = get_node("BlockerGlitchManager")

var package = preload("res://Scenes/package.tscn")

# Sum of amplitudes in targetWave:
# <= MAX_AMPLITUDE
# > MIN_AMPLITUDE
const MAX_AMPLITUDE = 3
const MIN_AMPLITUDE = 1
# Wavelength * Amplitude <= 2.0
const MAX_WAVELENGTH = 15
# Offset doesn't need clamping

# Score trackers
var totalPackagesDropped: int = 0
var totalPackagesEaten: int = 0
var waveCount: int = 0

var dropLimit: int = 10

class PackagePack:
	# Amount of time to wait before spawning starts
	var delay: float
	# Time between each spawn
	var padding: float
	# Health values of the packages
	var toSpawn: PackedVector2Array
	
	func _init(_delay: float, _padding: float, _toSpawn: PackedVector2Array) -> void:
		delay = _delay
		padding = _padding
		toSpawn = _toSpawn

var spawnQueue: Array[PackagePack]
var waveIndex: int
var subWaveIndex: int
const WAVES_UNTIL_CHANGE = 5

# Glitch variables
var glitchArray: PackedStringArray
const GLITCH_ORDER: PackedInt32Array = [0,1,1,2,2,2,3]
const GLITCH_TYPES: PackedStringArray = ["lerpAmplitude", "lerpWavelength", "lerpOffset", "packageWaveHider", "mouthWaveHider", "spawnBlockers"]
const LERP_AMOUNT = 0.01
var numberOfLerps = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true;
	$MainMenu.show()
	$PauseMenu.hide()
	$GameOverMenu.hide()

func startGame() -> void:
	# Reset variables
	totalPackagesDropped = 0
	totalPackagesEaten = 0
	waveCount = 0
	dropLimit = 10
	
	# Reset player sliders
	player.reset()
	
	# Remove old packages
	for pck in $Packages.get_children():
		pck.queue_free()
	
	# Set new target and spawnQueue
	newTargetWave()
	newSpawnQueue()
	newGlitchArray() # Shouldnt do anything, but nice for testing
	
	# Unpause and begin
	$Transition.start()
	get_tree().paused = false

func _process(_delta: float) -> void:
	# New wave, new spawnQueue
	if (waveIndex >= spawnQueue.size() and $Packages.get_child_count() == 0):
		var oldWaveComplexity = getInterWaveComplexity()
		waveCount += 1
		var newWaveComplexity = getInterWaveComplexity()
		if (oldWaveComplexity != newWaveComplexity):
			newGlitchArray()
			
		newTargetWave()
		newSpawnQueue()
		
		$Transition.start(0.5 + 3.0 * pow(0.8, newWaveComplexity))
		dropLimit += 1
	
	if (totalPackagesDropped > dropLimit):
		gameOver()
	
	# Mouth positioning
	handleMouthPositioning()

# Decides how complex new target wave should be based on waveCount
# "How many sets of WAVES_UNTIL_CHANGE have there been?"
func getInterWaveComplexity() -> int:
	return int(float(waveCount) / WAVES_UNTIL_CHANGE)

# Decides difficulty of spawnQueue
# Should ramp up between changes in getInterWaveComplexity
func getIntraWaveComplexity() -> int:
	return (waveCount % WAVES_UNTIL_CHANGE)

func newTargetWave() -> void:
	var waves = getInterWaveComplexity() + 1
	
	targetWave.clear()
	var ampSumMax = MAX_AMPLITUDE;
	for i in range(waves):
		var newWave: Vector3
		
		# Amplitude
		newWave.x = randf_range(0.1, 0.7 * ampSumMax)
		ampSumMax -= newWave.x
		
		# Wavelength
		newWave.y = min(randf_range(1.0, 2.0 / newWave.x), MAX_WAVELENGTH)
		
		# Offset
		newWave.z = randf_range(-10, 10)
		
		targetWave.append(newWave)
	
	# Ensure total amplitude > MIN_AMPLITUDE
	if (MAX_AMPLITUDE - ampSumMax <= MIN_AMPLITUDE):
		targetWave[0].x += MIN_AMPLITUDE - (MAX_AMPLITUDE - ampSumMax)

func newSpawnQueue() -> void:
	var intraWaveDifficulty = getIntraWaveComplexity()
	var interWaveDifficulty = getInterWaveComplexity() + 1
	spawnQueue.clear()
	
	var spdMult = 1.0 + (0.1 * interWaveDifficulty) + (0.05 * intraWaveDifficulty)
	
	var numPacks = randi_range(1, (intraWaveDifficulty + 2))
	var maxHP = $Mouths.get_child_count()
	if (numberOfLerps > 1): maxHP = max(1, maxHP - 1)
	for i in range(numPacks):
		var numPackages = floor(10.0 * log(0.2 * interWaveDifficulty + 1.0)) + randi_range(1, 1 + intraWaveDifficulty)
		if (i == 0):
			spawnQueue.append(PackagePack.new(0,0.3, generateStandard(numPackages, 1, 1.1 * spdMult)))
			continue
		if (randf() < 0.6):
			spawnQueue.append(PackagePack.new(randf_range(0.2 + pow(0.9,interWaveDifficulty+1), 1.0), randf_range(0.1 + pow(0.9,interWaveDifficulty+1), 1.0), generateAscending(numPackages, maxHP, spdMult)))
		else:
			spawnQueue.append(PackagePack.new(randf_range(0.2 + pow(0.9,interWaveDifficulty+1), 1.0), randf_range(0.1 + pow(0.9,interWaveDifficulty+1), 1.0), generateAlternating(numPackages, maxHP, spdMult)))
	
	waveIndex = 0

# Packages of equal hp
func generateStandard(num: int, hp: int, spdMult: float) -> PackedVector2Array:
	var res = []
	for i in range(num):
		res.append(Vector2(hp, spdMult))
	return res

# Packages of alternating hp
func generateAlternating(num: int, hpMax: int, spdMult: float) -> PackedVector2Array:
	var res = []
	if (hpMax == 1): return generateStandard(num, 1, spdMult)
	var evenHP = randi_range(1, hpMax)
	var oddHP = randi_range(1, hpMax)
	while (oddHP == evenHP): oddHP = randi_range(1, hpMax)
	for i in range(num):
		res.append(Vector2(evenHP if (i % 2 == 0) else oddHP, spdMult))
	return res

# Packages of ascending hp
func generateAscending(num: int, hpMax: int, spdMult: float) -> PackedVector2Array:
	var res = []
	var base = int(float(num) / hpMax)
	var remainder = num % hpMax
	for i in range(1, hpMax + 1):
		var count = base + (1 if i <= remainder else 0)
		for j in range(count):
			res.append(Vector2(i,spdMult))
	return res

func newGlitchArray() -> void:
	glitchArray.clear()
	var numGlitches = 3
	numberOfLerps = 0
	# Ramp up num glitches slowly
	if (getInterWaveComplexity() < GLITCH_ORDER.size()):
		numGlitches = GLITCH_ORDER[getInterWaveComplexity()]
	for i in range(numGlitches):
		var glitch: String = GLITCH_TYPES[randi_range(0, GLITCH_TYPES.size() - 1)]
		while (glitchArray.count(glitch) != 0):
			glitch = GLITCH_TYPES[randi_range(0, GLITCH_TYPES.size() - 1)]
		if (glitch.contains("lerp")):
			numberOfLerps += 1
		glitchArray.append(glitch)
	handleGlitches()

# Run once after newGlitchArray
func handleGlitches() -> void:
	player.resetGlitches()
	player.lerpAmount = LERP_AMOUNT / (numberOfLerps * numberOfLerps)
	drawer.resetGlitches()
	blocker.resetGlitches()
	for glitch in glitchArray:
		match(glitch):
			"lerpAmplitude":
				player.lerpAmplitudeGlitch = true
			"lerpWavelength":
				player.lerpWavelengthGlitch = true
			"lerpOffset":
				player.lerpOffsetGlitch = true
			"packageWaveHider":
				drawer.packageGlitch = true
			"mouthWaveHider":
				drawer.mouthGlitch = true
			"spawnBlockers":
				blocker.active = true

func handleMouthPositioning() -> void:
	var i = 0
	for mouth in mouths.get_children():
		var x = drawer.getXBounds().x + 50 + i * 100
		var y = drawer.getY() + getPlayerFunction(x)
		mouth.position = Vector2(x,y) + drawer.position
		#mouth.rotation = Vector2((x+0.01) - (x-0.01) ,getPlayerFunction(x+0.01) - getPlayerFunction(x-0.01)).angle()
		i += 1

func getTargetFunction(x: float) -> float:
	x /= 50
	var y = 0.0;
	for wave in targetWave:
		y += wave.x * sin(wave.y * x + wave.z)
	return 30 * y;

func getPlayerFunction(x: float) -> float:
	return 30 * player.getFunction(x / 50);

func getRemainingPackages() -> int:
	if (waveIndex >= spawnQueue.size()): return 0
	var sum = spawnQueue[waveIndex].toSpawn.size() - subWaveIndex
	for i in range(waveIndex + 1, spawnQueue.size()):
		sum += spawnQueue[i].toSpawn.size()
	return sum

# Time to spawn next package in toSpawn
func _on_wave_padding_delay_timeout() -> void:
	if (subWaveIndex >= spawnQueue[waveIndex].toSpawn.size()):
		waveIndex += 1
		if (waveIndex < spawnQueue.size()):
			$WaveStartDelay.start(spawnQueue[waveIndex].delay)
	else:
		var b = package.instantiate()
		b.create(spawnQueue[waveIndex].toSpawn[subWaveIndex])
		packages.add_child(b)
		subWaveIndex += 1
		$WavePaddingDelay.start(spawnQueue[waveIndex].padding)

# Time to start spawning from PackagePack
func _on_wave_start_delay_timeout() -> void:
	subWaveIndex = 0
	$WavePaddingDelay.start(spawnQueue[waveIndex].padding)

# Start next waves
func _on_transition_timeout() -> void:
	$WaveStartDelay.start(spawnQueue[waveIndex].delay)


func canPause() -> bool:
	return !$MainMenu.visible and !$GameOverMenu.visible

func openMainMenu() -> void:
	$MainMenu.show()
	stopTimers()

func stopTimers() -> void:
	$Transition.stop()
	$WaveStartDelay.stop()
	$WavePaddingDelay.stop()

func gameOver() -> void:
	$GameOverMenu.show()
	get_tree().paused = true
	stopTimers()
