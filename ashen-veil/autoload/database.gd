class_name ContentDatabase
extends Node
## Autoload "Database". Indexa por id todo el contenido de data/. Admite el sufijo .remap que Godot
## añade a los recursos al exportar.

const CARDS_DIR: String = "res://data/cards"
const ENEMIES_DIR: String = "res://data/enemies"
const DEFAULT_HERO_PATH: String = "res://data/dev/hero_default.tres"


class IndexResult:
	var items: Dictionary = {}
	var errors: PackedStringArray = []


var _cards: Dictionary = {}
var _enemies: Dictionary = {}


func _ready() -> void:
	reload()


func reload() -> void:
	var cards: IndexResult = index_directory(CARDS_DIR)
	var enemies: IndexResult = index_directory(ENEMIES_DIR)
	_cards = cards.items
	_enemies = enemies.items
	for message: String in cards.errors + enemies.errors:
		push_error(message)


func get_card(id: StringName) -> CardData:
	return _cards.get(id) as CardData


func get_enemy(id: StringName) -> EnemyData:
	return _enemies.get(id) as EnemyData


func all_cards() -> Array[CardData]:
	var result: Array[CardData] = []
	for id: StringName in _sorted_keys(_cards):
		result.append(_cards[id] as CardData)
	return result


func all_enemies() -> Array[EnemyData]:
	var result: Array[EnemyData] = []
	for id: StringName in _sorted_keys(_enemies):
		result.append(_enemies[id] as EnemyData)
	return result


func get_default_hero() -> HeroCombatConfig:
	if not ResourceLoader.exists(DEFAULT_HERO_PATH):
		return null
	return load(DEFAULT_HERO_PATH) as HeroCombatConfig


## Carga los .tres/.res de una carpeta y los indexa por su propiedad `id`.
## Los ids duplicados y los recursos sin id se registran como error (se conserva el primero).
static func index_directory(path: String) -> IndexResult:
	var result := IndexResult.new()
	if not DirAccess.dir_exists_absolute(path):
		return result
	var files: PackedStringArray = DirAccess.get_files_at(path)
	files.sort()
	for file_name: String in files:
		var name: String = file_name.trim_suffix(".remap")
		if not (name.ends_with(".tres") or name.ends_with(".res")):
			continue
		var full_path: String = path.path_join(name)
		var resource: Resource = load(full_path)
		if resource == null:
			result.errors.append("No se pudo cargar %s." % full_path)
			continue
		var id: StringName = StringName(str(resource.get("id")))
		if id == &"" or id == &"<null>":
			result.errors.append("%s no tiene id." % full_path)
			continue
		if result.items.has(id):
			result.errors.append("Id duplicado '%s' en %s (ya definido)." % [id, full_path])
			continue
		result.items[id] = resource
	return result


static func _sorted_keys(dict: Dictionary) -> Array:
	var keys: Array = dict.keys()
	keys.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
	return keys
