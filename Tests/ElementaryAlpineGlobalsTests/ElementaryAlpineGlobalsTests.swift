import Elementary
import ElementaryAlpineGlobals
import TestUtilities
import XCTest

final class ElementaryAlpineGlobalsTests: XCTestCase {
    func testData() {
        let html = renderToString {
            registerGlobal(.data, on: "dropdown", action: "() => ({ open: false })")
        }
        XCTAssertEqual(
            html,
            #"<script>document.addEventListener('alpine:init', () => { Alpine.data('dropdown', () => ({ open: false })) })</script>"#
        )
    }

    func testStore() {
        let html = renderToString {
            registerGlobal(.store, on: "notifications", action: "{ items: [] }")
        }
        XCTAssertEqual(
            html,
            #"<script>document.addEventListener('alpine:init', () => { Alpine.store('notifications', { items: [] }) })</script>"#
        )
    }

    func testBind() {
        let html = renderToString {
            registerGlobal(.bind, on: "SomeButton", action: "() => ({ type: 'button' })")
        }
        XCTAssertEqual(
            html,
            #"<script>document.addEventListener('alpine:init', () => { Alpine.bind('SomeButton', () => ({ type: 'button' })) })</script>"#
        )
    }
}

private func renderToString(@HTMLBuilder _ content: () -> some HTML) -> String {
    content().render()
}
