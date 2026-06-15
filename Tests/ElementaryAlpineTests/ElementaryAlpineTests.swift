import Elementary
import ElementaryAlpine
import TestUtilities
import XCTest

final class ElementaryAlpineTests: XCTestCase {
    func testData() {
        HTMLAttributeAssertEqual(.x.data("{ count: 0 }"), "x-data", "{ count: 0 }")
    }

    func testInit() {
        HTMLAttributeAssertEqual(.x.setup("count = 1"), "x-init", "count = 1")
    }

    func testShow() {
        HTMLAttributeAssertEqual(.x.show("open"), "x-show", "open")
    }

    func testShowImportant() {
        HTMLAttributeAssertEqual(
            .x.show("open", modifiers: [.important]),
            "x-show.important",
            "open"
        )
    }

    func testBind() {
        HTMLAttributeAssertEqual(.x.bind("placeholder", "text"), "x-bind:placeholder", "text")
        HTMLAttributeAssertEqual(.x.bind("trigger"), "x-bind", "trigger")
    }

    func testBindClass() {
        HTMLAttributeAssertEqual(.x.bindClass("{ 'hidden': !show }"), "x-bind:class", "{ 'hidden': !show }")
    }

    func testBindStyle() {
        HTMLAttributeAssertEqual(.x.bindStyle("{ color: 'red' }"), "x-bind:style", "{ color: 'red' }")
    }

    func testOnEvent() {
        HTMLAttributeAssertEqual(.x.on("click", "alert('hi')"), "x-on:click", "alert('hi')")
    }

    func testOnBaseModifiers() {
        HTMLAttributeAssertEqual(
            .x.on("click", "alert('hi')", modifiers: [.prevent]),
            "x-on:click.prevent",
            "alert('hi')"
        )
        HTMLAttributeAssertEqual(
            .x.on("click", "alert('hi')", modifiers: [.stop]),
            "x-on:click.stop",
            "alert('hi')"
        )
        HTMLAttributeAssertEqual(
            .x.on("click", "alert('hi')", modifiers: [.once]),
            "x-on:click.once",
            "alert('hi')"
        )
        HTMLAttributeAssertEqual(
            .x.on("click", "alert('hi')", modifiers: [.selfTarget]),
            "x-on:click.self",
            "alert('hi')"
        )
        HTMLAttributeAssertEqual(
            .x.on("click", "alert('hi')", modifiers: [.capture]),
            "x-on:click.capture",
            "alert('hi')"
        )
    }

    func testOnChainedModifiers() {
        HTMLAttributeAssertEqual(
            .x.on("click", "alert('hi')", modifiers: [.prevent, .stop]),
            "x-on:click.prevent.stop",
            "alert('hi')"
        )
    }

    func testOnKeyboardModifiers() {
        HTMLAttributeAssertEqual(
            .x.on("keyup", "submit()", modifiers: [.enter]),
            "x-on:keyup.enter",
            "submit()"
        )
        HTMLAttributeAssertEqual(
            .x.on("keyup", "close()", modifiers: [.escape]),
            "x-on:keyup.escape",
            "close()"
        )
        HTMLAttributeAssertEqual(
            .x.on("keyup", "next()", modifiers: [.tab]),
            "x-on:keyup.tab",
            "next()"
        )
        HTMLAttributeAssertEqual(
            .x.on("keyup", "...", modifiers: [.capsLock]),
            "x-on:keyup.caps-lock",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on("keyup", "...", modifiers: [.equal]),
            "x-on:keyup.equal",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on("keyup", "...", modifiers: [.period]),
            "x-on:keyup.period",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on("keyup", "...", modifiers: [.comma]),
            "x-on:keyup.comma",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on("keyup", "...", modifiers: [.slash]),
            "x-on:keyup.slash",
            "..."
        )
    }

    func testOnArrowKeys() {
        HTMLAttributeAssertEqual(
            .x.on("keyup", "...", modifiers: [.up]),
            "x-on:keyup.up",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on("keyup", "...", modifiers: [.down]),
            "x-on:keyup.down",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on("keyup", "...", modifiers: [.left]),
            "x-on:keyup.left",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on("keyup", "...", modifiers: [.right]),
            "x-on:keyup.right",
            "..."
        )
    }

    func testOnMouseModifiers() {
        HTMLAttributeAssertEqual(
            .x.on("click", "...", modifiers: [.shift]),
            "x-on:click.shift",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on("click", "...", modifiers: [.ctrl]),
            "x-on:click.ctrl",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on("click", "...", modifiers: [.alt]),
            "x-on:click.alt",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on("click", "...", modifiers: [.meta]),
            "x-on:click.meta",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on("click", "...", modifiers: [.cmd]),
            "x-on:click.cmd",
            "..."
        )
    }

    func testOnScopeModifiers() {
        HTMLAttributeAssertEqual(
            .x.on("keyup", "...", modifiers: [.escape, .window]),
            "x-on:keyup.escape.window",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on("click", "...", modifiers: [.document]),
            "x-on:click.document",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on("click", "...", modifiers: [.outside]),
            "x-on:click.outside",
            "..."
        )
    }

    func testOnPassiveModifiers() {
        HTMLAttributeAssertEqual(
            .x.on("touchstart", "...", modifiers: [.passive]),
            "x-on:touchstart.passive",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on("touchmove", "...", modifiers: [.passiveFalse]),
            "x-on:touchmove.passive.false",
            "..."
        )
    }

    func testOnEventNameHelpers() {
        HTMLAttributeAssertEqual(
            .x.on("custom-event", "...", modifiers: [.camel]),
            "x-on:custom-event.camel",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on("custom-event", "...", modifiers: [.dot]),
            "x-on:custom-event.dot",
            "..."
        )
    }

