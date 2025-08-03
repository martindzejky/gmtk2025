extends Control

@export var display_timer: Timer
@export var text: Label

func _ready():
  visible = false
  Game.wave_starts.connect(_on_wave_starts)

func _on_wave_starts(number: int):
  visible = true
  display_timer.start()
  text.text = 'Wave %d starts!' % (number + 1)

func _on_display_timer_timeout():
  visible = false
