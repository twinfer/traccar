# Galileo Protocol

The Galileo protocol is a sophisticated binary GPS tracking protocol developed by Galileosky Ltd., a leading Russian manufacturer of GPS/GLONASS tracking equipment. This protocol uses a tag-based binary format supporting extensive telemetry, photo transmission, compressed data, and even Iridium satellite communication.

## Protocol Overview

**Type:** Binary tag-based  
**Manufacturer:** Galileosky Ltd. (Russia)  
**Primary Use:** Fleet management, industrial monitoring, satellite tracking  
**Data Format:** Tag-length-value with variable-length fields  
**Bidirectional:** Yes (commands and acknowledgments)

## Message Structure

### Header Types
- **0x01**: Standard position/telemetry data
- **0x07**: Photo data transmission
- **0x08**: Compressed position data

### Standard Message Format
```
[Header:1][Length:2][Tags...][Checksum:2]
```

### Tag Structure
```
[Tag:1][Data:N]
```
Where N depends on the tag type (1, 2, 3, 4, 8, or 68 bytes)

## Key Features

- **Extensive Tag System**: 100+ different data tags
- **Photo Transmission**: Camera image support
- **Data Compression**: Minimal data set + selected tags
- **Iridium Support**: Satellite communication capability
- **CAN Bus Integration**: Multiple CAN data channels
- **Flexible I/O**: Up to 17 digital sensors
- **Driver Identification**: RFID/iButton support
- **Easy Logic**: Programmable device behavior

## Device Identification

### Commercial Device Models

#### Galileosky 2.5 Series
- **Galileosky 2.5**: Basic fleet management tracker
  - GPS/GLONASS dual system
  - CAN interface
  - RS-232, 1-Wire interfaces
  - External antennas
  
- **Galileosky 2.5 Lite**: Budget version
  - No RS-232 or CAN interfaces
  - Simplified I/O options

#### Galileosky 5.0 Series
- **Galileosky v5.0**: Advanced multifunctional tracker
  - Up to 17 digital sensors
  - Multiple interface support
  - Extended temperature range: -40°C to +85°C
  - Programmable with Easy Logic
  - 10+ year service life

#### Galileosky 7 Series
- **Galileosky 7.0 Lite**: Compact plastic case
  - Internal antennas
  - Basic fleet tracking
  - Lower cost option
  
- **Galileosky 7.0 Wi-Fi**: Wireless data option
  - Wi-Fi data transmission
  - Very compact and lightweight
  - Internal antennas
  
- **Galileosky 7x Plus**: Professional grade
  - Combines v5.0 features with new tech
  - Easy Logic technology
  - Advanced CAN support
  
- **Galileosky 7x C**: CAN-focused model
  - CAN Scanner technology
  - Vehicle diagnostics emphasis
  
- **Galileosky 7x LTE**: 4G connectivity
  - LTE support
  - External antennas
  - Exigner Driver App support

#### Galileosky 10 Series (Latest)
- **Galileosky 10 C**: Advanced fleet/stationary tracking
- **Galileosky 10 Pro**: Professional features
  - CAN 2.0 B support
  - CAN-FD support
- **Galileosky 10 Plus**: Extended functionality

### Physical Characteristics
- **Form Factor**: Varies by model (compact to industrial)
- **Antennas**: Internal (7.0) or external (2.5, 5.0, 7x)
- **Operating Temperature**: -40°C to +85°C
- **Power Supply**: 8-40V DC typical
- **Protection**: IP54 to IP67 depending on model
- **Mounting**: DIN rail or custom brackets

### Protocol Tag Categories

#### Basic Tags (1 byte)
- 0x01: Hardware version
- 0x02: Firmware version
- 0x35: HDOP
- 0x43: Device temperature
- 0xC4-0xD2: CAN 8-bit values
- 0xA0-0xAF: Additional CAN data

#### Standard Tags (2 bytes)
- 0x04: Device ID
- 0x10: Record index
- 0x34: Altitude
- 0x40-0x46: Status/I/O
- 0x50-0x57: ADC inputs
- 0x60-0x62: Fuel sensors
- 0xB0-0xB9: CAN 16-bit values

#### Extended Tags (4 bytes)
- 0x20: Timestamp
- 0x33: Speed and course
- 0x44: Acceleration
- 0x90: Driver ID
- 0xC0: Total fuel
- 0xD4: Odometer
- 0xE0: Extended index

#### Special Tags
- 0x03: IMEI (15 bytes)
- 0x30: Coordinates (9 bytes)
- 0x5B: Variable length custom data
- 0x5C: Driver key (68 bytes)
- 0xE1: Command result (variable)

### Protocol Detection Features

#### Message Patterns
- Always starts with header byte (0x01, 0x07, 0x08)
- Length field is little-endian 16-bit
- Tag-based structure allows flexible data
- Checksum at message end

#### Iridium Messages
Special format with identification bytes 0x01 0x00 0x1C

#### Compressed Format
- 10-byte minimal data set
- Bit-packed coordinates and time
- Additional tags follow

## Common Applications

- **Fleet Management**: Commercial vehicle tracking
- **Industrial Monitoring**: Stationary equipment
- **Agriculture**: Farming equipment tracking
- **Construction**: Heavy machinery monitoring
- **Logistics**: Cargo and container tracking
- **Public Transport**: Bus and tram monitoring
- **Emergency Services**: Ambulance/fire tracking
- **Mining**: Equipment in remote locations

## Platform Compatibility

- **Wialon**: Full integration with all features
- **Navixy**: Official support for all models
- **Flespi**: Device type profiles available
- **GPSWOX**: Galileosky device support
- **Fort Monitor**: Native compatibility
- **GPS-Server**: Protocol support
- **Most Russian platforms**: Native support

## Traccar Configuration

```xml
<entry key='galileo.port'>5003</entry>
```

### Protocol Acknowledgments
The protocol requires acknowledgments:
- Standard message (0x01): Reply with 0x02 + checksum
- Photo message (0x07): Reply with 0x07 + checksum

### Advanced Features
- **Easy Logic**: Visual programming for device behavior
- **CAN Scanner**: Automatic CAN bus data detection
- **Hub-to-Hub**: Data relay in areas without coverage
- **Driver App**: Mobile application integration

The Galileo protocol's comprehensive tag system and flexibility make it ideal for complex fleet management and industrial applications requiring extensive telemetry and customization.