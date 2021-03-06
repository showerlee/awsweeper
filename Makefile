PKG_LIST              := $(shell go list ./...)

.PHONY: setup
setup: ## Install build, test, and lint dependencies
	curl -sfL https://install.goreleaser.com/github.com/golangci/golangci-lint.sh | sh -s v1.21.0
	go install github.com/golang/mock/mockgen
	curl -sSfL https://raw.githubusercontent.com/jckuester/go-acc/master/install.sh | sh -s v0.2.1

.PHONY: lint
lint: ## Run some static code analysis
	./bin/golangci-lint run --enable-all

.PHONY: go-mod-tidy
go-mod-tidy: ## Clean go.mod
	@go mod tidy -v
	@git diff HEAD
	@git diff-index --quiet HEAD

.PHONY: fmt
fmt: ## Run gofmt on goimports all files
	gofmt -w -l -s .
	goimports -w -l .

PHONY: generate
generate: ## Run go generate
	go generate

.PHONY: test
test: ## Run unit tests
	go clean -testcache ${PKG_LIST}
	go test -v -p 1 -short -race ${PKG_LIST}

.PHONY: test-all
test-all: ## Run tests (including acceptance and integration tests)
	go clean -testcache ${PKG_LIST}
	./bin/go-acc ${PKG_LIST} -- -v $(TESTARGS) -p 1 -race -timeout 30m

.PHONY: build
build: ## Build binary
	go build

.PHONY: build
ci: generate build test-all # Run all the tests and code checks
