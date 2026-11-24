# Flujo de producción de assets con ComfyUI

Cómo aprovechar **ComfyUI Desktop** para producir el volumen de arte que necesitan 30 horas de juego, y dónde **no** conviene confiar solo en la IA.

---

## 1. Qué producir con ComfyUI y qué no

| Asset | Volumen aprox. | ¿ComfyUI? | Cómo |
|---|---|---|---|
| **Ilustraciones de cartas** | ~250 | ✅ **Uso ideal** | Generar con estilo fijo; el marco se pone en Godot |
| **Iconos de artilugios** | ~140 | ✅ | Generación más limpieza ligera |
| **Retratos de diálogo** | ~30 personajes × 2–4 expresiones | ✅ con control de consistencia | LoRA o referencias por personaje (§3) |
| **Arte conceptual** (zonas, enemigos, jefes) | Ilimitado | ✅ | Base para modelar y para dar coherencia |
| **Texturas** (piedra, frescos, madera, hueso) | ~100 | ✅ | Texturas que se repiten sin costuras, a baja resolución si el estilo es pixelado |
| **Props 3D** (columnas, altares, cráneos, estatuas, bancos) | ~200 | ⚠️ **Sí, con limpieza** | Imagen → 3D con nodos como Hunyuan3D o TRELLIS, y después retopología o reducción de polígonos en Blender |
| **Escenarios completos** | — | ❌ | Se montan **a mano en Godot** combinando los props (*kitbash*) |
| **Sprites animados del héroe y los enemigos** | 4 Vías × animaciones; ~40 enemigos | ⚠️ **Mejor vía indirecta** | Ver §4 |
| **Fondos lejanos y cielos** | ~20 | ✅ | El cielo color óxido, el verde enfermizo, las estructuras del cielo |
| **Interfaz** (marcos, ornamentos) | Pocos | ✅ como base | Se termina a mano para que sea nítida |

## 2. Guía de estilo (antes de generar nada)

Hay que fijar el estilo **una vez** y no cambiarlo:

- **Paleta:** ocres, óxido, ceniza y oro viejo para el mundo. **Blanco frío sin sombra** para Lucifer y lo hueco. **Desaturación total** para el Silencio. Verde para el Verde y Sereth.
- **Referencias de tono:** pintura barroca y tenebrista (claroscuro), iconografía bizantina para lo sagrado, grabado antiguo para los documentos.
- **Plantilla de prompt** para cada tipo de asset (carta, retrato, icono), guardada en el proyecto.
- **Las 10–20 primeras imágenes aprobadas** se convierten en la **referencia de estilo** de todo lo demás.

## 3. Consistencia

La IA tiende a cambiar el estilo y los personajes de una imagen a otra. Técnicas para evitarlo:

| Técnica | Para qué |
|---|---|
| **LoRA de estilo propio** (entrenado con las imágenes aprobadas) | Que todas las cartas parezcan del mismo juego |
| **LoRA o referencias por personaje** (IPAdapter, o modelos con imagen de referencia) | Que Sereth, Ocampo o el Retornado sean reconocibles en cada imagen |
| **ControlNet** (pose, profundidad, líneas) | Componer la ilustración según un boceto o una pose concreta |
| **Semillas y workflows guardados** | Poder regenerar una variante sin perder el resultado |
| **Workflows versionados** | Guardar los `.json` de los workflows en `pipeline/comfy/` dentro del repositorio |

## 4. Sprites de personaje: la vía recomendada

Animar sprites en píxeles frame a frame es lo más caro del 2D-HD, y la IA **no mantiene bien la coherencia entre fotogramas**. Para una sola persona, la ruta más eficiente es esta:

```
ComfyUI (arte conceptual del personaje)
      ▼
Imagen → modelo 3D (Hunyuan3D / TRELLIS en ComfyUI)
      ▼
Blender: limpieza, reducción de polígonos y texturas
      ▼
Rigging automático (Mixamo para humanoides; a mano para criaturas)
      ▼
Animaciones (Mixamo, o propias en Blender)
      ▼
Render a baja resolución con shader de píxel (en Blender o en Godot)
      ▼
Hojas de sprites para AnimatedSprite3D
```

