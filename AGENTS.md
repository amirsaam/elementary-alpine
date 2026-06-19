# AGENTS.md

AI contribution guidelines for `elementary-alpine`.

## Project Overview

`elementary-alpine` provides type-safe HTML attributes for [AlpineJS](https://alpinejs.dev/) directives, following the patterns of [elementary](https://github.com/elementary-swift/elementary) and [elementary-htmx](https://github.com/elementary-swift/elementary-htmx).

The package currently ships:

- **`ElementaryAlpine`** — core AlpineJS directives + globals (`registerGlobal` for `Alpine.data()`, `Alpine.store()`, `Alpine.bind()`)
- **`ElementaryAlpinePlugins`** — Alpine.js plugin wrappers (currently: Mask, Intersect, Resize, Persist, Focus, Collapse, Anchor, Sort)

## Versioning

**Scheme:** `Epoch.Major.(Minor×100 + Patch)` — [Epoch SemVer](https://antfu.me/posts/epoch-semver) with a `100×` multiplier.

- **Epoch** — milestones or groundbreaking changes (stays `0` for now)
- **Major** — breaking changes; each major is stable
- **Minor×100 + Patch** — encodes semver-style minor (×100) + patch (0–99); patch resets to `0` when Minor increments

**Examples:** `0.1.000` (core), `0.1.005` (patch), `0.1.100` (minor), `0.2.000` (breaking)

## Code Style

- Follow conventions in the project's `.swift-format` configuration
- **No comments** in code unless documenting non-obvious behavior
- Use `public` for all public API surface
- Prefer `RawRepresentable` + `ExpressibleByStringLiteral` for attribute value types
- Use enums (not structs) for modifier values — e.g. `OnModifier`, `ModelModifier`
- Use array parameters for modifiers: `modifiers: [.prevent, .stop]`
- Match the coding style of `elementary` and `elementary-htmx`

## Architecture

The target follows a four-file pattern:

```
Sources/ElementaryAlpine/
├── HTMLAttribute+Alpine.swift       # Attribute factory functions (e.g., `.x.data("...")`)
├── HTMLAttributeValue+Alpine.swift  # Value types (e.g., `BindClass`, `BindStyle`)
├── AlpineModifier.swift             # Modifier enums (e.g., `OnModifier`, `ModelModifier`)
└── AlpineGlobals.swift              # `AlpineGlobals` enum + `registerGlobal` function
```

```
Sources/ElementaryAlpinePlugins/
├── HTMLAttribute+AlpineMask.swift         # `.xMask.pattern(_:)`, `.xMask.dynamic(_:)`
├── HTMLAttribute+AlpineIntersect.swift    # `.xIntersect.intersect(_:modifiers:)`, `.enter(...)`, `.leave(...)`
├── AlpineIntersectModifier.swift          # `IntersectModifier` enum
├── HTMLAttribute+AlpineResize.swift       # `.xResize.resize(_:modifiers:)`
├── AlpineResizeModifier.swift             # `ResizeModifier` enum
├── HTMLAttribute+AlpineFocus.swift        # `.xFocus.trap(_:modifiers:)`
├── AlpineFocusModifier.swift              # `FocusModifier` enum
├── HTMLAttribute+AlpineCollapse.swift     # `.xCollapse.collapse(modifiers:)`
├── AlpineCollapseModifier.swift           # `CollapseModifier` enum
├── HTMLAttribute+AlpineAnchor.swift       # `.xAnchor.anchor(_:modifiers:)`
├── AlpineAnchorModifier.swift             # `AnchorModifier` enum
├── HTMLAttribute+AlpineSort.swift         # `.xSort.sort(_:modifiers:)`, `.item(...)`, `.group(...)`, `.handle`, `.ignore`, `.config(...)`
├── AlpineSortModifier.swift               # `SortModifier` enum
├── HTMLAttribute+AlpineMorph.swift         # `setupMorph(...)` (8 overloads) + `MorphOptions` struct (lifecycle hooks, key, lookahead)
├── HTMLAttribute+AlpineMorphBetween.swift # `setupMorphBetween(...)` (8 overloads, with `findMorphMarker` helper for HTML comment markers)
└── (per-plugin file per Alpine.js plugin)
```

> **Plugins with no directive surface** (e.g. Persist) ship as docs only — no Swift source, no `HTMLAttribute` helper. Persist's API is the `$persist(...)` magic, used as a JS string in `x-data` values. Morph has no directives but ships `setupMorph` / `setupMorphBetween` as full Swift APIs that generate the JS to call `Alpine.morph` / `Alpine.morphBetween`.

**Core (17 directives) under `HTMLAttribute.x`:**
- `x-data`, `x-init` (`.setup`), `x-show`, `x-bind`/`x-bind:class`/`x-bind:style`
- `x-on` with modifiers (base, keyboard, mouse, advanced)
- `x-text`, `x-html`, `x-model` with modifiers, `x-modelable`
- `x-for` (`.loop`), `x-transition` (all phases), `x-effect`, `x-ignore`, `x-ref`, `x-cloak`
- `x-teleport`, `x-if` (`.when`), `x-id`

**Globals:** `registerGlobal(_:on:action:)` with `AlpineGlobals` enum (`.data`/`.store`/`.bind`)

**Plugins** ship under `HTMLAttribute.<pluginName>` namespaces (e.g., `HTMLAttribute.xMask`). The `ElementaryAlpinePlugins` SwiftPM target has **no compile-time dependency on `ElementaryAlpine`** — both libraries depend only on `Elementary`. The plugin dependency on core exists at the **Alpine.js runtime** level (plugin CDN scripts hook into Alpine core).

## Modifier API

Modifiers use a uniform pattern: an enum with `rawValue: String` and a `modifiers:` array parameter:

```swift
public enum OnModifier {
    case prevent
    case stop
    // ...
    case selfTarget          // rawValue: "self"
    case debounce(Int)       // rawValue: "debounce.{ms}ms"
    // ...
}
```

Directives accepting modifiers:

| Directive | Function | Modifier enum |
|-----------|----------|---------------|
| `x-show` | `.show(_:modifiers:)` | `ShowModifier` (`.important`) |
| `x-on` | `.on(_:_:modifiers:)` | `OnModifier` (30+ cases) |
| `x-model` | `.model(_:modifiers:)` | `ModelModifier` (`.lazy`, `.change`, `.blur`, `.enter`, `.number`, `.boolean`, `.fill`) |
| `x-transition` | `.transition(modifiers:)` | `TransitionModifier` (`.opacity`, `.scale(Int?)`, `.origin(Origin)`, `.duration(Int)`, `.delay(Int)`) |
| `x-mask` | `.xMask.pattern(_:)` | — (no modifiers in Alpine.js) |
| `x-mask:dynamic` | `.xMask.dynamic(_:)` | — (no modifiers in Alpine.js) |
| `x-intersect` | `.xIntersect.intersect(_:modifiers:)` | `IntersectModifier` (`.once`, `.half`, `.full`, `.threshold(Int)`, `.margin(String)`) |
| `x-intersect:enter` | `.xIntersect.enter(_:modifiers:)` | `IntersectModifier` |
| `x-intersect:leave` | `.xIntersect.leave(_:modifiers:)` | `IntersectModifier` |
| `x-resize` | `.xResize.resize(_:modifiers:)` | `ResizeModifier` (`.document`) |
| `x-persist` | — (magic only, no directive) | `$persist(...)` used as JS string in `x-data` value |
| `x-trap` | `.xFocus.trap(_:modifiers:)` | `FocusModifier` (`.inert`, `.noscroll`, `.noreturn`, `.noautofocus`) |
| `x-collapse` | `.xCollapse.collapse(modifiers:)` | `CollapseModifier` (`.duration(Int)`, `.min(Int)`) |
| `x-anchor` | `.xAnchor.anchor(_:modifiers:)` | `AnchorModifier` (12 positioning + `.fixed`, `.offset(Int)`, `.noflip`, `.noStyle`) |
| `x-sort` | `.xSort.sort(_:modifiers:)` | `SortModifier` (`.ghost`) |
| `x-sort:item` | `.xSort.item(_:)` | — (no modifiers) |
| `x-sort:group` | `.xSort.group(_:)` | — (no modifiers) |
| `x-sort:handle` | `.xSort.handle` | — (no value, no modifiers) |
| `x-sort:ignore` | `.xSort.ignore` | — (no value, no modifiers) |
| `x-sort:config` | `.xSort.config(_:)` | — (no modifiers) |
| `x-morph` | `setupMorph(...)` / `setupMorphBetween(...)` | No modifiers (lifecycle hooks via `MorphOptions`) |

## Globals API

`ElementaryAlpine` provides a free `registerGlobal` function for registering Alpine.js global APIs. All globals are wrapped in `document.addEventListener('alpine:init', ...)` per the Alpine.js CDN pattern:

```swift
public enum AlpineGlobals {
    case data    // → Alpine.data(name, factory)
    case store   // → Alpine.store(name, value)
    case bind    // → Alpine.bind(name, factory)
}

public func registerGlobal(_ kind: AlpineGlobals, on: String, action: String) -> some HTML
```

**Usage in head:**

```swift
var head: some HTML {
    meta(.charset(.utf8))
    script(.src("https://cdn.jsdelivr.net/npm/alpinejs@3.15.12/dist/cdn.min.js"), .defer) {}
    registerGlobal(.data, on: "dropdown", action: "() => ({ open: false })")
    registerGlobal(.store, on: "notifications", action: "{ items: [] }")
    registerGlobal(.bind, on: "myButton", action: "() => ({ type: 'button' })")
}
```

## Setup API

`ElementaryAlpine` provides a free `setupAlpine(version:plugins:)` helper that emits the `<script>` tags needed to install Alpine.js and any specified plugins from a CDN. Plugin scripts are emitted first (per Alpine.js requirements), followed by Alpine core. Defaults: `version = "3.15.12"`, `plugins = []`.

```swift
public enum AlpinePlugin: String, CaseIterable, Hashable, Sendable {
    case mask, intersect, resize, persist, focus, collapse, anchor, sort, morph
}

public func setupAlpine(
    version: String = "3.15.12",
    plugins: [AlpinePlugin] = []
) -> some HTML
```

**Usage in head:**

```swift
var head: some HTML {
    meta(.charset(.utf8))
    script(.src("https://cdn.jsdelivr.net/npm/alpinejs@3.15.12/dist/cdn.min.js"), .defer) {}
    setupAlpine(plugins: [.mask, .focus, .morph])
}
```

## Swift Keyword Escapes

To avoid backticks in user code, reserved Swift keywords are renamed:

| HTML | Swift | Raw value |
|------|-------|-----------|
| `x-init` | `.setup` | `x-init` |
| `x-for` | `.loop` | `x-for` |
| `x-if` | `.when` | `x-if` |

The HTML output is unchanged — only the Swift function names differ.

## Testing

- Use the `TestUtilities` target pattern from `elementary-htmx`
- Test that rendered HTML matches AlpineJS expectations
- Test modifier chaining behavior for value types

## Dependencies

- `elementary` ≥ 0.6.0
- No other external dependencies
- Built against **Alpine.js v3.15.12** (consumers must include the Alpine.js runtime in their page)

## Commit Guidelines

- Prefix types: `feat:`, `fix:`, `chore:`, `test:`, `docs:`, `refactor:`
- Include target scope in parens: `feat(core):`
- Release tags: `chore: tag vX.Y.ZZZ`
- **Never push without explicit user confirmation** — commits stay local until the user authorizes a push
- The build agent prepares changes, shows the diff, and waits for user confirmation before each commit

## CI/CD

- GitHub Actions: lint, test, build on macOS
- Swift 6.0, iOS 15+, macOS 14+
- Run `swift format --lint` and `swift test` before merge
