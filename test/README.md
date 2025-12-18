# Tests

This directory contains tests for the Affymetrix Power Tools Docker image.

## Running Tests Locally

Run the test suite:

```bash
./test/test_apt_tools.sh
```

The test script will:
1. Build the Docker image with tag `apt-tools:test`
2. Run 12 comprehensive tests covering:
   - Image build process
   - Binary availability
   - Entrypoint functionality
   - Volume mounting
   - Platform architecture
   - Shell access
   - PATH configuration

## Test Requirements

- Docker installed and running
- Bash shell
- Sufficient disk space for building the image

## Test Output

The script provides colored output:
- Green: Passed tests
- Red: Failed tests
- Yellow: Informational messages

Example output:
```
[INFO] Test 1: Building Docker image
[PASS] Docker image built successfully
[INFO] Test 2: Verifying Docker image exists
[PASS] Docker image exists
...
========================================
Test Summary
========================================
Total tests run: 12
Tests passed: 12
Tests failed: 0
========================================
[PASS] All tests passed!
```

## CI/CD Integration

Tests run automatically in GitHub Actions on:
- Every push to main branch
- Every pull request
- Monthly scheduled runs
- Version tag pushes

See `.github/workflows/ci.yml` for the complete CI/CD pipeline.

## Adding New Tests

To add new tests, edit `test_apt_tools.sh` and:
1. Increment `TESTS_RUN` counter
2. Use `run_test "Test description"` to start a test
3. Use `log_success "message"` for passing tests
4. Use `log_error "message"` for failing tests

Example:
```bash
run_test "Testing new feature"
if docker run --rm "$IMAGE_NAME" some-command; then
    log_success "New feature works"
else
    log_error "New feature failed"
fi
```
