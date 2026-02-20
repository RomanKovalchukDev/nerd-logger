# Contributing

Thank you for taking the time to contribute to NerdLogger!

## Getting Started

1. Fork the repository and clone your fork.
2. Create a feature branch from `main`:
   ```
   git checkout -b feature/your-feature-name
   ```
3. Make your changes, add tests where appropriate, and ensure everything builds cleanly.
4. Open a pull request against `main` with a clear description of what changed and why.

## Development

**Requirements:** Swift 5, Xcode 15+, iOS 17+ / macOS 14+

Build and test via Swift Package Manager:

```bash
swift build
swift test
```

## Guidelines

- **Keep changes focused.** One feature or fix per pull request.
- **Follow existing code style.** Protocol-oriented design, no third-party dependencies, no force-unwraps.
- **Add tests** for new behaviour and bug fixes.
- **Update documentation** — if you add a destination, encoder, filter, or fetcher, update [USAGE.md](docs/USAGE.md) with an example.
- **Update diagrams** if the architecture changes. Source files are in [`docs/diagrams/`](docs/diagrams/).

## Reporting Issues

Open an issue and include:

- A minimal reproducible example.
- The platform and OS version you are targeting.
- The Swift / Xcode version you are using.

## License

By contributing you agree that your contributions will be licensed under the [MIT License](LICENSE).
