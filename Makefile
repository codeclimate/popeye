IMAGE_NAME ?= codeclimate/popeye

image:
	docker build --tag $(IMAGE_NAME) .

check: image
	docker run --env-file .env $(IMAGE_NAME) --group Ops

.PHONY: image check
