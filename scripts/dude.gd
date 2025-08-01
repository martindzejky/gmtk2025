extends Node2D
class_name Dude

@export_category('Sprites')
@export var legs_sprite: Sprite2D
@export var body_sprite: Sprite2D
@export var head_sprite: Sprite2D
@export var hat_sprite: Sprite2D

@export_category('Animations')
@export var animation_player: AnimationPlayer
@export var jump_animation_player: AnimationPlayer

var animations_starting_with_jump: Array[String] = ['running', 'captured']
var animations_without_blending: Array[String] = ['melee']

func play_animation(animation_name: String):
  if animations_without_blending.has(animation_name):
    animation_player.play(animation_name)
  else:
    animation_player.play(animation_name, 0.1)

  if animations_starting_with_jump.has(animation_name):
    play_jump_animation()


func play_jump_animation():
  jump_animation_player.play('jump')
  jump_animation_player.seek(0)
