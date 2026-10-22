

# ElementaryAlpine: Aplicaciones web reactivas con Swift

**Extensiones ergonómicas de [AlpineJS](https://alpinejs.dev/) para [Elementary](https://github.com/elementary-swift/elementary)**

```swift
import Elementary
import ElementaryAlpine

struct CounterPage: HTMLDocument {
    var head: some HTML {
        meta(.charset(.utf8))
        title("Counter")
        setupAlpine()
    }
    var body: some HTML {
        main(.class("container")) {
            div(.x.data("{ count: 0 }"), .class("counter")) {
                button(.x.on("click", "count--")) { "−" }
                span(.x.text("count")) { "0" }
                button(.x.on("click", "count++")) { "+" }
                button(.x.on("click", "count = 0"), .x.show("count > 0")) { "Reset" }
            }
        }
    }
}
```

**HTML generado:**

```html
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>Counter</title>
    <script
      src="https://cdn.jsdelivr.net/npm/alpinejs@3.15.12/dist/cdn.min.js"
      defer
    ></script>
  </head>
  <body>
    <main class="container">
      <div x-data="{ count: 0 }" class="counter">
        <button x-on:click="count--">−</button>
        <span x-text="count">0</span>
        <button x-on:click="count++">+</button>
        <button x-on:click="count = 0" x-show="count > 0">Reset</button>
      </div>
    </main>
  </body>
</html>
```

## Úsalo

Agrega `ElementaryAlpine` a las dependencias de tu `Package.swift`:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MyApp",
    dependencies: [
        .package(url: "https://github.com/elementary-swift/elementary-alpine", from: "0.3.0"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "ElementaryAlpine", package: "elementary-alpine"),
            ]
        ),
    ]
)
```

Para usar [plugins de Alpine.js](https://alpinejs.dev/plugins), agrega el producto `ElementaryAlpinePlugins`:

```swift
.product(name: "ElementaryAlpinePlugins", package: "elementary-alpine"),
```

Este paquete está construido contra **Alpine.js v3** (fijado en `3.15.12`).

## Pruébalo

Las aplicaciones de ejemplo se agregarán en el futuro.

## Recorrido rápido

```swift
// first-class support for all AlpineJS directives
div(.x.data("{ count: 0 }"), .class("counter")) {
    button(.x.on("click", "count++")) { "Increment" }
    span(.x.text("count")) { "0" }
}
```

```swift
// bind attributes reactively
input(.x.bind("placeholder", "text"), .type(.text))

// bind class with object syntax
div(.x.bindClass("{ 'hidden': !open }"))

// bind style with object syntax
div(.x.bindStyle("{ color: 'red' }"))
```

```swift
// event modifiers (passed as a modifiers array)
form(.x.on("submit", "...", modifiers: [.prevent])) {
    button { "Submit" }
}

// keyboard modifiers
input(.x.on("keyup", "submit()", modifiers: [.enter]))

// debounce / throttle (ms)
input(.x.on("input", "fetchResults()", modifiers: [.debounce(500)]))
```

```swift
// two-way binding
input(.x.model("search"))

// model with modifiers
input(.x.model("search", modifiers: [.number, .debounce(300)]))
```

```swift
// loops (semantic name for x-for)
template(.x.loop("item in items")) {
    li(.x.text("item")) { "" }
}

// conditional rendering (semantic name for x-if)
template(.x.when("open")) {
    div { "Content" }
}

// transitions with modifiers
div(.x.show("open"), .x.transition(modifiers: [.scale(80), .origin(.top)])) {
    "Content"
}
```

## Globales

Las APIs globales de Alpine.js (`Alpine.data`, `Alpine.store`, `Alpine.bind`) están disponibles como `registerGlobal` para registrar componentes reutilizables, almacenes (stores) y directivas enlazadas. El cuerpo de la acción es un cierre de cola que devuelve una expresión de JavaScript:

```swift
import ElementaryAlpine

// In your head:
registerGlobal(.data, on: "dropdown") {
    "() => ({ open: false, toggle() { this.open = !this.open } })"
}
registerGlobal(.store, on: "notifications") {
    "{ items: [] }"
}
registerGlobal(.bind, on: "myButton") {
    "() => ({ type: 'button' })"
}
```

**HTML generado:**

```html
<script>
  document.addEventListener('alpine:init', () => {
    Alpine.data('dropdown', () => ({
      open: false,
      toggle() {
        this.open = !this.open
      },
    }))
  })
</script>
<script>
  document.addEventListener('alpine:init', () => {
    Alpine.store('notifications', { items: [] })
  })
</script>
<script>
  document.addEventListener('alpine:init', () => {
    Alpine.bind('myButton', () => ({ type: 'button' }))
  })
</script>
```

**API:**

| Función                                  | Llamada de Alpine.js          | Caso de uso                                     |
| ---------------------------------------- | ----------------------------- | ----------------------------------------------- |
| `registerGlobal(.data, on:) { ... }`     | `Alpine.data(name, factory)`  | Datos de componente reutilizable (función fábrica) |
| `registerGlobal(.store, on:) { ... }`    | `Alpine.store(name, value)`   | Almacén reactivo global (objeto directo)        |
| `registerGlobal(.bind, on:) { ... }`     | `Alpine.bind(name, factory)`  | Objeto x-bind reutilizable (función fábrica)    |

## Configuración

El ayudante `setupAlpine(version:plugins:)` genera las etiquetas `<script>` necesarias para instalar Alpine.js y cualquier plugin desde un CDN. Los scripts de los plugins se emiten primero (según los requisitos de Alpine.js), seguidos del núcleo de Alpine.

**Sin plugins:**

```swift
var head: some HTML {
    meta(.charset(.utf8))
    setupAlpine()
}
```

**Con plugins:**

```swift
var head: some HTML {
    meta(.charset(.utf8))
    setupAlpine(plugins: [.mask, .focus, .morph])
}
```

**HTML generado:**

```html
<script
  src="https://cdn.jsdelivr.net/npm/@alpinejs/mask@3.15.12/dist/cdn.min.js"
  defer
