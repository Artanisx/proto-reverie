class_name EnemyStateData

## Enemy State Data class
##
## This contains just data for enemies, so enemy states can properly have parameters

var damage: int
var impact_direction: Vector3
var impulse: Vector3
var thrown_item: ThrownItem
var thrown_item_basis: Basis


## The below setters are special because returns itself and allows for chaining sets in one line
## Pattern called Fluent Interfaces, and this is "Method chaining"
## Example, inside a called function that has (thrown_item: ThrownItem, item_basis: Basis) parameters: 
## var state_data: EnemyStateData = EnemyStateData.new().set_thrown_item(thrown_item).set_thrown_item_basis(item_basis)	
func set_thrown_item(source: ThrownItem) -> EnemyStateData:
	thrown_item = source
	return self
	
func set_thrown_item_basis(basis: Basis) -> EnemyStateData:
	thrown_item_basis = basis
	return self
	
func set_impulse(source: Vector3) -> EnemyStateData:
	impulse = source
	return self	
	
func set_damage(dmg: int) -> EnemyStateData:
	damage = dmg
	return self	
	
func set_impact_direction(direction: Vector3) -> EnemyStateData:
	impact_direction = direction
	return self	
