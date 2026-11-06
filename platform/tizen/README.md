# Building the Tizen TV WGT

The root `Dockerfile` builds the Emscripten game, multiplayer transport bundle,
and signed Tizen Web application package. It uses the shareware game data
already included in this repository.

With Docker Buildx and BuildKit enabled, run this from the repository root:

```sh
docker buildx build --output type=local,dest=dist .
```

The result is `dist/EDuke32.wgt`. To target another Emscripten SDK release or
Tizen Studio installer version, pass `--build-arg EMSDK_VERSION=...` or
`--build-arg TIZEN_STUDIO_VERSION=...`.

The generated package uses a local development signing certificate with the
password `1234`, matching the signing flow in the Doom Tizen reference
Dockerfile. For installation on a Samsung TV, use a signing profile and
distributor certificate accepted by that TV; the local certificate may need
to be replaced with your Samsung TV certificate profile.

The Tizen application targets Tizen 6.1 or later and uses the icon in
`platform/tizen/icon.png`. The packaged JavaScript is transpiled for older TV
Chromium versions, and WebAssembly BigInt integration is disabled for browser
compatibility. The regular hosted web build is unchanged.
