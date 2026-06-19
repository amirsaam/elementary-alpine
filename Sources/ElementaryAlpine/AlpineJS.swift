import Elementary

extension HTMLAttribute where Tag: HTMLTrait.Attributes.Global {
    /// A namespace for the 17 core AlpineJS directives.
    /// See the [AlpineJS reference](https://alpinejs.dev/directives) for more information.
    public enum x {}
}

/// The official Alpine.js plugins that ship as separate CDN scripts.
///
/// Use with `setupAlpine(version:plugins:)` to install them. The plugin
/// scripts must be loaded **before** Alpine core (handled automatically by
/// `setupAlpine`).
public enum AlpinePlugin: String, CaseIterable, Hashable, Sendable {
    case mask
    case intersect
    case resize
    case persist
    case focus
    case collapse
    case anchor
    case sort
    case morph
}

/// Emits the `<script>` tags needed to install Alpine.js and any specified
/// plugins from a CDN. Plugin scripts are emitted first (per Alpine.js
/// requirements), followed by Alpine core.
///
/// - Parameters:
///   - version: The Alpine.js version to pin. Defaults to the version this
///     package is built against (`3.15.12`).
///   - plugins: The plugins to install. Empty by default; opt in by passing
///     the plugins you need (e.g., `plugins: [.mask, .focus]`).
///
/// **Generated HTML (no plugins):**
/// ```html
/// <script src=".../alpinejs@3.15.12/dist/cdn.min.js" defer></script>
/// ```
///
/// **Generated HTML (with plugins):**
/// ```html
/// <script src=".../@alpinejs/mask@3.15.12/dist/cdn.min.js" defer></script>
/// <script src=".../@alpinejs/focus@3.15.12/dist/cdn.min.js" defer></script>
/// <script src=".../alpinejs@3.15.12/dist/cdn.min.js" defer></script>
/// ```
///
/// **Example:**
/// ```swift
/// var head: some HTML {
///     meta(.charset(.utf8))
///     setupAlpine(plugins: [.mask, .focus, .morph])
/// }
/// ```
public func setupAlpine(
    version: String = "3.15.12",
    plugins: [AlpinePlugin] = []
) -> some HTML {
    Group {
        for plugin in plugins {
            script(
                .src("https://cdn.jsdelivr.net/npm/@alpinejs/\(plugin.rawValue)@\(version)/dist/cdn.min.js"),
                .defer
            ) {}
        }
        script(
            .src("https://cdn.jsdelivr.net/npm/alpinejs@\(version)/dist/cdn.min.js"),
            .defer
        ) {}
    }
}
