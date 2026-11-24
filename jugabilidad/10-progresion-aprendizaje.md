# Progresión de aprendizaje (tutorial integrado)

**Objetivo:** que el jugador aprenda **todas** las mecánicas del combate **jugando la historia**, sin pantallas de instrucciones, y que cada mecánica llegue **cuando la historia la justifica**.

Documentos relacionados: [02-combate.md](02-combate.md) (reglas), [../consolidacion/arcos/01-prologo.md](../consolidacion/arcos/01-prologo.md) y [02-acto-i.md](../consolidacion/arcos/02-acto-i.md) (historia).

---

## 1. Principios

1. **Una mecánica nueva cada vez.** Nunca dos a la vez en el mismo combate.
2. **Aprender → usar → combinar → dominar.** Cada mecánica pasa por cuatro fases:
   - **Aprender:** un combate diseñado para que solo funcione usándola.
   - **Usar:** dos o tres combates normales donde ayuda.
   - **Combinar:** un combate donde hay que mezclarla con algo anterior.
   - **Dominar:** un jefe o élite que la pone a prueba.
3. **El lore explica la regla.** El Velo no aparece porque sí: aparece la primera vez que te ataca una sombra y Madre Agnese te enseña a persignarte. Cada mecánica tiene un **momento narrativo**.
4. **Mostrar antes que decir.** Primero se ve (una intención, un número que cambia, un sonido), después llega como mucho **una línea de pista**.
5. **Fallar no castiga en las lecciones.** En los combates de "aprender", perder ofrece **reintentar al instante** desde el inicio del combate, sin cargar partida.
6. **Lo que no se ha enseñado no se ve.** La interfaz **oculta** las mecánicas aún no aprendidas (zonas de la Balanza, cargas de Gracia, Huecos). Se encienden en su momento, con su propia pequeña escena.
7. **Todo queda en el Diario.** Cada mecánica aprendida añade una entrada de **"Lo aprendido"** (2–4 líneas con un ejemplo), para quien quiera releerla.

---

## 2. Mapa de mecánicas

Orden en el que se enseña cada mecánica. La columna **Código** indica qué cambio de OpenSpec la implementa.

