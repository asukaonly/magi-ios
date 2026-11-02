# Magi iOS development

- The main Magi repository owns the wire protocol. Read `Contracts/source.json` and `README.md` before changing the client boundary.
- Synchronize committed schemas with `python3 scripts/sync-contract.py --source ../magi`. Never hand-edit generated models or bundled schemas.
- Support only the current service contract. Do not add compatibility adapters or protocol downgrade paths.
- Keep credentials in Keychain, never logs, URLs, UserDefaults, or cached transcript files.
- Keep server execution, memory processing, and plugin loading on the service.
- User-visible copy must have English and Simplified Chinese localizations.
- Validate core behavior with `swift test --package-path Packages/MagiCore` and build the app for an iOS simulator before delivery. Use targeted UI tests for changed flows.
- Keep commits atomic and use English Conventional Commit subjects. Push only when requested.
