import Elementary
import Foundation

// MARK: - Internal helper

/// Generates the complete `<script>` element for an `Alpine.morph` call.
/// When `trigger` is non-empty, the morph is wrapped in an `addEventListener` block
/// that fires when the trigger element receives the given event. When `trigger`
/// is empty, the script emits the imperative `Alpine.morph(...)` call directly,
/// which runs once on page load.
private func generateMorphScript(
    target: String,
    trigger: String = "",
    event: String = "",
    options: () -> MorphOptions = { MorphOptions() },
    jsCommand: () -> String = { "" },
    @HTMLBuilder returning: () -> some HTML
) -> some HTML {
    let rawHtml: String = returning().render()
    let escaped =
        rawHtml
        .replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "`", with: "\\`")
        .replacingOccurrences(of: "${", with: "\\${")
        .replacingOccurrences(of: "</script>", with: "<\\/script>")

    let optionsJS = options().toJS()
    let optionsPart: String = optionsJS.isEmpty ? "" : ", \(optionsJS)"
    let command = jsCommand()
    let morphCall: String
    if command.isEmpty {
        morphCall = "Alpine.morph(document.querySelector('\(target)'), `\(escaped)`\(optionsPart))"
    } else {
        morphCall = "\(command)\nAlpine.morph(document.querySelector('\(target)'), html\(optionsPart))"
    }
    if trigger.isEmpty {
        return HTMLRaw("<script>\n\(morphCall)\n</script>")
    }
    let handler = "document.querySelector('\(trigger)').addEventListener('\(event)', async () => {\n    \(morphCall)\n})"
    return HTMLRaw("<script>\n\(handler)\n</script>")
}

// MARK: - With trigger (event listener)

/// Generates a `<script>` that morphs a static HTML template into the target
/// element when the trigger element fires the given event.
///
/// This is the simplest form. Use it when:
/// - You have a static HTML template that doesn't change
/// - You don't need lifecycle hooks (`.updating`, `.key`, `.lookahead`, etc.)
/// - You don't need to fetch HTML dynamically
///
/// **Generated HTML:**
/// ```html
/// <script>
/// document.querySelector(trigger).addEventListener(event, async () => {
///     Alpine.morph(document.querySelector(target), `<html>`)
/// })
/// </script>
/// ```
///
/// **Example:**
/// ```swift
/// setupMorph(
///     trigger: "#refresh-btn",
///     target: "#user-card",
///     event: "click"
/// ) {
///     div(.x.data("{ name: 'Updated' }")) {
///         h2 { "Updated" }
///     }
/// }
/// ```
///
/// For lifecycle hooks, use the overload that takes `options:`.
/// For dynamic HTML (e.g., fetched from a server), use the overload that takes `jsCommand:`.
public func setupMorph(
    trigger: String,
    target: String,
    event: String,
    @HTMLBuilder returning: () -> some HTML
) -> some HTML {
    generateMorphScript(target: target, trigger: trigger, event: event, returning: returning)
}

/// Generates a `<script>` that morphs the target element with lifecycle hook
/// options when the trigger element fires the given event.
///
/// Use this overload when you need to hook into the morph lifecycle
/// (`.updating`, `.updated`, `.removing`, `.removed`, `.adding`, `.added`),
/// configure element identity with `.key`, or enable `.lookahead`.
///
/// **Generated HTML:**
/// ```html
/// <script>
/// document.querySelector(trigger).addEventListener(event, async () => {
///     Alpine.morph(document.querySelector(target), `<html>`, { ...options })
/// })
/// </script>
/// ```
///
/// **Example:**
/// ```swift
/// setupMorph(
///     trigger: "#list-refresh",
///     target: "#list",
///     event: "click",
///     options: {
///         .updating("console.log('patching', el)")
///             .key("(el) => el.id")
///             .lookahead()
///     }
/// ) {
///     ul { li { "item" } }
/// }
/// ```
public func setupMorph(
    trigger: String,
    target: String,
    event: String,
    options: () -> MorphOptions,
    @HTMLBuilder returning: () -> some HTML
) -> some HTML {
    generateMorphScript(target: target, trigger: trigger, event: event, options: options, returning: returning)
}

/// Generates a `<script>` that fetches HTML dynamically (or runs any JS
/// pre-command) and then morphs the target element when the trigger fires.
///
/// Use this overload when the new HTML depends on runtime data — typically
/// fetched from a server. The `jsCommand` closure must assign the HTML string
/// to a variable named `html` (the morph call uses it).
///
/// **Generated HTML:**
/// ```html
/// <script>
/// document.querySelector(trigger).addEventListener(event, async () => {
///     <jsCommand body, must assign to `html`>
///     Alpine.morph(document.querySelector(target), html)
/// })
/// </script>
/// ```
///
/// **Example:**
/// ```swift
/// setupMorph(
///     trigger: "#refresh-btn",
///     target: "#list",
///     event: "click",
///     jsCommand: { "const html = await fetch('/api/list').then(r => r.text())" }
/// ) {
///     div { "default" }
/// }
/// ```
public func setupMorph(
    trigger: String,
    target: String,
    event: String,
    jsCommand: () -> String,
    @HTMLBuilder returning: () -> some HTML
) -> some HTML {
    generateMorphScript(target: target, trigger: trigger, event: event, jsCommand: jsCommand, returning: returning)
}

