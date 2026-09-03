/*:
 # Welcome to TWSAPI

  **TWSAPI** is an async/await Swift wrapper for Interactive Brokers' Trader Workstation (TWS) and IB Gateway. It provides a native, type-safe Swift interface built on Swift Concurrency for handling market data, account updates, and orders. Before running these playground pages:
  - Open **Trader Workstation (TWS)** or **IB Gateway**.
  - Navigate to `Global Configuration` > `API` > `Settings`.
  - Check `Enable ActiveX and Socket Clients`.
 
 
  ### Connection
`Connection` is the client's entry point, built on SwiftNIO. Create one with a `Connection.Configuration` (host, port, client id), then call `try await api.connect()` / `try await api.disconnect()` to manage the session. `api.serviceStatus` reflects the connection's live state, including the market/historical data farm status messages TWS sends after connecting — check it rather than treating those as errors.
 
 TWS accepts several simultaneous client connections (each needs its own client id). Whether to split work across dedicated connections — one for market data, one for historical data, one for account data/orders — depends on your trading universe size and expected message load: a single connection keeps things simple and works fine for modest use, while separating high-volume streams (e.g. market data across a large universe) from lower-frequency ones (account/order flow) can avoid one task's message loop drowning out another's, and avoids needing extra `reqID` bookkeeping to disambiguate. Either way, splitting across connections buys you cleaner routing, not a bigger quota — market data lines and pacing limits are enforced by TWS per session/account, shared across every connected client.

 
  ### Requests
 Every operation — contract lookup, market data, historical data, account/position/PnL subscriptions — is a typed `Request` struct (`IBPBContractDataRequest`, `IBPBMarketDataRequest`, etc.) carrying a `reqID`. Build one, set its `reqID`, and send it with `try await api.sendRequest(_:)`.

   **Request IDs**: there are two kinds, and they're not interchangeable in meaning even though both are `Int32`:
   - **Generic request IDs** (market data, contract details, historical data, account/position/PnL requests) are chosen freely by your client and may repeat — any value you haven't reused for a still-open request works.
   - **Order IDs** must be strictly increasing and come from `nextValidId` (exposed here as `api.nextOrderID()`).

  - Note: the examples in this playground source every `reqID` — including non-order requests — from `api.nextOrderID()`. That works, but don't read it as a requirement; a locally-managed counter is equally correct for generic requests.

 
### Responses
 `api.messages()` delivers a stream of typed `Response` cases (`.contractDetails`, `.marketData`, `.accountUpdate`, `.error`, …), each tagged with the `reqID` of the request it answers. It's a per-connection stream with a single consumer in mind — always check a message's `reqID` against the request you're tracking before acting on it, since more than one request of the same kind can be in flight on the same connection.

 
 ### Contents:
 1. [Welcome](1.%20Welcome)
 2. [Contracts](2.%20Contracts)
 3. [Historic Data](3.%20Historical%20Data)
 4. [Live Data](4.%20Live%20Data)
 5. [Account Updates](5.%20Account%20Updates)

 */
