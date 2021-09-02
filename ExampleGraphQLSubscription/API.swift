// @generated
//  This file was automatically generated and should not be edited.

import Apollo
import Foundation

public final class TrackCoinSubscription: GraphQLSubscription {
  /// The raw GraphQL definition of this operation.
  public let operationDefinition: String =
    """
    subscription trackCoin($ep: Int!) {
      bookTitleChanged(input: $ep) {
        __typename
        id
        title
      }
    }
    """

  public let operationName: String = "trackCoin"

  public var ep: Int

  public init(ep: Int) {
    self.ep = ep
  }

  public var variables: GraphQLMap? {
    return ["ep": ep]
  }

  public struct Data: GraphQLSelectionSet {
    public static let possibleTypes: [String] = ["Subscription"]

    public static var selections: [GraphQLSelection] {
      return [
        GraphQLField("bookTitleChanged", arguments: ["input": GraphQLVariable("ep")], type: .object(BookTitleChanged.selections)),
      ]
    }

    public private(set) var resultMap: ResultMap

    public init(unsafeResultMap: ResultMap) {
      self.resultMap = unsafeResultMap
    }

    public init(bookTitleChanged: BookTitleChanged? = nil) {
      self.init(unsafeResultMap: ["__typename": "Subscription", "bookTitleChanged": bookTitleChanged.flatMap { (value: BookTitleChanged) -> ResultMap in value.resultMap }])
    }

    public var bookTitleChanged: BookTitleChanged? {
      get {
        return (resultMap["bookTitleChanged"] as? ResultMap).flatMap { BookTitleChanged(unsafeResultMap: $0) }
      }
      set {
        resultMap.updateValue(newValue?.resultMap, forKey: "bookTitleChanged")
      }
    }

    public struct BookTitleChanged: GraphQLSelectionSet {
      public static let possibleTypes: [String] = ["Book"]

      public static var selections: [GraphQLSelection] {
        return [
          GraphQLField("__typename", type: .nonNull(.scalar(String.self))),
          GraphQLField("id", type: .nonNull(.scalar(Int.self))),
          GraphQLField("title", type: .nonNull(.scalar(String.self))),
        ]
      }

      public private(set) var resultMap: ResultMap

      public init(unsafeResultMap: ResultMap) {
        self.resultMap = unsafeResultMap
      }

      public init(id: Int, title: String) {
        self.init(unsafeResultMap: ["__typename": "Book", "id": id, "title": title])
      }

      public var __typename: String {
        get {
          return resultMap["__typename"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "__typename")
        }
      }

      public var id: Int {
        get {
          return resultMap["id"]! as! Int
        }
        set {
          resultMap.updateValue(newValue, forKey: "id")
        }
      }

      public var title: String {
        get {
          return resultMap["title"]! as! String
        }
        set {
          resultMap.updateValue(newValue, forKey: "title")
        }
      }
    }
  }
}
