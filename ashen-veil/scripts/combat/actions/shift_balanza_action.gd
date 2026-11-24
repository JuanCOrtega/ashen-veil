class_name ShiftBalanzaAction
extends CombatAction
## Mueve la Balanza una cantidad fija, o hacia el centro (Equilibrio).

var amount: int
var toward_center: bool


func _init(p_amount: int, p_toward_center: bool = false) -> void:
	amount = p_amount
	toward_center = p_toward_center


func execute(state: CombatState) -> void:
	var hero: HeroCombatant = state.hero
	var old_value: int = hero.balanza
	if toward_center:
		hero.push_balanza_toward_center(amount)
		log_text = "Equilibrio %d: Balanza %+d → %+d." % [amount, old_value, hero.balanza]
	else:
		hero.shift_balanza(amount)
		log_text = "Balanza %+d → %+d." % [old_value, hero.balanza]
	EventBus.balanza_changed.emit(old_value, hero.balanza)
