import Elementary
import ElementaryAlpinePlugins
import XCTest

final class ElementaryAlpineMorphBetweenTests: XCTestCase {
    func testBasicSetupMorphBetween() {
        let html = renderToString {
            setupMorphBetween(
                trigger: "#btn",
                startMarker: "<!--start-->",
                endMarker: "<!--end-->",
                event: "click"
            ) {
                li { "new" }
            }
        }
        XCTAssertTrue(html.contains("const findMorphMarker = (marker) => {"))
        XCTAssertTrue(html.contains("document.createTreeWalker"))
        XCTAssertTrue(html.contains("NodeFilter.SHOW_COMMENT"))
        XCTAssertTrue(html.contains("findMorphMarker('<!--start-->')"))
        XCTAssertTrue(html.contains("findMorphMarker('<!--end-->')"))
        XCTAssertTrue(html.contains("Alpine.morphBetween(findMorphMarker('<!--start-->'), findMorphMarker('<!--end-->'), `<li>new</li>`)"))
    }

    func testWithSingleOption() {
        let html = renderToString {
            setupMorphBetween(
                trigger: "#btn",
                startMarker: "<!--start-->",
                endMarker: "<!--end-->",
                event: "click",
                options: { .updating { "console.log(el)" } }
            ) {
                li { "new" }
            }
        }
        XCTAssertTrue(html.contains("updating(el, toEl, childrenOnly, skip) { console.log(el) }"))
    }

    func testLookaheadOption() {
        let html = renderToString {
            setupMorphBetween(
                trigger: "#btn",
                startMarker: "<!--start-->",
                endMarker: "<!--end-->",
                event: "click",
                options: { .lookahead() }
            ) {
                li { "new" }
            }
        }
        XCTAssertTrue(html.contains("lookahead: true"))
    }

    func testKeyOption() {
        let html = renderToString {
            setupMorphBetween(
                trigger: "#btn",
                startMarker: "<!--start-->",
                endMarker: "<!--end-->",
                event: "click",
                options: { .key { "(el) => el.id" } }
            ) {
                li { "new" }
            }
        }
        XCTAssertTrue(html.contains("key: (el) => el.id"))
    }

    func testAllHooks() {
        let html = renderToString {
            setupMorphBetween(
                trigger: "#btn",
                startMarker: "<!--start-->",
                endMarker: "<!--end-->",
                event: "click",
                options: {
                    .updating { "console.log('u')" }
                        .updated { "console.log('d')" }
                        .removing { "console.log('r')" }
                        .removed { "console.log('rm')" }
                        .adding { "console.log('a')" }
                        .added { "console.log('ad')" }
                        .key { "(el) => el.id" }
                        .lookahead()
                }
            ) {
                li { "new" }
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

    func testJsCommand() {
        let expected =
            "Alpine.morphBetween(findMorphMarker('<!--start-->'), findMorphMarker('<!--end-->'), html)"
        let html = renderToString {
            setupMorphBetween(
                trigger: "#btn",
                startMarker: "<!--start-->",
                endMarker: "<!--end-->",
                event: "click",
                jsCommand: { "const html = await fetch('/api/list').then(r => r.text())" }
            ) {
                li { "default" }
            }
        }
        XCTAssertTrue(html.contains("const html = await fetch('/api/list').then(r => r.text())"))
        XCTAssertTrue(html.contains(expected))
    }

    func testJsCommandWithOptions() {
        let expected =
            "Alpine.morphBetween(findMorphMarker('<!--start-->'), findMorphMarker('<!--end-->'), html, { lookahead: true })"
        let html = renderToString {
            setupMorphBetween(
                trigger: "#btn",
                startMarker: "<!--start-->",
                endMarker: "<!--end-->",
                event: "click",
                options: { .lookahead() },
                jsCommand: { "const html = await fetch('/api/list').then(r => r.text())" }
            ) {
                li { "default" }
            }
        }
        XCTAssertTrue(html.contains("const html = await fetch"))
        XCTAssertTrue(html.contains(expected))
    }

    func testEmptyJsCommandUsesStaticTemplate() {
        let html = renderToString {
            setupMorphBetween(
                trigger: "#btn",
                startMarker: "<!--start-->",
                endMarker: "<!--end-->",
                event: "click",
                jsCommand: { "" }
            ) {
                li { "new" }
            }
        }
        XCTAssertTrue(
            html.contains(
                "Alpine.morphBetween(findMorphMarker('<!--start-->'), findMorphMarker('<!--end-->'), `<li>new</li>`)"
            )
        )
        XCTAssertFalse(html.contains("const html"))
    }

    func testLookaheadFalseNotIncluded() {
        let html = renderToString {
            setupMorphBetween(
                trigger: "#btn",
                startMarker: "<!--start-->",
                endMarker: "<!--end-->",
                event: "click",
                options: { .lookahead(false) }
            ) {
                li { "new" }
            }
        }
        XCTAssertFalse(html.contains("lookahead"))
    }

    func testNoTriggerMinimalOverload() {
        let expected = "Alpine.morphBetween(findMorphMarker('<!--start-->'), findMorphMarker('<!--end-->'), `<li>new</li>`)"
        let html = renderToString {
            setupMorphBetween(
                startMarker: "<!--start-->",
                endMarker: "<!--end-->"
            ) {
                li { "new" }
            }
        }
        XCTAssertTrue(html.contains("const findMorphMarker = (marker) => {"))
        XCTAssertTrue(html.contains(expected))
    }

    func testNoTriggerOptionsOverload() {
        let html = renderToString {
            setupMorphBetween(
                startMarker: "<!--start-->",
                endMarker: "<!--end-->",
                options: { .added { "console.log('added')" } }
            ) {
                li { "new" }
            }
        }
        XCTAssertTrue(html.contains("added(el) { console.log('added') }"))
        XCTAssertFalse(html.contains("addEventListener"))
    }

    func testNoTriggerJsCommandOverload() {
        let expected =
            "Alpine.morphBetween(findMorphMarker('<!--start-->'), findMorphMarker('<!--end-->'), html)"
        let html = renderToString {
            setupMorphBetween(
                startMarker: "<!--start-->",
                endMarker: "<!--end-->",
                jsCommand: { "const html = await fetch('/api/list').then(r => r.text())" }
            ) {
                li { "default" }
            }
        }
        XCTAssertTrue(html.contains("const html = await fetch('/api/list').then(r => r.text())"))
        XCTAssertTrue(html.contains(expected))
        XCTAssertFalse(html.contains("addEventListener"))
    }

    func testNoTriggerFullOverload() {
        let expected =
            "Alpine.morphBetween(findMorphMarker('<!--start-->'), findMorphMarker('<!--end-->'), html, { lookahead: true })"
        let html = renderToString {
            setupMorphBetween(
                startMarker: "<!--start-->",
                endMarker: "<!--end-->",
                options: { .lookahead() },
                jsCommand: { "const html = await fetch('/api/list').then(r => r.text())" }
            ) {
                li { "default" }
            }
        }
        XCTAssertTrue(html.contains("const html = await fetch"))
        XCTAssertTrue(html.contains(expected))
        XCTAssertFalse(html.contains("addEventListener"))
    }
}

private func renderToString(@HTMLBuilder _ content: () -> some HTML) -> String {
    content().render()
}
