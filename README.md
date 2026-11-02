# Magi iOS

Native iOS client for [Magi](https://github.com/asukaonly/magi).

## Responsibilities

- Present conversations, personal tasks, and notifications.
- Manage service connections, authentication, local state, and reconnection.
- Integrate iOS permissions, sharing, push notifications, and explicitly authorized device capabilities.

The Magi service owns agent execution, memory, plugins, and authoritative business state.

## Protocol source of truth

The [client–server contract](https://github.com/asukaonly/magi/blob/main/docs/client-server-contract.md)
and [generated schemas](https://github.com/asukaonly/magi/tree/main/contracts/api)
are maintained in the main Magi repository. Keep this client aligned with the current
contract; do not add legacy protocol adapters or independently redefine the wire schemas.

Service plugins are maintained in [magi-plugins](https://github.com/asukaonly/magi-plugins).

## Status

Repository initialized. The iOS application project has not been created yet.
