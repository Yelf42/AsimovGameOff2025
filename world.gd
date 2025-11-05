extends Node2D

# Array of waves
var targetWave: PackedVector3Array
# x -> Amplitude
# y -> Wavelength
# z -> X-Offset

@onready var player = get_node("Player")
@onready var drawer = get_node("WaveDrawer")
@onready var packages = get_node("Packages")

var package = preload("res://package.tscn")

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

class PackagePack:
	# Amount of time to wait before spawning starts
	var delay: float
	# Time between each spawn
	var padding: float
	# Health values of the packages
	var toSpawn: PackedFloat32Array
	
	func _init(_delay: float, _padding: float, _toSpawn: PackedFloat32Array) -> void:
		delay = _delay
		padding = _padding
		toSpawn = _toSpawn

var spawnQueue: Array[PackagePack]
var waveIndex: int
var subWaveIndex: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	newTargetWave(1)
	newSpawnQueue()
	$Transition.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# New wave, new spawnQueue
	if (waveIndex >= spawnQueue.size() and $Packages.get_child_count() == 0):
		newTargetWave(1)
		newSpawnQueue()
		$Transition.start()
	
	# Mouth positioning
	handleMouthPositioning()

func newTargetWave(waves: int) -> void:
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
	spawnQueue.clear()
	spawnQueue.append(PackagePack.new(1, 0.2, [1,1,1,1]))
	spawnQueue.append(PackagePack.new(1, 0.8, [2,3,2,3]))
	waveIndex = 0

func handleMouthPositioning() -> void:
	var i = 0
	for mouth in $Mouths.get_children():
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
		b.create(spawnQueue[waveIndex].toSpawn[subWaveIndex], 0.1)
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
