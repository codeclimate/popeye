IMAGE_NAME ?= codeclimate/popeye

image:
	docker build --tag $(IMAGE_NAME) .

.PHONY: image