/// Generates a `<script>` with the full set of options: lifecycle hooks,
/// element identity (`.key`), `.lookahead`, and a dynamic JS pre-command.
///
/// This is the most complete form. Use it when you need everything at once.
///
/// **Generated HTML:**
/// ```html
/// <script>
/// document.querySelector(trigger).addEventListener(event, async () => {
///     <jsCommand body>
///     Alpine.morph(document.querySelector(target), html, { ...options })
/// })
/// </script>
/// ```
///
/// **Example:**
/// ```swift
/// setupMorph(
///     trigger: "#refresh-btn",
///     target: "#list",
///     event: "click",
///     options: {
///         .key("(el) => el.id")
///             .lookahead()
///     },
///     jsCommand: { "const html = await fetch('/api/list').then(r => r.text())" }
/// ) {
///     div { "fallback" }
/// }
/// ```
public func setupMorph(
    trigger: String,
    target: String,
    event: String,
    options: () -> MorphOptions,
    jsCommand: () -> String,
    @HTMLBuilder returning: () -> some HTML
) -> some HTML {
    generateMorphScript(
        target: target,
        trigger: trigger,
        event: event,
        options: options,
        jsCommand: jsCommand,
        returning: returning
    )
}

// MARK: - Without trigger (imperative call)

/// Generates a `<script>` that calls `Alpine.morph(target, html)` once on
/// page load. No event listener is attached.
///
/// Use this overload when you want the morph to happen immediately when the
/// page loads — for initial state setup, pre-rendering, or one-time morphs.
/// For morphs triggered by user actions, use an overload with `trigger:` and `event:`.
///
/// **Generated HTML:**
/// ```html
/// <script>
/// Alpine.morph(document.querySelector(target), `<html>`)
/// </script>
/// ```
///
/// **Example:**
/// ```swift
/// setupMorph(target: "#content") {
///     div { "initial content" }
/// }
/// ```
public func setupMorph(
    target: String,
    @HTMLBuilder returning: () -> some HTML
) -> some HTML {
    generateMorphScript(target: target, returning: returning)
}

/// Generates a `<script>` that calls `Alpine.morph(target, html, options)` once
/// on page load, with lifecycle hook options. No event listener is attached.
///
/// **Generated HTML:**
/// ```html
/// <script>
/// Alpine.morph(document.querySelector(target), `<html>`, { ...options })
/// </script>
/// ```
///
/// **Example:**
/// ```swift
/// setupMorph(
///     target: "#content",
///     options: { .updating("console.log('init', el)") }
/// ) {
///     div { "initial content" }
/// }
/// ```
public func setupMorph(
    target: String,
    options: () -> MorphOptions,
    @HTMLBuilder returning: () -> some HTML
) -> some HTML {
    generateMorphScript(target: target, options: options, returning: returning)
}

/// Generates a `<script>` that runs a dynamic JS pre-command (e.g., a fetch)
/// and then calls `Alpine.morph(target, html)` once on page load. No event
/// listener is attached.
///
/// The `jsCommand` closure must assign the HTML string to a variable named `html`.
///
/// **Generated HTML:**
/// ```html
/// <script>
/// <jsCommand body, must assign to `html`>
/// Alpine.morph(document.querySelector(target), html)
/// </script>
/// ```
///
/// **Example:**
/// ```swift
/// setupMorph(
///     target: "#content",
///     jsCommand: { "const html = await fetch('/api/initial').then(r => r.text())" }
/// ) {
///     div { "loading..." }
/// }
/// ```
public func setupMorph(
    target: String,
    jsCommand: () -> String,
    @HTMLBuilder returning: () -> some HTML
) -> some HTML {
    generateMorphScript(target: target, jsCommand: jsCommand, returning: returning)
}

/// Generates a `<script>` that runs a dynamic JS pre-command and calls
/// `Alpine.morph(target, html, options)` once on page load, with lifecycle
/// hook options. No event listener is attached.
///
/// This is the most complete imperative form.
///
/// **Generated HTML:**
/// ```html
/// <script>
/// <jsCommand body>
/// Alpine.morph(document.querySelector(target), html, { ...options })
/// </script>
/// ```
///
/// **Example:**
/// ```swift
/// setupMorph(
///     target: "#content",
///     options: { .key("(el) => el.id") },
///     jsCommand: { "const html = await fetch('/api/initial').then(r => r.text())" }
/// ) {
///     div { "loading..." }
/// }
/// ```
public func setupMorph(
    target: String,
    options: () -> MorphOptions,
    jsCommand: () -> String,
    @HTMLBuilder returning: () -> some HTML
) -> some HTML {
    generateMorphScript(
        target: target,
        options: options,
        jsCommand: jsCommand,
        returning: returning
    )
}
