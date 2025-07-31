extends Node
class_name WaveSpawner

@export var waves: Array[SpawnWave]

var current_wave := -1

func _ready():
  assert(waves.size() > 0, 'No waves defined')
  Game.enemies_updated.connect(_on_enemies_updated)
  call_deferred('_on_enemies_updated')

func _on_enemies_updated():
  if waves.size() == 0:
    # TODO: something cool should happen here
    return

  var free_enemies = get_tree().get_nodes_in_group('enemy').filter(func(enemy: Enemy): return not enemy.is_captured())

  if free_enemies.size() == 0:
    collect_captured_enemies()
    var new_wave = waves.pop_front()
    spawn_wave(new_wave)

func collect_captured_enemies():
  get_tree().call_group('enemy', 'collect_captured')

func spawn_wave(wave: SpawnWave):
  current_wave += 1
  print('Spawning wave ', current_wave)

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

