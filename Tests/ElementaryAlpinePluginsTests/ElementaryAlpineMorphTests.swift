import Elementary
import ElementaryAlpinePlugins
import XCTest

final class ElementaryAlpineMorphTests: XCTestCase {
    func testBasicSetupMorph() {
        let html = renderToString {
            setupMorph(
                trigger: "#btn",
                target: "#target",
                event: "click"
            ) {
                div { "new" }
            }
        }
        XCTAssertEqual(
            html,
            #"""
            <script>
            document.querySelector('#btn').addEventListener('click', async () => {
                Alpine.morph(document.querySelector('#target'), `<div>new</div>`)
            })
            </script>
            """#
        )
    }

    func testWithSingleOption() {
        let html = renderToString {
            setupMorph(
                trigger: "#btn",
                target: "#target",
                event: "click",
                options: { .updating("console.log(el)") }
            ) {
                div { "new" }
            }
        }
        XCTAssertEqual(
            html,
            #"""
            <script>
            document.querySelector('#btn').addEventListener('click', async () => {
                Alpine.morph(document.querySelector('#target'), `<div>new</div>`, { updating(el, toEl, childrenOnly, skip) { console.log(el) } })
            })
            </script>
            """#
        )
    }

    func testLookaheadOption() {
        let html = renderToString {
            setupMorph(
                trigger: "#btn",
                target: "#target",
                event: "click",
                options: { .lookahead() }
            ) {
                div { "new" }
            }
        }
        XCTAssertTrue(html.contains("lookahead: true"))
    }

    func testKeyOption() {
        let html = renderToString {
            setupMorph(
                trigger: "#btn",
                target: "#list",
                event: "click",
                options: { .key("(el) => el.id") }
            ) {
                ul { li { "a" } }
            }
        }
        XCTAssertTrue(html.contains("key: (el) => el.id"))
    }

    func testAllHooks() {
        let html = renderToString {
            setupMorph(
                trigger: "#btn",
                target: "#target",
                event: "click",
                options: {
                    .updating("console.log('u')")
                        .updated("console.log('d')")
                        .removing("console.log('r')")
                        .removed("console.log('rm')")
                        .adding("console.log('a')")
                        .added("console.log('ad')")
                        .key("(el) => el.id")
                        .lookahead()
                }
            ) {
                div { "new" }
            }
        }
        XCTAssertTrue(html.contains("updating(el, toEl, childrenOnly, skip) { console.log('u') }"))
        XCTAssertTrue(html.contains("updated(el, toEl) { console.log('d') }"))
        XCTAssertTrue(html.contains("removing(el, skip) { console.log('r') }"))
        XCTAssertTrue(html.contains("removed(el) { console.log('rm') }"))
        XCTAssertTrue(html.contains("adding(el, skip) { console.log('a') }"))
        XCTAssertTrue(html.contains("added(el) { console.log('ad') }"))
        XCTAssertTrue(html.contains("key: (el) => el.id"))
        XCTAssertTrue(html.contains("lookahead: true"))
    }

    func testChildrenOnlyAndSkipInHook() {
        let body = """
            if (el.dataset.frozen) {
                childrenOnly()
            }
            if (el.dataset.skip) {
                skip()
            }
            """
        let html = renderToString {
            setupMorph(
                trigger: "#btn",
                target: "#target",
                event: "click",
                options: { .updating(body) }
            ) {
                div { "new" }
            }
        }
        XCTAssertTrue(html.contains("childrenOnly()"))
        XCTAssertTrue(html.contains("skip()"))
    }

    func testHTMLEscapingBacktick() {
        let html = renderToString {
            setupMorph(trigger: "#btn", target: "#target", event: "click") {
                div { "with `backtick`" }
            }
        }
        XCTAssertTrue(html.contains(#"\`backtick\`"#))
    }

    func testHTMLEscapingDollarBrace() {
        let html = renderToString {
            setupMorph(trigger: "#btn", target: "#target", event: "click") {
                div { "${var}" }
            }
        }
        XCTAssertTrue(html.contains(#"\${var}"#))
    }

    func testHTMLEscapingBackslash() {
        let html = renderToString {
            setupMorph(trigger: "#btn", target: "#target", event: "click") {
                div { "back\\slash" }
            }
        }
        XCTAssertTrue(html.contains("back\\\\slash"))
    }

    func testScriptTagEscaping() {
        let html = renderToString {
            setupMorph(trigger: "#btn", target: "#target", event: "click") {
                div { "safe content" }
            }
        }
        let outerScriptTags = html.components(separatedBy: "</script>").count - 1
        XCTAssertEqual(outerScriptTags, 1, "Should have exactly one outer </script> tag, not multiple")
    }

    func testJsCommand() {
        let html = renderToString {
            setupMorph(
                trigger: "#btn",
                target: "#list",
                event: "click",
                jsCommand: { "const html = await fetch('/api/list').then(r => r.text())" }
            ) {
                div { "default" }
            }
        }
        XCTAssertTrue(html.contains("const html = await fetch('/api/list').then(r => r.text())"))
        XCTAssertTrue(html.contains("Alpine.morph(document.querySelector('#list'), html)"))
    }

    func testJsCommandWithOptions() {
        let html = renderToString {
            setupMorph(
                trigger: "#btn",
                target: "#list",
                event: "click",
                options: { .lookahead() },
                jsCommand: { "const html = await fetch('/api/list').then(r => r.text())" }
            ) {
                div { "default" }
            }
        }
        XCTAssertTrue(html.contains("const html = await fetch"))
        XCTAssertTrue(html.contains("Alpine.morph(document.querySelector('#list'), html, { lookahead: true })"))
    }

    func testEmptyJsCommandUsesStaticTemplate() {
        let html = renderToString {
            setupMorph(
                trigger: "#btn",
                target: "#target",
                event: "click",
                jsCommand: { "" }
            ) {
                div { "new" }
            }
        }
        XCTAssertTrue(html.contains("Alpine.morph(document.querySelector('#target'), `<div>new</div>`)"))
        XCTAssertFalse(html.contains("const html"))
    }

    func testNoOptionsProducesNoThirdArgument() {
        let html = renderToString {
            setupMorph(trigger: "#btn", target: "#target", event: "click") {
                div { "new" }
            }
        }
        XCTAssertFalse(html.contains("undefined"))
    }

    func testLookaheadFalseNotIncluded() {
        let html = renderToString {
            setupMorph(
                trigger: "#btn",
                target: "#target",
                event: "click",
                options: { .lookahead(false) }
            ) {
                div { "new" }
            }
        }
        XCTAssertFalse(html.contains("lookahead"))
    }

    func testMinimalOverload() {
        let html = renderToString {
            setupMorph(trigger: "#btn", target: "#target", event: "click") {
                div { "minimal" }
            }
        }
        XCTAssertEqual(
            html,
            #"""
            <script>
            document.querySelector('#btn').addEventListener('click', async () => {
                Alpine.morph(document.querySelector('#target'), `<div>minimal</div>`)
            })
            </script>
            """#
        )
    }

    func testOptionsOnlyOverload() {
        let html = renderToString {
            setupMorph(
                trigger: "#btn",
                target: "#target",
                event: "click",
                options: { .added("console.log('added')") }
            ) {
                div { "new" }
            }
        }
        XCTAssertTrue(html.contains("added(el) { console.log('added') }"))
        XCTAssertFalse(html.contains("const html"))
    }

    func testJsCommandOnlyOverload() {
        let html = renderToString {
            setupMorph(
                trigger: "#btn",
                target: "#list",
                event: "click",
                jsCommand: { "const html = await fetch('/api/list').then(r => r.text())" }
            ) {
                div { "default" }
            }
        }
        XCTAssertTrue(html.contains("const html = await fetch('/api/list').then(r => r.text())"))
        XCTAssertTrue(html.contains("Alpine.morph(document.querySelector('#list'), html)"))
        XCTAssertFalse(html.contains("lookahead"))
    }

    func testFullOverload() {
        let html = renderToString {
            setupMorph(
                trigger: "#btn",
                target: "#list",
                event: "click",
                options: { .lookahead() },
                jsCommand: { "const html = await fetch('/api/list').then(r => r.text())" }
            ) {
                div { "default" }
            }
        }
        XCTAssertTrue(html.contains("const html = await fetch"))
        XCTAssertTrue(html.contains("Alpine.morph(document.querySelector('#list'), html, { lookahead: true })"))
    }

    func testNoTriggerMinimalOverload() {
        let html = renderToString {
            setupMorph(target: "#target") {
                div { "new" }
            }
        }
        XCTAssertEqual(
            html,
            #"""
            <script>
            Alpine.morph(document.querySelector('#target'), `<div>new</div>`)
            </script>
            """#
        )
    }

    func testNoTriggerOptionsOverload() {
        let html = renderToString {
            setupMorph(
                target: "#target",
                options: { .added("console.log('added')") }
            ) {
                div { "new" }
            }
        }
        XCTAssertTrue(
            html.contains(
                "Alpine.morph(document.querySelector('#target'), `<div>new</div>`, { added(el) { console.log('added') } })"
            )
        )
        XCTAssertFalse(html.contains("addEventListener"))
    }

    func testNoTriggerJsCommandOverload() {
        let html = renderToString {
            setupMorph(
                target: "#list",
                jsCommand: { "const html = await fetch('/api/list').then(r => r.text())" }
            ) {
                div { "default" }
            }
        }
        XCTAssertTrue(html.contains("const html = await fetch('/api/list').then(r => r.text())"))
        XCTAssertTrue(html.contains("Alpine.morph(document.querySelector('#list'), html)"))
        XCTAssertFalse(html.contains("addEventListener"))
    }

    func testNoTriggerFullOverload() {
        let html = renderToString {
            setupMorph(
                target: "#list",
                options: { .lookahead() },
                jsCommand: { "const html = await fetch('/api/list').then(r => r.text())" }
            ) {
                div { "default" }
            }
        }
        XCTAssertTrue(html.contains("const html = await fetch"))
        XCTAssertTrue(html.contains("Alpine.morph(document.querySelector('#list'), html, { lookahead: true })"))
        XCTAssertFalse(html.contains("addEventListener"))
    }
}

private func renderToString(@HTMLBuilder _ content: () -> some HTML) -> String {
    content().render()
}
