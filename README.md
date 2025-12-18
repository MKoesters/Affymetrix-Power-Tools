# Affymetrix Power Tools (APT) Docker Image

Docker image for running Affymetrix Power Tools on macOS (including Apple Silicon) and Linux.

## Overview

This Docker image packages Affymetrix Power Tools (APT) version 2.12.0 for cross-platform microarray data analysis. APT is a suite of command-line tools for analyzing Affymetrix GeneChip arrays.

## Quick Start

### Pull from Docker Hub

```bash
docker pull mkoesters/affymetrix-power-tools:latest
```

### Build Locally

```bash
docker build -t apt-tools .
```

### Run Default Tool (apt-cel-convert)

```bash
# Get help
docker run --rm apt-tools --help

# Convert a CEL file
docker run --rm -v $(pwd)/data:/data apt-tools \
  --cel-files /data/sample.CEL \
  --out-dir /data/output
```

## Available Tools

The image includes all APT 2.12.0 command-line tools:

- `apt-cel-convert` - Convert CEL files to text format (default)
- `apt-probeset-summarize` - Summarize probe sets to gene expression values
- `apt-probeset-genotype` - Genotype calling for SNP arrays
- `apt-cel-extract` - Extract specific data from CEL files
- `apt-format-result` - Format and convert analysis results

### Running Other Tools

Override the default entrypoint to use different APT tools:

```bash
# apt-probeset-summarize
docker run --rm -v $(pwd)/data:/data \
  --entrypoint apt-probeset-summarize \
  apt-tools \
  --cel-files /data/cel_files \
  --out-dir /data/results

# apt-probeset-genotype
docker run --rm -v $(pwd)/data:/data \
  --entrypoint apt-probeset-genotype \
  apt-tools \
  --cel-files /data/cel_files \
  --out-dir /data/genotypes

# List all available tools
docker run --rm --entrypoint ls apt-tools /opt/apt/bin
```

## Usage Examples

### Example 1: Convert CEL Files to Text

```bash
docker run --rm -v $(pwd)/CEL_Files:/data apt-tools \
  --cel-files /data/*.CEL \
  --out-dir /data/converted \
  --format text
```

Read in R:
```r
data <- read.table("CEL_Files/converted/sample.txt", header = TRUE, sep = "\t")
```

### Example 2: Expression Analysis

```bash
docker run --rm -v $(pwd):/data \
  --entrypoint apt-probeset-summarize \
  apt-tools \
  --cel-files /data/cel_files \
  --analysis-files-path /data/library_files \
  --out-dir /data/expression_results
```

### Example 3: Genotype Calling

```bash
docker run --rm -v $(pwd):/data \
  --entrypoint apt-probeset-genotype \
  apt-tools \
  --cel-files /data/cel_files \
  --analysis-files-path /data/library_files \
  --out-dir /data/genotypes
```

### Example 4: Interactive Shell

```bash
# Open bash with all APT tools available
docker run --rm -it -v $(pwd)/data:/data \
  --entrypoint bash \
  apt-tools

# Inside container:
apt-cel-convert --help
apt-probeset-summarize --help
```

## Volume Mounting

The container uses `/data` as the working directory. Mount your local directories:

```bash
# Mount specific directory
-v $(pwd)/CEL_Files:/data

# Mount current directory
-v $(pwd):/data

# Mount with custom path
-v /path/to/your/data:/data
```

**Important**: All paths in commands must reference the mounted location inside the container (e.g., `/data/file.CEL`).

## Platform Support

- **Architecture**: linux/amd64
- **Apple Silicon**: Runs via Rosetta 2 emulation
- **Performance**: Native on x86_64, emulated on ARM64 (expect slower performance on Apple Silicon)

## Troubleshooting

### Permission Errors

On Linux, you may need to run with user permissions:

```bash
docker run --rm -v $(pwd)/data:/data --user $(id -u):$(id -g) apt-tools
```

### Path Not Found

- Ensure paths use `/data/` prefix inside container
- Verify volume is mounted correctly
- Check file permissions on host

### Slow Performance on Apple Silicon

This is expected due to x86_64 emulation. For large datasets, consider:
- Using a native x86_64 system
- Cloud-based computation
- AWS/GCP virtual machines

## Development

### Running Tests

```bash
./test/test_apt_tools.sh
```

See [test/README.md](test/README.md) for details.

### Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and contribution guidelines.

## CI/CD

This project uses GitHub Actions for:
- Automated testing on every PR
- Security scanning with Trivy
- Docker image building and publishing
- SBOM generation

See [.github/workflows/ci.yml](.github/workflows/ci.yml) for details.

## Version Information

- **APT Version**: 2.12.0
- **Base Image**: Ubuntu 22.04
- **Source**: ThermoFisher Scientific

## License

This Docker configuration is provided as-is. Affymetrix Power Tools are proprietary software from ThermoFisher Scientific. Users must comply with ThermoFisher's licensing terms.

## Resources

- [APT Documentation](https://www.thermofisher.com/affymetrix)
- [Report Issues](https://github.com/MKoesters/Affymetrix-Power-Tools/issues)
- [Docker Hub](https://hub.docker.com/r/mkoesters/affymetrix-power-tools)

## Acknowledgments

Affymetrix Power Tools is developed and maintained by ThermoFisher Scientific.
