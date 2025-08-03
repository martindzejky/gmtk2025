extends Node
class_name WaveSpawner

@export var waves: Array[SpawnWave]
@export var wave_pause_timer: Timer
@export var spawning := false

var current_wave := -1 # first wave is 0, but the UI should show 1

func _ready():
  assert(waves.size() > 0, 'No waves defined')
  Game.enemies_updated.connect(_on_enemies_updated)

  if spawning:
    call_deferred('start_spawning')

func start_spawning():
  spawning = true
  call_deferred('spawn_wave')

func _on_enemies_updated():
  if wave_pause_timer.time_left > 0:
    return

  var free_enemies = get_tree().get_nodes_in_group('enemy').filter(func(enemy: Enemy): return not enemy.is_captured())

  if free_enemies.size() == 0:
    print('Wave %d completed' % current_wave)
    collect_captured_enemies()
    wave_pause_timer.start()
    Game.emit_wave_ends(current_wave)

func collect_captured_enemies():
  get_tree().call_group('enemy', 'collect_captured')

func spawn_wave():
  if waves.size() == 0:
    print('NO MORE WAVES LEFT!!!')
    # TODO: something cool should happen here
    return

  var wave = waves.pop_front()

  current_wave += 1
  print('Spawning wave %d' % current_wave)
  Game.emit_wave_starts(current_wave)

  var total_chance = 0
  for enemy in wave.enemies:
    total_chance += enemy.chance

  for i in range(wave.spawn_number):
    var random_chance = randf_range(0, total_chance)
    var current_chance = 0
    for enemy in wave.enemies:
      current_chance += enemy.chance
      if random_chance <= current_chance:
        var enemy_instance = enemy.enemy.instantiate()

        get_parent().add_child(enemy_instance)

        var random_position = (Vector2.RIGHT * randf_range(wave.spawn_min_distance, wave.spawn_max_distance))
        random_position = random_position.rotated(randf_range(0, 2 * PI))

        enemy_instance.global_position = Game.player.global_position + random_position

        break

  Game.call_deferred('emit_enemies_updated')

func _on_wave_pause_timeout():
  spawn_wave()
