# EDuke32-Tizen

Play Duke Nukem 3D on a Samsung Smart TV running Tizen. EDuke32 is compiled to
WebAssembly and packaged as a Tizen widget (`.wgt`); the freely distributable
Duke Nukem 3D shareware episode is included.

The project is based on **[EDuke32](https://www.eduke32.com/)**, the open-source
Duke Nukem 3D port. This repository adapts it for Tizen TVs and also maintains
the WebAssembly browser build and serverless multiplayer.

## Installation

The Tizen app requires **Tizen 6.1 or later**. The simplest way to install it
is with [Apps2Samsung](https://github.com/Apps2Samsung/Apps2Samsung), which
handles TV discovery, app signing, and installation.

### 1. Enable Developer Mode on the TV

1. Open **Apps** from the TV's Home or Smart Hub screen.
2. Enter `12345` with the remote's number buttons. If the remote has no number
   buttons, use its **123** button and enter the digits on screen.
3. Turn **Developer Mode** on and enter the computer's local IP address as the
   host PC. The computer and TV must be on the same network.
4. Restart the TV.

### 2. Install EDuke32

1. Download the latest `EDuke32-<version>.wgt` from the
   [GitHub Releases](https://github.com/dos-ise/eduke32-tizen/releases/latest)
   page.
2. Install and open the latest
   [Apps2Samsung release](https://github.com/Apps2Samsung/Apps2Samsung/releases/latest)
   on your computer.
3. Select your TV and install the downloaded WGT as a local/custom app.
   Apps2Samsung signs the package for the selected TV and sends it to the TV.
4. Launch **EDuke32** from the TV's Apps screen.

On Tizen 7 or later, Samsung may require signing in to a Samsung developer
account to create the TV's installation certificate. See the
[Apps2Samsung Developer Mode guide](https://github.com/Apps2Samsung/Apps2Samsung/wiki/FAQ#-how-to-enable-developer-mode-on-your-tv)
if the TV cannot be found or the install fails. If the TV does not connect
after a restart, fully power it off and unplug it briefly before trying again.

The WGT is also available for manual installation with Tizen Studio. Manual
installation requires a signing profile and certificate accepted by the TV;
the development certificate used by the build is not a Samsung distribution
certificate.

## Game data

The WGT includes the freely distributable **Duke Nukem 3D shareware 1.3d
episode**, so it can be played after installation. Retail game data is not
included. If you own the full game, import your `DUKE3D.GRP` through the game's
settings panel on a supported build.

## Building the WGT

Requirements: Docker with BuildKit/Buildx enabled.

From the repository root, build and export `dist/EDuke32.wgt`:

```sh
docker buildx build --output type=local,dest=dist .
```

Set the Tizen widget version explicitly when building:

```sh
docker buildx build --build-arg APP_VERSION=1.2.3 --output type=local,dest=dist .
```

The Docker build compiles the Emscripten game and multiplayer bundle, prepares
the Tizen web app, and signs the WGT with a local development certificate.

## GitHub Releases

To publish a release, run **Actions → Release Tizen WGT → Run workflow** on the
desired branch. Enter a numeric version such as `1.2.3` for a regular release.
Leave the version empty to create a timestamped development pre-release. The
workflow writes the version into the Tizen widget manifest and attaches the
resulting WGT to the GitHub release.

## WebAssembly and multiplayer

EDuke32 runs in the browser through Emscripten as well as on Tizen. Its
NetDuke32 multiplayer connects peers directly over WebRTC; public Nostr relays
are used only for signaling and match discovery. Browser and native builds can
play together. For details about the browser transport, see
`platform/emscripten/README-netplay.md`.

## Credit where it's due

This fork is a thin layer on decades of other people's work:

- **[EDuke32](https://www.eduke32.com/)** — the engine itself: the EDuke32
  team's port, renderer, scripting, and years of maintenance. GPL-2.0
  (`source/duke3d/gpl-2.0.txt`) plus the BUILD license
  (`source/build/buildlic.txt`).
- **NetDuke32** (StrikerTheHedgefox) — the revived classic lockstep netcode
  this fork's multiplayer started from.
- **BUILD engine** — Ken Silverman.
- **JFDuke3D** — Jonathon Fowler's foundational source port.
- **Duke Nukem 3D** — 3D Realms. The game, its name, and its retail assets
  remain the property of their copyright holders and are not included here.
