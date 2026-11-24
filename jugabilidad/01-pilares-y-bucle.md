# Pilares y bucle de juego

## Pilares de diseño

Toda decisión de diseño se contrasta con estos cinco pilares. Si una mecánica no sirve a ninguno, sobra.

1. **Tu héroe es tuyo.** Dos jugadores con la misma Vía deben terminar el juego con héroes distintos por su Linaje, sus talentos, su mazo, sus artilugios y las cartas que les dio la historia.
2. **La historia se juega, no se lee.** Cada decisión y cada personaje salvado o perdido **cambia tu mazo**. Quien presta atención a la historia tiene un mazo mejor.
3. **El equilibrio es poder, y el exceso es tentación.** La Balanza Fulgor ↔ Umbral es el corazón de cada combate. Inclinarse da potencia inmediata; mantenerse en el centro da la Gracia. El Silencio castiga los extremos.
4. **Lo que falta es lo que importa.** Los enemigos del Silencio se vencen con verdad: cartas de testimonio, nombres, voz. La mecánica repite el tema.
5. **Respeta el tiempo del jugador.** Combates de 3 a 6 minutos, diálogos de una o dos líneas, enemigos visibles en el mapa (sin combates aleatorios) y guardado frecuente.

---

## Bucle principal

```
 EXPLORAR ──► COMBATIR ──► OBTENER ──► CONSTRUIR ──► DECIDIR
 (zona, Mirada) (cartas, Balanza) (drops, cartas, XP) (mazo, artilugios, talentos) (historia)
     ▲                                                                           │
     └───────────────────────────────────────────────────────────────────────────┘
```

| Bucle | Duración | Qué hace el jugador |
|---|---|---|
| **Micro** (un turno) | 15–40 s | Lee las intenciones enemigas, juega cartas, gestiona Fervor y Balanza |
| **Medio** (un combate) | 3–6 min | Desvela enemigos, busca la Gracia, sobrevive. Recompensa: XP, carta a elegir, posible artilugio |
| **Macro** (una zona) | 30–60 min | Explora, encuentra secretos con la Mirada, toma una decisión narrativa, vence a un jefe y ajusta el mazo en un santuario |
| **Campaña** | ~30 h | Sube de nivel, reúne artilugios y cartas de historia, forma su versión del héroe y llega a un final |

---

## Estructura de la campaña

**Duración total: unas 30 horas** (unas 20 h siguiendo solo la historia principal).

| Parte | Lugar | Duración | Hub | Jefes principales | Nivel al terminar |
|---|---|---|---|---|---|
| **Prólogo** | Orvieto | 2 h | Orvieto | Fabbri, el Callado | 6 |
| **Acto I** | Roma | 6 h | Trastevere | La Procesión de las Sombras y el Acusador | 14 |
| **Acto II** | París y Francia | 7 h | Belleville | El Guardián de los Seis Millones; élites en Loudun y Tiffauges | 22 |
| **Acto III** | Lourdes y Armenia | 8 h | Hotel de Madame Lucienne; Echmiadzin | La Madre de la Gruta; el Heraldo (Gueghard) | 31 |
| **Acto IV** | Oviedo, Aviñón y Aksum | 7 h | Capilla de la Tabla | El Gran Inquisidor; Saccà; el Retornado; la Voz Ausente | 40 |

- **Entre actos** se juegan los **Ecos** (de 15 a 30 minutos cada uno, ver §Ecos en [07-exploracion-y-mundo.md](07-exploracion-y-mundo.md)).
- **Contenido opcional (unas 10 h):** misiones secundarias, zonas para farmear, conjuntos de artilugios, jefes opcionales (el Cefalóforo, Gilles de Rais, los Doce Santos) y un **post-juego**: la *Cripta de las Lagunas*, un desafío de combates encadenados con artilugios Máximos exclusivos.

- **Orvieto sigue siendo la base** durante toda la partida. Desde cualquier santuario se puede volver: allí están el fabricante de artilugios, la purificación de cartas y las conversaciones con los compañeros.
- **El juego es lineal por actos, con zonas abiertas dentro de cada acto**: el orden de las misiones dentro de un acto es libre.

---

## Progresión general

El héroe crece en cuatro ejes a la vez. Ninguno basta por sí solo:

| Eje | Cómo crece | Ritmo |
|---|---|---|
| **Nivel** (1–40) | XP de combates y misiones | Algo más de 1 nivel por hora; más rápido al principio |
| **Talentos** | Una elección cada 5 niveles (8 en total) | Decisiones grandes y permanentes |
| **Mazo** | Cartas de drop, de historia, de compañeros y de santuarios | Siempre crece; se edita en los santuarios |
| **Artilugios** | Drops, cofres, jefes y fabricación | 6 huecos; mejoras constantes |

**Los Despertares** son hitos narrativos (uno al final del Prólogo y de cada acto: cinco en total) que desbloquean una nueva capacidad de la Vía: un segundo Don, una mano más grande o más Fervor. **Son la recompensa de la historia, no del grindeo.**

---

## Dificultad

- **Peregrino:** narrativa. Más Vitalidad, intenciones enemigas siempre visibles y la Balanza perdona más.
- **Custodio:** la experiencia prevista.
- **Mártir:** los enemigos tienen más Huecos, el Silencio borra cartas desde un exceso menor y las curaciones fuera de combate están limitadas.
- Se puede cambiar en cualquier momento salvo en Mártir, que se fija al empezar.
