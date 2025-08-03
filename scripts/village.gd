extends Node2D
class_name Village

func end_cutscene_for_folks_and_player():
  Game.player.end_cutscene()
  for folk in get_tree().get_nodes_in_group('folk'):
    folk.end_cutscene()