| # | Mecánica | Momento narrativo | Cómo se enseña | Código |
|---|---|---|---|---|
| 1 | Jugar cartas, **Fervor** y objetivo | Combate de apertura (Noche de las Rupturas) | Mano fija de 3 cartas de ataque; un enemigo débil | `combate-nucleo` ✅ |
| 2 | **Intenciones** enemigas | Mismo combate, segunda ronda | El enemigo anuncia un golpe fuerte; el jugador lo ve venir | `combate-nucleo` ✅ |
| 3 | **Guardia** (daño físico) | Combate de apertura, final | Mano con *Cubrirse* justo cuando el enemigo anuncia un golpe grande | `combate-nucleo` ✅ |
| 4 | **Robo, descarte y reciclado** | Orvieto, primer combate largo | Se nota solo; pista si la pila de robo llega a 0 | `combate-nucleo` ✅ |
| 5 | **Velo** y daño etéreo | Trabajo por ración (C2): la primera sombra | Una sombra atraviesa la Guardia; Madre Agnese da *Persignarse* | `combate-nucleo` ✅ |
| 6 | **La Mirada** (exploración) | Final del trabajo por ración: el primer hilo | Fuera de combate: el mundo se vuelve gris y aparece el hilo | Exploración (futuro) |
| 7 | **Balanza** (el valor) | El milagro de Nilo (C3) | Aparece el medidor cuando el jugador juega su primera carta ☀ o ☾ | `combate-nucleo` ✅ (mostrar/ocultar: tutorial) |
| 8 | **Cartas de historia** | La noche de Piero (C4) | La decisión da una carta ✞ distinta según la elección | Narrativa (futuro) |
| 9 | **Santuario:** guardar y editar el mazo; elegir carta de recompensa | Primera vela votiva en los túneles (C5) | Primer santuario obligatorio; la primera recompensa de combate es "elige 1 de 3" | Mundo y guardado (futuro) |
| 10 | **Equilibrio** (*Respirar*) | Túneles (C5), regalo de Madre Agnese | La carta llega cuando la Balanza ya está inclinada | `combate-nucleo` ✅ |
| 11 | **Zonas de la Balanza**: Orden, Inclinado y bonificación | El Pozo de las dos escaleras (C6) | **Puzle fuera de combate**: alternar escaleras de Fulgor y de Umbral. Al salir se enciende el medidor con zonas | `balanza-gracia-desvelar` |
| 12 | **Exceso** y el primer **borrado del Silencio** | Fondo del Pozo: el reflejo sin ojos | Combate breve donde el mazo empuja al Exceso; el reflejo **borra una carta**. Pista: *"Algo calla cuando te inclinas demasiado."* | `silencio-en-combate` |
| 13 | **Cargas de Gracia** (sin poder usarla) | Desde el Pozo en adelante | Las cargas se llenan al terminar turnos en el Orden… pero el botón está **bloqueado**. Es un misterio deliberado | `balanza-gracia-desvelar` |
| 14 | **Cartas de compañero** | Sereth en el osario (C8–C9) | La decisión da *Sereth: la que cierra* o *Muralla de Orvieto* | `compañeros` (futuro) |
| 15 | **Primer talento y Despertar** | Final del Prólogo (nivel 5 y Despertar I) | Pantalla de talentos con solo 3 opciones; el Don II llega con el Despertar | `progresion-heroe` (futuro) |
| 16 | **Huecos y Desvelar** | Fabbri, el Callado (C10) | Fabbri es **inmune al daño**; sus Huecos son 🗣. *Nombrar* (dada por Agnese en C5) es la única forma de romperlo | `balanza-gracia-desvelar` |
| 17 | **Testimonio** | Fabbri, fase 2 | La carta *La familia de Fabbri* (si se encontró el muro del túnel 14) lo Desvela de golpe y devuelve cartas borradas | `silencio-en-combate` |
| 18 | **Inducidos** (no matar) | Fabbri, fase 1 | Los vecinos inducidos protegen a Fabbri; matarlos cuesta una carta de historia. Se despiertan con Voz | `silencio-en-combate` |
| 19 | **Ecos** (interludios con mazo fijo) | Eco 0, el Velo del Templo | Mazo fijo de Eleazar; sin combate o con un ritual. Enseña que en los Ecos "eres otro" | `ecos` (futuro) |
| 20 | **Artilugios** (equipar y sus efectos) | Acto I, Trastevere: el primer cofre con un artilugio útil | El primer artilugio cambia una carta que el jugador ya usa (*Cuchillo de la Via della Cava*) | `artilugios-pasivas` |
| 21 | **Filas**: Vanguardia y Retaguardia | Acto I, los legionarios de la Vía Apia | Formación: los de detrás no se alcanzan cuerpo a cuerpo; llega una carta de área | `filas-iniciativa` |
| 22 | **Iniciativa**: retrasar y precipitar | Acto I, el barquero del Tíber | El barquero regala *Moneda de Caronte* y una carta que retrasa | `filas-iniciativa` |
| 23 | **La Gracia** (técnica definitiva) | Acto I, el ángel de Castel Sant'Angelo | Primera Gracia guiada: Miguel ilumina al jugador y el botón se desbloquea | `balanza-gracia-desvelar` (desbloqueo: tutorial) |
| 24 | **Acusaciones** (decisiones pasadas en combate) | Acto I, el Acusador | El jefe muestra decisiones del Prólogo; las cartas de Testimonio responden | `jefes-acto-i` |
| 25 | **Estados** (Quemadura, Ceguera, Escarcha…) | Acto I, combates normales | Aparecen de uno en uno con su icono y una línea en el Diario | `estados` |
| 26 | **Corrupción de cartas** | Acto I final / Acto II: el primer altar de escarcha | Una carta jugada en Exceso se agrieta; el altar ofrece corromper un artilugio | `corrupcion` |
| 27 | **Vínculo** de compañeros | Acto II, el campamento de Saint-Denis | Una conversación sube el Vínculo y la carta del compañero mejora a la vista | `compañeros` |
| 28 | **Conjuntos de artilugios** | Acto II, la segunda pieza de un conjunto | El inventario muestra el bono "2/3" | `artilugios-pasivas` |
| 29 | **Legión** (enemigos que ocupan una fila) | Acto II, el Louvre | Enemigo que se divide al recibir daño; las cartas de área brillan | `enemigos-acto-ii` |
| 30 | **Serafines Huecos** (solo ◐ Sombra) y ofrecimientos | Acto II final, Montmartre | Primer enemigo inmune a casi todo; ofrece beneficios que inclinan la Balanza | `enemigos-acto-ii` |

**Ritmo resultante:** el Prólogo enseña unas 19 mecánicas en ~2 h (muchas son pequeñas). El Acto I enseña 6 en ~6 h y el Acto II, 5 en ~7 h. A partir del Acto III ya no hay mecánicas nuevas de combate, **solo combinaciones y dominio**.

---

## 3. El Prólogo como tutorial, escena a escena

Referencia de escenas: [01-prologo.md](../consolidacion/arcos/01-prologo.md) (C1–C12).

