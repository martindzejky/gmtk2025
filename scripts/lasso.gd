extends Node2D
class_name Lasso

@export var player: Player
@export var hook: Hook


func _draw():
  if has_hook():
    var mouse_pos = get_global_mouse_position()
    draw_line(Vector2.ZERO, to_local(mouse_pos), Color.DARK_GRAY, 2.0)

func _process(_delta):
  queue_redraw()

  if Input.is_action_just_pressed('shoot'):
    if has_hook():
      hook.shoot_in_direction(global_position.direction_to(get_global_mouse_position()))
    elif hook_is_hooked():
      hook.unhook()
    elif hook_is_flying():
      hook.state = Hook.State.RETURNING

func has_hook():
  return hook.state == Hook.State.WITH_PLAYER

func hook_is_hooked():
  return hook.state == Hook.State.HOOKED

func hook_is_flying():
  return hook.state == Hook.State.FLYING
