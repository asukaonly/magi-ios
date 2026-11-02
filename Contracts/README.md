# Product contract snapshot

`product-api.json` is exported by the main Magi repository from its reachable
product routes, native gateway contracts, and product event schemas. `source.json`
records the exact source commit and SHA-256. It is not an independent API definition.

Refresh only from a committed main-repository export:

```sh
python3 scripts/sync-contract.py --source ../magi
python3 scripts/generate-contract.py --check
```

The generator produces Codable projections and bundles the same schema in
`MagiCore`. The runtime validates responses and product SSE frames against that
schema before decoding. Free-form owner schemas remain `JSONValue`; endpoint
consumers validate the fields they need. Protocol version checks are exact.
