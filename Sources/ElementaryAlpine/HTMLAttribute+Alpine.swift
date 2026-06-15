import Elementary

extension HTMLAttribute where Tag: HTMLTrait.Attributes.Global {
    /// A namespace for AlpineJS attributes.
    /// See the [AlpineJS reference](https://alpinejs.dev/) for more information.
    public enum x {}
}

extension HTMLAttribute.x {
    public static func data(_ value: String) -> HTMLAttribute {
        .init(name: "x-data", value: value)
    }

    public static func `init`(_ value: String) -> HTMLAttribute {
        .init(name: "x-init", value: value)
    }

    public static func show(_ value: String) -> HTMLAttribute {
        .init(name: "x-show", value: value)
    }

    public static func bind(_ attribute: String, _ value: String) -> HTMLAttribute {
        .init(name: "x-bind:\(attribute)", value: value)
    }

    public static func bind(_ value: String) -> HTMLAttribute {
        .init(name: "x-bind", value: value)
    }

    public static func bindClass(_ value: HTMLAttributeValue.Alpine.BindClass) -> HTMLAttribute {
        .init(name: "x-bind:class", value: value.rawValue)
    }

    public static func bindStyle(_ value: HTMLAttributeValue.Alpine.BindStyle) -> HTMLAttribute {
        .init(name: "x-bind:style", value: value.rawValue)
    }

    public static func on(_ modifier: HTMLAttributeValue.Alpine.OnModifier, _ value: String) -> HTMLAttribute {
        .init(name: "x-on:\(modifier.rawValue)", value: value)
    }

    public static func on(_ event: String, _ value: String) -> HTMLAttribute {
        .init(name: "x-on:\(event)", value: value)
    }

    public static func text(_ value: String) -> HTMLAttribute {
        .init(name: "x-text", value: value)
    }

    public static func html(_ value: String) -> HTMLAttribute {
        .init(name: "x-html", value: value)
    }

    public static func model(_ value: String) -> HTMLAttribute {
        .init(name: "x-model", value: value)
    }
}