></script>
<script
  src="https://cdn.jsdelivr.net/npm/@alpinejs/focus@3.15.12/dist/cdn.min.js"
  defer
></script>
<script
  src="https://cdn.jsdelivr.net/npm/@alpinejs/morph@3.15.12/dist/cdn.min.js"
  defer
></script>
<script
  src="https://cdn.jsdelivr.net/npm/alpinejs@3.15.12/dist/cdn.min.js"
  defer
></script>
```

**Plugins disponibles** (usa los casos del enum `AlpinePlugin`):

| Plugin    | Caso del enum  | Origen                |
| --------- | -------------- | --------------------- |
| Mask      | `.mask`        | `@alpinejs/mask`      |
| Intersect | `.intersect`   | `@alpinejs/intersect` |
| Resize    | `.resize`      | `@alpinejs/resize`    |
| Persist   | `.persist`     | `@alpinejs/persist`   |
| Focus     | `.focus`       | `@alpinejs/focus`     |
| Collapse  | `.collapse`    | `@alpinejs/collapse`  |
| Anchor    | `.anchor`      | `@alpinejs/anchor`    |
| Sort      | `.sort`        | `@alpinejs/sort`      |
| Morph     | `.morph`       | `@alpinejs/morph`     |

**Versión personalizada:**

```swift
setupAlpine(version: "3.14.0", plugins: [.focus])
```

### Incluir Alpine.js manualmente

`setupAlpine` siempre emite URLs del CDN de jsDelivr. Si necesitas alojar Alpine.js tú mismo, usar un CDN diferente o autoalojar tus scripts de plugins, escribe las etiquetas `<script>` directamente. **Los scripts de los plugins deben cargarse antes que el núcleo de Alpine** — según la documentación de Alpine.js, el script del núcleo se engancha a las instancias de los plugins al inicio.

**Desde un CDN:**

```swift
var head: some HTML {
    meta(.charset(.utf8))
    script(.src("https://cdn.jsdelivr.net/npm/alpinejs@3.15.12/dist/cdn.min.js"), .defer) {}
}
```

**Desde un archivo local:**

Descarga `alpine.min.js` desde los [lanzamientos de Alpine.js](https://github.com/alpinejs/alpine/releases) y colócalo en el `Public/` de tu proyecto (o directorio equivalente servido). Para Hummingbird/Vapor, declara el recurso en `Package.swift`:

```swift
.executableTarget(
    name: "App",
    // ...
    resources: [
        .copy("Public")
    ]
)
```

Luego refiérete a él por su ruta de URL:

```swift
var head: some HTML {
    meta(.charset(.utf8))
    script(.src("/alpine.min.js"), .defer) {}
}
```

> El mismo patrón se aplica a los scripts de plugins: descarga cada lanzamiento de `@alpinejs/<plugin>@3.15.12`, coloca el `cdn.min.js` en `Public/` y cárgalos en orden de plugins primero.

## Modificadores

Las directivas que soportan modificadores toman un parámetro de array `modifiers:` con un valor de enum tipado:

```swift
// x-show
.x.show("open", modifiers: [.important])              // → x-show.important="open"

// x-on
.x.on("click", "...", modifiers: [.prevent, .stop])  // → x-on:click.prevent.stop="..."
.x.on("keyup", "...", modifiers: [.enter])            // → x-on:keyup.enter="..."
.x.on("input", "...", modifiers: [.debounce(500)])    // → x-on:input.debounce.500ms="..."
.x.on("click", "...", modifiers: [.selfTarget])       // → x-on:click.self="..."

// x-model
.x.model("search", modifiers: [.number, .change, .blur, .enter])

// x-transition
.x.transition(modifiers: [.opacity])
.x.transition(modifiers: [.scale(80), .origin(.topRight)])
.x.transition(modifiers: [.duration(500), .delay(50)])
```

### Transiciones multipase personalizadas

Para un control total sobre las clases `x-transition:phase` (por ejemplo, utilidades de Tailwind en un componente estilo Pines), usa las funciones por fase. Cada una toma un `String` de clases CSS y devuelve un único `HTMLAttribute<Tag>` que puede pasarse en línea con otros atributos:

```swift
div(.x.show("open"),
    .x.transitionEnter("transition ease-out duration-50"),
    .x.transitionEnterStart("opacity-0 -translate-y-1"),
    .x.transitionEnterEnd("opacity-100 translate-y-0"),
    .x.transitionLeave("transition ease-in duration-100"),
    .x.transitionLeaveStart("opacity-100"),
    .x.transitionLeaveEnd("opacity-0 -translate-y-1")
) {
    "Content"
}
```

Funciones disponibles por fase: `.x.transitionEnter`, `.x.transitionEnterStart`, `.x.transitionEnterEnd`, `.x.transitionLeave`, `.x.transitionLeaveStart`, `.x.transitionLeaveEnd`. Incluye solo las fases que necesites.

## Magias (Magics)

Las [magias](https://alpinejs.dev/magics) de Alpine.js son ayudantes del lado de JS que existen dentro de las expresiones de Alpine. No generan atributos HTML ni scripts: aparecen como **literals de cadena** en los valores de las directivas:

```swift
// $dispatch — dispatch a custom event
button(.x.on("click", "$dispatch('notify')")) { "Notify" }

