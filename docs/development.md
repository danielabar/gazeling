# Development

## Build, test, run

`make` has short names for the scripts. Run `make help` to list them.

```sh
make test    # scripts/test.sh: GazelingKit unit tests
make build   # scripts/build.sh: generate the Xcode project and build
make run     # scripts/run.sh: build and launch
make demo    # scripts/demo.sh: build and launch with short timers (break within 30 s)
make inspect # build and launch with no automatic breaks; start them from the Debug menu items
make stop    # quit the running app
make logs    # app log from the last 5 minutes
```

## Logs

Mac apps log to the system log, not to files in the project. The sandboxed app cannot write into the project folder, so there is no `logs/` directory. Code logs with `os.Logger` (subsystem `com.danielabar.gazeling`).

Read recent logs from the terminal (use the full path, because `log` is shadowed by a zsh builtin):

```sh
/usr/bin/log show --last 5m --predicate 'subsystem == "com.danielabar.gazeling"' --style compact
/usr/bin/log stream --predicate 'subsystem == "com.danielabar.gazeling"'   # live
```

Console.app shows the same logs (search for `com.danielabar.gazeling`).

## Seeing a break without waiting 20 minutes

Debug builds (what `scripts/run.sh` makes) have these items at the bottom of the menu bar menu: "Debug: start short break", "Debug: start long break", "Debug: play exercise" (a submenu: pick any exercise and it plays at once, for its own length) and "Debug: goodbye wave (4 s)". They also accept launch arguments, in seconds. Overrides are not saved to the user's settings.

```sh
APP=$(xcodebuild -project Gazeling.xcodeproj -scheme Gazeling -showBuildSettings | awk '/ BUILT_PRODUCTS_DIR/{print $3}')/Gazeling.app
open "$APP" --args --short-interval 30 --heads-up 10 --short-duration 20
```

Flags: `--no-auto-breaks` (no scheduled breaks at all, only the Debug menu), `--short-interval`, `--short-duration`, `--long-interval`, `--long-duration`, `--heads-up`, `--break-now`.
