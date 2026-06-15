import Elementary

public enum AlpineGlobals {
    case data
    case store
    case bind
}

public func registerGlobal(_ kind: AlpineGlobals, on: String, action: String) -> some HTML {
    let method: String
    switch kind {
    case .data: method = "data"
    case .store: method = "store"
    case .bind: method = "bind"
    }
    return script {
        HTMLRaw("document.addEventListener('alpine:init', () => { Alpine.\(method)('\(on)', \(action)) })")
    }
}