// $store — access a global store
div(.x.text("$store.user.name"))

// $refs — reference an element by key
input(.x.ref("myInput"), .type(.text))
button(.x.on("click", "$refs.myInput.focus()")) { "Focus" }

// $watch — reactively watch a property
div(.x.setup("count = 0; $watch('count', value => console.log(value))"))

// $nextTick — wait for next DOM update
div(.x.setup("$nextTick(() => console.log('mounted')"))

// $el, $root, $data, $id — context accessors
div(.x.data("{ open: false }"), .x.text("$el.tagName"))
```

**Magias disponibles:** `$el`, `$refs`, `$store`, `$watch`, `$dispatch`, `$nextTick`, `$root`, `$data`, `$id`, `$persist` (requiere el [plugin Persist](#persist))

> No se necesita código ni atributos para las magias: simplemente usa el nombre de la magia como una cadena en cualquier expresión de Alpine.

## Plugins

Los [plugins de Alpine.js](https://alpinejs.dev/plugins) extienden el entorno de ejecución con directivas adicionales. Este paquete incluye una biblioteca separada, **`ElementaryAlpinePlugins`**, que los expone como ayudantes de atributos de Swift.

> **Los scripts de plugins de Alpine.js dependen del núcleo de Alpine.js.** A nivel de Swift, `ElementaryAlpinePlugins` no tiene dependencia en tiempo de compilación de `ElementaryAlpine`: ambas bibliotecas solo dependen de `Elementary`. La dependencia existe a nivel de **tiempo de ejecución de JavaScript**: los scripts del CDN de los plugins se enganchan a la instancia principal de Alpine, por lo que la etiqueta del script del plugin debe estar presente en tu página (y cargarse antes que el núcleo de Alpine, según la documentación de Alpine.js).

Usa [`setupAlpine(plugins:)`](#setup) para instalar las etiquetas de script de los plugins que utilices — los scripts de los plugins se emiten antes que el núcleo de Alpine, en el orden correcto:

```swift
var head: some HTML {
    meta(.charset(.utf8))
    setupAlpine(plugins: [.mask, .focus, .morph])
}
```

Si necesitas alojar los scripts de plugins tú mismo o usar un CDN que no sea jsDelivr, consulta [Incluir Alpine.js manualmente](#including-alpinejs-manually) arriba.

### Mask

[Mask](https://alpinejs.dev/plugins/mask) formatea la entrada de texto mientras el usuario escribe. Útil para números de teléfono, tarjetas de crédito, fechas, números de cuenta, etc.

**Uso:**

```swift
import Elementary
import ElementaryAlpine
import ElementaryAlpinePlugins

// Static pattern — wildcards: 9 (numeric), a (alpha), * (any)
input(.xMask.pattern("99/99/9999"), .x.model("date"))
input(.xMask.pattern("(999) 999-9999"), .x.model("phone"))

// Dynamic mask — expression receives $input
input(.xMask.dynamic("$money($input)"), .x.model("amount"))

// Dynamic mask — function reference
input(.xMask.dynamic("creditCardMask"), .x.model("card"))
```

**HTML generado:**

```html
<input x-mask="99/99/9999" x-model="date" />
<input x-mask="(999) 999-9999" x-model="phone" />
<input x-mask:dynamic="$money($input)" x-model="amount" />
<input x-mask:dynamic="creditCardMask" x-model="card" />
```

**Notas:**

- `x-mask:dynamic` acepta una expresión de JavaScript o un nombre de función. La expresión recibe `$input` (el valor actual de la entrada) como una magia.
- El ayudante integrado `$money($input, '.', ',', 4)` maneja el formato de moneda con separadores decimales/de miles personalizables y precisión opcional. Pásalo como el valor de la directiva: no se necesita un modificador de Swift.
- El plugin Mask **no tiene modificadores HTML** en Alpine.js, por lo que `MaskDynamicModifier` no existe. Toda la configuración ocurre en la cadena de valor.

### Intersect

[Intersect](https://alpinejs.dev/plugins/intersect) es un envoltorio de conveniencia para la [Intersection Observer API](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API). Ejecuta una expresión cuando un elemento entra o sale del viewport — útil para carga diferida, desplazamiento infinito, seguimiento de "vistas", etc.

**Uso:**

```swift
import Elementary
import ElementaryAlpine
import ElementaryAlpinePlugins

// Trigger when the element enters the viewport
div(.xIntersect.intersect("shown = true")) {
    "I'm in the viewport!"
}

// Trigger only the first time
div(.xIntersect.intersect("loaded = true", modifiers: [.once])) {
    "..."
}

// Trigger when at least half of the element is visible
div(.xIntersect.intersect("loaded = true", modifiers: [.half])) {
    "..."
}

// Trigger when the whole element is visible
div(.xIntersect.intersect("loaded = true", modifiers: [.full])) {
    "..."
}

// Custom threshold (0–100, percentage of element visible)
div(.xIntersect.intersect("loaded = true", modifiers: [.threshold(50)])) {
    "..."
}

// Expand the viewport boundary (CSS-margin syntax)
div(.xIntersect.intersect("loaded = true", modifiers: [.margin("200px")])) {
    "..."
}

