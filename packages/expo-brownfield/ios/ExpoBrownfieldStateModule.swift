import ExpoModulesCore

let KEY_RECREATED_EVENT_NAME = "onKeyRecreated"

// MARK: - ExpoBrownfieldStateModule

public class ExpoBrownfieldStateModule: Module {
  public func definition() -> ModuleDefinition {
    Name("ExpoBrownfieldStateModule")

    Events(KEY_RECREATED_EVENT_NAME)

    Class(SharedState.self) {
      Constructor { (key: String) in
        return SharedState(key)
      }

      Function("get") { (state: SharedState) -> Any? in
        return state.get()
      }
      
      Function("set") { (state: SharedState, value: SharedStateValue) in
        state.set(value.value)
      }
    }

    OnCreate {
      BrownfieldStateInternal.shared.setExpoModule(self)
    }

    OnDestroy {
      BrownfieldStateInternal.shared.clearExpoModule(self)
    }

    Function("getSharedState") { (key: String) -> SharedState in
      return BrownfieldStateInternal.shared.getOrCreate(key)
    }

    Function("deleteSharedState") { (key: String) in
      BrownfieldStateInternal.shared.delete(key)
    }
  }

  public func notifyKeyRecreated(_ key: String) {
    sendEvent(KEY_RECREATED_EVENT_NAME, ["key": key])
  }
}

// MARK: - SharedStateValue

/**
 The raw value passed to `SharedState.set` from JavaScript, converted to its native representation
 (`nil` for `null` and `undefined`). A module definition cannot take a bare `Any?` argument, so the
 value arrives through this `Convertible` wrapper.
 */
struct SharedStateValue: Convertible {
  let value: Any?

  static func convert(from value: Any?, appContext: AppContext) throws -> SharedStateValue {
    return SharedStateValue(value: value)
  }
}
