.PHONY:
pull:
	docker pull docker.io/debian:jessie

.PHONY:
build:
	docker build -t camptocamp/saccas_suissealpine_photo:latest .

.PHONY:
run: build
	docker-compose up -e DOCKER_TAG=latest

.PHONY:
latest:
	docker pull docker.io/camptocamp/saccas_suissealpine_photo:latest
	docker-compose -e DOCKER_TAG=latest up

.build/venv/bin/python .build/venv/bin/pip:
	pyvenv .build/venv

.build/venv/bin/py.test: requirements_host.txt .build/venv/bin/python
	.build/venv/bin/pip install -r requirements_host.txt

.PHONY:
test-inside: build
	docker-compose run --rm -e TRAVIS -e DOCKER_TAG=latest wsgi scripts/launch_inside_tests.sh

.PHONY:
test-outside: .build/venv/bin/py.test build
	.build/venv/bin/py.test -v tests/wsgi; ERROR=$$?; [ 0 -eq $$ERROR ] || (scripts/show_logs.sh; exit $$ERROR)

.PHONY:
test: test-inside test-outside

.PHONY:
check: test

.PHONY:
logs:
	scripts/show_logs.sh

.PHONY:
enter:
	docker exec -it saccas_suissealpine_photo_wsgi_1 bash

.PHONY:
clean:
	rm -rf .build .cache
	find . -type f -path '*/__pycache__/*' -delete
	find . -type d -name __pycache__ -delete

.PHONY:
cleanall: clean
	rm -rf active/* incoming/*

.PHONY:
publish: clean
	scripts/travis-build.sh
	scripts/travis-publish.sh
