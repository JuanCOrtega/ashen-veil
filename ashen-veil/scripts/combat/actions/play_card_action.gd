class_name PlayCardAction
extends CombatAction
## Saca la carta de la mano a "en resolución" y anuncia que se ha jugado.

var card: CardInstance
var targets: Array[Combatant] = []


func _init(p_card: CardInstance, p_targets: Array[Combatant]) -> void:
	card = p_card
	targets = p_targets


func execute(state: CombatState) -> void:
	state.hero.piles.move(card, CombatEnums.Pile.RESOLVING)
	var names: PackedStringArray = []
	for target: Combatant in targets:
		names.append(target.display_name)
	log_text = "Juega %s → %s." % [card.data.display_name, ", ".join(names)]
	EventBus.card_played.emit(card, targets)
