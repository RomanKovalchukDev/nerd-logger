# ``NerdLogger``

Structured, multi-destination logging for iOS apps.

## Overview

The `NerdLogger` package provides a composable pipeline for emitting, filtering, encoding,
and persisting log records. All log records are modelled as ``LogEntity`` values that
carry a severity level, message, optional call-site information, and arbitrary key-value
metadata. The ``LogLevel`` enum defines five ordered severities from ``LogLevel/debug``
through ``LogLevel/critical``.

The main entry point for callers is ``LogProtocol``. Its concrete implementation
``NerdLogger`` fans every record out to a set of registered ``LogDestinationProtocol``
instances. Three built-in destinations cover the most common targets: ``ConsoleDestination``
prints to stdout or the os.log subsystem via ``OSLogDestination``, while
``FileDestination`` persists records to disk with configurable flush modes and
file rotation managed by ``LogFileManager``.

Each destination runs records through a list of ``LogFilterProtocol`` instances before
encoding. Three filter implementations are provided: ``LogSeverityFilter`` drops records
below a minimum level, ``LogTagFilter`` passes only records whose tag appears in an
allowlist, and ``LogClosureFilter`` delegates the decision to an arbitrary closure.
Encoders (``LogCSVEncoder``, ``LogJSONEncoder``, ``LogSimpleEncoder``) and their matching
decoders (``LogCSVDecoder``, ``LogJSONDecoder``) let each destination choose its own
wire format. Persisted records can be retrieved later through ``FileLogFetcher`` or
``SegmentedLogFetcher`` when the destination uses rolling log files.

## Topics

### Core Model

- ``LogEntity``
- ``LogLevel``
- ``LogOption``

### Logger

- ``LogProtocol``
- ``NerdLogger``

### Destinations

- ``LogDestinationProtocol``
- ``PersistedLogDestinationProtocol``
- ``ConsoleDestination``
- ``ConsoleDestination/OutputMethod``
- ``FileDestination``
- ``OSLogDestination``

### File Management

- ``LogFileManagerProtocol``
- ``LogFileManager``
- ``FlushMode``
- ``ExecutionMethod``

### Filters

- ``LogFilterProtocol``
- ``LogSeverityFilter``
- ``LogTagFilter``
- ``LogClosureFilter``

### Encoders

- ``LogEncoderProtocol``
- ``LogCSVEncoder``
- ``LogJSONEncoder``
- ``LogSimpleEncoder``

### Decoders

- ``LogDecoderProtocol``
- ``LogCSVDecoder``
- ``LogJSONDecoder``

### Fetchers

- ``LogFetcherProtocol``
- ``FileLogFetcher``
- ``SegmentedLogFetcher``

### Supporting Types

- ``LogMetadataProvider``
- ``TypeNameProtocol``
- ``InternalLog``
- ``LogFetcherFilter``
- ``LogEntityDTO``
- ``LogLevelDTO``
- ``FileError``