### Combate de apertura (antes de C1)
- **Lugar:** la Noche de las Rupturas. **Un solo combate compartido por todos los Orígenes:** cada Origen cambia solo la ambientación, el texto y el tipo de enemigo (un saqueador en Roma, un custodio en las catacumbas, un Fiel de la Aurora en Turín…), con las mismas estadísticas y el mismo patrón.
- **Mazo fijo:** 6 cartas (4 de ataque, 2 de *Cubrirse*). **Orden de robo fijo.**
- **Enemigo:** un único enemigo humano (un saqueador o un Fiel de la Aurora), 14 de Vitalidad, patrón: *atacar 3 → atacar 3 → golpe fuerte 9*.
- **Lección:** ronda 1, jugar cartas y Fervor. Ronda 2, ves el *golpe fuerte 9* anunciado. Ronda 3, en la mano está *Cubrirse*.
- **Pista única (si el jugador no hace nada en 10 s):** *"Arrastra una carta hacia el enemigo."*
- **Si pierde:** reintento instantáneo.

### C2 · Trabajo por ración (por Vía)
Cada Vía aprende el **Velo** y su **Don I** en su propio trabajo:

| Vía | Trabajo | Enemigo de la lección | Lo que aprende |
|---|---|---|---|
| Consagrador | Limpiar la cisterna | Sombras-rata (etéreas) | Velo; *Lo humilde*: cartas de coste 0 más fuertes |
| Cantor | Calmar el túnel 9 | Una sombra que susurra (etérea) | Velo; *Lectura*: ve los Huecos desde el inicio (adelanta la mecánica 16 solo como vista) |
| Psicopompo | Enterrar a los muertos | El muerto que no quiere irse | Velo; *Ecos*: liberar o retener el eco del caído |
| Taumaturgo | Ayudar en la enfermería | Una fiebre que se manifiesta (etérea) | Velo; *Residuo*: curar de más da Velo |

- **Momento narrativo del Velo:** Madre Agnese, después del combate: *"Eso no se para con los brazos. Se para con esto."* Y da *Persignarse* (o la carta de Velo de la Vía).
- **Al terminar:** el primer **hilo** (mecánica 6, la Mirada).

### C3 · El milagro
- Sin combate. Nilo cura a Piero.
- **Primera vez que aparece el medidor de la Balanza**, justo después del milagro, en el primer combate siguiente, al jugar la primera carta ☀ o ☾. Solo se muestra el valor (sin zonas).

### C4 · La noche de Piero (opcional)
- **Primera decisión con icono** (☀ ◆ ☾ y ✞). Enseña que **las decisiones dan cartas**.

### C5 · Las voces del túnel
- **Primer santuario** (vela votiva): guardar, editar el mazo y viajar. Obligatorio en el camino.
- **Primera recompensa "elige 1 de 3".**
- **Madre Agnese** da dos cartas antes de bajar: *Respirar* (Equilibrio) y ***Nombrar*** (Voz), con una frase: *"Los nombres importan ahí abajo."* *Nombrar* no tiene utilidad obvia hasta Fabbri, y es a propósito.
- **Sin artilugios en el Prólogo.** Los cofres dan óbolos, materiales o cartas. Los artilugios se enseñan en el Acto I (mecánica 20) para no recargar el Prólogo.

### C6 · El Pozo de las dos escaleras
- **Puzle sin combate:** la escalera de bajada brilla en Fulgor y la de subida en Umbral. Si solo usas una, el pozo se alarga. Hay que alternar.
- **Al salir:** el medidor de la Balanza **se divide en zonas** (Orden en el centro). Una línea: *"En el centro, las dos escaleras se tocan."*
- **Fondo del pozo:** combate corto contra **el reflejo sin ojos**. El mazo de ese momento empuja a ☀ (el jugador lleva cartas de Fulgor); al entrar en **Exceso**, el reflejo **borra una carta** de la mano (Laguna). Es el **primer contacto con el Silencio**, contado por la mecánica.
- **Cargas de Gracia:** desde aquí aparecen tres círculos vacíos que se llenan al terminar turnos en el Orden. El botón de Gracia está bloqueado, con un candado y el texto *"Aún no sabes a quién pedírsela."*

### C7–C9 · El osario y Sereth
- **Decisión principal del Prólogo** → carta de compañero o *Muralla de Orvieto*.
- Si se libera a Sereth: su carta aparece **en el siguiente combate**, ya en la mano, con una pista: *"Sereth espera a que alguien esté a punto de caer."*

