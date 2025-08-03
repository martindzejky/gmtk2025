extends Control

@export var village_scene: PackedScene

func _on_play_button_pressed():
  get_tree().change_scene_to_packed(village_scene)

func _on_exit_button_pressed():
  get_tree().quit()
