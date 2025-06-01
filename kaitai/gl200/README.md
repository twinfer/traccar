# GL200 Protocol Documentation

## Overview

The GL200 protocol is used by Queclink GPS tracking devices. It's primarily a text-based protocol with comma-separated values, though it also supports binary format messages.

## Device Identification

### Manufacturer
**Queclink Wireless Solutions** - Based in Shanghai, China

### Commercial Device Models
Queclink devices can be identified by protocol version prefixes in their messages:

| Prefix | Model | Description |
|--------|-------|-------------|
| `02`, `21` | GL200 | Portable GPS tracker, 1300mAh battery, waterproof |
| `04`, `35` | GV200 | Vehicle tracker |
| `06`, `25` | GV300 | Advanced vehicle tracker |
| `08` | GMT100 | Asset tracker |
| `09` | GV50P | Compact tracker |
| `0F`, `2F` | GV55 | Small vehicle tracker |
| `10` | GV55 LITE | Budget version of GV55 |
| `11`, `40` | GL500 | Advanced portable tracker |
| `1A`, `30` | GL300 | Updated portable tracker |
| `1F`, `36` | GV500 | Professional vehicle tracker |
| `27` | GV300W | Waterproof variant |
| `28` | GL300VC | Voice-capable variant |
| `2C` | GL300W | Waterproof portable tracker |
| `2D` | GV500VC | Voice-capable variant |
| `31` | GV65 | Compact tracker |
| `3F` | GMT100 | Asset tracker variant |
| `41` | GV75W | Waterproof tracker |
| `42` | GT501 | Advanced tracker |
| `44` | GL530 | Multi-functional tracker |
| `45` | GB100 | Basic tracker |
| `50` | GV55W | Waterproof variant |
| `52` | GL50 | Entry-level tracker |
| `55` | GL50B | Battery-powered variant |
| `5E` | GV500MAP | Mapping-focused variant |
| `6E` | GV310LAU | Regional variant |
| `BD` | CV200 | Commercial vehicle tracker |
| `C2` | GV600M | Multi-functional tracker |
| `DC` | GV600MG | Global variant |
| `DE` | GL500M | Multi-mode tracker |
| `F1` | GV350M | Professional tracker |
| `F8` | GV800W | 8-channel tracker |
| `FC` | GV600W | Waterproof variant |
| `802004` | GV58LAU | Regional variant |
| `802005` | GV355CEU | European variant |

### IMEI Patterns
- Standard 15-digit IMEI format
- Example patterns from real devices:
  - `862599050544301`
  - `868589060745174`
- Older GL200 hardware versions with IMEI between `35946403600001X` and `35946403607338X` do not support output functions

### Key Features by Model
- **GL200**: Portable, waterproof IP65, 1300mAh battery, 3-axis accelerometer, temperature sensor
- **GL300 Series**: Enhanced battery life, multiple I/O ports
- **GV Series**: Vehicle-focused with OBD support, harsh driving detection
- **GMT Series**: Asset tracking optimized, long battery life
- **W Suffix**: Waterproof variants (IP67)
- **VC Suffix**: Voice communication capability
- **M Suffix**: Multi-mode or enhanced functionality

### Port Configuration
- Default port: 5004 (Traccar)
- Protocol: gl200

## Protocol Structure

### Text Message Format
```
+<PREFIX>:<MSG_TYPE>,<fields...>,<checksum>$
```

- **PREFIX**: `RESP`, `BUFF`, or `ACK`
- **MSG_TYPE**: 3-letter code identifying message type
- **fields**: Comma-separated values
- **checksum**: Optional checksum
- **$**: Optional message terminator

### Common Message Types

#### Location Reports
- **FRI** - Fixed Report Information (regular positions)
- **ERI** - Extended Report Information (with additional data)
- **RTL** - Real-time location
- **STR** - Store location report

#### Events
- **IGN/IGF** - Ignition on/off
- **STT/STP** - Motion start/stop
- **SOS** - Emergency button
- **SPD** - Overspeed alert
- **TOW** - Tow alert
- **HBM** - Harsh behavior (brake/acceleration)
- **GEO** - Geofence alert

#### Vehicle Data
- **OBD** - OBD-II diagnostic data
- **CAN** - CAN bus data
- **FRI** - Fuel information (when mask includes fuel)

#### Network & Sensors
- **GSM** - Cell tower information
- **WIF** - WiFi access points
- **BAA/BID** - Bluetooth accessories
- **TMP/TEM** - Temperature sensors
- **LSA** - Light sensor

#### System
- **INF** - Device information
- **HBD** - Heartbeat
- **ACK** - Command acknowledgment

## Field Types

### Location Fields
1. **Timestamp**: `yyyyMMddHHmmss` (UTC)
2. **Latitude**: Decimal degrees (positive=North)
3. **Longitude**: Decimal degrees (positive=East)
4. **Altitude**: Meters
5. **Speed**: km/h
6. **Course**: Degrees (0-360)
7. **Satellites**: Number of GPS satellites
8. **HDOP**: Horizontal dilution of precision

### Device Fields
1. **Protocol Version**: 6 or 10 characters
2. **IMEI**: 15 digits or 14 hex characters
3. **Device Name**: String identifier
4. **Report Mask**: Hex value indicating present fields
5. **Battery**: Voltage (V) or percentage
6. **Power**: External power (mV)

### Network Fields
1. **MCC**: Mobile Country Code
2. **MNC**: Mobile Network Code
3. **LAC**: Location Area Code
4. **Cell ID**: Cell tower ID
5. **RSSI**: Signal strength

## Report Masks

The report mask is a hexadecimal value that indicates which optional fields are present in the message.

### Common Mask Bits
- Bit 0: External power
- Bit 1: Battery
- Bit 2: Motion status
- Bit 3: Acceleration data
- Bit 4: Temperature
- Bit 5: Fuel level
- Bit 6: CAN data
- Bit 7: Digital inputs

## Example Messages

### Location Report (FRI)
```
+RESP:GTFRI,3C0102,867162025009031,,0,0,1,1,0.0,0,2258.4,-79.851134,43.902219,20230515143020,0310,0260,0000,0000,0.0,20230515143020,0001$
```

### Ignition On (IGN)
```
+RESP:GTIGN,3C0102,867162025009031,,0,0,0,1,0.0,0,2258.4,-79.851134,43.902219,20230515143020,0310,0260,0000,0000,0.0,20230515143020,0001$
```

### OBD Data
```
+RESP:GTOBD,3C0102,867162025009031,,1,0,60,15.2,89,1250,12.5,0,0,0,0,0,2258.4,-79.851134,43.902219,20230515143020,0310,0260,0000,0000,0.0,20230515143020,0001$
```

## Device Models

The protocol version prefix identifies the device model:

- **02/21**: GL200
- **04/35**: GV200
- **06/25**: GV300
- **1A/30**: GL300
- **1F/36**: GV500
- **C2**: GV600M
- **DE**: GL500M
- **F1**: GV350M

## Special Parsing Rules

1. **Empty Fields**: Empty fields between commas should be treated as null
2. **Analog Inputs**: Values prefixed with 'F' are fuel sensors
3. **Time Format**: All timestamps are in UTC
4. **Coordinate Format**: Decimal degrees, negative for South/West
5. **Status Bits**: Binary status fields encode multiple boolean values