### C10 · Fabbri, el Callado (jefe del Prólogo)
Es el **examen** del Prólogo: combina Guardia/Velo, Balanza, Voz y Testimonio.
- **Fase 1:** Fabbri es **inmune** (el número de daño aparece tachado). Sus Huecos son 🗣🗣🗣🗣. Los vecinos **inducidos** lo protegen. Matar a un vecino muestra un aviso narrativo y quita una carta ✞.
  - **Pista si el jugador ataca 3 veces sin efecto:** *"Agnese dijo que los nombres importan."* (*Nombrar*.)
- **Fase 2:** la nana sin boca. Si el jugador tiene *La familia de Fabbri* (encontrada en el túnel 14), jugarla lo **Desvela de golpe**: es la primera carta de **Testimonio**.
- **Si no la tiene,** el combate es más largo, pero posible solo con *Nombrar*. **Nunca se bloquea el avance por no haber explorado.**

### C11–C12 y Eco 0
- **Subida de nivel y primer talento** (si llega a nivel 5) y **Despertar I** (Don II).
- **Eco 0:** ritual con mazo fijo de Eleazar. Enseña que en los Ecos **eres otra persona** con otras cartas, y que al volver **traes una carta**.

---

## 4. Reglas para diseñar combates de lección

| Regla | Detalle |
|---|---|
| **Orden de robo fijo** | Los combates de "aprender" pueden fijar las primeras cartas que se roban para garantizar la situación de la lección |
| **Enemigos con guion** | Patrón de intenciones corto y legible, pensado para la lección (por ejemplo: *3 → 3 → 9*) |
| **Vitalidad baja** | Los combates de lección duran 2–4 rondas como máximo |
| **Una pista, una línea** | Solo aparece si el jugador duda (sin actuar unos segundos) o se equivoca de forma clara. Nunca más de una a la vez |
| **Reintento instantáneo** | En Custodio y Mártir, solo en los combates de "aprender". En **Peregrino**, en cualquier combate |
| **Opción de saltar** | En nuevas partidas, un ajuste permite **saltar las pistas** (no los combates). En **Peregrino** las pistas no se pueden desactivar |
| **Coherencia narrativa** | Cada pista la dice un personaje (Agnese, Sereth, Bruno) o es un pensamiento del héroe. Nunca "PULSA X" |

---

## 5. Requisitos técnicos que salen de este documento

Para tenerlos en cuenta en los próximos cambios de OpenSpec:

1. **Encuentros como datos** (`EncounterData`): enemigos, posiciones, **orden de robo fijo opcional**, si permite reintento y qué pistas tiene.
2. **Sistema de pistas** del tutorial: una pista se dispara por **eventos del EventBus** (por ejemplo, "3 ataques sin efecto contra un Callado") o por inactividad, y solo una vez.
3. **Mecánicas bloqueadas u ocultas en la interfaz:** zonas de la Balanza, cargas de Gracia, botón de Gracia y Huecos se muestran según **flags de "mecánica aprendida"** en el estado de la partida.
4. **Reintento de combate** sin pasar por el guardado.
5. **Entradas de "Lo aprendido"** en el Diario, activadas por los mismos flags.
6. **La Gracia se puede cargar antes de poder usarse** (bloqueo independiente de las cargas).

---

## 6. Hoja de ruta de cambios de código (actualizada)

| Orden | Cambio de OpenSpec | Mecánicas (§2) | Necesario para |
|---|---|---|---|
| ✅ | `combate-nucleo` | 1–5, 7, 10 | Base |
| 1 | `balanza-gracia-desvelar` | 11, 13, 16, 23 (técnica) | Pozo, Fabbri, Miguel |
| 2 | `silencio-en-combate` | 12, 17, 18 | Pozo, Fabbri |
| 3 | `tutorial-encuentros` | Requisitos de §5 | Todo el Prólogo |
| 4 | `compañeros` | 14, 27 | Sereth |
| 5 | `progresion-heroe` | 15 (niveles, talentos, Despertares, Dones) | Final del Prólogo |
| — | **Porción jugable del Prólogo** (necesita además exploración, diálogos, guardado y arte, **previa consulta**) | 6, 8, 9, 19 | Primer hito jugable |
| 6+ | `artilugios-pasivas`, `filas-iniciativa`, `estados`, `corrupcion`, jefes y enemigos por acto | 20–30 | Actos I y II |

---

## 7. Decisiones tomadas

- **Combate de apertura compartido** por todos los Orígenes (si se mantienen): mismas estadísticas y patrón; cambian la ambientación, el texto y el enemigo. Ver §3.
- **Los artilugios se enseñan en el Acto I**, no en el Prólogo. Ver §3 (C5) y la mecánica 20.
- **Dificultad Peregrino:** pistas siempre activas (no desactivables) y reintento instantáneo en cualquier combate. Ver §4 y [01-pilares-y-bucle.md](01-pilares-y-bucle.md) (Dificultad).
