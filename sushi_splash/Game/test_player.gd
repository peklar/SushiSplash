extends Node2D

# Constants
const GRAVITY: float = 3000.0  # Pixels/s² (tweak for realistic bounce)
const BLEND: float = 0.1       # Visual smoothing factor

# State
var prev_pos: Vector2 = Vector2.ZERO
var curr_pos: Vector2 = Vector2.ZERO
var prev_time: float = 0.0
var curr_time: float = 0.0
var velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
	curr_pos = position
	prev_pos = position
	curr_time = Time.get_ticks_msec() / 1000.0
	prev_time = curr_time

# Call this externally when a new position packet is received
func update_position(new_pos: Vector2) -> void:
	prev_pos = curr_pos
	prev_time = curr_time
	curr_pos = new_pos
	curr_time = Time.get_ticks_msec() / 1000.0

	var dt: float = curr_time - prev_time
	if dt > 0.0001:
		velocity = (curr_pos - prev_pos) / dt

func _process(delta: float) -> void:
	var now: float = Time.get_ticks_msec() / 1000.0
	var dt: float = now - curr_time
	dt = clamp(dt, 0.0, 0.25)  # avoid excessive extrapolation

	# Predict future position with gravity
	var predicted_pos: Vector2 = curr_pos + velocity * dt + 0.5 * Vector2(0.0, GRAVITY) * dt * dt

	# Smooth transition toward prediction
	position = position.lerp(predicted_pos, BLEND)
