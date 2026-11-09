# Local HTTPS backend

This tool runs the current `../kano` checkout
with an isolated SQLite snapshot and synthetic, time-relative records. The API
is served through a local HTTPS proxy so the iOS app can use the same transport
rules as production.

Prerequisites are Go 1.27 at `/opt/homebrew/bin/go`, Python 3, OpenSSL, curl,
and Xcode's `xcrun simctl`. The service checkout must remain at the path above;
the tool never writes inside it.

Run these commands from the iOS repository:

```sh
Tools/local-backend/local-backend start
Tools/local-backend/local-backend status
Tools/local-backend/local-backend logs
Tools/local-backend/local-backend reseed
Tools/local-backend/local-backend stop
```

The default HTTPS endpoint is `https://localhost:8443`. Set
`KANO_LOCAL_HTTPS_PORT` to use another HTTPS port, and
`KANO_LOCAL_BACKEND_PORT` to change the loopback HTTP port used internally.
State, the private CA and leaf certificate, logs, PIDs, the built binaries,
the isolated `.env`, database, empty static directory and cached PNGs live in
`Tools/local-backend/.state/`.

Point the app at the service by running
`Tools/local-backend/local-backend configure-app`; this writes the ignored
`Config/Local.xcconfig`. Remove it with `unconfigure-app`. The generated CA is
trusted only by booted iOS simulators with:

```sh
Tools/local-backend/local-backend trust-simulators
```

The command uses `xcrun simctl keychain <udid> add-root-cert` and never changes
the macOS login or system keychain. The database contains synthetic titles,
URLs, posts, events, videos, translations and PNG media. `reseed` rebuilds
those records relative to the current Japan time while preserving the server's
schema, so old snapshots intentionally become stale unless reseeded.
