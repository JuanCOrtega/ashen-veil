class_name CombatState
extends RefCounted
## Datos puros del combate. Sin nodos ni señales: se puede probar sin escena.

var hero: HeroCombatant
var enemies: Array[EnemyCombatant] = []
var round_number: int = 0
var rng: RandomNumberGenerator


func living_enemies() -> Array[EnemyCombatant]:
	var result: Array[EnemyCombatant] = []
	for enemy: EnemyCombatant in enemies:
		if not enemy.is_defeated():
			result.append(enemy)
	return result


func all_enemies_defeated() -> bool:
	return living_enemies().is_empty()


func all_combatants() -> Array[Combatant]:
	var result: Array[Combatant] = [hero]
	for enemy: EnemyCombatant in enemies:
		result.append(enemy)
	return result