// Trigger on enter (alias of x-intersect)
div(.xIntersect.enter("shown = true")) { "..." }

// Trigger on leave
div(.xIntersect.leave("shown = false")) { "..." }

// Chained modifiers
div(.xIntersect.intersect("loaded = true", modifiers: [.threshold(50), .full])) {
    "..."
}
```

**HTML generado:**

```html
<div x-intersect="shown = true">I'm in the viewport!</div>
<div x-intersect.once="loaded = true">...</div>
<div x-intersect.half="loaded = true">...</div>
<div x-intersect.full="loaded = true">...</div>
<div x-intersect.threshold.50="loaded = true">...</div>
<div x-intersect.margin.200px="loaded = true">...</div>
<div x-intersect:enter="shown = true">...</div>
<div x-intersect:leave="shown = false">...</div>
<div x-intersect.threshold.50.full="loaded = true">...</div>
```

**Referencia de modificadores:**

| Modificador        | Valor crudo           | Notas                                                 |
| ------------------ | --------------------- | ----------------------------------------------------- |
| `.once`            | `once`                | Disparar solo la primera vez                          |
| `.half`            | `half`                | Disparar al 50% de visibilidad                        |
| `.full`            | `full`                | Disparar al 99% de visibilidad                        |
| `.threshold(Int)`  | `threshold.N`         | Porcentaje personalizado (0–100)                      |
| `.margin(String)`  | `margin.<css-margin>` | Expandir/contrar el límite del viewport (sintaxis CSS)|

### Resize

[Resize](https://alpinejs.dev/plugins/resize) es un envoltorio de conveniencia para la [Resize Observer API](https://developer.mozilla.org/en-US/docs/Web/API/Resize_Observer_API). Expone las magias `$width` y `$height` cada vez que un elemento cambia de tamaño.

**Uso:**

```swift
import Elementary
import ElementaryAlpine
import ElementaryAlpinePlugins

// Track an element's size
div(.xResize.resize("width = $width; height = $height")) {
    p(.x.text("'Width: ' + width + 'px'")) { "" }
    p(.x.text("'Height: ' + height + 'px'")) { "" }
}

// Track the entire document
div(.xResize.resize("width = $width; height = $height", modifiers: [.document])) { ... }
```

**HTML generado:**

```html
<div x-resize="width = $width; height = $height">
  <p x-text="'Width: ' + width + 'px'"></p>
  <p x-text="'Height: ' + height + 'px'"></p>
</div>
<div x-resize.document="width = $width; height = $height">...</div>
```

**Referencia de modificadores:**

| Modificador | Valor crudo | Notas                                              |
| ----------- | ---------- | -------------------------------------------------- |
| `.document` | `document` | Observar el documento en lugar de un elemento específico |

### Persist

[Persist](https://alpinejs.dev/plugins/persist) guarda el estado de Alpine en `localStorage` (o `sessionStorage`) para que los valores persistan entre cargas de página. Útil para filtros de búsqueda, pestañas activas, preferencias de tema y otro estado que los usuarios esperan que sobreviva a una recarga.

A diferencia de los demás plugins, Persist es una **magia**, no una directiva: no existe un atributo HTML `x-persist`. La API es la función `$persist(...)` usada dentro de valores de `x-data`.

**Uso:**

```swift
import Elementary
import ElementaryAlpine
import ElementaryAlpinePlugins

// Persist a counter to localStorage
div(.x.data("{ count: $persist(0) }")) {
    button(.x.on("click", "count++")) { "Increment" }
    span(.x.text("count")) { "" }
}

// Use a custom localStorage key
div(.x.data("{ count: $persist(0).as('my-count') }")) {
    button(.x.on("click", "count++")) { "Increment" }
    span(.x.text("count")) { "" }
}

// Use sessionStorage instead (cleared when the tab closes)
div(.x.data("{ count: $persist(0).using(sessionStorage) }")) {
    button(.x.on("click", "count++")) { "Increment" }
    span(.x.text("count")) { "" }
}
```

**HTML generado:**

```html
<div x-data="{ count: $persist(0) }">
  <button x-on:click="count++">Increment</button>
  <span x-text="count"></span>
</div>
<div x-data="{ count: $persist(0).as('my-count') }">
  <button x-on:click="count++">Increment</button>
  <span x-text="count"></span>
</div>
<div x-data="{ count: $persist(0).using(sessionStorage) }">
  <button x-on:click="count++">Increment</button>
  <span x-text="count"></span>
</div>
```

**Notas:**

- Persist **no es una directiva**, por lo que no existe un ayudante `HTMLAttribute`. Escribe `$persist(...)` como una cadena JS en tu valor `x-data`.
- `.as(...)` y `.using(...)` son **llamadas a métodos de JavaScript** en el valor devuelto por `$persist(...)`, no modificadores HTML: no pueden ser seguros en tipo en Swift.
- `$persist` funciona con primitivas, arrays y objetos. Si cambias el tipo de un valor persistido, limpia su entrada en `localStorage` primero.

### Focus

[Focus](https://alpinejs.dev/plugins/focus) te permite gestionar el foco en una página, incluyendo atrapar el foco dentro de un elemento (para modales/diálogos), navegar el foco con las teclas de flecha y más.

**Uso:**

```swift
import Elementary
import ElementaryAlpine
import ElementaryAlpinePlugins

