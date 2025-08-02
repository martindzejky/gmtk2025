extends Node2D

@export var dude: Dude

func _on_idle_pressed() -> void:
  dude.play_animation('idle')

func _on_running_pressed() -> void:
  dude.play_animation('running')

func _on_captured_pressed() -> void:
  dude.play_animation('captured')

func _on_melee_pressed() -> void:
  dude.play_animation('melee')

func _on_shoot_pressed() -> void:
  dude.play_animation('shoot')

func _on_randomize_pressed() -> void:
  dude.randomize()
