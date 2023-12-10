#!make

TARGETS      := darwin/amd64 darwin/arm64 linux/amd64 linux/arm64

DIST_DIRS    := find * -type d -exec

GOPATH = $(shell go env GOPATH)
GOBIN  = $(GOPATH)/bin
GOX    = go run github.com/mitchellh/gox
SHA256 = sha256sum
ifeq ($(shell uname),Darwin)
	SHA256 = shasum -a 256
endif

VERSION ?= dev
BUILD_DATE ?= $(shell date +%Y-%m-%d-%H:%M-%Z)
GIT_SHA=$$(git rev-parse HEAD)
BUILD_DATE_VAR := github.com/cybwan/discli/pkg/version.BuildDate
BUILD_VERSION_VAR := github.com/cybwan/discli/pkg/version.Version
BUILD_GITCOMMIT_VAR := github.com/cybwan/discli/pkg/version.GitCommit
LDFLAGS ?= "-X $(BUILD_DATE_VAR)=$(BUILD_DATE) -X $(BUILD_VERSION_VAR)=$(VERSION) -X $(BUILD_GITCOMMIT_VAR)=$(GIT_SHA) -s -w"

.PHONY: build-cross
build-cross:
	GO111MODULE=on CGO_ENABLED=0 $(GOX) -ldflags $(LDFLAGS) -parallel=5 -output="_dist/{{.OS}}-{{.Arch}}/eukcli" -osarch='$(TARGETS)' ./cmd/eureka

.PHONY: dist
dist:
	( \
		cd _dist && \
		$(DIST_DIRS) tar -zcf discli-${VERSION}-{}.tar.gz {} \; && \
		$(DIST_DIRS) zip -r discli-${VERSION}-{}.zip {} \; && \
		$(SHA256) discli-* > sha256sums.txt \
	)

.PHONY: release-artifacts
release-artifacts: build-cross dist