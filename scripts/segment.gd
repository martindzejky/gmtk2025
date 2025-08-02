extends Node2D
class_name Segment

@export var raycast: RayCast2D

var index := 0
var hook: Hook

func _process(_delta):
  queue_redraw()

  if is_last_segment():
    raycast.target_position = hook.player.global_position - global_position
  else:
    raycast.target_position = get_next_segment().global_position - global_position

func _draw():
  var line_start := Vector2(0, -20)
  var line_end = hook.player.get_melee_slot().global_position - global_position

  if not is_last_segment():
    line_end = get_next_segment().global_position - global_position
    line_end.y -= 20

  draw_line(line_start, line_end, '#734234', 1.5)

func is_last_segment():
  return index == hook.segments.size() - 1

func get_previous_segment():
  return hook.segments[index - 1]

func get_next_segment():
  return hook.segments[index + 1]

func update_raycast_exceptions():
  raycast.clear_exceptions()

  for segment in hook.segments:
    raycast.add_exception(segment.get_parent())

func _physics_process(_delta):
  if raycast.is_colliding():
    print('New enemy hit by segment raycast, adding a segment at index ', index + 1)
    hook.add_segment_to_enemy(raycast.get_collider(), raycast.get_collision_point(), index + 1)
