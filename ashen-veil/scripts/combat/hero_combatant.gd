class_name HeroCombatant
extends Combatant
## El héroe en combate: añade Fervor, Balanza y pilas de cartas.

var max_fervor: int = 3
var fervor: int = 0
var hand_size: int = 5
var balanza: int = 0
var piles: CardPiles


func _init(config: HeroCombatConfig, rng: RandomNumberGenerator) -> void:
	super(config.hero_name, config.max_vitality)
	max_fervor = config.max_fervor
	hand_size = config.hand_size
	balanza = CombatRules.clamp_balanza(config.starting_balanza)
	for stat: CombatEnums.Stat in [
		CombatEnums.Stat.STRENGTH,
		CombatEnums.Stat.FULGOR,
		CombatEnums.Stat.UMBRAL,
		CombatEnums.Stat.VOICE,
		CombatEnums.Stat.WILL,
	]:
		set_stat(stat, config.get_stat(stat))
	piles = CardPiles.new(rng)


func is_hero() -> bool:
	return true


func shift_balanza(delta: int) -> void:
	balanza = CombatRules.clamp_balanza(balanza + delta)


## Acerca la Balanza a 0 sin cruzar al otro lado.
func push_balanza_toward_center(amount: int) -> void:
	var step: int = maxi(0, amount)
	if balanza > 0:
		balanza = maxi(0, balanza - step)
	elif balanza < 0:
		balanza = mini(0, balanza + step)
