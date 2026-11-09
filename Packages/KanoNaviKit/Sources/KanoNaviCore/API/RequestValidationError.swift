import Foundation

public enum RequestValidationError: Error, Equatable, Sendable {
  case invalidDateRange
  case invalidPage
  case invalidPageSize
  case invalidCategory
  case invalidAccount
}
