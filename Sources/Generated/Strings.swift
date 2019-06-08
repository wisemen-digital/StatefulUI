// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum StatefulUIStrings {

  public enum Button {
    /// Refresh
    public static let refresh = StatefulUIStrings.tr("Localizable", "button.refresh")
  }

  public enum Message {
    /// There was an issue fetching the data. Please check your internet connection and try again.
    public static let error = StatefulUIStrings.tr("Localizable", "message.error")
    /// Loading…
    public static let loading = StatefulUIStrings.tr("Localizable", "message.loading")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension StatefulUIStrings {
  private static func tr(_ table: String, _ key: String) -> String {
    return NSLocalizedString(key, tableName: table, bundle: .resources, comment: "")
  }

  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: .resources, comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}

