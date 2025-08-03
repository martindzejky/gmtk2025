extends Control

func _on_play_button_pressed():
  Game.go_to_village()

func _on_exit_button_pressed():
  get_tree().quit()