- **Ventajas:** consistencia total entre fotogramas, posibilidad de cambiar el ángulo y añadir animaciones nuevas sin volver a dibujar.
- **Retoque final** en Aseprite: perfilar los contornos y limpiar los píxeles en los fotogramas clave.
- **Animaciones mínimas por personaje** (gracias al combate frontal): reposo, atacar, lanzar, recibir golpe, caer, y una animación especial para la Gracia o la habilidad propia. **Unas 6 animaciones.**
- **Para los compañeros (que son cartas):** solo 1 animación de aparición. Es el ahorro más grande del diseño.

## 5. Props 3D para los escenarios

1. Generar en ComfyUI una imagen limpia del objeto (fondo neutro, vista de 3/4).
2. Convertirla a 3D con un nodo de imagen → 3D.
3. En Blender: **reducir polígonos**, corregir la geometría, ajustar la escala y **reproyectar la textura**.
4. Exportar en **glTF** e importar en Godot.
5. Montar una **biblioteca de props por región** (Orvieto: toba, osario, pozo; Roma: mármol, archivo, catacumbas; París: gótico, catacumbas, vidrieras; Lourdes y Armenia: gruta, hormigón, roca tallada; Aksum: piedra etíope, estelas).

## 6. Organización de archivos

```
ASHEN-VEIL/
├── pipeline/
│   ├── comfy/            # Workflows .json versionados
│   ├── prompts/          # Plantillas de prompt por tipo de asset
│   ├── style_refs/       # Imágenes aprobadas de referencia
│   └── registro.csv      # Qué modelo, LoRA, semilla y prompt generó cada asset
└── ashen-veil/  (res://assets/)
    ├── cards/            # card_<id>.png
    ├── artifacts/        # art_<id>.png
    ├── portraits/        # por_<personaje>_<expresion>.png
    ├── sprites/          # spr_<personaje>_<animacion>.png
    ├── props/            # <region>/<prop>.glb
    └── textures/
```

**Nombres coherentes con los `id` de los datos:** la carta `sereth_la_que_cierra` usa `card_sereth_la_que_cierra.png`. Así el validador (ver [08-arquitectura-godot.md](08-arquitectura-godot.md) §6) puede comprobar qué arte falta.

## 7. Aspectos legales y de publicación

- **Licencias:** revisa la licencia de **cada** checkpoint, LoRA y modelo de imagen → 3D que uses. Algunos prohíben el uso comercial, otros exigen atribución y otros **excluyen ciertos territorios**. Anota en `registro.csv` qué modelo se usó para cada asset.
- **Steam** pide **declarar** el contenido generado con IA al publicar la página del juego. Guardar el registro facilita esa declaración.
- **No imitar obras con derechos** ni el estilo reconocible de artistas vivos en los prompts.
- **Sensibilidad religiosa:** la IA puede generar figuras que el proyecto decidió no representar (ver [../consolidacion/04-concordancia.md](../consolidacion/04-concordancia.md) §6). **Revisa a mano todo el arte religioso** antes de incluirlo.

## 8. Prioridad para la porción jugable del Prólogo

| Asset | Cantidad |
|---|---|
| Ilustraciones de cartas | ~30 |
| Iconos de artilugios | ~12 |
| Sprites del héroe (1 Vía, con el flujo de §4) | 6 animaciones |
| Enemigos (Inducido, Sombra libre, Callado, Fiel, Fabbri) | 5 |
| Retratos | Sereth, Madre Agnese, Bruno, Nilo, Fabbri |
| Props de Orvieto | ~40 (toba, osario, pozo, Duomo, túneles) |
| Arte de Sereth | Arte conceptual + sprite de aparición (carta de compañero) |
