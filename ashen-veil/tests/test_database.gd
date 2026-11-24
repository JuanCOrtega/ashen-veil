extends GutTest
## Tarea 2.3: indexado de contenido por id.

const F = preload("res://tests/helpers/combat_factory.gd")
const OK_DIR: String = "user://test_db_ok"
const DUP_DIR: String = "user://test_db_dup"


func before_all() -> void:
	for dir: String in [OK_DIR, DUP_DIR]:
		DirAccess.make_dir_recursive_absolute(dir)
		for file_name: String in DirAccess.get_files_at(dir):
			DirAccess.remove_absolute(dir.path_join(file_name))
	ResourceSaver.save(F.card(&"uno", 1, []), OK_DIR.path_join("uno.tres"))
	ResourceSaver.save(F.card(&"dos", 1, []), OK_DIR.path_join("dos.tres"))
	ResourceSaver.save(F.card(&"repetida", 1, []), DUP_DIR.path_join("a.tres"))
	ResourceSaver.save(F.card(&"repetida", 2, []), DUP_DIR.path_join("b.tres"))


func test_indexes_by_id() -> void:
	var result: ContentDatabase.IndexResult = ContentDatabase.index_directory(OK_DIR)
	assert_eq(result.errors.size(), 0)
	assert_eq(result.items.size(), 2)
	assert_true(result.items.has(&"uno"))
	assert_true(result.items[&"dos"] is CardData)


func test_duplicate_ids_report_a_clear_error_and_keep_the_first() -> void:
	var result: ContentDatabase.IndexResult = ContentDatabase.index_directory(DUP_DIR)
	assert_eq(result.items.size(), 1)
	assert_eq(result.errors.size(), 1)
	assert_string_contains(result.errors[0], "repetida")
	assert_eq((result.items[&"repetida"] as CardData).cost, 1, "Se conserva el primero (a.tres)")


func test_missing_directory_is_empty_not_an_error() -> void:
	var result: ContentDatabase.IndexResult = ContentDatabase.index_directory("user://no_existe_xyz")
	assert_eq(result.items.size(), 0)
	assert_eq(result.errors.size(), 0)


func test_unknown_id_returns_null() -> void:
	assert_null(Database.get_card(&"no_existe"))
	assert_null(Database.get_enemy(&"no_existe"))
