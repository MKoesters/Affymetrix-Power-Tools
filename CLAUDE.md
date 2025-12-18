# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Production Docker image for Affymetrix Power Tools (APT) version 2.12.0, providing cross-platform microarray data analysis tools. Built for linux/amd64 with Apple Silicon support via Rosetta 2 emulation.

## Build and Test Commands

```bash
# Build the Docker image
docker build -t apt-tools .

# Run test suite (12 comprehensive tests)
./test/test_apt_tools.sh

# Build and run tests (common workflow)
docker build -t apt-tools . && ./test/test_apt_tools.sh

# Test specific tool
docker run --rm apt-tools --help
docker run --rm --entrypoint apt-probeset-summarize apt-tools --help

# List all APT binaries
docker run --rm --entrypoint ls apt-tools /opt/apt/bin
```

## Architecture

### Docker Image Structure
- **Base**: Ubuntu 22.04 (linux/amd64 only)
- **APT Installation**: `/opt/apt/` with binaries in `/opt/apt/bin/`
- **Default Entrypoint**: `apt-cel-convert` (overridable via `--entrypoint`)
- **Working Directory**: `/data` (mount point for user data)
- **Build Validation**: Automatic verification of critical binaries during build

### Key APT Tools
- `apt-cel-convert` - CEL to text conversion (default)
- `apt-probeset-summarize` - Gene expression summarization
- `apt-probeset-genotype` - SNP genotype calling
- `apt-cel-extract` - Data extraction
- `apt-format-result` - Result formatting

### Dockerfile Build Arguments
- `APT_VERSION`: Version of APT (default: 2.12.0)
- `APT_DOWNLOAD_URL`: Download URL for APT binaries

### Volume Mounting Pattern
All file paths in APT commands must reference `/data` inside container:
```bash
docker run --rm -v $(pwd)/local_data:/data apt-tools \
  --cel-files /data/*.CEL \
  --out-dir /data/output
```

## Testing

### Test Suite (`test/test_apt_tools.sh`)
Comprehensive bash test script with 12 tests covering:
1. Docker image build
2. Image existence verification
3. Default entrypoint functionality
4. APT binary availability (all 5 main tools)
5. Individual tool accessibility
6. Volume mounting
7. Working directory validation
8. Platform architecture (linux/amd64)
9. Shell access
10. Installation directory structure
11. PATH configuration

### Test Output
- Green `[PASS]`: Test passed
- Red `[FAIL]`: Test failed
- Yellow `[INFO]`: Informational message
- Exit code 0 on success, 1 on failure

### Adding Tests
Add new tests in `test/test_apt_tools.sh`:
```bash
run_test "Test description"
if [test condition]; then
    log_success "Success message"
else
    log_error "Failure message"
fi
```

## CI/CD Pipeline

### Workflow File: `.github/workflows/ci.yml`

**Jobs:**
1. **test**: Build image, run test suite, check image size
2. **security**: Trivy vulnerability scanning, SARIF upload to GitHub Security
3. **publish**: Build and push to Docker Hub (main branch only)
4. **verify**: Pull and validate published image

**Triggers:**
- Push to `main` branch
- Pull requests to `main`
- Version tags (`v*`)
- Monthly schedule (1st of month)

**Required Secrets:**
- `DOCKERHUB_USERNAME`: Docker Hub username
- `DOCKERHUB_TOKEN`: Docker Hub access token

**Security Scanning:**
- Trivy scans for CRITICAL and HIGH vulnerabilities
- Results uploaded to GitHub Security tab
- Scan runs on every build

**Image Tags:**
- `latest` (main branch only)
- `2.12.0` (APT version)
- Semantic versions from git tags
- SHA-based tags for branches

**Artifacts:**
- SBOM (Software Bill of Materials) in SPDX JSON format
- 30-day retention

## Development Workflow

### Local Development
```bash
# Make changes to Dockerfile
# Build image
docker build -t apt-tools .

# Run tests
./test/test_apt_tools.sh

# Test interactively
docker run --rm -it --entrypoint bash apt-tools
```

### Before Committing
1. Run full test suite
2. Verify all tests pass
3. Check that image builds successfully
4. Test volume mounting if changed

### Pull Request Process
1. Create feature branch from `main`
2. Make changes with descriptive commits
3. Run tests locally
4. Push and create PR
5. CI/CD runs automatically (test + security scan)
6. All checks must pass before merge

## Production Considerations

### Image Size
Monitor image size in CI output. Current base is Ubuntu 22.04 + APT tools.

### Security
- Trivy scans run automatically
- Review security tab for vulnerabilities
- APT binaries are proprietary (from ThermoFisher)
- No sensitive data in image

### Performance
- Native performance on x86_64
- Emulated on ARM64 (Apple Silicon) - expect slower execution
- For production workloads on ARM, use x86_64 cloud instances

### Running Different Tools
Override entrypoint for non-default tools:
```bash
docker run --rm -v $(pwd)/data:/data \
  --entrypoint apt-probeset-genotype \
  apt-tools \
  --cel-files /data/samples \
  --out-dir /data/results
```

## File Structure

```
.
├── Dockerfile              # Production Docker image definition
├── .dockerignore          # Docker build exclusions
├── README.md              # User documentation
├── CLAUDE.md              # This file (developer guide)
├── CONTRIBUTING.md        # Contribution guidelines
├── LICENSE                # License file
├── .github/
│   └── workflows/
│       └── ci.yml         # CI/CD pipeline
└── test/
    ├── test_apt_tools.sh  # Test suite (executable)
    └── README.md          # Test documentation
```

## Common Issues

### Tests Failing Locally
- Ensure Docker is running
- Check disk space for image build
- Verify test script is executable: `chmod +x test/test_apt_tools.sh`

### CI/CD Failures
- Check GitHub Actions logs for specific failure
- Ensure secrets are configured (for publish job)
- Verify Dockerfile syntax
- Review Trivy security scan results

### Image Build Failures
- Verify APT download URL is accessible
- Check network connectivity
- Ensure sufficient disk space
- Review validation step output

## Updating APT Version

To update to a new APT version:
1. Update `APT_VERSION` build arg in Dockerfile
2. Update `APT_DOWNLOAD_URL` if URL pattern changes
3. Update version references in README.md
4. Update CONTRIBUTING.md
5. Update this file (CLAUDE.md)
6. Run full test suite
7. Create git tag matching version
8. Push tag to trigger release build
