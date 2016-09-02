PKG=bm
BUILD_DIR=build
PONYC=ponyc
PONY_SRC=$(wildcard **/*.pony) $(wildcard **/**/*.pony) $(wildcard **/**/**/*.pony)
BIN=$(BUILD_DIR)/$(PKG)
TEST_SRC=$(PKG)/test
TEST_BIN=$(BUILD_DIR)/test
BENCH_SRC=$(PKG)/bench
BENCH_BIN=$(BUILD_DIR)/bench

all: $(BUILD_DIR) test $(BIN) ## Run tests and build the package

test: $(TEST_BIN) runtest ## Build and run tests

$(TEST_BIN): $(BUILD_DIR) $(PONY_SRC)
	$(PONYC) -o $(BUILD_DIR) --path . $(TEST_SRC)

runtest: ## Run the tests
	$(TEST_BIN)

bench: $(BENCH_BIN) runbench ## Build and run benchmarks

$(BENCH_BIN): $(BUILD_DIR) $(PONY_SRC)
	$(PONYC) -o $(BUILD_DIR) --path . $(BENCH_SRC)

runbench: ## Run benchmarks
	$(BENCH_BIN)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BIN): $(PONY_SRC) 
	$(PONYC) -o $(BUILD_DIR) $(PKG)

doc: $(PONY_SRC) ## Build the documentation 
	$(PONYC) -o $(BUILD_DIR) --docs --path . --pass=docs $(PKG)

clean: ## Remove all artifacts
	-rm -rf $(BUILD_DIR)

.PHONY: help

help: ## Show help
		@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

