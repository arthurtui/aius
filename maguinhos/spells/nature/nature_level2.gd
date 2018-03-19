extends "res://spells/base_spell.gd"

const SPEED = 6
const DAMAGE = 15
const KNOCKBACK = 5
var element = 1 # Lightning = 0, Nature = 1, Fire = 2, Water = 3
var level = 2

var direction = Vector2( 0, 0 ) # direction that the seed flies to
var parent
var is_seed = true


#func _ready():
#	get_node( "SFX" ).play( "leaf" )


func fire( direction, parent ):
	self.direction = direction
	self.parent = parent
	set_rotation( direction.angle() - deg2rad(90) )
	set_position( parent.position )
	set_process( true )


func _process(delta):
	move_and_collide( direction * SPEED )


func _on_Area2D_body_enter( body ):
	if body != parent:
		grow()
		$GrowTimer.stop()
		$LifeTimer.start()
		if body.has_method( "take_damage" ):
			# If the thorns are grown, play death animation
			# when enemy enters them. Otherwise, the seed just
			# disappears dealing damage
			if !is_seed:
				body.take_damage(2 * DAMAGE, null)
				body.root(1)
				_on_LifeTimer_timeout()
			else:
				body.take_damage(DAMAGE, self.direction, KNOCKBACK)
				die()


func _on_GrowTimer_timeout():
	$LifeTimer.start()
	is_seed = false
	grow()


# Projectile stops moving and expands
func grow():
	set_process( false )
	$AnimationPlayer.play( "grow" )
	$Area2D.set_scale(Vector2(2.5, 2.5))


func _on_LifeTimer_timeout():
	$LifeTimer.queue_free()
	$AnimationPlayer.play( "die" )


func die():
	$Area2D.queue_free()
	queue_free()