// Trap focus inside an element while `open` is true
div(.x.data("{ open: false }")) {
    button(.x.on("click", "open = true")) { "Open Dialog" }
    span(.x.show("open"), .xFocus.trap("open")) {
        p { "..." }
        input(.type(.text), .placeholder("Some input..."))
        input(.type(.text), .placeholder("Some other input..."))
        button(.x.on("click", "open = false")) { "Close Dialog" }
    }
}

// Hide all other elements from screen readers while trapped
div(.xFocus.trap("open", modifiers: [.inert])) { ... }

// Disable page scroll while trapped
div(.xFocus.trap("open", modifiers: [.noscroll])) { ... }

// Don't return focus to the previous element on untrap
div(.xFocus.trap("open", modifiers: [.noreturn])) { ... }

// Don't auto-focus the first focusable element on trap
div(.xFocus.trap("open", modifiers: [.noautofocus])) { ... }

// Chained modifiers
div(.xFocus.trap("open", modifiers: [.inert, .noscroll, .noreturn])) { ... }
```

**HTML generado:**

```html
<div x-trap="open">...</div>
<div x-trap.inert="open">...</div>
<div x-trap.noscroll="open">...</div>
<div x-trap.noreturn="open">...</div>
<div x-trap.noautofocus="open">...</div>
<div x-trap.inert.noscroll.noreturn="open">...</div>
```

**Referencia de modificadores:**

| Modificador    | Valor crudo   | Notas                                                       |
| -------------- | ------------- | ----------------------------------------------------------- |
| `.inert`       | `inert`       | Marcar otros elementos de la página como `aria-hidden="true"` mientras está atrapado |
| `.noscroll`    | `noscroll`    | Bloquear el desplazamiento de la página mientras está atrapado |
| `.noreturn`    | `noreturn`    | No devolver el foco al soltar                               |
| `.noautofocus` | `noautofocus` | No enfocar automáticamente el primer elemento enfocable     |

**Notas:**

- El plugin Focus también proporciona una magia `$focus` (`.next()`, `.previous()`, `.wrap()`, `.first()`, `.last()`, etc.) usada como cadenas JS dentro de manejadores `x-on`: no se necesita un ayudante de Swift.
- El plugin Focus anteriormente se llamaba "Trap": `x-trap` y sus modificadores no han cambiado.

### Collapse

[Collapse](https://alpinejs.dev/plugins/collapse) expande y colapsa elementos con animaciones suaves de altura. A diferencia de `x-transition`, `x-collapse` está dedicado al colapso basado en altura y funciona junto con `x-show`.

**Uso:**

```swift
import Elementary
import ElementaryAlpine
import ElementaryAlpinePlugins

// Basic collapse (works with x-show)
p(.x.show("expanded"), .xCollapse.collapse()) {
    "..."
}

// Custom duration (ms)
p(.x.show("expanded"), .xCollapse.collapse(modifiers: [.duration(1000)])) {
    "..."
}

// Minimum collapsed height (px) — useful for "cut-off" instead of full hide
p(.x.show("expanded"), .xCollapse.collapse(modifiers: [.min(50)])) {
    "..."
}

// Chained modifiers
p(.x.show("expanded"), .xCollapse.collapse(modifiers: [.duration(500), .min(50)])) {
    "..."
}
```

**HTML generado:**

```html
<p x-show="expanded" x-collapse>...</p>
<p x-show="expanded" x-collapse.duration.1000ms>...</p>
<p x-show="expanded" x-collapse.min.50px>...</p>
<p x-show="expanded" x-collapse.duration.500ms.min.50px>...</p>
```

**Referencia de modificadores:**

| Modificador      | Valor crudo   | Notas                                                                 |
| ---------------- | ------------- | --------------------------------------------------------------------- |
| `.duration(Int)` | `duration.Nms`| Duración de la animación en milisegundos                              |
| `.min(Int)`      | `min.Npx`     | Altura mínima colapsada en píxeles (corta en lugar de ocultar completamente) |

**Notas:**

- `x-collapse` solo puede existir en un elemento que ya tenga `x-show`. Anima la propiedad de altura cuando `x-show` alterna la visibilidad.
- `x-collapse` no tiene valor: solo acepta modificadores.

### Anchor

[Anchor](https://alpinejs.dev/plugins/anchor) ancla la posición de un elemento a otro elemento en la página. Construido sobre [Floating UI](https://floating-ui.com/), potencia menús desplegables, popovers, tooltips y diálogos.

**Uso:**

```swift
import Elementary
import ElementaryAlpine
import ElementaryAlpinePlugins

// Anchor below the button (default positioning)
div(.x.data("{ open: false }")) {
    button(.x.ref("button"), .x.on("click", "open = ! open")) { "Toggle" }
    div(.x.show("open"), .xAnchor.anchor("$refs.button")) {
        "Dropdown content"
    }
}

// Anchor below-right of the button
div(.x.show("open"), .xAnchor.anchor("$refs.button", modifiers: [.bottomStart])) {
    "Dropdown content"
}

// Use fixed positioning (escapes overflow:hidden containers)
div(.x.show("open"), .xAnchor.anchor("$refs.button", modifiers: [.fixed])) {
    "Dropdown content"
}

// Add an offset (px)
div(.x.show("open"), .xAnchor.anchor("$refs.button", modifiers: [.offset(10)])) {
    "Dropdown content"
}

// Prevent auto-flip when there's no room below
div(.x.show("open"), .xAnchor.anchor("$refs.button", modifiers: [.noflip])) {
    "Dropdown content"
}

