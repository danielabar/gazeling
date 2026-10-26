import Foundation

public protocol SettingsStore {
  /// Returns the saved settings, or the defaults if nothing valid is saved.
  func load() -> Settings
  func save(_ settings: Settings)
}

/// For tests and previews.
public final class InMemorySettingsStore: SettingsStore {
  private var settings: Settings

  public init(_ settings: Settings = Settings()) {
    self.settings = settings
  }

  public func load() -> Settings { settings }
  public func save(_ settings: Settings) { self.settings = settings }
}

public struct UserDefaultsSettingsStore: SettingsStore {
  private let defaults: UserDefaults
  private let key = "settings"

  public init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }

  public func load() -> Settings {
    guard let data = defaults.data(forKey: key),
      let settings = try? JSONDecoder().decode(Settings.self, from: data)
    else { return Settings() }
    return settings
  }

  public func save(_ settings: Settings) {
    defaults.set(try? JSONEncoder().encode(settings), forKey: key)
  }
}
