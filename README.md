# Magi iOS

Native SwiftUI client for [Magi](https://github.com/asukaonly/magi), for iPhone and
iPad running iOS 17 or later. Built with Swift 6; no third-party runtime dependencies.

## Client features

- Pair to an existing Magi service; keep the device credential in iOS Keychain.
- Browse and create conversations, send text, camera/library images and file attachments, and receive product events with HTTP/SSE.
- Recover delivery through durable local records and exact server confirmations.
- Answer questions and approve or deny one-time tool requests.
- View personal tasks, mark them complete, and read service notifications.
- Read and search memory, inspect supporting events, correct facts, and explicitly forget events.
- Browse the extension marketplace, review package permissions, install/update and authorize service plugins.
- Read Apple Health steps, sleep and workouts through the bundled native collector; preview before sending.
- Keep recent conversations available offline; resume synchronization in the foreground.
- English and Simplified Chinese, with native accessibility and system appearance.

The service owns execution, memory, business state, and plugins. This application
does not load service plugins or start a local backend. APNs, Share Extension,
microphone capture and automatic background delivery are not implemented. Notifications are the service inbox, refreshed while the app is open.
Images use multipart uploads and attachment IDs, with authenticated inline/fullscreen
previews. Camera/library images are resized to 2560 pixels and encoded as JPEG without
location metadata; up to eight attachments can accompany text or be sent alone.
Generic files are uploaded from Files and displayed by name. Task creation/editing and the full desktop settings UI are
also outside this slice.

## Open and run

1. Open `MagiIOS.xcodeproj` in Xcode 16 or later (validated with Xcode 27.2).
2. Select the **MagiIOS** scheme and an iPhone or iPad simulator, then Run.
3. Tap **Get started** on the welcome screen, then enter the service address and
   a fresh pairing code from Magi's device access settings (or
   `magi-server pair --config <server.json> --json`). The separate pairing screen
   keeps its fields in place when focus changes.

Copy the complete service address, including its port. The desktop development
page at port 5173 is not the service. A local desktop service may select a different
port after restarting, and a code only works on the service that generated it.

For a physical device, select your own development team under Signing & Capabilities
and use a reachable HTTPS service with a trusted certificate. Loopback HTTP is only
for local development; `127.0.0.1` on a physical phone does not reach your Mac.
The service needs its core model configuration before it can accept chat messages.

Do not disable code signing when *running* the simulator app: Keychain access needs
the normal simulator signing step. An unsigned build is useful only as a compile check.

## Boundaries

```text
SwiftUI screens + AppStore
        │
        ├── Keychain: device credential
        ├── LocalState: protected cache and pending turns
        │
     MagiCore: generated DTOs, validation, HTTP, SSE, recovery
        │ HTTPS / product events
        ▼
     Magi service: authoritative state, agents, memory, plugins
```

The [client–server contract](https://github.com/asukaonly/magi/blob/main/docs/client-server-contract.md)
belongs to the main repository. `Contracts/source.json` pins the exact source
commit and SHA-256; `scripts/sync-contract.py` imports its committed product export.
Generated Swift models and the bundled schema must stay synchronized. There are
no protocol downgrade paths or legacy adapters.

Connection credentials never enter URLs or the transcript cache. The client
refuses redirects, enforces HTTPS outside loopback, and checks the paired server
identity. The local journal is excluded from backups and uses iOS file protection.
Pending sends preserve their original payload, turn ID, and service data epoch.
After an ambiguous result, a retry checks the exact server receipt first.
Messages from an earlier service data epoch remain visible but cannot be retried.

## Apple Health and third-party extensions

Marketplace packages run on the Magi service. Their Python `platforms` describe
service hosts; `device_collectors` declare required native capabilities separately.
The iOS executable bundles the HealthKit collector for `apple_health.observe` /
`source.change.v1` / `apple_health.record` version 1. Installing a service package
never downloads Swift code or extends iOS entitlements. This release registers the official Apple Health adapter. The descriptor contract
allows future adapters to be matched explicitly; adding native capabilities requires
an app update. Third-party service packages remain installable through the marketplace.

The first Health flow installs and authorizes the service package, obtains explicit
processing consent, then asks HealthKit for read permission. Choose steps, sleep,
and/or workouts and a seven- or thirty-day initial range. Records stay local until
Send. The app explains that configured external models may process shared records.
HealthKit does not disclose whether individual read permissions were denied; an
empty read is never presented as proof of authorization or deletion.

The collector uses anchored changes for sleep/workouts and deduplicated daily step
statistics. A protected, backup-excluded journal persists checkpoints together with
exact pending observations. A separate Keychain credential is scoped to this
connection. Receipts, producer sequences, data epochs and connection epochs prevent
lost acknowledgements from creating duplicate events or replaying cleared data.
Collection is manual and delivery only continues while the app is in the foreground.
The Send result means durable service admission; memory processing follows separately.

Pause stops subsequent sends and retains queued work. Clear sync data discards
pending work and service retained content, while preserving imported memory under
the existing service policy. Source deletion retires the source record; it does not
mean user forgetting. Use the Memory page to forget an imported event and invalidate
its derived memories. Neither action changes records in Apple Health.

## Verification

```sh
python3 scripts/generate-contract.py --check
python3 scripts/check-localizations.py
swift test --package-path Packages/MagiCore

# Requires a built main-repository magi-server and its development dependencies.
python3 scripts/test-real-service.py --magi ../magi --executable ../magi/target/debug/magi-server

# Starts and stops a loopback-only test fixture; does not use personal service data.
scripts/test-ui.sh

# Optional network-dependent integration: installs the official package into the
# isolated temporary service and sends synthetic health records only.
python3 scripts/test-real-service.py --magi ../magi --executable ../magi/target/debug/magi-server --health
```

The real-service test checks pairing, session creation/idempotency, history,
confirmation, SSE, image/file upload, draft-image access protection, memory, plugin,
task/notification reads, and retirement. It deliberately
has no model key and verifies the model-setup rejection; it does not prove a real
model reply. UI tests use an explicit test-only HTTP fixture to cover the complete
screen flows, lost acknowledgement without duplicate dispatch, Keychain restore,
foreground return, service outage and recovery with a retained draft, and both languages. The health integration verifies marketplace install, trust,
connection creation, collector grants/claims, replay-safe admission, visible memory,
source deletion admission, pause/cache clear and explicit memory forgetting.
Physical-device HealthKit permission/data reads, camera capture, APNs, real model
inference, and App Store/TestFlight acceptance have not been validated.

No GitHub Actions packaging, signing or automatic iOS build workflow is configured;
verification runs locally.

The checked-in Xcode project opens without generators. If membership changes,
`ruby scripts/generate-project.rb` regenerates it using the `xcodeproj` gem (1.27).

## Repository layout

- `MagiIOS/`: application, secure credential storage, screens, localization, assets.
- `Packages/MagiCore/`: portable Swift service boundary and recovery tests.
- `Contracts/`: pinned service contract and provenance.
- `MagiIOSUITests/`, `scripts/`: UI verification, contract generation, real-service smoke test.
