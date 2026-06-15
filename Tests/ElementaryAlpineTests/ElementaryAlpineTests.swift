import Elementary
import ElementaryAlpine
import TestUtilities
import XCTest

final class ElementaryAlpineTests: XCTestCase {
    func testData() {
        HTMLAttributeAssertEqual(.x.data("{ count: 0 }"), "x-data", "{ count: 0 }")
    }

    func testInit() {
        HTMLAttributeAssertEqual(.x.`init`("count = 1"), "x-init", "count = 1")
    }

    func testShow() {
        HTMLAttributeAssertEqual(.x.show("open"), "x-show", "open")
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
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "click").prevent(), "alert('hi')"),
            "x-on:click.prevent",
            "alert('hi')"
        )
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "click").stop(), "alert('hi')"),
            "x-on:click.stop",
            "alert('hi')"
        )
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "click").once(), "alert('hi')"),
            "x-on:click.once",
            "alert('hi')"
        )
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "click").`self`(), "alert('hi')"),
            "x-on:click.self",
            "alert('hi')"
        )
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "click").capture(), "alert('hi')"),
            "x-on:click.capture",
            "alert('hi')"
        )
    }

    func testOnChainedModifiers() {
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "click").prevent().stop(), "alert('hi')"),
            "x-on:click.prevent.stop",
            "alert('hi')"
        )
    }

    func testOnKeyboardModifiers() {
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "keyup").enter(), "submit()"),
            "x-on:keyup.enter",
            "submit()"
        )
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "keyup").escape(), "close()"),
            "x-on:keyup.escape",
            "close()"
        )
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "keyup").tab(), "next()"),
            "x-on:keyup.tab",
            "next()"
        )
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "keyup").capsLock(), "..."),
            "x-on:keyup.caps-lock",
            "..."
        )
    }

    func testOnArrowKeys() {
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "keyup").up(), "..."),
            "x-on:keyup.up",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "keyup").down(), "..."),
            "x-on:keyup.down",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "keyup").left(), "..."),
            "x-on:keyup.left",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "keyup").right(), "..."),
            "x-on:keyup.right",
            "..."
        )
    }

    func testOnMouseModifiers() {
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "click").shift(), "..."),
            "x-on:click.shift",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "click").ctrl(), "..."),
            "x-on:click.ctrl",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "click").alt(), "..."),
            "x-on:click.alt",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "click").meta(), "..."),
            "x-on:click.meta",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "click").cmd(), "..."),
            "x-on:click.cmd",
            "..."
        )
    }

    func testOnScopeModifiers() {
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "keyup").escape().window(), "..."),
            "x-on:keyup.escape.window",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "click").document(), "..."),
            "x-on:click.document",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "click").outside(), "..."),
            "x-on:click.outside",
            "..."
        )
    }

    func testOnPassiveModifiers() {
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "touchstart").passive(), "..."),
            "x-on:touchstart.passive",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "touchmove").passiveFalse(), "..."),
            "x-on:touchmove.passive.false",
            "..."
        )
    }

    func testOnEventNameHelpers() {
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "custom-event").camel(), "..."),
            "x-on:custom-event.camel",
            "..."
        )
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "custom-event").dot(), "..."),
            "x-on:custom-event.dot",
            "..."
        )
    }

    func testOnDebounce() {
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "input").debounce(), "fetch()"),
            "x-on:input.debounce",
            "fetch()"
        )
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "input").debounce("500ms"), "fetch()"),
            "x-on:input.debounce.500ms",
            "fetch()"
        )
    }

    func testOnThrottle() {
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "scroll").throttle(), "handle()"),
            "x-on:scroll.throttle",
            "handle()"
        )
        HTMLAttributeAssertEqual(
            .x.on(HTMLAttributeValue.Alpine.OnModifier(event: "scroll").throttle("750ms"), "handle()"),
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
            .x.model(HTMLAttributeValue.Alpine.ModelModifier(property: "search").number()),
            "x-model.number",
            "search"
        )
        HTMLAttributeAssertEqual(
            .x.model(HTMLAttributeValue.Alpine.ModelModifier(property: "search").debounce()),
            "x-model.debounce",
            "search"
        )
        HTMLAttributeAssertEqual(
            .x.model(HTMLAttributeValue.Alpine.ModelModifier(property: "search").debounce("300ms")),
            "x-model.debounce.300ms",
            "search"
        )
        HTMLAttributeAssertEqual(
            .x.model(HTMLAttributeValue.Alpine.ModelModifier(property: "search").`defer`()),
            "x-model.defer",
            "search"
        )
        HTMLAttributeAssertEqual(
            .x.model(HTMLAttributeValue.Alpine.ModelModifier(property: "search").lazy()),
            "x-model.lazy",
            "search"
        )
        HTMLAttributeAssertEqual(
            .x.model(HTMLAttributeValue.Alpine.ModelModifier(property: "search").fill()),
            "x-model.fill",
            "search"
        )
    }

    func testModelChainedModifiers() {
        HTMLAttributeAssertEqual(
            .x.model(HTMLAttributeValue.Alpine.ModelModifier(property: "search").number().debounce("300ms")),
            "x-model.number.debounce.300ms",
            "search"
        )
    }

    func testFor() {
        HTMLAttributeAssertEqual(.x.`for`("item in items"), "x-for", "item in items")
    }

    func testTransition() {
        HTMLAttributeAssertEqual(.x.transition, "x-transition", nil)
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

    func testTransitionScale() {
        HTMLAttributeAssertEqual(.x.transitionScale, "x-transition.scale", nil)
    }

    func testTransitionOpacity() {
        HTMLAttributeAssertEqual(.x.transitionOpacity, "x-transition.opacity", nil)
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
        HTMLAttributeAssertEqual(.x.`if`("open"), "x-if", "open")
    }

    func testId() {
        HTMLAttributeAssertEqual(.x.id("modal"), "x-id", "modal")
    }

    func testModelable() {
        HTMLAttributeAssertEqual(.x.modelable("value"), "x-modelable", "value")
    }
}
