# Development

## Build, test, run

```sh
scripts/test.sh   # GazelingKit unit tests
scripts/build.sh  # generate the Xcode project and build
scripts/run.sh    # build and launch
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

Debug builds (what `scripts/run.sh` makes) have a "Debug: start short break" and "Debug: start long break" item in the menu bar menu. They also accept launch arguments, in seconds. Overrides are not saved to the user's settings.

```sh
APP=$(xcodebuild -project Gazeling.xcodeproj -scheme Gazeling -showBuildSettings | awk '/ BUILT_PRODUCTS_DIR/{print $3}')/Gazeling.app
open "$APP" --args --short-interval 30 --heads-up 10 --short-duration 20
```

Flags: `--short-interval`, `--short-duration`, `--long-interval`, `--long-duration`, `--heads-up`, `--break-now`.
