# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Traccar is an open-source GPS tracking server that supports 200+ GPS protocols and 2000+ GPS tracking device models. It's a Java-based backend service providing REST APIs for GPS tracking functionality.

## Development Commands

### Build and Run
```bash
# Build the project
./gradlew build

# Run the server in development mode
java -jar target/tracker-server.jar debug.xml

# Clean build
./gradlew clean build
```

### Testing
```bash
# Run all tests
./gradlew test

# Run a specific test class
./gradlew test --tests "org.traccar.protocol.Gps103ProtocolDecoderTest"

# Run tests with specific pattern
./gradlew test --tests "*ProtocolDecoderTest"
```

### Code Quality
```bash
# Run checkstyle
./gradlew checkstyleMain checkstyleTest

# Run static analysis
./gradlew findbugsMain
```

## Architecture Overview

### Core Components

1. **Protocol Layer** (`org.traccar.protocol`)
   - Each GPS device protocol consists of:
     - `*Protocol` - Protocol definition and server setup
     - `*ProtocolDecoder` - Decodes device messages into Position objects
     - `*ProtocolEncoder` (optional) - Encodes commands to device format
     - `*FrameDecoder` (optional) - Handles TCP frame delimiting
   - All decoders extend `BaseProtocolDecoder`

2. **Processing Pipeline**
   - Device data flows through: Network → Protocol Decoder → Handlers → Database
   - Handlers (`org.traccar.handler`) process positions sequentially:
     - `TimeHandler` - Time validation
     - `GeolocationHandler` - Cell tower/WiFi geolocation
     - `HemisphereHandler` - Coordinate hemisphere correction
     - `DistanceHandler` - Odometer calculation
     - `FilterHandler` - Invalid position filtering
     - `GeocoderHandler` - Reverse geocoding
     - `SpeedLimitHandler` - Road speed limit lookup
     - `MotionHandler` - Motion state detection
     - `CopyAttributesHandler` - Attribute copying
     - `ComputedAttributesHandler` - Calculated attributes
     - `EngineHoursHandler` - Engine hours calculation
     - `DriverHandler` - Driver identification
     - `GeofenceHandler` - Geofence enter/exit detection
     - `OutdatedHandler` - Outdated position handling
     - `DatabaseHandler` - Database persistence

3. **Dependency Injection**
   - Uses Google Guice with `MainModule` as the root module
   - Protocol instances are created via reflection and injected dependencies

4. **Database Schema**
   - Managed by Liquibase migrations in `schema/` directory
   - Main tables: tc_devices, tc_positions, tc_users, tc_groups

### Key Patterns

- **Protocol Testing**: Use `ProtocolTest` base class with methods like `verifyPosition()`
- **Binary Protocol Parsing**: Use `BinaryBuffer` and `Parser` utilities
- **Text Protocol Parsing**: Use `PatternBuilder` for regex-based parsing
- **Position Building**: Use `Position` class with attributes map for custom data

### Configuration

- Development config: `debug.xml`
- Production config typically named `traccar.xml`
- Environment variables override: `CONFIG_KEY_NAME` → `config.key.name`

### Adding New Protocols

1. Create classes in `org.traccar.protocol` package
2. Extend appropriate base classes
3. Register protocol in server startup
4. Add comprehensive unit tests
5. Binary protocols use `ByteBuf`, text protocols use `String`