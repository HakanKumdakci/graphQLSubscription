//
//  ApolloNetwork.swift
//  ExampleGraphQLSubscription
//
//  Created by Hakan Kumdakçı on 27.08.2021.
//

import Foundation
import Apollo


// MARK: - Singleton Wrapper

class Apollo {
  static let shared = Apollo()
    
  /// A web socket transport to use for subscriptions
  private lazy var webSocketTransport: WebSocketTransport = {
    let url = URL(string: "ws://localhost:8080/websocket")!
    let request = URLRequest(url: url)
    let webSocketClient = WebSocket(request: request)
    return WebSocketTransport(websocket: webSocketClient)
  }()
  
  /// An HTTP transport to use for queries and mutations
  private lazy var normalTransport: RequestChainNetworkTransport = {
    let url = URL(string: "http://localhost:8080/graphql")!
    return RequestChainNetworkTransport(interceptorProvider: DefaultInterceptorProvider(store: self.store), endpointURL: url)
  }()

  /// A split network transport to allow the use of both of the above
  /// transports through a single `NetworkTransport` instance.
  private lazy var splitNetworkTransport = SplitNetworkTransport(
    uploadingNetworkTransport: self.normalTransport,
    webSocketNetworkTransport: self.webSocketTransport
  )

  /// Create a client using the `SplitNetworkTransport`.
  private(set) lazy var client = ApolloClient(networkTransport: self.splitNetworkTransport, store: self.store)

  /// A common store to use for `normalTransport` and `client`.
  private lazy var store = ApolloStore()
}
