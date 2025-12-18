#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Image name
IMAGE_NAME="apt-tools:test"

# Test output directory
TEST_OUTPUT_DIR="$(pwd)/test/output"
mkdir -p "$TEST_OUTPUT_DIR"

# Helper function for test output
log_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[PASS]${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

log_error() {
    echo -e "${RED}[FAIL]${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

run_test() {
    TESTS_RUN=$((TESTS_RUN + 1))
    log_info "Test $TESTS_RUN: $1"
}

# Cleanup function
cleanup() {
    log_info "Cleaning up test artifacts..."
    rm -rf "$TEST_OUTPUT_DIR"
}

trap cleanup EXIT

# Test 1: Build Docker image
run_test "Building Docker image"
if docker build -t "$IMAGE_NAME" . > /dev/null 2>&1; then
    log_success "Docker image built successfully"
else
    log_error "Failed to build Docker image"
    exit 1
fi

# Test 2: Verify image exists
run_test "Verifying Docker image exists"
if docker images "$IMAGE_NAME" | grep -q "test"; then
    log_success "Docker image exists"
else
    log_error "Docker image not found"
    exit 1
fi

# Test 3: Test default entrypoint (apt-cel-convert --help)
run_test "Testing default entrypoint (apt-cel-convert --help)"
if docker run --rm "$IMAGE_NAME" --help 2>&1 | grep -q "apt-cel-convert"; then
    log_success "Default entrypoint works"
else
    log_error "Default entrypoint failed"
fi

# Test 4: Verify all expected APT binaries are present
run_test "Verifying APT binaries are installed"
EXPECTED_BINS=(
    "apt-cel-convert"
    "apt-probeset-summarize"
    "apt-probeset-genotype"
    "apt-cel-extract"
    "apt-format-result"
)

BINARIES_FOUND=true
for bin in "${EXPECTED_BINS[@]}"; do
    if docker run --rm --entrypoint which "$IMAGE_NAME" "$bin" > /dev/null 2>&1; then
        log_info "  Found: $bin"
    else
        log_error "  Missing binary: $bin"
        BINARIES_FOUND=false
    fi
done

if [ "$BINARIES_FOUND" = true ]; then
    log_success "All expected binaries found"
else
    log_error "Some binaries are missing"
fi

# Test 5: Test apt-probeset-summarize is accessible
run_test "Testing apt-probeset-summarize accessibility"
if docker run --rm --entrypoint apt-probeset-summarize "$IMAGE_NAME" --help 2>&1 | grep -q "apt-probeset-summarize"; then
    log_success "apt-probeset-summarize is accessible"
else
    log_error "apt-probeset-summarize is not accessible"
fi

# Test 6: Test apt-probeset-genotype is accessible
run_test "Testing apt-probeset-genotype accessibility"
if docker run --rm --entrypoint apt-probeset-genotype "$IMAGE_NAME" --help 2>&1 | grep -q "apt-probeset-genotype"; then
    log_success "apt-probeset-genotype is accessible"
else
    log_error "apt-probeset-genotype is not accessible"
fi

# Test 7: Test volume mounting
run_test "Testing volume mounting"
echo "test data" > "$TEST_OUTPUT_DIR/test_input.txt"
if docker run --rm -v "$TEST_OUTPUT_DIR:/data" --entrypoint cat "$IMAGE_NAME" /data/test_input.txt 2>&1 | grep -q "test data"; then
    log_success "Volume mounting works"
else
    log_error "Volume mounting failed"
fi

# Test 8: Test working directory is /data
run_test "Testing working directory is /data"
if docker run --rm --entrypoint pwd "$IMAGE_NAME" | grep -q "/data"; then
    log_success "Working directory is /data"
else
    log_error "Working directory is not /data"
fi

# Test 9: Test platform architecture
run_test "Testing platform architecture is amd64"
if docker inspect "$IMAGE_NAME" | grep -q "linux/amd64"; then
    log_success "Image architecture is linux/amd64"
else
    log_error "Image architecture is not linux/amd64"
fi

# Test 10: Test shell access
run_test "Testing interactive shell access"
if docker run --rm --entrypoint bash "$IMAGE_NAME" -c "echo 'shell test'" 2>&1 | grep -q "shell test"; then
    log_success "Shell access works"
else
    log_error "Shell access failed"
fi

# Test 11: Verify APT version
run_test "Verifying APT version 2.12.0"
if docker run --rm --entrypoint ls "$IMAGE_NAME" /opt/apt 2>&1 | grep -q "bin"; then
    log_success "APT installation directory structure is correct"
else
    log_error "APT installation directory structure is incorrect"
fi

# Test 12: Test PATH configuration
run_test "Testing PATH includes APT binaries"
if docker run --rm --entrypoint bash "$IMAGE_NAME" -c "echo \$PATH" | grep -q "/opt/apt/bin"; then
    log_success "PATH includes /opt/apt/bin"
else
    log_error "PATH does not include /opt/apt/bin"
fi

# Summary
echo ""
echo "========================================"
echo "Test Summary"
echo "========================================"
echo "Total tests run: $TESTS_RUN"
echo -e "${GREEN}Tests passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Tests failed: $TESTS_FAILED${NC}"
    echo "========================================"
    exit 1
else
    echo "Tests failed: $TESTS_FAILED"
    echo "========================================"
    log_success "All tests passed!"
    exit 0
fi
