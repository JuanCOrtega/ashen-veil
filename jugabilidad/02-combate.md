# Combate

Combate táctico **por turnos**: **un solo héroe** contra **1 a 6 enemigos**. El héroe actúa jugando **cartas**. Los enemigos muestran sus **intenciones** antes de actuar.

---

## 1. El tablero

```
         HÉROE                       ENEMIGOS
                          RETAGUARDIA   [ E4 ] [ E5 ] [ E6 ]
         [ H ]            VANGUARDIA    [ E1 ] [ E2 ] [ E3 ]
```

- El héroe ocupa **una sola posición** y no se mueve. Su "posición" es la **postura**, que cambian algunas cartas.
- Los enemigos se colocan en **2 filas × 3 columnas**:
  - Mientras quede algún enemigo en la **Vanguardia**, los ataques **cuerpo a cuerpo** no alcanzan a la **Retaguardia**.
  - Los ataques **a distancia**, las **Voces** y los efectos de **área** sí alcanzan a la Retaguardia.
  - Hay cartas que **empujan** (de Vanguardia a Retaguardia) o **atraen** (al revés).
- **Ventaja de producción:** la disposición es frontal, al estilo de los JRPG clásicos. No hace falta animar desplazamientos.

## 2. Estructura de una ronda

1. **Inicio de ronda:**
   - El héroe recupera todo su **Fervor** (3 de base).
   - Roba hasta tener **5 cartas** en la mano.
   - Se aplican los efectos de la **Balanza**, incluido el borrado del Silencio si hay exceso.
2. **Intenciones:** cada enemigo muestra un icono con lo que hará: atacar, defenderse, invocar, inducir, borrar…
3. **Turno del héroe:** juega cartas mientras tenga Fervor.
4. **Fin del turno:** las cartas que no se jugaron se descartan (salvo las *Retenidas*).
5. **Turno enemigo:** los enemigos actúan **en el orden de la barra de iniciativa**, visible en la parte superior de la pantalla.
6. **Fin de ronda:** se resuelven los efectos que duran turnos (quemaduras, escarcha, etc.).

### Iniciativa
- La barra muestra el orden de actuación de los enemigos en la ronda actual.
- **Cartas de Umbral** pueden **retrasar** a un enemigo: su acción pasa a la ronda siguiente.
- **Cartas de Fulgor** pueden **precipitar** a un enemigo: actúa primero, cuando el héroe está preparado.

## 3. Recursos del héroe

| Recurso | Base | Función |
|---|---|---|
| **Vitalidad** | Según la Vía y el Linaje | Vida. A 0, la partida termina y se recarga el último guardado |
| **Fervor** | 3 por ronda | La energía para jugar cartas (coste de 0 a 3) |
| **Mano** | 5 cartas | Cartas que se roban cada ronda |
| **Guardia** | 0 | Escudo contra el daño **físico**. Se pierde al inicio de la ronda siguiente |
| **Velo** | 0 | Escudo contra el daño **etéreo**. **No se pierde entre rondas**, pero se desgasta un 50 % cada ronda |
| **Balanza** | 0 | De -10 (Umbral) a +10 (Fulgor) |
| **Gracia** | 0 / 3 cargas | Activa la técnica definitiva de la Vía |

### Daño físico y daño etéreo (la Ley de la Intermediación)
En el lore, las entidades no pueden tocar a los vivos, **salvo a los Despiertos**, cuya ceniza es etérea. En combate:

- **Los enemigos humanos** (fieles, soldados, Callados) hacen **daño físico**, que se para con **Guardia**.
- **Los enemigos etéreos** (Legión, Serafines Huecos, guardianes corrompidos) hacen **daño etéreo**, que golpea la ceniza del héroe y se para con **Velo**.
- La pregunta táctica de cada combate es contra qué te defiendes esta ronda.
- **Las armas físicas no hieren a lo etéreo** salvo que estén **consagradas**. Por eso el Consagrador puede luchar contra todo.

## 4. La Balanza

```
  -10 ······ -6 ······· -2 ··· 0 ··· +2 ······· +6 ······ +10
  │ EXCESO   │ INCLINADO │    ORDEN    │ INCLINADO │  EXCESO  │
  │ UMBRAL   │  UMBRAL   │             │  FULGOR   │  FULGOR  │
```

- **Cada carta mueve la Balanza** según su valor: por ejemplo, ☀+2 hacia el Fulgor o ☾-1 hacia el Umbral. Las cartas de **Voz** y de **Orden** suelen valer 0, o empujan hacia el centro.
- La Balanza **se mantiene entre combates**, aunque al final de cada combate regresa 2 puntos hacia el centro.

| Zona | Efecto |
|---|---|
| **Orden** (de -2 a +2) | Al terminar el turno aquí se gana **1 carga de Gracia**. Las cartas de Voz cuestan 1 menos |
| **Inclinado** (de ±3 a ±6) | Las cartas de esa fuerza hacen **+25 %** |
| **Exceso** (de ±7 a ±10) | Las cartas de esa fuerza hacen **+50 %**, pero **el Silencio borra 1 carta de la mano** al inicio de cada ronda (ver §7) y las cartas que se juegan aquí acumulan **corrupción** |

