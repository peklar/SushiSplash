extends Node

@onready var music: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	add_child(music)
	music.stream = preload("res://Audio/sushisplash.ogg")
	music.volume_db = -15
	music.autoplay = true
	music.play()
