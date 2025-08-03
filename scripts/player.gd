extends CharacterBody2D
class_name Player

@export_category('Dude')
@export var dude: Dude

@export_category('Movement')
@export var move_speed := 200.0
@export var dash_speed := 400.0
@export var dash_curve: Curve
@export var dash_progress_timer: Timer
@export var dash_cooldown_timer: Timer
@export var dash_cooldown_progress: ProgressBar

@export_category('Lasso')
@export var lasso: Lasso

@export_category('Cutscene')
@export var cutscene := false
@export var main_menu := false

@export_category('Grave')
@export var grave_scene: PackedScene

# super duper state for the player...
var dying := false
var dead := false

func _ready():
  Game.player = self

  if main_menu:
    dying = true
    dead = true
    Game.force_fail_game()
  else:
    Game.reset_game()

func _physics_process(_delta):
  if dead: return

  var input_vector := Vector2.ZERO
  if not cutscene and not dying and not Game.game_is_failed:
    input_vector = Input.get_vector('move_left', 'move_right', 'move_up', 'move_down')

  if dash_cooldown_timer.time_left <= 0 and Input.is_action_just_pressed('dash') and not cutscene and not dying and not Game.game_is_failed:
    dash_progress_timer.start()
    dash_cooldown_timer.start()

    # this is a quick hack to save time:
    # I want to change the collision layer from 'player' to 'player_dash' which is the next layer
    # so just shift the layer bit by 1
    collision_layer = collision_layer << 1

  if dash_progress_timer.time_left > 0:
    velocity = input_vector * dash_speed * dash_curve.sample(1 - dash_progress_timer.time_left / dash_progress_timer.wait_time)
  else:
    velocity = input_vector * move_speed

  # just in case
  if cutscene or dying or Game.game_is_failed:
    velocity = Vector2.ZERO

  move_and_slide()

  if dash_progress_timer.time_left <= 0 and dash_cooldown_timer.time_left > 0:
    var cooldown_after_dash = dash_cooldown_timer.wait_time - dash_progress_timer.wait_time
    dash_cooldown_progress.value = 1 - (dash_cooldown_timer.time_left / cooldown_after_dash)
    dash_cooldown_progress.visible = true
  else:
    dash_cooldown_progress.visible = false

  if dying:
    dude.play_animation('die')
  elif lasso.has_hook():
    if dash_progress_timer.time_left > 0:
      dude.play_animation('dash_lasso')
    elif velocity.length() > 0:
      dude.play_animation('running_lasso')
    else:
      dude.play_animation('idle_lasso')
  else:
    if dash_progress_timer.time_left > 0:
      dude.play_animation('dash')
    elif velocity.length() > 0:
      dude.play_animation('running')
    else:
      dude.play_animation('idle')

  if abs(velocity.x) > 0:
    dude.scale.x = sign(velocity.x)

func end_cutscene():
  cutscene = false

func hit():
  if cutscene: return
  dying = true
  Game.call_deferred('player_dying')

func _on_dude_die_end() -> void:
  dead = true

  var grave = grave_scene.instantiate()
  get_parent().add_child(grave)
  grave.global_position = global_position + Vector2(20, 0) * sign(dude.scale.x)
  grave.show_sheriff_star()

  dude.queue_free()
  Game.call_deferred('emit_player_died')

func _on_dash_progress_timeout() -> void:
  # again the hack mentioned above
  collision_layer = collision_layer >> 1
