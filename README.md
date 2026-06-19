# ElementaryAlpine: Reactive web apps with Swift

**Ergonomic [AlpineJS](https://alpinejs.dev/) extensions for [Elementary](https://github.com/elementary-swift/elementary)**

```swift
import Elementary
import ElementaryAlpine

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

## Including Alpine.js

This package generates AlpineJS HTML attributes — it does not bundle the Alpine.js runtime. You must include it yourself in your page `<head>`.

This package is built against **Alpine.js v3** (pinned to `3.15.12`).

### From a CDN

```swift
var head: some HTML {
    meta(.charset(.utf8))
    script(.src("https://cdn.jsdelivr.net/npm/alpinejs@3.15.12/dist/cdn.min.js"), .defer) {}
}
```

### From a local file

Download `alpine.min.js` from the [Alpine.js releases](https://github.com/alpinejs/alpine/releases) and place it in your project's `Public/` folder, then reference it:

```swift
var head: some HTML {
    meta(.charset(.utf8))
    script(.src("/alpine.min.js"), .defer) {}
}
```

For Hummingbird/Vapor examples, add the file as a resource in your `Package.swift`:

```swift
.executableTarget(
    name: "App",
    // ...
    resources: [
        .copy("Public")
    ]
)
```

## Modifiers

Directives that support modifiers take a `modifiers:` array parameter with a typed enum value:

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

## Globals

Alpine.js global APIs (`Alpine.data`, `Alpine.store`, `Alpine.bind`) are available as `registerGlobal` for registering reusable components, stores, and bound directives:

```swift
import ElementaryAlpine

// In your head:
registerGlobal(.data, on: "dropdown", action: "() => ({ open: false, toggle() { this.open = !this.open } })")
registerGlobal(.store, on: "notifications", action: "{ items: [] }")
registerGlobal(.bind, on: "myButton", action: "() => ({ type: 'button' })")
```

**Generated HTML:**

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

| Function                               | Alpine.js call               | Use case                                   |
| -------------------------------------- | ---------------------------- | ------------------------------------------ |
| `registerGlobal(.data, on:, action:)`  | `Alpine.data(name, factory)` | Reusable component data (factory function) |
| `registerGlobal(.store, on:, action:)` | `Alpine.store(name, value)`  | Global reactive store (direct object)      |
| `registerGlobal(.bind, on:, action:)`  | `Alpine.bind(name, factory)` | Reusable x-bind object (factory function)  |

## Magics

Alpine.js [magics](https://alpinejs.dev/magics) are JS-side helpers that exist inside Alpine expressions. They don't generate HTML attributes or scripts — they appear as **string literals** in directive values:

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

**Available magics:** `$el`, `$refs`, `$store`, `$watch`, `$dispatch`, `$nextTick`, `$root`, `$data`, `$id`, `$persist` (requires the [Persist plugin](#persist))

> No code or attributes are needed for magics — just use the magic name as a string in any Alpine expression.

## Plugins

[Alpine.js plugins](https://alpinejs.dev/plugins) extend the runtime with additional directives. This package ships a separate library, **`ElementaryAlpinePlugins`**, that exposes them as Swift attribute helpers.

> **Alpine.js plugin scripts depend on Alpine.js core.** At the Swift level, `ElementaryAlpinePlugins` has no compile-time dependency on `ElementaryAlpine` — both libraries only depend on `Elementary`. The dependency exists at the **JavaScript runtime** level: plugin CDN scripts hook into the core Alpine instance, so the plugin script tag must be present in your page (and load before Alpine core, per the Alpine.js docs).

**Install plugin scripts** in your `<head>` (BEFORE Alpine core, per Alpine.js docs). Add only the scripts for the plugins you use:

```swift
var head: some HTML {
    meta(.charset(.utf8))
    // Mask
    script(.src("https://cdn.jsdelivr.net/npm/@alpinejs/mask@3.15.12/dist/cdn.min.js"), .defer) {}
    // Intersect
    script(.src("https://cdn.jsdelivr.net/npm/@alpinejs/intersect@3.15.12/dist/cdn.min.js"), .defer) {}
    // Resize
    script(.src("https://cdn.jsdelivr.net/npm/@alpinejs/resize@3.15.12/dist/cdn.min.js"), .defer) {}
    // Persist
    script(.src("https://cdn.jsdelivr.net/npm/@alpinejs/persist@3.15.12/dist/cdn.min.js"), .defer) {}
    // Focus
    script(.src("https://cdn.jsdelivr.net/npm/@alpinejs/focus@3.15.12/dist/cdn.min.js"), .defer) {}
    // Collapse
    script(.src("https://cdn.jsdelivr.net/npm/@alpinejs/collapse@3.15.12/dist/cdn.min.js"), .defer) {}
    // Anchor
    script(.src("https://cdn.jsdelivr.net/npm/@alpinejs/anchor@3.15.12/dist/cdn.min.js"), .defer) {}
    // Sort
    script(.src("https://cdn.jsdelivr.net/npm/@alpinejs/sort@3.15.12/dist/cdn.min.js"), .defer) {}
    // Morph
    script(.src("https://cdn.jsdelivr.net/npm/@alpinejs/morph@3.15.12/dist/cdn.min.js"), .defer) {}
    // Alpine core (must come after all plugin scripts)
    script(.src("https://cdn.jsdelivr.net/npm/alpinejs@3.15.12/dist/cdn.min.js"), .defer) {}
}
```

### Mask

[Mask](https://alpinejs.dev/plugins/mask) formats text input as the user types. Useful for phone numbers, credit cards, dates, account numbers, etc.

**Usage:**

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

**Generated HTML:**

```html
<input x-mask="99/99/9999" x-model="date" />
<input x-mask="(999) 999-9999" x-model="phone" />
<input x-mask:dynamic="$money($input)" x-model="amount" />
<input x-mask:dynamic="creditCardMask" x-model="card" />
```

**Notes:**

- `x-mask:dynamic` accepts a JavaScript expression or a function name. The expression receives `$input` (the current input value) as a magic.
- The built-in `$money($input, '.', ',', 4)` helper handles currency formatting with optional custom decimal/thousands separators and precision. Pass it as the directive value — no Swift modifier is needed.
- The Mask plugin has **no HTML modifiers** in Alpine.js, so `MaskDynamicModifier` does not exist. All configuration happens in the value string.

### Intersect

[Intersect](https://alpinejs.dev/plugins/intersect) is a convenience wrapper for the [Intersection Observer API](https://developer.mozilla.org/en-US/docs/Web/API/Intersection_Observer_API). It runs an expression when an element enters or leaves the viewport — useful for lazy loading, infinite scroll, "view" tracking, etc.

**Usage:**

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

**Generated HTML:**

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

**Modifier reference:**

| Modifier          | Raw value             | Notes                                                 |
| ----------------- | --------------------- | ----------------------------------------------------- |
| `.once`           | `once`                | Fire only the first time                              |
| `.half`           | `half`                | Fire at 50% visibility                                |
| `.full`           | `full`                | Fire at 99% visibility                                |
| `.threshold(Int)` | `threshold.N`         | Custom percentage (0–100)                             |
| `.margin(String)` | `margin.<css-margin>` | Expand/contract viewport boundary (CSS-margin syntax) |

### Resize

[Resize](https://alpinejs.dev/plugins/resize) is a convenience wrapper for the [Resize Observer API](https://developer.mozilla.org/en-US/docs/Web/API/Resize_Observer_API). It exposes `$width` and `$height` magics whenever an element changes size.

**Usage:**

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

**Generated HTML:**

```html
<div x-resize="width = $width; height = $height">
  <p x-text="'Width: ' + width + 'px'"></p>
  <p x-text="'Height: ' + height + 'px'"></p>
</div>
<div x-resize.document="width = $width; height = $height">...</div>
```

**Modifier reference:**

| Modifier    | Raw value  | Notes                                              |
| ----------- | ---------- | -------------------------------------------------- |
| `.document` | `document` | Observe the document instead of a specific element |

### Persist

[Persist](https://alpinejs.dev/plugins/persist) saves Alpine state to `localStorage` (or `sessionStorage`) so values persist across page loads. Useful for search filters, active tabs, theme preferences, and other state that users expect to survive a refresh.

Unlike the other plugins, Persist is a **magic**, not a directive — there is no `x-persist` HTML attribute. The API is the `$persist(...)` function used inside `x-data` values.

**Usage:**

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

**Generated HTML:**

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

**Notes:**

- Persist is **not a directive**, so there is no `HTMLAttribute` helper. Write `$persist(...)` as a JS string in your `x-data` value.
- `.as(...)` and `.using(...)` are **JavaScript method calls** on the `$persist(...)` return value, not HTML modifiers — they cannot be type-safe in Swift.
- `$persist` works with primitives, arrays, and objects. If you change the type of a persisted value, clear its localStorage entry first.

### Focus

[Focus](https://alpinejs.dev/plugins/focus) lets you manage focus on a page, including trapping focus within an element (for modals/dialogs), navigating focus with arrow keys, and more.

**Usage:**

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

**Generated HTML:**

```html
<div x-trap="open">...</div>
<div x-trap.inert="open">...</div>
<div x-trap.noscroll="open">...</div>
<div x-trap.noreturn="open">...</div>
<div x-trap.noautofocus="open">...</div>
<div x-trap.inert.noscroll.noreturn="open">...</div>
```

**Modifier reference:**

| Modifier       | Raw value     | Notes                                                       |
| -------------- | ------------- | ----------------------------------------------------------- |
| `.inert`       | `inert`       | Mark other page elements `aria-hidden="true"` while trapped |
| `.noscroll`    | `noscroll`    | Block page scrolling while trapped                          |
| `.noreturn`    | `noreturn`    | Don't return focus on untrap                                |
| `.noautofocus` | `noautofocus` | Don't auto-focus the first focusable element                |

**Notes:**

- The Focus plugin also provides a `$focus` magic (`.next()`, `.previous()`, `.wrap()`, `.first()`, `.last()`, etc.) used as JS strings inside `x-on` handlers — no Swift helper needed.
- The Focus plugin was previously called "Trap" — `x-trap` and its modifiers are unchanged.

### Collapse

[Collapse](https://alpinejs.dev/plugins/collapse) expands and collapses elements with smooth height animations. Unlike `x-transition`, `x-collapse` is dedicated to height-based collapse and works alongside `x-show`.

**Usage:**

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

**Generated HTML:**

```html
<p x-show="expanded" x-collapse>...</p>
<p x-show="expanded" x-collapse.duration.1000ms>...</p>
<p x-show="expanded" x-collapse.min.50px>...</p>
<p x-show="expanded" x-collapse.duration.500ms.min.50px>...</p>
```

**Modifier reference:**

| Modifier         | Raw value      | Notes                                                                 |
| ---------------- | -------------- | --------------------------------------------------------------------- |
| `.duration(Int)` | `duration.Nms` | Animation duration in milliseconds                                    |
| `.min(Int)`      | `min.Npx`      | Minimum collapsed height in pixels (cuts off rather than fully hides) |

**Notes:**

- `x-collapse` can only exist on an element that already has `x-show`. It animates the height property when `x-show` toggles visibility.
- `x-collapse` has no value — it only accepts modifiers.

### Anchor

[Anchor](https://alpinejs.dev/plugins/anchor) anchors an element's positioning to another element on the page. Built on top of [Floating UI](https://floating-ui.com/), it powers dropdowns, popovers, tooltips, and dialogs.

**Usage:**

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

**Generated HTML:**

```html
<div x-anchor="$refs.button">Dropdown content</div>
<div x-anchor.bottom-start="$refs.button">Dropdown content</div>
<div x-anchor.fixed="$refs.button">Dropdown content</div>
<div x-anchor.offset.10="$refs.button">Dropdown content</div>
<div x-anchor.noflip="$refs.button">Dropdown content</div>
<div x-anchor.no-style="$refs.button" x-bind:style="...">Dropdown content</div>
<div x-anchor="document.getElementById('trigger')">Dropdown content</div>
```

**Positioning modifiers:**

| Modifier       | Raw value      | Notes                                        |
| -------------- | -------------- | -------------------------------------------- |
| `.top`         | `top`          | Above the reference, centered                |
| `.topStart`    | `top-start`    | Above the reference, aligned to the start    |
| `.topEnd`      | `top-end`      | Above the reference, aligned to the end      |
| `.bottom`      | `bottom`       | Below the reference, centered                |
| `.bottomStart` | `bottom-start` | Below the reference, aligned to the start    |
| `.bottomEnd`   | `bottom-end`   | Below the reference, aligned to the end      |
| `.left`        | `left`         | Left of the reference, centered              |
| `.leftStart`   | `left-start`   | Left of the reference, aligned to the start  |
| `.leftEnd`     | `left-end`     | Left of the reference, aligned to the end    |
| `.right`       | `right`        | Right of the reference, centered             |
| `.rightStart`  | `right-start`  | Right of the reference, aligned to the start |
| `.rightEnd`    | `right-end`    | Right of the reference, aligned to the end   |

**Other modifiers:**

| Modifier       | Raw value  | Notes                                                                                       |
| -------------- | ---------- | ------------------------------------------------------------------------------------------- |
| `.fixed`       | `fixed`    | Use `position: fixed` (escapes `overflow: hidden` containers)                               |
| `.offset(Int)` | `offset.N` | Spacing in pixels between anchored and reference element                                    |
| `.noflip`      | `noflip`   | Don't auto-flip when there's no room in the chosen direction                                |
| `.noStyle`     | `no-style` | Don't apply positioning styles; access them via `$anchor.x` / `$anchor.y` in `x-bind:style` |

**Notes:**

- `x-anchor` is a thin wrapper around [Floating UI](https://floating-ui.com/). For advanced configuration not exposed by the modifiers, use `x-anchor.noStyle` and apply styles yourself via `x-bind:style` and the `$anchor` magic.
- A `transform`, `filter`, `perspective`, `backdrop-filter`, `will-change`, or `contain` on any ancestor creates a new containing block for `position: fixed` descendants. `.fixed` will behave like `position: absolute` relative to that ancestor.

### Sort

[Sort](https://alpinejs.dev/plugins/sort) lets you re-order elements by dragging them with your mouse. Built on top of [SortableJS](https://github.com/SortableJS/Sortable), it powers Kanban boards, to-do lists, sortable table columns, and more.

**Usage:**

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

**Generated HTML:**

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

**Modifier reference:**

| Modifier | Raw value | Notes                                                                  |
| -------- | --------- | ---------------------------------------------------------------------- |
| `.ghost` | `ghost`   | Show a ghost of the dragged element in its place (default: empty hole) |

**Notes:**

- The Sort handler is called every time sort order changes. Inside the handler, `$item` is the moved item's key (from `x-sort:item`) and `$position` is its new index (starting at `0`). The handler can also be a function reference that receives `(item, position)` as arguments.
- `x-sort:item` keys are typically numeric (`"1"`, `"2"`, …) but can be any string used to identify the item.
- `x-sort:group` lets you drag items between lists. When using `.as` handlers with cross-group drag, only the destination list's handler is called.
- `x-sort:config` accepts any [SortableJS options](https://github.com/SortableJS/Sortable?tab=readme-ov-file#options). Be aware that overwriting `handle`, `group`, `filter`, `onSort`, `onStart`, or `onEnd` may break functionality.
- While dragging, Alpine adds a `.sorting` class to `<body>` — useful for conditional CSS like `body.sorting #warning { display: block; }`.

### Morph

[Morph](https://alpinejs.dev/plugins/morph) lets you update a section of the DOM with new HTML while preserving Alpine state, browser focus, scroll position, and form input values. Useful for server-rendered updates (Livewire, LiveView) or any time you want to swap content without losing state.

Unlike the other plugins, Morph provides **two factory functions** that generate a `<script>` element with the right JS to call `Alpine.morph` or `Alpine.morphBetween`.

**`setupMorph`** — replaces a single element with new HTML on a trigger event.

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

**Generated HTML:**

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

**`setupMorphBetween`** — morphs the content between two marker nodes (typically HTML comments).

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

The generated JS includes a `findMorphMarker` helper that handles both CSS selectors (`#start`, `.end`) and HTML comment markers (`<!--start-->`, `<!--end-->`), so you can use whichever style matches your markup.

**Generated HTML:**

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

**Options (lifecycle hooks + key + lookahead):**

Both functions accept a `MorphOptions` builder for configuring the morph:

```swift
setupMorph(
    trigger: "#btn",
    target: "#list",
    event: "click"
) {
    .updating("console.log('updating', el)")
    .key("(el) => el.id")
    .lookahead()
} returning: {
    ul { li { "item" } }
}
```

**Available options** (same for both `setupMorph` and `setupMorphBetween`):

| Method            | Alpine.js option                         | Description                          |
| ----------------- | ---------------------------------------- | ------------------------------------ |
| `.updating("js")` | `updating(el, toEl, childrenOnly, skip)` | Called before patching               |
| `.updated("js")`  | `updated(el, toEl)`                      | Called after patching                |
| `.removing("js")` | `removing(el, skip)`                     | Called before removing               |
| `.removed("js")`  | `removed(el)`                            | Called after removing                |
| `.adding("js")`   | `adding(el, skip)`                       | Called before adding                 |
| `.added("js")`    | `added(el)`                              | Called after adding                  |
| `.key("js")`      | `key(el)`                                | Function returning the element's key |
| `.lookahead()`    | `lookahead: true`                        | Enable lookahead algorithm           |

**Dynamic HTML (fetch):**

Use the `jsCommand` parameter to dynamically compute the HTML (e.g., from a fetch). The closure must assign the HTML string to a variable named `html`:

```swift
setupMorph(
    trigger: "#btn",
    target: "#list",
    event: "click"
) {
    "const html = await fetch('/api/list').then(r => r.text())"
} returning: {
    div { "default" }
}
```

**All three trailing closures (options + jsCommand + returning):**

```swift
setupMorph(
    trigger: "#btn",
    target: "#list",
    event: "click"
) {
    .updating("console.log('updating', el)")
    .key("(el) => el.id")
    .lookahead()
} jsCommand: {
    "const html = await fetch('/api/list').then(r => r.text())"
} returning: {
    div { "default" }
}
```

**Without trigger (imperative):**

Both functions have overloads without `trigger`/`event` parameters — they emit a script that runs the morph once on page load:

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

**Notes:**

- For more complex morph scenarios (e.g., custom element resolution, exotic comment markers), use a raw `<script>` block instead.

## Play with it

Example apps will be added in a future release.

## Documentation

The package ships two libraries:

- **`ElementaryAlpine`** — core:
  - **Attribute helpers** via the `.x` syntax on all `HTMLElements` for all 17 core [AlpineJS directives](https://alpinejs.dev/directives):
    - `x-data`, `x-init` (`.setup`), `x-show`
    - `x-bind` / `x-bind:class` / `x-bind:style`
    - `x-on` with modifiers (base, keyboard, mouse, advanced)
    - `x-text`, `x-html`, `x-model` with modifiers, `x-modelable`
    - `x-for` (`.loop`), `x-transition` (all phases), `x-effect`, `x-ignore`, `x-ref`, `x-cloak`
    - `x-teleport`, `x-if` (`.when`), `x-id`
  - **Global helpers** — `registerGlobal(_:on:action:)` for `Alpine.data()`, `Alpine.store()`, `Alpine.bind()` (see [Globals](#globals))
- **`ElementaryAlpinePlugins`** — Alpine.js plugin wrappers (see [Plugins](#plugins)). Currently ships **Mask** (`.xMask.pattern` / `.xMask.dynamic`), **Intersect** (`.xIntersect.intersect` / `.enter` / `.leave`), **Resize** (`.xResize.resize`), **Persist** (the `$persist` magic — no directive surface), **Focus** (`.xFocus.trap`), **Collapse** (`.xCollapse.collapse`), **Anchor** (`.xAnchor.anchor`), **Sort** (`.xSort.sort` / `.item` / `.group` / `.handle` / `.ignore` / `.config`), and **Morph** (`setupMorph` + `setupMorphBetween`).

## Future directions

- All 9 official Alpine.js plugins are now documented. Future work: example apps and ecosystem integrations.

PRs welcome.

## License

[Apache 2.0](./LICENSE)
