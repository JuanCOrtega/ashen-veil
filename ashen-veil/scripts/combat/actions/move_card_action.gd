class_name MoveCardAction
extends CombatAction

const PILE_NAMES: Dictionary = {
	CombatEnums.Pile.DRAW: "robo",
	CombatEnums.Pile.HAND: "mano",
	CombatEnums.Pile.DISCARD: "descarte",
	CombatEnums.Pile.EXILE: "exilio",
	CombatEnums.Pile.ERASED: "borradas",
	CombatEnums.Pile.RESOLVING: "en resolución",
}

var card: CardInstance
var to_pile: CombatEnums.Pile


func _init(p_card: CardInstance, p_to_pile: CombatEnums.Pile) -> void:
	card = p_card
	to_pile = p_to_pile


func execute(state: CombatState) -> void:
	var from: int = state.hero.piles.move(card, to_pile)
	log_text = "%s → %s." % [card.data.display_name, PILE_NAMES[to_pile]]
	EventBus.card_moved.emit(card, from as CombatEnums.Pile, to_pile)
