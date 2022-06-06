IMAGE_NAME := cert-manager-webhook-ns1
IMAGE_TAG := latest
REPO_NAME := registry.home.thwack.net

OUT := $(shell pwd)/_out

$(shell mkdir -p "$(OUT)")

.PHONY: all build tag push helm rendered-manifest.yaml

all: ;

# When Go code changes, we need to update the Docker image
build:
	docker buildx build --platform linux/x86_64,linux/arm64 -t "$(IMAGE_NAME):$(IMAGE_TAG)" .

push: 
	docker buildx build --platform linux/x86_64,linux/arm64 -t "$(REPO_NAME)/$(IMAGE_NAME):$(IMAGE_TAG)" --push .


# When helm chart changes, we need to publish to the repo (/docs/):
#
# Ensure version is updated in Chart.yaml
# Run `make helm`
# Check and commit the resuls, including the tar.gz
helm:
	helm package deploy/$(IMAGE_NAME)/ -d docs/
	helm repo index docs --url https://ns1.github.io/cert-manager-webhook-ns1 --merge docs/index.yaml

rendered-manifest.yaml:
	helm template \
		$(IMAGE_NAME) \
		--set image.repository=$(IMAGE_NAME) \
		--set image.tag=$(IMAGE_TAG) \
		deploy/$(IMAGE_NAME) > "$(OUT)/rendered-manifest.yaml"
