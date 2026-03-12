# Deep Swift Patterns — Actor Persistence & Protocol DI

Extended examples for patterns referenced in the main skill. Read on demand for implementation detail.

## Actor-Based Repository (Generic, File-Backed)

Complete copy-paste implementation for local data persistence with actors.

```swift
public actor LocalRepository<T: Codable & Identifiable> where T.ID == String {
    private var cache: [String: T] = [:]
    private let fileURL: URL

    public init(directory: URL = .documentsDirectory, filename: String = "data.json") {
        self.fileURL = directory.appendingPathComponent(filename)
        self.cache = Self.loadSynchronously(from: fileURL)
    }

    public func save(_ item: T) throws {
        cache[item.id] = item
        try persistToFile()
    }

    public func delete(_ id: String) throws {
        cache[id] = nil
        try persistToFile()
    }

    public func find(by id: String) -> T? { cache[id] }
    public func loadAll() -> [T] { Array(cache.values) }

    private func persistToFile() throws {
        let data = try JSONEncoder().encode(Array(cache.values))
        try data.write(to: fileURL, options: .atomic)
    }

    private static func loadSynchronously(from url: URL) -> [String: T] {
        guard let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([T].self, from: data) else { return [:] }
        return Dictionary(uniqueKeysWithValues: items.map { ($0.id, $0) })
    }
}
```

**Design decisions:**
- Actor (not class + lock) — compiler-enforced thread safety
- In-memory cache + file persistence — fast reads, durable writes
- Synchronous init loading — avoids async init complexity for local files
- `.atomic` writes — prevents partial writes on crash
- Generic over `Codable & Identifiable` — reusable across model types

## Protocol DI with Configurable Error Injection

Multi-protocol coordination pattern for testable I/O boundaries.

```swift
// 1. Small, focused protocols -- one concern each
public protocol FileSystemProviding: Sendable {
    func containerURL(for purpose: Purpose) -> URL?
}

public protocol FileAccessorProviding: Sendable {
    func read(from url: URL) throws -> Data
    func write(_ data: Data, to url: URL) throws
    func fileExists(at url: URL) -> Bool
}

// 2. Production implementations
public struct DefaultFileAccessor: FileAccessorProviding {
    public func read(from url: URL) throws -> Data { try Data(contentsOf: url) }
    public func write(_ data: Data, to url: URL) throws {
        try data.write(to: url, options: .atomic)
    }
    public func fileExists(at url: URL) -> Bool {
        FileManager.default.fileExists(atPath: url.path)
    }
}

// 3. Mock with configurable error injection
public final class MockFileAccessor: FileAccessorProviding, @unchecked Sendable {
    public var files: [URL: Data] = [:]
    public var readError: Error?    // Set to simulate read failures
    public var writeError: Error?   // Set to simulate write failures

    public func read(from url: URL) throws -> Data {
        if let error = readError { throw error }
        guard let data = files[url] else { throw CocoaError(.fileReadNoSuchFile) }
        return data
    }

    public func write(_ data: Data, to url: URL) throws {
        if let error = writeError { throw error }
        files[url] = data
    }

    public func fileExists(at url: URL) -> Bool { files[url] != nil }
}

// 4. Inject with default parameters
public actor SyncManager {
    private let fileSystem: FileSystemProviding
    private let fileAccessor: FileAccessorProviding

    public init(
        fileSystem: FileSystemProviding = DefaultFileSystemProvider(),
        fileAccessor: FileAccessorProviding = DefaultFileAccessor()
    ) {
        self.fileSystem = fileSystem
        self.fileAccessor = fileAccessor
    }
}
```

**Testing error paths with configurable mocks:**

```swift
@Test("Sync manager handles read corruption")
func testReadError() async {
    let mock = MockFileAccessor()
    mock.readError = CocoaError(.fileReadCorruptFile)  // Simulate corruption

    let manager = SyncManager(fileAccessor: mock)
    await #expect(throws: SyncError.self) {
        try await manager.sync()
    }
}

@Test("Sync manager handles missing container")
func testMissingContainer() async {
    let mockFS = MockFileSystemProvider(containerURL: nil)
    let manager = SyncManager(fileSystem: mockFS)

    await #expect(throws: SyncError.containerNotAvailable) {
        try await manager.sync()
    }
}
```

**Key principles:**
- Only mock boundaries (file system, network, APIs) — not internal types
- `Sendable` conformance required for protocols used across actor boundaries
- `@unchecked Sendable` on mock classes is acceptable in test targets
- Default parameters let production code use real implementations without specifying them
