extends CanvasLayer

func _on_resume_pressed():
  Game.hide_pause_menu()

func _on_restart_pressed():
  Game.hide_pause_menu()
  Game.restart_game()

func _on_exit_pressed():
  Game.hide_pause_menu()
  Game.go_to_main_menu()
