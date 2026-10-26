.PHONY: help build test run demo stop logs

help:
	@echo "make test   run the unit tests"
	@echo "make build  build the app"
	@echo "make run    build and start the app with normal timings"
	@echo "make demo   build and start with short timers (break within 30 s)"
	@echo "make stop   quit the running app"
	@echo "make logs   show the app log from the last 5 minutes"

build:
	scripts/build.sh

test:
	scripts/test.sh

run:
	scripts/run.sh

demo:
	scripts/demo.sh

stop:
	-pkill -x Gazeling

logs:
	/usr/bin/log show --last 5m --predicate 'subsystem == "com.danielabar.gazeling"' --style compact