**El dilema de cada combate:** ¿aprovechar el exceso para acabar rápido o volver al centro para cargar la Gracia?

## 5. La Gracia

- Se gana **1 carga** por cada turno que termina en la zona de Orden, y **otra** al jugar ciertas cartas de testimonio.
- Con **3 cargas** se puede activar la **técnica de Gracia** de la Vía, que viene de su coro angélico patrón (ver [03-heroe.md](03-heroe.md)). Es la definitiva del héroe.
- Las cargas **se pierden si se entra en Exceso**.
- **Momentos de Gracia narrativa:** algunos jefes tienen fases en las que un ángel ofrece la Gracia de inmediato si el héroe hace algo concreto (decir la verdad, perdonar, soltar). Son la escena épica de cada acto.

## 6. Desvelar (romper al enemigo)

Cada enemigo tiene una barra de **Huecos**: iconos que indican qué lo expone.

| Icono | Se rompe con |
|---|---|
| ⚔ Físico | Ataques físicos |
| ☀ Fulgor | Cartas de Fulgor |
| ☾ Umbral | Cartas de Umbral |
| 🗣 Voz | Cartas de Voz y de testimonio |
| ◐ Sombra | Cartas que "proyectan sombra" (Umbral u Orden). **Única forma de herir a los Serafines Huecos** |

- Cada golpe del tipo correcto **quita un Hueco**. Al llegar a 0, el enemigo queda **Desvelado**: pierde su próxima acción y recibe **daño doble** durante una ronda.
- Algunos Huecos están **ocultos (?)** hasta que el héroe usa la **Mirada** (una acción gratuita por combate) o lleva el **Linaje del Rostro**.
- **Los Callados son inmunes al daño** hasta ser Desvelados, y sus Huecos son **solo de Voz**. *Al Silencio se le vence diciendo.*

## 7. El Silencio en combate

El Silencio no ataca la Vitalidad: **ataca el mazo**.

| Efecto | Qué hace |
|---|---|
| **Laguna** | Borra una carta de la mano: se exilia hasta el final del combate |
| **Mordaza** | Las cartas de Voz cuestan +1 durante X rondas |
| **Escarcha** | Una carta de la mano queda congelada y no se puede jugar este turno |
| **Olvido** | Una carta del mazo desaparece durante el resto del combate, sin que se diga cuál. Se revela al barajar |
| **Hueco en el nombre** | Un compañero (carta) no responde: se baraja en el fondo del mazo |

**Contramedida:** las cartas con la palabra clave **Testimonio** devuelven cartas borradas a la mano.

## 8. Corrupción de cartas

- Cada vez que se juega una carta **estando en Exceso**, gana 1 punto de **corrupción**.
- Con **3 puntos**, la carta se **transforma** en su versión corrompida: más poderosa y con un coste añadido. Ejemplo:

| Carta normal | Carta corrompida |
|---|---|
| **Imposición de manos** (1 ☀+2): cura 8 | **Que nadie muera** (1 ☀+4): cura 14. **El objetivo no puede morir durante 3 rondas**, ni siquiera los enemigos curados por efectos de área |

- Las cartas corrompidas se pueden **purificar** en los santuarios (ver [07-exploracion-y-mundo.md](07-exploracion-y-mundo.md)), con un coste.
- **Conexión narrativa:** un mazo muy corrompido cambia algunos diálogos, y los compañeros lo comentan. Si más de un tercio del mazo está corrompido al final, se abre el **final de la Luz Única** o el **final del Silencio**.

## 9. Compañeros como cartas

- Cada compañero reclutado añade **2 o 3 cartas** al catálogo del jugador.
- Al jugarse, el compañero **aparece un instante** en el campo (una sola animación), hace su efecto y desaparece.
- El **Vínculo** (de 1 a 3) sube con las decisiones de la historia y **mejora sus cartas**. Ejemplo:

| Sereth — *La que cierra* | Vínculo 1 | Vínculo 2 | Vínculo 3 |
|---|---|---|---|
| 1 ☾-2 | Un enemigo con menos del 20 % de Vitalidad muere | …con menos del 30 % | …y su eco se convierte en una carta temporal para el héroe |

## 10. Recompensas de combate

| Recompensa | Siempre | A veces |
|---|---|---|
| XP | ✅ | |
| **Óbolos** (moneda) | ✅ | |
| **Elegir 1 carta de 3**, o saltar y recibir óbolos | ✅ en combates normales | |
| Materiales de fabricación | | ✅ |
| **Artilugio** | | ✅ (élites y jefes siempre) |
| Carta de historia | | Solo en combates narrativos |

## 11. Duración prevista

| Tipo | Enemigos | Rondas | Minutos |
|---|---|---|---|
| Normal | 2–4 | 3–5 | 3–4 |
| Élite | 1–3 (uno con aura) | 5–7 | 5–6 |
| Jefe | 1 + invocaciones, con 2 o 3 fases | 8–14 | 10–15 |