// Apply positioning yourself via $anchor.x/$anchor.y in x-bind:style
div(
    .x.show("open"),
    .xAnchor.anchor("$refs.button", modifiers: [.noStyle]),
    .x.bindStyle("{ position: 'absolute', top: $anchor.y+'px', left: $anchor.x+'px' }")
) {
    "Dropdown content"
}

// Anchor to an element by id
div(.x.show("open"), .xAnchor.anchor("document.getElementById('trigger')")) {
    "Dropdown content"
}
```

**HTML generado:**

```html
<div x-anchor="$refs.button">Dropdown content</div>
<div x-anchor.bottom-start="$refs.button">Dropdown content</div>
<div x-anchor.fixed="$refs.button">Dropdown content</div>
<div x-anchor.offset.10="$refs.button">Dropdown content</div>
<div x-anchor.noflip="$refs.button">Dropdown content</div>
<div x-anchor.no-style="$refs.button" x-bind:style="...">Dropdown content</div>
<div x-anchor="document.getElementById('trigger')">Dropdown content</div>
```

**Modificadores de posición:**

| Modificador    | Valor crudo    | Notas                                        |
| -------------- | -------------- | -------------------------------------------- |
| `.top`         | `top`          | Encima de la referencia, centrado            |
| `.topStart`    | `top-start`    | Encima de la referencia, alineado al inicio  |
| `.topEnd`      | `top-end`      | Encima de la referencia, alineado al final   |
| `.bottom`      | `bottom`       | Debajo de la referencia, centrado            |
| `.bottomStart` | `bottom-start` | Debajo de la referencia, alineado al inicio  |
| `.bottomEnd`   | `bottom-end`   | Debajo de la referencia, alineado al final   |
| `.left`        | `left`         | A la izquierda de la referencia, centrado    |
| `.leftStart`   | `left-start`   | A la izquierda de la referencia, alineado al inicio |
| `.leftEnd`     | `left-end`     | A la izquierda de la referencia, alineado al final |
| `.right`       | `right`        | A la derecha de la referencia, centrado      |
| `.rightStart`  | `right-start`  | A la derecha de la referencia, alineado al inicio |
| `.rightEnd`    | `right-end`    | A la derecha de la referencia, alineado al final |

**Otros modificadores:**

| Modificador    | Valor crudo  | Notas                                                                                       |
| -------------- | ---------- | ------------------------------------------------------------------------------------------- |
| `.fixed`       | `fixed`    | Usar `position: fixed` (escapa de contenedores `overflow: hidden`)                          |
| `.offset(Int)` | `offset.N` | Espaciado en píxeles entre el elemento anclado y el de referencia                           |
| `.noflip`      | `noflip`   | No voltear automáticamente cuando no haya espacio en la dirección elegida                   |
| `.noStyle`     | `no-style` | No aplicar estilos de posición; accede a ellos vía `$anchor.x` / `$anchor.y` en `x-bind:style` |

**Notas:**

- `x-anchor` es un envoltorio delgado alrededor de [Floating UI](https://floating-ui.com/). Para configuración avanzada no expuesta por los modificadores, usa `x-anchor.noStyle` y aplica los estilos tú mismo vía `x-bind:style` y la magia `$anchor`.
- Una `transform`, `filter`, `perspective`, `backdrop-filter`, `will-change` o `contain` en cualquier ancestro crea un nuevo bloque contenedor para descendientes con `position: fixed`. `.fixed` se comportará como `position: absolute` relativo a ese ancestro.

### Sort

[Sort](https://alpinejs.dev/plugins/sort) te permite reordenar elementos arrastrándolos con el ratón. Construido sobre [SortableJS](https://github.com/SortableJS/Sortable), potencia tableros Kanban, listas de tareas, columnas de tabla ordenables y más.

**Uso:**

```swift
import Elementary
import ElementaryAlpine
import ElementaryAlpinePlugins

// Basic sortable list
ul(.xSort.sort) {
    li(.xSort.item("1")) { "foo" }
    li(.xSort.item("2")) { "bar" }
    li(.xSort.item("3")) { "baz" }
}

// Sort with a handler that runs on every reorder
ul(.xSort.sort("alert($item + ' - ' + $position)")) {
    li(.xSort.item("1")) { "foo" }
    li(.xSort.item("2")) { "bar" }
    li(.xSort.item("3")) { "baz" }
}

// Group sortable lists — items can be dragged between lists with the same group
ul(.xSort.sort("handle"), .xSort.group("todos")) {
    li(.xSort.item("1")) { "foo" }
    li(.xSort.item("2")) { "bar" }
    li(.xSort.item("3")) { "baz" }
}

ol(.xSort.sort("handle"), .xSort.group("todos")) {
    li(.xSort.item("4")) { "foo" }
    li(.xSort.item("5")) { "bar" }
    li(.xSort.item("6")) { "baz" }
}

// Drag handles — only the handle initiates drag
ul(.xSort.sort) {
    li(.xSort.item("1")) {
        span(.xSort.handle) { " - " }
        "foo"
    }
    li(.xSort.item("2")) {
        span(.xSort.handle) { " - " }
        "bar"
    }
}

// Ignore elements — buttons inside items stay clickable
ul(.xSort.sort) {
    li(.xSort.item("1")) {
        "foo"
        button(.xSort.ignore) { "Edit" }
    }
}

// Show a ghost of the dragged element instead of an empty space
ul(.xSort.sort(modifiers: [.ghost])) {
    li(.xSort.item("1")) { "foo" }
    li(.xSort.item("2")) { "bar" }
}

