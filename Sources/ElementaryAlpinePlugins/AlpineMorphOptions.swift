public struct MorphOptions {
    public var updating: String?
    public var updated: String?
    public var removing: String?
    public var removed: String?
    public var adding: String?
    public var added: String?
    public var key: String?
    public var lookahead: Bool = false

    public init() {}

    public func updating(_ js: String) -> MorphOptions {
        var copy = self
        copy.updating = js
        return copy
    }

    public static func updating(_ js: String) -> MorphOptions {
        MorphOptions().updating(js)
    }
    public static func updated(_ js: String) -> MorphOptions {
        MorphOptions().updated(js)
    }
    public static func removing(_ js: String) -> MorphOptions {
        MorphOptions().removing(js)
    }
    public static func removed(_ js: String) -> MorphOptions {
        MorphOptions().removed(js)
    }
    public static func adding(_ js: String) -> MorphOptions {
        MorphOptions().adding(js)
    }
    public static func added(_ js: String) -> MorphOptions {
        MorphOptions().added(js)
    }
    public static func key(_ js: String) -> MorphOptions {
        MorphOptions().key(js)
    }
    public static func lookahead(_ enabled: Bool = true) -> MorphOptions {
        var opts = MorphOptions()
        opts.lookahead = enabled
        return opts
    }

    public func updated(_ js: String) -> MorphOptions {
        var copy = self
        copy.updated = js
        return copy
    }

    public func removing(_ js: String) -> MorphOptions {
        var copy = self
        copy.removing = js
        return copy
    }

    public func removed(_ js: String) -> MorphOptions {
        var copy = self
        copy.removed = js
        return copy
    }

    public func adding(_ js: String) -> MorphOptions {
        var copy = self
        copy.adding = js
        return copy
    }

    public func added(_ js: String) -> MorphOptions {
        var copy = self
        copy.added = js
        return copy
    }

    public func key(_ js: String) -> MorphOptions {
        var copy = self
        copy.key = js
        return copy
    }

    public func lookahead(_ enabled: Bool = true) -> MorphOptions {
        var copy = self
        copy.lookahead = enabled
        return copy
    }

    func toJS() -> String {
        var parts: [String] = []
        if let updating = updating {
            parts.append("updating(el, toEl, childrenOnly, skip) { \(updating) }")
        }
        if let updated = updated {
            parts.append("updated(el, toEl) { \(updated) }")
        }
        if let removing = removing {
            parts.append("removing(el, skip) { \(removing) }")
        }
        if let removed = removed {
            parts.append("removed(el) { \(removed) }")
        }
        if let adding = adding {
            parts.append("adding(el, skip) { \(adding) }")
        }
        if let added = added {
            parts.append("added(el) { \(added) }")
        }
        if let key = key {
            parts.append("key: \(key)")
        }
        if lookahead {
            parts.append("lookahead: true")
        }
        return parts.isEmpty ? "" : "{ \(parts.joined(separator: ", ")) }"
    }
}
