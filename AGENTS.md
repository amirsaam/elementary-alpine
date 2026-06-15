# AGENTS.md

AI contribution guidelines for `elementary-alpine`.

## Project Overview

`elementary-alpine` provides type-safe HTML attributes for [AlpineJS](https://alpinejs.dev/) directives, following the patterns of [elementary](https://github.com/elementary-swift/elementary) and [elementary-htmx](https://github.com/elementary-swift/elementary-htmx).

The package currently ships:

- **`ElementaryAlpine`** — core AlpineJS directives

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
- Use `consuming` methods for modifier chaining (see `HTMLAttributeValue.HTMX` in elementary-htmx)
- Match the coding style of `elementary` and `elementary-htmx`

## Architecture

The core target follows a two-file pattern:

```
Sources/ElementaryAlpine/
├── HTMLAttribute+Alpine.swift   # Attribute factory functions (e.g., `.x.data("...")`)
└── HTMLAttributeValue+Alpine.swift  # Value types (e.g., `OnModifier`, `ModelModifier`)
```

All 17 core AlpineJS directives are implemented under `HTMLAttribute.x`:
- `x-data`, `x-init`, `x-show`, `x-bind`/`x-bind:class`/`x-bind:style`
- `x-on` with modifiers (base, keyboard, mouse, advanced)
- `x-text`, `x-html`, `x-model` with modifiers, `x-modelable`
- `x-for`, `x-transition` (all phases), `x-effect`, `x-ignore`, `x-ref`, `x-cloak`
- `x-teleport`, `x-if`, `x-id`

## Testing

- Use the `TestUtilities` target pattern from `elementary-htmx`
- Test that rendered HTML matches AlpineJS expectations
- Test modifier chaining behavior for value types

## Dependencies

- `elementary` ≥ 0.6.0
- No other external dependencies

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
