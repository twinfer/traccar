# Huabao JT/T 808 Protocol Documentation

## Overview

The Huabao protocol implements the Chinese national standard JT/T 808 for GPS tracking and vehicle monitoring systems. It's a binary protocol with sophisticated framing, escape sequences, and comprehensive vehicle diagnostics support.

## Device Identification

### Standard
**JT/T 808** - Chinese National Standard for GPS Vehicle Tracking
- Administered by: Ministry of Transport of China
- Used by: Chinese domestic GPS tracking device manufacturers

### Commercial Device Models

#### Common Manufacturers
Multiple Chinese manufacturers implement JT/T 808, including:
- **Huabao** - Original protocol implementer
- **Jimi IoT** - JimiIoT series devices
- **Concox** - Some models support JT/T 808
- **Suntech** - Chinese market variants
- **Coban** - JT/T 808 compatible models
- **Various OEM manufacturers** across China

#### Device Categories by Message Support

| Category | Standard | Alternative | Text | Features |
|----------|----------|-------------|------|----------|
| **Basic Trackers** | ✓ | | | GPS, LBS, basic alarms |
| **Vehicle Terminals** | ✓ | ✓ | ✓ | Full JT/T 808 compliance |
| **Fleet Devices** | ✓ | ✓ | ✓ | OBD, CAN, driver management |
| **Advanced Terminals** | ✓ | ✓ | ✓ | Video, WiFi, acceleration |

### IMEI/Device ID Patterns
- Device ID: 6 bytes (standard) or 7 bytes (alternative mode)
- Encoding: Binary representation of IMEI or device serial
- Checksum: Luhn algorithm for IMEI validation
- Example device IDs:
  - Standard 6-byte: `862470041866622` → Binary representation
  - Alternative 7-byte: Extended format for newer devices

### Device Identification Methods

1. **Frame Delimiter Detection**
   ```
   0x7E → Standard JT/T 808 device
   0xE7 → Alternative/extended device
   (text) → Configuration response mode
   ```

2. **Message Type Analysis**
   Different device capabilities revealed by supported message types:
   - Basic: 0x0001, 0x0002, 0x0100, 0x0102, 0x0200
   - Advanced: 0x0704, 0x0900, 0x2070, 0x5501, 0x5502
   - Fleet: Full message type support including multimedia

3. **Extension Field Support**
   Device capabilities indicated by extension fields in location reports:
   - 0x01: Odometer support
   - 0x51: Temperature sensors
   - 0x80/0xF3: OBD-II capability
   - 0xEB: Network positioning (LBS/WiFi)

### Port Configuration
- Default port: 5026 (Traccar)
- Protocol: huabao

## Protocol Structure

### Frame Format

All messages are wrapped in escape-encoded frames:

```
[DELIMITER] [MESSAGE_TYPE] [ATTRIBUTES] [DEVICE_ID] [SEQUENCE] [DATA] [CHECKSUM] [DELIMITER]
     1           2             2           6/7        1/2       N        1          1
```

### Frame Delimiters and Escape Sequences

#### Standard Mode (0x7E)
- **Frame delimiter**: `0x7E`
- **Escape sequences**:
  - `0x7D 0x01` → `0x7D` (literal 0x7D)
  - `0x7D 0x02` → `0x7E` (literal 0x7E)

#### Alternative Mode (0xE7)  
- **Frame delimiter**: `0xE7`
- **Escape sequences**:
  - `0xE6 0x01` → `0xE6` (literal 0xE6)
  - `0xE6 0x02` → `0xE7` (literal 0xE7)
  - `0x3E 0x01` → `0x3E` (literal 0x3E)
  - `0x3E 0x02` → `0x3D` (literal 0x3D)

### Attributes Field

16-bit field containing message properties:
- **Bits 0-9**: Data length (0-1023 bytes)
- **Bit 10**: Encryption flag (0=no, 1=RSA encrypted)
- **Bit 13**: Fragmentation flag (0=complete, 1=fragmented)
- **Bits 14-15**: Reserved

### Message Types

#### Device to Server
| Type | Name | Description |
|------|------|-------------|
| 0x0001 | Terminal Response | Response to server commands |
| 0x0002 | Heartbeat | Keep-alive signal |
| 0x0100 | Terminal Register | Device registration |
| 0x0102 | Terminal Authentication | Authentication with code |
| 0x0200 | Location Report | Real-time position |
| 0x0210 | Location Batch Type 2 | Bulk position data (variant) |
| 0x0704 | Location Batch | Bulk position data |
| 0x0900 | Transparent Data | Pass-through data |
| 0x2070 | Acceleration Data | G-force sensor readings |
| 0x5501 | Location Report Type 2 | Alternative position format |
| 0x5502 | Location Report Blind | Position without extensions |

