class_name CombatEnums
extends RefCounted
## Enumeraciones compartidas por el sistema de combate.

enum DamageType { PHYSICAL, ETHEREAL }

enum TargetType { ONE_ENEMY, ALL_ENEMIES, HERO }

enum CardType { STRIKE, RITE, VOICE, TESTIMONY, COMPANION, ECHO, CORRUPTED, LACUNA }

enum Rarity { COMMON, VOTIVE, SANCTIFIED, MAXIMAL, STORY }

enum Pile { DRAW, HAND, DISCARD, EXILE, ERASED, RESOLVING }

## Atributos del héroe. NONE = el efecto no escala con ningún atributo.
enum Stat { STRENGTH, FULGOR, UMBRAL, VOICE, WILL, NONE }
