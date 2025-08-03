extends CanvasLayer

@export var title: Label

func _ready():
  match Game.fail_game_reason:
    Game.FailGameReason.PLAYER_DIED:
      title.text = "You died!"
    Game.FailGameReason.FOLKS_DIED:
      title.text = "You failed to protect the folks!"

func _on_restart_pressed() -> void:
  Game.restart_game()

func _on_exit_pressed() -> void:
  Game.go_to_main_menu()
