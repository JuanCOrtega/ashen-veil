extends SceneTree
## Lanzador del generador de contenido inicial.
## Uso: godot --headless --path ashen-veil -s res://tools/build_starter_content.gd
## El generador se carga en _initialize (cuando los autoloads ya existen) para que
## los scripts del combate compilen sin errores.


func _initialize() -> void:
	var builder_script: GDScript = load("res://tools/starter_content_builder.gd")
	var builder: RefCounted = builder_script.new()
	var errors: int = int(builder.call("build"))
	quit(1 if errors > 0 else 0)
