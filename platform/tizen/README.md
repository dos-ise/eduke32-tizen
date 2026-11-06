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
`--build-arg TIZEN_STUDIO_VERSION=...`. Set the widget's version with
`--build-arg APP_VERSION=1.2.3`; it is written to the `version` attribute in
`config.xml` inside the WGT.

To publish a GitHub Release, run **Actions → Release Tizen WGT → Run workflow**.
Enter a numeric version such as `1.2.3` for a regular release, or leave it empty
to create a timestamped development pre-release. The workflow builds a WGT with
that version in its Tizen manifest and attaches it to the release.

The generated package uses a local development signing certificate with the
password `1234`, matching the signing flow in the Doom Tizen reference
Dockerfile. For installation on a Samsung TV, use a signing profile and
distributor certificate accepted by that TV; the local certificate may need
to be replaced with your Samsung TV certificate profile.

The Tizen application targets Tizen 6.1 or later and uses the icon in
`platform/tizen/icon.png`. The packaged JavaScript is transpiled for older TV
Chromium versions, and WebAssembly BigInt integration is disabled for browser
compatibility. The regular hosted web build is unchanged.
