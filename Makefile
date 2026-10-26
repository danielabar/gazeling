.PHONY: help build test run demo stop logs pose-sheet

help:
	@echo "make test   run the unit tests"
	@echo "make build  build the app"
	@echo "make run    build and start the app with normal timings"
	@echo "make demo   build and start with short timers (break within 30 s)"
	@echo "make stop   quit the running app"
	@echo "make logs   show the app log from the last 5 minutes"
	@echo "make pose-sheet  render the owl pose sheet to scratch/owl/ and open it"

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

pose-sheet:
	swift run --package-path Packages/GazelingKit PoseSheet "$(CURDIR)/scratch/owl/pose-sheet.png"
	open scratch/owl/pose-sheet.png
