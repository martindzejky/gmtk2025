extends Control

@export var display_timer: Timer
@export var text: Label

func _ready():
  visible = false
  Game.wave_ends.connect(_on_wave_ends)

func _on_wave_ends(number: int):
  visible = true
  # get_tree().paused = true # TODO: enable if I get to upgrades
  display_timer.start()
  text.text = 'Wave %d complete!' % (number + 1)

func _on_continue_pressed() -> void:
  # get_tree().paused = false # TODO: enable if I get to upgrades
  visible = false

func _on_display_timer_timeout():
  visible = false
