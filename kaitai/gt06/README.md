# GT06 Protocol Documentation

## Overview

The GT06 protocol is a binary protocol used by many Chinese GPS tracking devices. It's one of the most widely cloned and implemented protocols in the GPS tracking industry.

## Device Identification

### Manufacturers
Multiple Chinese manufacturers produce GT06-compatible devices, primarily based in Shenzhen, China. Common brands include:
- Concox
- Coban
- ReachFar
- Dyegoo
- Jimi IoT
- Various OEM manufacturers

### Commercial Device Models

#### GT Series
- **GT02** - Basic vehicle tracker
- **GT02A** - Enhanced version
- **GT06** - Most common model, widely cloned
- **GT06N** - Updated version with additional features
- **GT06E** - Extended functionality variant

#### Device-Specific Models (identified by message types)
| Model | Identifying Features | Message Types |
|-------|---------------------|---------------|
| **JI09** | Jimi device | Uses MSG_GPS_LBS_EXTEND (0x1E) |
| **GK310** | | Uses MSG_HEARTBEAT (0x23), MSG_ADDRESS_REQUEST (0x2A) |
| **AZ735** | | Uses MSG_GPS_LBS_5 (0x31), special status messages |
| **SL4X** | | Uses MSG_WIFI_5 (0x33), MSG_LBS_3 (0x34) |
| **Jimi IoT 4G** | 4G capable | Uses MSG_STATUS_2 (0x36) |
| **JM-VL03** | | Uses MSG_GPS_LBS_7 (0xA0) |

#### Clone/Compatible Models
The GT06 protocol is also used by devices sold under names:
- **TK100** to **TK116** series
- **GPS103** (some variants)
- Various unbranded Chinese trackers

### IMEI Patterns
- Standard 15-digit IMEI format
- Example patterns from real devices:
  - `086471700328358`
  - `862798052429087`
- Login message contains 8-byte BCD encoded IMEI

### Device Identification Methods

1. **Message Type Analysis**
   - Different models support different message type sets
   - Extended message types (>0x80) often indicate newer models

2. **Device Type ID**
   - Sent in login message (2 bytes after IMEI)
   - Manufacturer-specific codes

3. **Protocol Behavior**
   - Some models send specific message sequences
   - Heartbeat intervals can vary by model

### Common Features by Model

#### Basic Models (GT02, GT06)
- GPS + LBS positioning
- Basic status reporting
- SMS commands support
- 2G connectivity

#### Advanced Models (GT06N, GT06E)
- Multiple positioning modes (GPS + LBS + WiFi)
- OBD-II support (some variants)
- Voice monitoring capability
- Fuel monitoring
- Temperature sensors
- Multiple I/O ports

#### 4G Models
- LTE connectivity with 2G/3G fallback
- Enhanced data transmission
- Video/photo capability (some models)

### Important Notes

⚠️ **Warning**: Due to widespread cloning, devices sold as "GT06" may vary significantly in features and protocol implementation. Always test the specific device to confirm compatibility.

### Port Configuration
- Default port: 5023 (Traccar)
- Protocol: gt06
- Some clones may use modified protocols requiring different ports

### Clone Identification Tips
1. Check the login packet's device type ID
2. Monitor which message types the device sends
3. Test command compatibility
4. Verify CRC calculation method (some clones use different algorithms)

## Protocol Structure

### Packet Format

```
+--------+--------+---------+------+--------+-----+--------+
| Header | Length | Msg Type| Data | Serial | CRC | Footer |
+--------+--------+---------+------+--------+-----+--------+
| 2 bytes| 1-2 b  | 1 byte  | var  | 2 bytes| 2 b | 2 bytes|
+--------+--------+---------+------+--------+-----+--------+
```

- **Header**: `0x7878` (standard) or `0x7979` (extended length)
- **Length**: Packet length (1 byte for standard, 2 bytes for extended)
- **Message Type**: Command/response identifier
- **Data**: Variable length payload
- **Serial Number**: Message sequence number
- **CRC**: CRC16-X25 checksum
- **Footer**: `0x0D0A` (CRLF)

