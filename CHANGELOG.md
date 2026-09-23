# Changelog

All notable changes to NerdLogger are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

This changelog starts its history at version 2.0.0. Earlier history is available through the git
tags up to 1.1.0.

## [2.0.0]

This is a major release. It contains a breaking change to `NerdLogger`'s initializer: see Changed.

### Fixed
- Deadlock when `NerdLogger.destinations` was read from concurrent Swift concurrency tasks. The
  destination list was guarded by a concurrent `DispatchQueue`, and every read blocked the calling
  thread in `queue.sync`. Swift Testing and any `TaskGroup` schedule work on the cooperative pool,
  whose width equals the active processor count, so once every pool thread was parked in a read, no
  thread remained to run the pending barrier writes and nothing could make progress. On a three core
  machine (for example a GitHub Actions macOS runner) this hung the whole test suite indefinitely
  with no output. Reads and writes are now serialized with an `NSLock`, which completes inline on
  the calling thread and never waits for another thread.

### Changed
- `NerdLogger.init(destinations:queue:)` is now `NerdLogger.init(destinations:)`. The queue existed
  only to synchronize the destination list, which an `NSLock` now does, so the parameter has no
  remaining purpose. Callers pass the same destinations and drop the `queue` argument. Scheduling of
  the actual log work is unchanged: it is configured per destination through
  `ExecutionMethod.asynchronous(queue:)`.

### Added
- Regression test that reads the destination list from twice as many concurrent tasks as there are
  active processors, which deadlocks against the previous implementation on any core count.