#### Server to Device
| Type | Name | Description |
|------|------|-------------|
| 0x8001 | General Response | Acknowledge device messages |
| 0x8100 | Register Response | Registration acknowledgment |
| 0x8103 | Configuration Parameters | Device configuration |
| 0x8105 | Terminal Control | Remote device control |
| 0x8109 | Time Sync Response | Time synchronization |
| 0x8300 | Send Text Message | Display message to driver |

## Location Report Structure

### Core Location Data
```
[ALARM_FLAGS] [STATUS_FLAGS] [LATITUDE] [LONGITUDE] [ALTITUDE] [SPEED] [COURSE] [TIMESTAMP] [EXTENSIONS...]
      4             4            4          4          2         2        2         6           N
```

#### Coordinate Format
- **Latitude/Longitude**: Degrees × 1,000,000 (32-bit unsigned)
- **Range**: 0-90° (latitude), 0-180° (longitude)
- **Hemisphere**: Determined by status flags
- **Precision**: 6 decimal places

#### Time Format (BCD Encoded)
```
[YY] [MM] [DD] [HH] [MM] [SS]
 1    1    1    1    1    1
```
- Year: 2-digit BCD (e.g., 0x21 = 2021)
- All fields in BCD format

### Status Flags (32-bit)

| Bit | Description | Values |
|-----|-------------|--------|
| 0 | ACC status | 0=off, 1=on |
| 1 | Location status | 0=invalid, 1=valid |
| 2 | Latitude hemisphere | 0=north, 1=south |
| 3 | Longitude hemisphere | 0=east, 1=west |
| 4 | Operating status | 0=normal, 1=emergency |
| 5-7 | Reserved | |
| 8-9 | Positioning type | 00=GPS, 01=Beidou, 10=GLONASS, 11=Galileo |
| 10 | Encryption status | 0=unencrypted, 1=encrypted |
| 11-13 | Load status | Vehicle load information |
| 18 | Fuel circuit | 0=normal, 1=disconnected |
| 19 | Power circuit | 0=normal, 1=disconnected |
| 20 | Door status | 0=locked, 1=unlocked |

### Alarm Flags (32-bit)

| Bit | Alarm Type | Description |
|-----|------------|-------------|
| 0 | Emergency button | SOS activated |
| 1 | Overspeed | Speed limit exceeded |
| 2 | Fatigue driving | Driving time exceeded |
| 3 | Dangerous driving | Harsh acceleration/braking |
| 4 | GNSS module failure | GPS hardware issue |
| 5 | GNSS antenna disconnected | Antenna cable issue |
| 6 | GNSS antenna short circuit | Antenna short |
| 7 | Terminal main power undervoltage | Low voltage |
| 8 | Terminal main power disconnected | Power loss |
| 9 | LCD failure | Display malfunction |
| 10 | TTS module failure | Voice system issue |
| 11 | Camera failure | Camera malfunction |
| 16 | Cumulative driving timeout | Max driving time |
| 17 | Parked timeout | Extended parking |
| 18 | Entering restricted area | Geofence entry |
| 19 | Leaving restricted area | Geofence exit |
| 20 | Entering route | Route adherence |
| 21 | Leaving route | Route deviation |
| 22 | Insufficient driving time | Min driving time |
| 23 | Route deviation | Off planned route |
| 24 | Vehicle VSS failure | Speed sensor issue |
| 25 | Vehicle fuel abnormal | Fuel system alarm |
| 26 | Vehicle stolen | Theft alarm |
| 27 | Vehicle illegal ignition | Unauthorized start |
| 28 | Vehicle illegal displacement | Unauthorized movement |
| 29 | Collision rollover alarm | Impact detected |
| 30 | Rollover alarm | Vehicle overturned |
| 31 | Illegal door opening | Unauthorized access |

## Extension Fields

Location reports support variable-length extension fields:

### Extension Format
```
[TYPE] [LENGTH] [DATA]
  1       1       N
```

### Common Extension Types

#### 0x01 - Odometer
```
[ODOMETER_KM]
     4 bytes
```
- Unit: kilometers
- Format: 32-bit unsigned integer

#### 0x02 - Fuel Level
```
[FUEL_LEVEL]
   2 bytes
```
- Unit: 0.1L
- Format: 16-bit unsigned integer

#### 0x30 - RSSI (Signal Strength)
```
[RSSI]
  1 byte
```
- Unit: dBm
- Format: 8-bit unsigned integer