## Message Types

### Core Messages
| Type | Value | Description |
|------|-------|-------------|
| LOGIN | 0x01 | Device authentication |
| GPS | 0x10 | GPS location only |
| GPS_LBS_1 | 0x12 | GPS + Cell tower location |
| STATUS | 0x13 | Device status |
| HEARTBEAT | 0x23 | Keep-alive signal |
| GPS_LBS_STATUS_1 | 0x16 | GPS + LBS + Status combined |
| GPS_LBS_STATUS_2 | 0x26 | Variant 2 |
| GPS_LBS_STATUS_3 | 0x27 | Variant 3 |

### Extended Messages
| Type | Value | Description |
|------|-------|-------------|
| STRING | 0x15 | String information |
| ALARM | 0x95 | Alarm notification |
| COMMAND_0 | 0x80 | Server command |
| COMMAND_1 | 0x81 | Server command variant |
| TIME_REQUEST | 0x8A | Time synchronization |
| INFO | 0x94 | Device information |
| OBD | 0x8C | OBD-II data |

### Network Messages
| Type | Value | Description |
|------|-------|-------------|
| LBS_STATUS | 0x19 | Cell tower + Status |
| WIFI | 0x17 | WiFi access points |
| LBS_WIFI | 0x2C | Combined LBS + WiFi |
| LBS_MULTIPLE | 0x28 | Multiple cell towers |
| LBS_EXTEND | 0x18 | Extended LBS data |

## Data Structures

### Login Message (0x01)
```
IMEI (8 bytes, BCD) + Type ID (2 bytes) + [Time Zone (2 bytes)]
```

### GPS Data
```
Date/Time (6 bytes) + GPS Info + Satellites (1 byte) + 
Latitude (4 bytes) + Longitude (4 bytes) + Speed (1 byte) + 
Course/Flags (2 bytes)
```

### LBS (Cell Tower) Data
```
MCC (2 bytes) + MNC (1-2 bytes) + LAC (2-4 bytes) + Cell ID (3-8 bytes)
```

### Status Byte
- Bit 0: Terminal information
- Bit 1: Ignition (0=off, 1=on)
- Bit 2: GPS tracking on/Charge status
- Bits 3-5: Alarm type
- Bit 6: Reserved
- Bit 7: Defense activated

### Alarm Types
- 0: Normal
- 1: SOS
- 2: Power cut
- 3: Vibration
- 4: Enter fence
- 5: Exit fence
- 6: Over speed
- 7: Movement

## Coordinate Format

- **Latitude/Longitude**: Stored as minutes × 30000
- **Sign**: Determined by bits in course/flags field
  - Bit 10: 0=North/South+, 1=South-
  - Bit 11: 0=East+, 1=West-

## CRC Calculation

CRC16-X25 algorithm:
- Polynomial: 0x1021
- Initial value: 0xFFFF
- Calculated from length byte to serial number (inclusive)

## Response Format

Server must acknowledge most messages with same structure:
```
Header + Length + Type + Serial + CRC + Footer
```

## Device Variants

Different manufacturers may extend the protocol:
- **Standard GT06**: Basic implementation
- **GT06E**: Extended with additional features
- **JC400**: Video-capable devices
- **WANWAY S20**: Solar-powered variants
- **OBD6**: OBD-II integrated devices

## Example Messages

### Login Request
```
78 78 0D 01 03 51 60 80 80 80 80 01 00 01 8C DD 0D 0A
```

### GPS + LBS + Status
```
78 78 1F 12 0E 03 1D 0A 09 0C C6 02 7A C8 18 0C 46 58 60 00 14 00 01 CC 00 28 7D 00 1F 71 00 00 01 00 08 20 86 0D 0A
```

### Heartbeat
```
78 78 0A 23 00 00 01 00 01 00 3B 0D 0A
```

## Implementation Notes

1. **Byte Order**: Big-endian for multi-byte fields
2. **Time Zone**: Some devices send time zone offset
3. **Variable Length**: Some fields vary by device model
4. **Validation**: Always verify CRC before processing
5. **Acknowledgment**: Most messages require server response