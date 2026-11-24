class_name FervorAction
extends CombatAction
## Recarga el Fervor del héroe a su máximo (refill = true) o gasta una cantidad.

var refill: bool
var amount: int


func _init(p_refill: bool, p_amount: int = 0) -> void:
	refill = p_refill
	amount = p_amount


static func refill_action() -> FervorAction:
	return FervorAction.new(true)


static func spend_action(cost: int) -> FervorAction:
	return FervorAction.new(false, cost)


func execute(state: CombatState) -> void:
	var hero: HeroCombatant = state.hero
	var old_value: int = hero.fervor
	if refill:
		hero.fervor = hero.max_fervor
		log_text = "Fervor recargado: %d." % hero.fervor
	else:
		hero.fervor = maxi(0, hero.fervor - amount)
		log_text = "Gasta %d de Fervor (queda %d)." % [amount, hero.fervor]
	EventBus.fervor_changed.emit(old_value, hero.fervor)
