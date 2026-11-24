extends Node
## Bus global de eventos. La interfaz y los sistemas futuros (pasivas, artilugios)
## se suscriben aquí en lugar de depender directamente del combate.

signal combat_started(state: CombatState)
signal combat_ended(victory: bool)
signal round_started(round_number: int)
signal round_ended(round_number: int)
signal player_turn_started(round_number: int)
signal player_turn_ended(round_number: int)

signal card_played(card: CardInstance, targets: Array)
signal card_drawn(card: CardInstance, overflowed: bool)
signal card_moved(card: CardInstance, from_pile: CombatEnums.Pile, to_pile: CombatEnums.Pile)
signal discard_recycled(count: int)

signal damage_dealt(source: Combatant, target: Combatant, amount: int, absorbed: int, vitality_lost: int, damage_type: CombatEnums.DamageType)
signal guard_gained(target: Combatant, amount: int)
signal velo_gained(target: Combatant, amount: int)
signal guard_cleared()
signal velo_decayed()

signal fervor_changed(old_value: int, new_value: int)
signal balanza_changed(old_value: int, new_value: int)
signal intent_set(enemy: EnemyCombatant, intent: IntentData)
signal combatant_defeated(combatant: Combatant)
