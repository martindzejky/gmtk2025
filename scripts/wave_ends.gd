extends Control

@export var text: Label

func _ready():
  visible = false
  Game.wave_ends.connect(_on_wave_ends)

func _on_wave_ends(number: int):
  visible = true
  get_tree().paused = true
  text.text = 'Wave %d complete!' % (number + 1)

func _on_continue_pressed() -> void:
  get_tree().paused = false
  visible = false