    func testOnDebounce() {
        HTMLAttributeAssertEqual(
            .x.on("input", "fetch()", modifiers: [.debounce(500)]),
            "x-on:input.debounce.500ms",
            "fetch()"
        )
    }

    func testOnThrottle() {
        HTMLAttributeAssertEqual(
            .x.on("scroll", "handle()", modifiers: [.throttle(750)]),
            "x-on:scroll.throttle.750ms",
            "handle()"
        )
    }

    func testText() {
        HTMLAttributeAssertEqual(.x.text("count"), "x-text", "count")
    }

    func testHtml() {
        HTMLAttributeAssertEqual(.x.html("<div>raw</div>"), "x-html", "<div>raw</div>")
    }

    func testModel() {
        HTMLAttributeAssertEqual(.x.model("search"), "x-model", "search")
    }

    func testModelModifiers() {
        HTMLAttributeAssertEqual(
            .x.model("search", modifiers: [.number]),
            "x-model.number",
            "search"
        )
        HTMLAttributeAssertEqual(
            .x.model("search", modifiers: [.lazy]),
            "x-model.lazy",
            "search"
        )
        HTMLAttributeAssertEqual(
            .x.model("search", modifiers: [.change]),
            "x-model.change",
            "search"
        )
        HTMLAttributeAssertEqual(
            .x.model("search", modifiers: [.blur]),
            "x-model.blur",
            "search"
        )
        HTMLAttributeAssertEqual(
            .x.model("search", modifiers: [.enter]),
            "x-model.enter",
            "search"
        )
        HTMLAttributeAssertEqual(
            .x.model("search", modifiers: [.boolean]),
            "x-model.boolean",
            "search"
        )
        HTMLAttributeAssertEqual(
            .x.model("search", modifiers: [.fill]),
            "x-model.fill",
            "search"
        )
    }

    func testModelChainedModifiers() {
        HTMLAttributeAssertEqual(
            .x.model("search", modifiers: [.change, .blur, .enter]),
            "x-model.change.blur.enter",
            "search"
        )
    }

    func testFor() {
        HTMLAttributeAssertEqual(.x.loop("item in items"), "x-for", "item in items")
    }

    func testTransition() {
        HTMLAttributeAssertEqual(.x.transition(), "x-transition", nil)
    }

    func testTransitionEnter() {
        HTMLAttributeAssertEqual(
            .x.transitionEnter("duration-300 ease-out"),
            "x-transition:enter",
            "duration-300 ease-out"
        )
    }

    func testTransitionEnterStart() {
        HTMLAttributeAssertEqual(
            .x.transitionEnterStart("opacity-0"),
            "x-transition:enter-start",
            "opacity-0"
        )
    }

    func testTransitionEnterEnd() {
        HTMLAttributeAssertEqual(
            .x.transitionEnterEnd("opacity-100"),
            "x-transition:enter-end",
            "opacity-100"
        )
    }

    func testTransitionLeave() {
        HTMLAttributeAssertEqual(
            .x.transitionLeave("duration-200 ease-in"),
            "x-transition:leave",
            "duration-200 ease-in"
        )
    }

    func testTransitionLeaveStart() {
        HTMLAttributeAssertEqual(
            .x.transitionLeaveStart("opacity-100"),
            "x-transition:leave-start",
            "opacity-100"
        )
    }

    func testTransitionLeaveEnd() {
        HTMLAttributeAssertEqual(
            .x.transitionLeaveEnd("opacity-0"),
            "x-transition:leave-end",
            "opacity-0"
        )
    }

    func testTransitionModifiers() {
        HTMLAttributeAssertEqual(
            .x.transition(modifiers: [.opacity]),
            "x-transition.opacity",
            nil
        )
        HTMLAttributeAssertEqual(
            .x.transition(modifiers: [.scale()]),
            "x-transition.scale",
            nil
        )
        HTMLAttributeAssertEqual(
            .x.transition(modifiers: [.scale(80)]),
            "x-transition.scale.80",
            nil
        )
        HTMLAttributeAssertEqual(
            .x.transition(modifiers: [.duration(500)]),
            "x-transition.duration.500ms",
            nil
        )
        HTMLAttributeAssertEqual(
            .x.transition(modifiers: [.delay(50)]),
            "x-transition.delay.50ms",
            nil
        )
        HTMLAttributeAssertEqual(
            .x.transition(modifiers: [.scale(), .origin(.top)]),
            "x-transition.scale.origin.top",
            nil
        )
        HTMLAttributeAssertEqual(
            .x.transition(modifiers: [.scale(80), .origin(.topRight)]),
            "x-transition.scale.80.origin.top.right",
            nil
        )
    }

    func testEffect() {
        HTMLAttributeAssertEqual(.x.effect("console.log(count)"), "x-effect", "console.log(count)")
    }

    func testIgnore() {
        HTMLAttributeAssertEqual(.x.ignore, "x-ignore", nil)
    }

    func testRef() {
        HTMLAttributeAssertEqual(.x.ref("input"), "x-ref", "input")
    }

    func testCloak() {
        HTMLAttributeAssertEqual(.x.cloak, "x-cloak", nil)
    }

    func testTeleport() {
        HTMLAttributeAssertEqual(.x.teleport("body"), "x-teleport", "body")
    }

    func testIf() {
        HTMLAttributeAssertEqual(.x.when("open"), "x-if", "open")
    }

    func testId() {
        HTMLAttributeAssertEqual(.x.id("modal"), "x-id", "modal")
    }

    func testModelable() {
        HTMLAttributeAssertEqual(.x.modelable("value"), "x-modelable", "value")
    }
}

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
