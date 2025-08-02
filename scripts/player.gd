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

func _ready():
  Game.player = self

func _physics_process(_delta):
  var input_vector = Input.get_vector('move_left', 'move_right', 'move_up', 'move_down')

  if dash_cooldown_timer.time_left <= 0 and Input.is_action_just_pressed('dash'):
    dash_progress_timer.start()
    dash_cooldown_timer.start()

  if dash_progress_timer.time_left > 0:
    velocity = input_vector * dash_speed * dash_curve.sample(1 - dash_progress_timer.time_left / dash_progress_timer.wait_time)
  else:
    velocity = input_vector * move_speed

  move_and_slide()

  if dash_progress_timer.time_left <= 0 and dash_cooldown_timer.time_left > 0:
    var cooldown_after_dash = dash_cooldown_timer.wait_time - dash_progress_timer.wait_time
    dash_cooldown_progress.value = 1 - (dash_cooldown_timer.time_left / cooldown_after_dash)
    dash_cooldown_progress.visible = true
  else:
    dash_cooldown_progress.visible = false

  if dash_progress_timer.time_left > 0:
    dude.play_animation('dash')
  elif velocity.length() > 0:
    dude.play_animation('running')
  else:
    dude.play_animation('idle')

  if abs(velocity.x) > 0:
    dude.scale.x = sign(velocity.x)
