extends Node
# this is the Game autoload

@export var main_menu_scene: PackedScene
# TODO: tutorial scene
@export var village_scene: PackedScene
@export var fail_ui_scene: PackedScene
@export var pause_ui_scene: PackedScene

var player: Player
var hook: Hook
var pause_ui: CanvasLayer

signal player_died
signal folks_updated
signal enemies_updated
signal wave_starts(number: int)
signal wave_ends(number: int)

enum FailGameReason {
  PLAYER_DIED,
  FOLKS_DIED,
}

var game_is_failed := false
var fail_game_camera_target_position: Vector2
var fail_game_reason: FailGameReason

func _process(_delta):
  # editor shortcuts
  if OS.is_debug_build():
    if Input.is_action_just_pressed('restart'):
      get_tree().reload_current_scene()

    if Input.is_action_just_pressed('freeze'):
      get_tree().paused = !get_tree().paused

  # pause menu toggle
  if Input.is_action_just_pressed('exit'):
    handle_pause_toggle()

func reset_game():
  game_is_failed = false

func emit_player_died():
  player_died.emit()

func emit_folks_updated():
  folks_updated.emit()

func emit_enemies_updated():
  enemies_updated.emit()

func emit_wave_starts(number: int):
  wave_starts.emit(number)

func emit_wave_ends(number: int):
  wave_ends.emit(number)

func player_dying():
  if game_is_failed: return

  fail_game_camera_target_position = player.global_position
  fail_game_reason = FailGameReason.PLAYER_DIED
  fail_game()

func folk_dying():
  if game_is_failed: return

  var remaining_folks = get_tree().get_nodes_in_group('folk')
  if remaining_folks.size() == 1:
    # this is the last folk about to die
    fail_game_camera_target_position = remaining_folks[0].global_position
    fail_game_reason = FailGameReason.FOLKS_DIED
    fail_game()

func restart_game():
  get_tree().reload_current_scene()

func go_to_main_menu():
  # TODO: transition
  get_tree().change_scene_to_packed(main_menu_scene)

func go_to_village():
  # TODO: transition
  get_tree().change_scene_to_packed(village_scene)

func fail_game():
  if game_is_failed: return
  game_is_failed = true

  var camera = get_viewport().get_camera_2d()
  camera.reparent(get_tree().current_scene)

  var tween = create_tween()
  tween.set_trans(Tween.TRANS_QUAD)
  tween.tween_property(camera, 'global_position', fail_game_camera_target_position, 0.2)
  await tween.finished

  # wait for two seconds
  await get_tree().create_timer(2.0).timeout

  var fail_ui = fail_ui_scene.instantiate()
  get_tree().current_scene.add_child(fail_ui)

func force_fail_game():
  game_is_failed = true

func handle_pause_toggle():
  if game_is_failed: return
  if get_tree().current_scene.name != 'village': return
  if player != null and player.cutscene: return

  if pause_ui != null:
    hide_pause_menu()
  else:
    show_pause_menu()

func show_pause_menu():
  if pause_ui != null: return

  pause_ui = pause_ui_scene.instantiate()
  get_tree().current_scene.add_child(pause_ui)
  get_tree().paused = true

func hide_pause_menu():
  if pause_ui == null: return

  pause_ui.queue_free()
  get_tree().paused = false