#### 0x31 - Satellite Count
```
[SATELLITE_COUNT]
     1 byte
```
- Number of visible satellites
- Format: 8-bit unsigned integer

#### 0x51 - Temperature Sensors
```
[TEMP1] [TEMP2] ... [TEMPN]
   2      2           2
```
- Unit: 0.1°C
- Format: 16-bit signed integer per sensor

#### 0x56 - Battery Level
```
[BATTERY_PERCENTAGE]
       1 byte
```
- Unit: percentage (0-100)
- Format: 8-bit unsigned integer

#### 0x69 - Battery Voltage
```
[BATTERY_VOLTAGE]
     2 bytes
```
- Unit: 0.1V
- Format: 16-bit unsigned integer

#### 0x80 - OBD Data
```
[OBD_VALUES...]
      N bytes
```
- Variable length OBD-II data
- Format: Vendor-specific

#### 0xEB - Network Positioning Data
```
[TYPE] [NETWORK_DATA...]
  1         N bytes
```

**Type 0x01 - Cell Tower**:
```
[MCC] [MNC] [LAC] [CELL_ID] [RSSI]
  2     2     2       4       1
```

**Type 0x02 - WiFi**:
```
[COUNT] [AP1_MAC] [AP1_RSSI] [AP2_MAC] [AP2_RSSI] ...
   1        6         1         6         1
```

#### 0xF3 - Advanced OBD Data
```
[ADVANCED_OBD_FIELDS...]
         N bytes
```
- Extended OBD-II parameters
- Format: Protocol-specific

## Message Examples

### Terminal Registration (0x0100)
```
7E 01 00 00 2F 01 39 38 36 39 31 30 30 00 01 00 00 00 01 00 00 00 02 D4 01 04 00 00 00 65 02 04 00 00 00 05 03 02 00 1E 04 02 01 2C 18 01 01 2B
```

### Location Report (0x0200)
```
7E 02 00 00 1A 01 39 38 36 39 31 30 00 01 00 00 00 00 00 00 00 00 01 CC CC CC 7F 00 28 7D 00 1F 71 00 2E 19 05 10 18 15 15 01 04 00 00 00 01 30 01 00 36 7E
```

### Heartbeat (0x0002)
```
7E 00 02 00 00 01 39 38 36 39 31 30 00 01 31 7E
```

### Location Batch (0x0704)
```
7E 07 04 00 3C 01 39 38 36 39 31 30 00 02 00 02 00 00 1A [LOCATION_DATA_1] 00 1A [LOCATION_DATA_2] 7D 01 7E
```

## Checksum Calculation

XOR checksum of all bytes between start and end delimiters (excluding delimiters):
```python
checksum = 0
for byte in message_content:
    checksum ^= byte
```

## Time Zone Handling

- Default: GMT+8 (China Standard Time)
- BCD encoded: YYMMDDHHMMSS
- All timestamps in local time unless configured otherwise

## Authentication Process

1. **Device sends Terminal Register (0x0100)**
   - Province ID, City ID
   - Manufacturer ID, Device Model
   - Device ID, Plate information

2. **Server responds with Register Response (0x8100)**
   - Result code (0=success)
   - Authentication code (if successful)

3. **Device sends Terminal Authentication (0x0102)**
   - Authentication code from step 2

4. **Server responds with General Response (0x8001)**
   - Acknowledges authentication

## Configuration Parameters

Devices can be configured via Configuration Parameters message (0x8103):

### Common Parameters
- 0x0001: Heartbeat interval (seconds)
- 0x0002: TCP timeout (seconds)
- 0x0003: TCP retransmission count
- 0x0004: UDP timeout (seconds)
- 0x0005: UDP retransmission count
- 0x0010: Main server APN
- 0x0011: Main server username
- 0x0012: Main server password
- 0x0013: Main server IP/domain
- 0x0018: Server TCP port
- 0x0019: Server UDP port
- 0x001A: Location reporting strategy
- 0x001B: Location reporting scheme
- 0x001C: Driver offline reporting interval
- 0x001D: Sleep mode reporting interval
- 0x001E: Emergency alarm reporting interval
- 0x001F: Default reporting interval

## Advanced Features

### Multimedia Support
- Photo/video transmission via transparent data
- Audio recording and playback
- TTS (Text-to-Speech) messages

### Fleet Management
- Driver identification via RFID
- Route planning and monitoring
- Fuel consumption tracking
- Vehicle maintenance scheduling

### Security Features
- RSA encryption support
- Device authentication
- Anti-tampering alarms
- Emergency response

### Regulatory Compliance
- Chinese taxi regulation compliance
- Commercial vehicle monitoring
- Driver behavior analysis
- Accident reconstruction data