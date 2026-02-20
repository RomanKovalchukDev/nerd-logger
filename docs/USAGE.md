# NerdLogger — Usage Guide

- [Destinations](#destinations)
  - [Console](#console-destination)
  - [OSLog](#oslog-destination)
  - [File](#file-destination)
- [Encoders](#encoders)
  - [Simple text](#simple-text-encoder)
  - [JSON](#json-encoder)
  - [CSV](#csv-encoder)
- [Log Options](#log-options)
- [Filters](#filters)
  - [Severity filter](#severity-filter)
  - [Tag filter](#tag-filter)
  - [Closure filter](#closure-filter)
- [Metadata Provider](#metadata-provider)
- [Execution Methods](#execution-methods)
- [Flush Modes](#flush-modes)
- [Fetching Logs](#fetching-logs)
- [Managing Destinations at Runtime](#managing-destinations-at-runtime)

---

## Destinations

### Console Destination

Prints logs to the Xcode console. Supports `print`, `debugPrint`, and `NSLog` output methods.

```swift
let consoleDestination = ConsoleDestination(
    id: "console",
    outputMethod: .print,
    executionMethod: .synchronous(lock: NSRecursiveLock()),
    filters: [],
    encoder: LogSimpleEncoder(
        dateFormatter: dateFormatter,
        logOptions: .console
    )
)
```

### OSLog Destination

Routes logs to the unified logging system, visible in Console.app. Log levels are mapped to `OSLogType` automatically (`debug` → `.debug`, `warning` → `.default`, `critical` → `.fault`).

```swift
import os.log

let osLogDestination = OSLogDestination(
    id: "oslog",
    logger: Logger(subsystem: "com.myapp", category: "general"),
    executionMethod: .asynchronous(queue: DispatchQueue(label: "com.myapp.oslog")),
    filters: [],
    encoder: LogSimpleEncoder(
        dateFormatter: dateFormatter,
        logOptions: .default
    )
)
```

### File Destination

Persists logs to a file on disk. Supports automatic trimming by age or file size, configurable flush mode, and custom file permissions.

```swift
let fileDestination = FileDestination(
    id: "file",
    containerURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0],
    fileName: "app.log",
    filePermission: "0644",
    flushMode: .periodic(30),         // flush every 30 seconds
    executionMethod: .asynchronous(queue: DispatchQueue(label: "com.myapp.filelog")),
    dateFormatter: dateFormatter,
    trimDecoder: LogJSONDecoder(decoder: JSONDecoder()),
    maxLogAge: 7 * 24 * 60 * 60,     // 7 days
    maxFileSize: 5 * 1024 * 1024,     // 5 MB
    filters: [],
    encoder: LogJSONEncoder(
        encoder: JSONEncoder(),
        logOptions: .all
    ),
    onInternalLog: { message in print("FileDestination: \(message)") }
)

// Call setup() before logging to create the file and run initial trim
let logger = NerdLogger(destinations: [fileDestination], queue: logQueue)
logger.setupAllDestinations()
```

---

## Encoders

### Simple Text Encoder

Formats logs as a single human-readable line. Field order follows the `logOptions` array.

```swift
// Output: [2026-01-08 12:00:00] [ERROR] [Auth] Login failed
let encoder = LogSimpleEncoder(
    dateFormatter: dateFormatter,
    logOptions: [.timestamp, .level, .tag, .message]
)
```

### JSON Encoder

Serialises each log entry as a compact JSON object. Useful for file destinations when you want to fetch and decode logs later.

```swift
let jsonEncoder = JSONEncoder()
jsonEncoder.dateEncodingStrategy = .iso8601

let encoder = LogJSONEncoder(
    encoder: jsonEncoder,
    logOptions: .all
)
// Output: {"logLevel":"ERROR","message":"Login failed","tag":"Auth","date":"2026-01-08T12:00:00Z",...}
```

### CSV Encoder

Encodes each log entry as a CSV row. Field order and delimiter are fully configurable. Fields containing delimiters or newlines are automatically quoted and escaped.

```swift
let encoder = LogCSVEncoder(
    delimiter: ",",
    dateFormatter: dateFormatter,
    logOptions: [.timestamp, .level, .tag, .message]
)
// Output: "2026-01-08 12:00:00","ERROR","Auth","Login failed"
```

---

## Log Options

`LogOption` controls which fields are included in the encoded output and their order.

| Case | Description |
|---|---|
| `.timestamp` | Date/time of the log |
| `.level` | Log level (DEBUG, INFO, WARNING, ERROR, CRITICAL) |
| `.tag` | Optional tag string |
| `.fileInfo` | File name, function name, line number |
| `.thread` | Thread name, ID, and queue label |
| `.otherInfo` | Extra key/value pairs from `extraInfo` |
| `.message` | The log message |

Preset arrays are available as static properties:

```swift
LogOption.default    // [.timestamp, .level, .tag, .otherInfo, .message]
LogOption.console    // [.timestamp, .level, .tag, .message]
LogOption.logReport  // [.timestamp, .level, .message]
LogOption.messageOnly // [.message]
LogOption.all        // all cases in declaration order
```

---

## Filters

Filters are evaluated per destination. A log is dropped if **any** filter returns `true` from `shouldIgnoreLog`.

### Severity Filter

Drops any log below the specified minimum level.

```swift
// Only pass through warnings and above
let severityFilter = LogSeverityFilter(id: "severity", minLogLevel: .warning)
```

### Tag Filter

Only passes logs whose tag is in the allowlist. Logs with a `nil` tag are always dropped.

```swift
let tagFilter = LogTagFilter(id: "tags", tags: ["Auth", "Network", "Payment"])
```

### Closure Filter

Full control via a predicate closure.

```swift
let closureFilter = LogClosureFilter(id: "custom") { entity in
    // Return true to DROP the log
    entity.message.contains("sensitive")
}
```

### Combining Filters

Pass multiple filters to a destination — all are evaluated in order:

```swift
let fileDestination = FileDestination(
    id: "file",
    // ...
    filters: [
        LogSeverityFilter(id: "severity", minLogLevel: .info),
        LogTagFilter(id: "tags", tags: ["Auth", "Network"])
    ],
    // ...
)
```

---

## Metadata Provider

Attach shared key/value pairs to every log that passes through a destination, without having to repeat them at each call site.

```swift
class AppMetadataProvider: LogMetadataProvider {
    var metadata: [String: String] = [
        "appVersion": Bundle.main.shortVersionString ?? "",
        "userId": ""
    ]
}

let provider = AppMetadataProvider()
provider.metadata["userId"] = currentUser.id

consoleDestination.metadataProvider = provider
// Every log through this destination will include appVersion and userId in extraInfo
```

---

## Execution Methods

Control how each destination dispatches its work.

```swift
// Synchronous — blocks the calling thread; easier to follow in the debugger
.synchronous(lock: NSRecursiveLock())

// Asynchronous — non-blocking; better throughput in production
.asynchronous(queue: DispatchQueue(label: "com.myapp.log.file", qos: .utility))
```

A common pattern is to use `.synchronous` for `ConsoleDestination` during development, and `.asynchronous` for `FileDestination` in production.

---

## Flush Modes

File destinations buffer writes. `FlushMode` controls when data is committed to disk.

```swift
.always          // fsync after every write — safest, slowest
.manual          // only flush when you call logger.flushAllDestinations()
.periodic(60)    // flush every 60 seconds via a background timer
```

Manually flushing on app suspend:

```swift
func applicationDidEnterBackground(_ application: UIApplication) {
    logger.flushAllDestinations()
}
```

---

## Fetching Logs

Use `FileLogFetcher` to read a persisted log file back into `[LogEntity]`. The decoder must match the encoder used to write the file.

```swift
let fetcher = FileLogFetcher(
    fileURL: logsDirectory.appendingPathComponent("app.log"),
    decoder: LogJSONDecoder(decoder: JSONDecoder())
)

// Fetch all logs
let allLogs = try fetcher.fetchLogs(with: nil)

// Fetch only errors from the last hour
let recentErrors = try fetcher.fetchLogs(with: { entity in
    entity.logLevel >= .error &&
    (entity.date ?? .distantPast) > Date().addingTimeInterval(-3600)
})
```

---

## Managing Destinations at Runtime

```swift
// Add a destination after initialisation
logger.addDestination(crashReportingDestination)

// Remove a specific destination
logger.removeDestinationWithID("console")

// Remove all destinations
logger.removeAllDestinations()

// Access the current list
let active = logger.destinations
```
