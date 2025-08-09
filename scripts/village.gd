extends Node2D
class_name Village

@export var cutscene_animation: AnimationPlayer

func end_cutscene_for_folks_and_player():
  Game.player.end_cutscene()
  for folk in get_tree().get_nodes_in_group('folk'):
    folk.end_cutscene()

func _process(_delta):
  if Input.is_action_just_pressed('exit'):
    if not cutscene_animation.is_playing(): return

    var skip_marker := cutscene_animation.get_animation('cutscene').get_marker_time('skip')
    if cutscene_animation.current_animation_position < skip_marker:
      cutscene_animation.seek(skip_marker)
