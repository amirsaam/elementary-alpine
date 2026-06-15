import Elementary

public extension HTMLAttributeValue {
    /// A namespace for AlpineJS attribute value types.
    /// See the [AlpineJS reference](https://alpinejs.dev/) for more information.
    enum Alpine {}
}

public extension HTMLAttributeValue.Alpine {
    struct BindClass: RawRepresentable, ExpressibleByStringLiteral {
        public var rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(stringLiteral value: String) {
            rawValue = value
        }
    }

    struct BindStyle: RawRepresentable, ExpressibleByStringLiteral {
        public var rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(stringLiteral value: String) {
            rawValue = value
        }
    }

    struct OnModifier: RawRepresentable {
        public var rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public init(event: String) {
            rawValue = event
        }
    }

    struct ModelModifier {
        var property: String
        var modifiers: String

        public init(property: String) {
            self.property = property
            self.modifiers = ""
        }
    }
}

public extension HTMLAttributeValue.Alpine.OnModifier {
    consuming func prevent() -> Self {
        appending(modifier: "prevent")
    }

    consuming func stop() -> Self {
        appending(modifier: "stop")
    }

    consuming func once() -> Self {
        appending(modifier: "once")
    }

    consuming func `self`() -> Self {
        appending(modifier: "self")
    }

    consuming func capture() -> Self {
        appending(modifier: "capture")
    }

    consuming func shift() -> Self {
        appending(modifier: "shift")
    }

    consuming func ctrl() -> Self {
        appending(modifier: "ctrl")
    }

    consuming func alt() -> Self {
        appending(modifier: "alt")
    }

    consuming func meta() -> Self {
        appending(modifier: "meta")
    }

    consuming func cmd() -> Self {
        appending(modifier: "cmd")
    }

    consuming func enter() -> Self {
        appending(modifier: "enter")
    }

    consuming func escape() -> Self {
        appending(modifier: "escape")
    }

    consuming func space() -> Self {
        appending(modifier: "space")
    }

    consuming func tab() -> Self {
        appending(modifier: "tab")
    }

    consuming func capsLock() -> Self {
        appending(modifier: "caps-lock")
    }

    consuming func up() -> Self {
        appending(modifier: "up")
    }

    consuming func down() -> Self {
        appending(modifier: "down")
    }

    consuming func left() -> Self {
        appending(modifier: "left")
    }

    consuming func right() -> Self {
        appending(modifier: "right")
    }

    consuming func window() -> Self {
        appending(modifier: "window")
    }

    consuming func document() -> Self {
        appending(modifier: "document")
    }

    consuming func outside() -> Self {
        appending(modifier: "outside")
    }

    consuming func passive() -> Self {
        appending(modifier: "passive")
    }

    consuming func `passiveFalse`() -> Self {
        appending(modifier: "passive.false")
    }

    consuming func camel() -> Self {
        appending(modifier: "camel")
    }

    consuming func dot() -> Self {
        appending(modifier: "dot")
    }

    consuming func debounce(_ duration: String? = nil) -> Self {
        appending(modifier: "debounce", value: duration)
    }

    consuming func throttle(_ duration: String? = nil) -> Self {
        appending(modifier: "throttle", value: duration)
    }

    internal consuming func appending(modifier: String, value: String? = nil) -> Self {
        rawValue += "."
        rawValue += modifier
        if let value {
            rawValue += "."
            rawValue += value
        }
        return self
    }
}

public extension HTMLAttributeValue.Alpine.ModelModifier {
    consuming func debounce(_ duration: String? = nil) -> Self {
        appending(modifier: "debounce", value: duration)
    }

    consuming func number() -> Self {
        appending(modifier: "number")
    }

    consuming func `defer`() -> Self {
        appending(modifier: "defer")
    }

    consuming func lazy() -> Self {
        appending(modifier: "lazy")
    }

    consuming func fill() -> Self {
        appending(modifier: "fill")
    }

    internal consuming func appending(modifier: String, value: String? = nil) -> Self {
        if !modifiers.isEmpty {
            modifiers += "."
        }
        modifiers += modifier
        if let value {
            modifiers += "."
            modifiers += value
        }
        return self
    }
}
