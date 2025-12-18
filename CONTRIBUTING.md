# Contributing

Thank you for your interest in contributing to the Affymetrix Power Tools Docker image project.

## Development Setup

1. Fork and clone the repository
2. Ensure Docker is installed and running
3. Build the image locally:
   ```bash
   docker build -t apt-tools .
   ```

## Running Tests

Before submitting changes, run the test suite:

```bash
./test/test_apt_tools.sh
```

All tests must pass before submitting a pull request.

## Making Changes

### Dockerfile Changes

1. Make your changes to the Dockerfile
2. Build and test locally
3. Ensure the image still works for all APT tools
4. Run the full test suite

### Test Changes

1. Add tests for new functionality
2. Update existing tests if behavior changes
3. Ensure test script remains POSIX-compliant where possible

### Documentation Changes

1. Update README.md for user-facing changes
2. Update CLAUDE.md for development guidance
3. Update comments in code for clarity

## Pull Request Process

1. Create a feature branch from `main`
2. Make your changes with clear, descriptive commits
3. Run tests locally and ensure they pass
4. Push your branch and create a pull request
5. Fill out the PR template with:
   - Description of changes
   - Motivation and context
   - Testing performed
   - Related issues

## CI/CD Pipeline

When you submit a PR, automated checks will run:

1. **Build and Test**: Builds the Docker image and runs test suite
2. **Security Scan**: Scans image for vulnerabilities using Trivy
3. **Publish**: (main branch only) Pushes to Docker Hub
4. **Verify**: (main branch only) Validates published image

All checks must pass before merging.

## Code Style

- Use clear, descriptive variable names
- Add comments for complex logic
- Follow existing code formatting
- Keep lines under 120 characters where practical

## Versioning

This project tracks the APT version (currently 2.12.0). When updating:

1. Update `APT_VERSION` in Dockerfile
2. Update version references in README.md
3. Update CLAUDE.md if architecture changes
4. Create a git tag matching the version

## Security

- Report security vulnerabilities privately via GitHub Security Advisories
- Do not include sensitive data in commits
- Review Trivy scan results in CI/CD

## Questions

For questions or discussions, open an issue on GitHub.
