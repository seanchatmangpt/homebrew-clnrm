# Homebrew Clnrm

This is a Homebrew tap for the [Cleanroom Testing Framework](https://github.com/seanchatmangpt/clnrm).

## Installation

```bash
# Add the tap
brew tap seanchatmangpt/clnrm

# Install the CLI
brew install clnrm

# Verify installation
clnrm --version
```

## What is Cleanroom?

Cleanroom is a **framework self-testing platform** that enables reliable, hermetic integration testing with automatic container lifecycle management and comprehensive observability. Unlike traditional testing tools, Cleanroom tests **itself** - eating its own dog food to ensure maximum reliability.

### Key Features

- **🔒 Hermetic Isolation** - Complete isolation from host system and other tests
- **📦 Plugin-Based Architecture** - Extensible service system for any technology
- **⚡ Container Reuse** - 10-50x performance improvement through singleton containers
- **📊 Built-in Observability** - Automatic tracing and metrics collection
- **🎛️ Professional CLI** - Feature-rich command-line interface
- **📋 TOML Configuration** - Declarative test definitions without code

## Quick Start

```bash
# Initialize a test project
clnrm init my-framework-tests
cd my-framework-tests

# Create your first test (edit tests/container_lifecycle.toml)
# Run tests
clnrm run tests/

# Run with parallel execution
clnrm run tests/ --parallel --jobs 4

# Watch mode for development
clnrm run tests/ --watch
```

## Documentation

- [Main Documentation](https://github.com/seanchatmangpt/clnrm)
- [CLI Guide](https://github.com/seanchatmangpt/clnrm/blob/main/docs/CLI_GUIDE.md)
- [Examples](https://github.com/seanchatmangpt/clnrm/tree/main/examples)

## Formula Information

- **Formula**: `clnrm`
- **Version**: 0.3.1
- **License**: MIT
- **Platforms**: macOS (Intel/ARM), Linux
- **Dependencies**: Rust (build-time only)

## Contributing

This tap is maintained alongside the main Cleanroom project. For issues or contributions, please visit the [main repository](https://github.com/seanchatmangpt/clnrm).
