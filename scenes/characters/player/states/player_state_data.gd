class_name PlayerStateData

## Player State Data class
##
## This contains just data for players, so player states can properly have parameters

var damage: int
var impact_direction: Vector3

func set_damage(dmg: int) -> PlayerStateData:
	damage = dmg
	return self	
	
func set_impact_direction(direction: Vector3) -> PlayerStateData:
	impact_direction = direction
	return self	
