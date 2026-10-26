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

Launch with arguments (needed for the Phase 1 spikes): `open <path>/Gazeling.app --args --spike-idle`.
