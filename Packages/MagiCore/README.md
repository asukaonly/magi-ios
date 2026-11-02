# MagiCore

A Foundation-only client boundary for iOS 17+ and macOS 14+. No third-party runtime
dependencies. Swift 6 concurrency checking is enabled.

- `Wire`: generated Codable projections of the pinned service contract.
- `Contract`: validation against the bundled source JSON Schema.
- `MagiClient`: pairing, short-lived access renewal, product HTTP and SSE.
- `EventStream`: bounded frames, server identity, sequence and epoch recovery.
- `LocalState` / `TurnDelivery`: atomic device-local journal, data-generation
  fencing, and exact server confirmation before retrying a previously attempted turn.

Credentials must be provided by the host's secure store. They are never persisted
in the journal. Redirects are refused and HTTP is limited to loopback development.
POST requests are never automatically replayed on authentication failure. Sending
is journaled before dispatch and retries use the original turn identity and payload.

```sh
swift test --package-path Packages/MagiCore
```

The unit tests inject a transport. They prove protocol handling and delivery
recovery, not a live model response or a deployed service connection.