// Pass custom SortableJS options
ul(.xSort.sort, .xSort.config("{ animation: 0 }")) {
    li(.xSort.item("1")) { "foo" }
}
```

**HTML generado:**

```html
<ul x-sort>
  <li x-sort:item="1">foo</li>
  <li x-sort:item="2">bar</li>
  <li x-sort:item="3">baz</li>
</ul>

<ul x-sort="alert($item + ' - ' + $position)">
  <li x-sort:item="1">foo</li>
  <li x-sort:item="2">bar</li>
  <li x-sort:item="3">baz</li>
</ul>

<ul x-sort="handle" x-sort:group="todos">
  <li x-sort:item="1">foo</li>
  <li x-sort:item="2">bar</li>
  <li x-sort:item="3">baz</li>
</ul>

<ol x-sort="handle" x-sort:group="todos">
  <li x-sort:item="4">foo</li>
  <li x-sort:item="5">bar</li>
  <li x-sort:item="6">baz</li>
</ol>

<ul x-sort>
  <li x-sort:item="1"><span x-sort:handle> - </span>foo</li>
  <li x-sort:item="2"><span x-sort:handle> - </span>bar</li>
</ul>

<ul x-sort>
  <li x-sort:item="1">
    foo
    <button x-sort:ignore>Edit</button>
  </li>
</ul>

<ul x-sort.ghost>
  <li x-sort:item="1">foo</li>
  <li x-sort:item="2">bar</li>
</ul>

<ul x-sort x-sort:config="{ animation: 0 }">
  <li x-sort:item="1">foo</li>
</ul>
```

**Referencia de modificadores:**

| Modificador | Valor crudo | Notas                                                                  |
| ----------- | ----------- | ---------------------------------------------------------------------- |
| `.ghost`    | `ghost`     | Mostrar un fantasma del elemento arrastrado en su lugar (predeterminado: espacio vacío) |

**Notas:**

- El manejador de Sort se llama cada vez que cambia el orden de clasificación. Dentro del manejador, `$item` es la clave del elemento movido (desde `x-sort:item`) y `$position` es su nuevo índice (empezando en `0`). El manejador también puede ser una referencia a función que recibe `(item, position)` como argumentos.
- Las claves `x-sort:item` suelen ser numéricas (`"1"`, `"2"`, …) pero pueden ser cualquier cadena usada para identificar el elemento.
- `x-sort:group` permite arrastrar elementos entre listas. Al usar manejadores `.as` con arrastre entre grupos, solo se llama al manejador de la lista de destino.
- `x-sort:config` acepta cualquier [opción de SortableJS](https://github.com/SortableJS/Sortable?tab=readme-ov-file#options). Ten en cuenta que sobrescribir `handle`, `group`, `filter`, `onSort`, `onStart` o `onEnd` puede romper la funcionalidad.
- Mientras se arrastra, Alpine añade una clase `.sorting` a `<body>` — útil para CSS condicional como `body.sorting #warning { display: block; }`.

### Morph

