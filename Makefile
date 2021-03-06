IMAGE_NAME ?= codeclimate/popeye

build:
	mkdir -p build

image:
	docker build --tag $(IMAGE_NAME)-build --file Build.dockerfile .

build/popeye: image build
	docker run --rm --volume "$(PWD)/build:/build" $(IMAGE_NAME)-build \
	  cp /home/app/dist/build/popeye/popeye /build/popeye

release: build/popeye
	docker build --tag $(IMAGE_NAME) .

check: release
	docker run --rm --volume ~/.aws:/root/aws:ro \
	  codeclimate/popeye --group ssh --user pat@codeclimate.com

.PHONY: image
