# Running Recap — Historial de Implementaciones

Aplicación web single-file (`index.html`) desplegada en GitHub Pages.  
Repositorio: [JowyMx/running-recap](https://github.com/JowyMx/running-recap)

---

## Funcionalidades principales

### Carga de datos
- **Archivos soportados**: GPX / TCX / KML (ruta + métricas básicas) y CSV de Garmin (métricas avanzadas sin ruta)
- **Combinación**: se pueden subir ambos archivos para obtener ruta + métricas avanzadas
- **Nombre de sesión**: campo de texto con autoguardado en `localStorage`

### Fondo del recap
- **Foto de fondo** (`bg-photo`): zona de carga con drag-and-drop, muestra la foto como fondo a pantalla completa con overlay oscuro `rgba(0,0,0,0.55)` para legibilidad
- **Video de fondo**: se detecta automáticamente por `file.type.startsWith('video/')`, se inserta un `<video autoplay loop muted playsinline>` como fondo
- **Z-index**: `bg-photo(0)` → `#screen(1)` → controles UI (2)

---

## Pantalla de carga — Opciones de personalización

### Temas completos
6 temas predefinidos que aplican fondo + color de texto en un solo toque:

| Tema | Fondo | Color texto |
|---|---|---|
| Custom | Sin tema (foto/video del usuario) | — |
| Noche | `#0a0a0a` | Blanco |
| Strava | `linear-gradient(160deg, #3d1500, #0a0a0a)` | Naranja Internacional |
| Garmin | `linear-gradient(160deg, #002847, #000d1a)` | Azul Garmin |
| Blanco | `#f0f0f0` | Negro |
| Trail | `linear-gradient(160deg, #1b2f12, #080c06)` | Amarillo |

- Al subir una foto/video se activa automáticamente "Custom"
- Tema y foto/video conviven: el tema aplica el fondo solo si no hay foto

### Posición del recap
Selector de 5 posiciones con iconos visuales (mini mockup de pantalla):
- **Pantalla completa** (por defecto)
- **Arriba izquierda / Arriba derecha**
- **Abajo izquierda / Abajo derecha**

En modo esquina el `#screen` es un panel `58vw × 60vh` con fondo transparente sobre la foto/video. Usa `transform: translateZ(0)` para anclar los elementos de navegación al panel.

### Color de texto
Selector con colores predefinidos + picker personalizado:
- Blanco `#ffffff` (por defecto)
- Negro `#000000`
- Amarillo `#ffe066`
- Aqua `#7fffd4`
- Rojo `#ff6b6b`
- Naranja Internacional `#FF4F00`
- Azul Garmin `#109AD7`
- Picker personalizado `<input type="color">`

El color se aplica mediante una etiqueta `<style id="rt-override">` inyectada dinámicamente que cubre:
- `#screen * { color: ${color} }` — todo el texto HTML
- `#screen [class$="-bar"] { background: ${color} }` — todas las barras de gráficas
- `#screen svg text/circle/line/path` — elementos SVG
- `#screen svg stop` — gradientes SVG (primer stop: opacidad 0.22, último: 0)
- Canvas del mapa de ruta (`ctx.strokeStyle` y `ctx.fillStyle`)

---

## Selector de métricas

- Lista visual de métricas disponibles con icono, nombre y valor preview
- Checkbox de selección con checkmark animado
- Botón "Seleccionar todo / Desmarcar todo"
- **Duración estimada del recap** en tiempo real: suma los milisegundos de cada slide según las métricas seleccionadas y datos disponibles. Se actualiza al marcar/desmarcar cada métrica
- Preferencias guardadas en `localStorage`

### Métricas disponibles
| Icono | Métrica | Slides generados |
|---|---|---|
| 📏 | Distancia | 1 slide valor |
| ⏱ | Tiempo | 1 slide valor |
| 🏃 | Ritmo | 1 valor + tabla vueltas + gráfica |
| ❤️ | Frecuencia cardíaca | 1 valor + tabla + gráfica |
| ⛰ | Elevación | 1 valor + tabla + perfil GPS |
| 🔄 | Cadencia | 1 valor + tabla + gráfica |
| 👟 | Zancada | 1 valor + tabla + gráfica |
| ⚡ | Potencia | 1 valor + tabla + gráfica |
| 💪 | Tiempo de contacto | 1 valor + tabla + gráfica |
| 🌡 | Temperatura | 1 valor + tabla + gráfica |
| 📐 | Relación vertical | 1 valor + tabla + gráfica |
| 〰️ | Oscilación vertical | 1 valor + tabla + gráfica |

---

## Reproducción del recap

### Navegación
- **Toque derecho / tecla →**: avanza al siguiente slide
- **Toque izquierdo / tecla ←**: regresa al slide anterior
- Detección de zona por `e.clientX` vs `offsetWidth / 2`

### Resumen final
- Tabla con todas las métricas seleccionadas + iconos alineados a la izquierda
- Mapa de ruta GPS renderizado en `<canvas>` (si hay datos GPX/TCX/KML)
- Botones "Repetir" y "Nueva sesión" aparecen tras **3 segundos** de delay

### Tablas de vueltas
- Grid CSS: `2em 3.2em minmax(0,1fr) auto` con gap `6px`
- Columna TOTAL usa `auto` + `white-space: nowrap` para no truncar tiempos
- Barras animadas desde 0% al valor real con easing cuadrático

---

## Elementos eliminados
- ~~Botón de compartir como Story 9:16~~ (eliminado — `#story-btn` + `shareStory()`)
- ~~Barra de progreso lineal~~ (eliminada — `#bar`)
- ~~Puntos de avance por slide~~ (eliminados — `#dots`)
- ~~Indicador "toca para avanzar"~~ (eliminado — `#tap-hint`)
- ~~Transición dip-to-black entre slides~~ (implementada y luego revertida por preferencia del usuario)

---

## Archivos del proyecto
```
index.html     — App completa (único archivo)
manifest.json  — PWA manifest
icon.svg       — Ícono de la app
CHANGELOG.md   — Este archivo
```

---

## Stack técnico
- HTML5 / CSS3 / JavaScript vanilla (sin frameworks)
- `FileReader` API — carga de archivos locales
- `Canvas 2D` — mapa de ruta GPS
- `localStorage` — persistencia de preferencias
- `Web Share API` — (removido)
- `html2canvas` — (librería incluida, sin uso activo)
- GitHub Pages — deploy automático desde `master`