[Morph](https://alpinejs.dev/plugins/morph) te permite actualizar una sección del DOM con nuevo HTML mientras preservas el estado de Alpine, el foco del navegador, la posición de desplazamiento y los valores de los formularios. Útil para actualizaciones renderizadas en el servidor (Livewire, LiveView) o cada vez que quieras intercambiar contenido sin perder estado.

A diferencia de los demás plugins, Morph proporciona **dos funciones fábrica** que generan un elemento `<script>` con el JS correcto para llamar `Alpine.morph` o `Alpine.morphBetween`.

**`setupMorph`** — reemplaza un solo elemento con nuevo HTML ante un evento disparador.

```swift
setupMorph(
    trigger: "#refresh-btn",
    target: "#user-card",
    event: "click"
) {
    div(.x.data("{ name: 'Updated' }")) {
        h2 { "Updated content" }
    }
}
```

**HTML generado:**

```html
<script>
  document.querySelector('#refresh-btn').addEventListener('click', async () => {
    Alpine.morph(
      document.querySelector('#user-card'),
      `<div x-data="{ name: 'Updated' }"><h2>Updated content</h2></div>`,
    )
  })
</script>
```

**`setupMorphBetween`** — transforma el contenido entre dos nodos marcadores (típicamente comentarios HTML).

```swift
// In your body, place markers around the content you want to update:
// <!--list-start-->
// <li>item</li>
// <!--list-end-->

setupMorphBetween(
    trigger: "#refresh",
    startMarker: "<!--list-start-->",
    endMarker: "<!--list-end-->",
    event: "click"
) {
    li { "new item" }
}
```

El JS generado incluye un ayudante `findMorphMarker` que maneja tanto selectores CSS (`#start`, `.end`) como marcadores de comentarios HTML (`<!--start-->`, `<!--end-->`), por lo que puedes usar el estilo que coincida con tu marcado.

**HTML generado:**

```html
<script>
  const findMorphMarker = (marker) => {
    let el = document.querySelector(marker)
    if (el) return el
    if (marker.startsWith('<!--') && marker.endsWith('-->')) {
      const text = marker.slice(4, -3).trim()
      const walker = document.createTreeWalker(
        document.body,
        NodeFilter.SHOW_COMMENT,
      )
      let node
      while ((node = walker.nextNode())) {
        if (node.nodeValue && node.nodeValue.trim() === text) return node
      }
    }
    return null
  }
  document.querySelector('#refresh').addEventListener('click', async () => {
    Alpine.morphBetween(
      findMorphMarker('<!--list-start-->'),
      findMorphMarker('<!--list-end-->'),
      `<li>new item</li>`,
    )
  })
</script>
```

**Opciones (ganchos de ciclo de vida + clave + lookahead):**

Ambas funciones aceptan un constructor `options:` para configurar la transformación. El cierre del constructor devuelve un valor `MorphOptions`, construido encadenando métodos de ciclo de vida. Cada método toma un cierre de cola que devuelve una expresión de JavaScript:

```swift
setupMorph(
    trigger: "#list-refresh",
    target: "#list",
    event: "click"
) {
    .updating { "console.log('updating', el)" }
    .key { "(el) => el.id" }
    .lookahead()
} returning: {
    ul { li { "item" } }
}
```

**Opciones disponibles** (iguales para `setupMorph` y `setupMorphBetween`):

| Método          | Opción de Alpine.js                    | Descripción                        |
| --------------- | -------------------------------------- | ---------------------------------- |
| `.updating { }` | `updating(el, toEl, childrenOnly, skip)` | Llamado antes de parchear          |
| `.updated { }`  | `updated(el, toEl)`                    | Llamado después de parchear        |
| `.removing { }` | `removing(el, skip)`                   | Llamado antes de eliminar          |
| `.removed { }`  | `removed(el)`                          | Llamado después de eliminar        |
| `.adding { }`   | `adding(el, skip)`                     | Llamado antes de añadir            |
| `.added { }`    | `added(el)`                            | Llamado después de añadir          |
| `.key { }`      | `key(el)`                              | Función que devuelve la clave del elemento |
| `.lookahead()`  | `lookahead: true`                      | Habilitar algoritmo de lookahead   |

**HTML dinámico (fetch):**

Usa el parámetro `jsCommand:` para calcular dinámicamente el HTML (por ejemplo, desde un fetch). El cierre debe asignar la cadena HTML a una variable llamada `html`:

```swift
setupMorph(
    trigger: "#refresh-btn",
    target: "#list",
    event: "click"
) {
    "const html = await fetch('/api/list').then(r => r.text())"
} returning: {
    div { "default" }
}
```

**Los tres parámetros (options + jsCommand + returning):**

Combina los tres cuando necesites ganchos de ciclo de vida, HTML dinámico y una plantilla de respaldo:

```swift
setupMorph(
    trigger: "#refresh-btn",
    target: "#list",
    event: "click"
) {
    .updating { "console.log('updating', el)" }
    .key { "(el) => el.id" }
    .lookahead()
} jsCommand: {
    "const html = await fetch('/api/list').then(r => r.text())"
} returning: {
    div { "default" }
}
```

**Sin disparador (imperativo):**

Ambas funciones tienen sobrecargas sin los parámetros `trigger`/`event`: emiten un script que ejecuta la transformación una vez al cargar la página:

```swift
setupMorph(target: "#content") {
    div { "initial content" }
}

setupMorphBetween(
    startMarker: "<!--start-->",
    endMarker: "<!--end-->"
) {
    li { "initial" }
}
```

**Notas:**

- Para escenarios de morph más complejos (por ejemplo, resolución personalizada de elementos, marcadores de comentarios exóticos), usa un bloque `<script>` raw en su lugar.

## Documentación

El paquete incluye dos bibliotecas:

- **`ElementaryAlpine`** — núcleo:
  - **Ayudantes de atributos** mediante la sintaxis `.x` en todos los `HTMLElements` para las 18 directivas centrales de [AlpineJS](https://alpinejs.dev/directives):
    - `x-data`, `x-init` (`.setup`), `x-show`
    - `x-bind` / `x-bind:class` / `x-bind:style`
    - `x-on` con modificadores (base, teclado, ratón, avanzados)
    - `x-text`, `x-html`, `x-model` con modificadores, `x-modelable`
    - `x-for` (`.loop`), `x-transition` (todas las fases), `x-effect`, `x-ignore`, `x-ref`, `x-cloak`
    - `x-teleport`, `x-if` (`.when`), `x-id`
  - **Ayudantes globales** — `registerGlobal(_:on:action:)` para `Alpine.data()`, `Alpine.store()`, `Alpine.bind()` (ver [Globales](#globals))
  - **Ayudante de CDN** — `setupAlpine(version:plugins:)` emite las etiquetas `<script>` para Alpine.js + plugins (ver [Configuración](#setup))
- **`ElementaryAlpinePlugins`** — envoltorios de plugins de Alpine.js (ver [Plugins](#plugins)). Actualmente incluye **Mask** (`.xMask.pattern` / `.xMask.dynamic`), **Intersect** (`.xIntersect.intersect` / `.enter` / `.leave`), **Resize** (`.xResize.resize`), **Persist** (la magia `$persist` — sin superficie de directiva), **Focus** (`.xFocus.trap`), **Collapse** (`.xCollapse.collapse`), **Anchor** (`.xAnchor.anchor`), **Sort** (`.xSort.sort` / `.item` / `.group` / `.handle` / `.ignore` / `.config`) y **Morph** (`setupMorph` + `setupMorphBetween`).

Para directrices de contribución y detalles de arquitectura, ver [`AGENTS.md`](./AGENTS.md).

## Direcciones futuras

- Todos los 9 plugins oficiales de Alpine.js están ahora documentados (8 con paquetes fuente; Persist es solo CDN — `$persist(...)` se usa en línea en cadenas JS). Trabajo futuro: aplicaciones de ejemplo e integraciones de ecosistema.

PRs bienvenidos.

## Licencia

[Apache 2.0](./LICENSE)
