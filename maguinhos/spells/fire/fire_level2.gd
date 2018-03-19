extends "res://spells/base_spell.gd"

const SPEED = 5
const DAMAGE = 15
const KNOCKBACK = 25
const HOMING_FACTOR = 40 # the lowest the factor is, the fastest the homing
var element = 2 # Lightning = 0, Nature = 1, Fire = 2, Water = 3
var level = 2

var direction = Vector2( 0, 0 ) # direction that the fireball flies to
var parent

var target
var accel


#func _ready():
#	get_node( "SFX" ).play( "fire" )


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
	set_rotation( direction.angle() - deg2rad(90.0))
	set_position( parent.position )
	set_process( true )


func _process(delta):
	move_and_collide( direction * SPEED )
	if target != null:
		home()


# Given the conditions, homes in the direction of the target
func home():
	if !weakref(target).get_ref(): # target was freed
		target = null
		return

	var target_pos = target.position
	var dif = target_pos - self.position
	direction += dif.normalized() / HOMING_FACTOR
	
	if direction.x > 1.1:
		direction.x = 1.1
	elif direction.x < - 1.1:
		direction.x = - 1.1

	if direction.y > 1.1:
		direction.y = 1.1
	elif direction.y < - 1.1:
		direction.y = - 1.1


# does damage if take damage function exists in body
func _on_Area2D_body_enter( body ):
	if body != parent:
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE, self.direction, KNOCKBACK)
		die()


func _on_DetectionArea_body_enter( body ):
	if body.is_in_group("Player") and body != parent:
		target = body
		$DetectionArea.queue_free()


func _on_LifeTimer_timeout():
	die()


func die():
#	get_node( "SFX" ).play( "fireball" )
	$Area2D.queue_free()
	$LifeTimer.queue_free()
	$AnimationPlayer.play( "death" )
	set_process( false )


func free_scn():
	queue_free()