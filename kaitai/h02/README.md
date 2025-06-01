# H02 Protocol Documentation

## Overview

The H02 protocol is a mixed protocol supporting both text-based and binary message formats. It's widely used by various GPS tracking devices and clones.

## Device Identification

### Manufacturers
The H02 protocol is implemented by numerous Chinese manufacturers, making it difficult to identify specific brands. Known implementations include:
- Various Shenzhen-based manufacturers
- Multiple OEM/ODM factories
- Rebranded devices from different suppliers

### Commercial Device Models

#### Confirmed H02 Devices
- **LK106** - Confirmed by manufacturer to use complete H02 protocol
- **H02** - Original protocol implementation
- Various devices marketed as "H02 compatible"

#### Commonly Confused Models
Due to the Chinese GPS tracker market's nature, many devices are sold under similar names but may use different protocols:
- Devices labeled as **TK102**, **TK103**, **GT02A** may or may not use H02
- Some **GPS103** variants use H02 protocol
- Various unbranded trackers claiming H02 compatibility

### IMEI Patterns
- Standard 15-digit IMEI format
- Example patterns from real devices:
  - `135790246811220`
  - `865205035331981`
- Binary format uses 5 or 8-byte device ID

### Device Identification Methods

1. **Message Format Detection**
   ```
   * → Text-based H02 message
   $ → Binary H02 message  
   X → Special binary format (32 bytes)
   ```

2. **Protocol Version in Messages**
   - Text messages contain manufacturer code (e.g., "HQ", "hq")
   - Binary messages have fixed-length formats (32 or 45 bytes)

3. **Feature Detection**
   - Support for V1, V3, V4, NBR, LINK message types
   - Binary message length (short vs long format)

### Message Type Support by Device Category

| Device Type | V1 | V4 | NBR | LINK | V3 | VP1 | Binary |
|-------------|----|----|-----|------|----|----|--------|
| Basic H02 | ✓ | | | | | | ✓ |
| Advanced H02 | ✓ | ✓ | ✓ | ✓ | ✓ | | ✓ |
| LBS-capable | | | ✓ | | ✓ | | |
| Simplified | | | | | | ✓ | |

### Common Features

#### Basic Features (All H02 devices)
- GPS positioning
- GSM/GPRS connectivity
- Basic alarms (SOS, vibration, overspeed)
- Remote commands

#### Advanced Features (Model-dependent)
- LBS (cell tower) positioning
- Multiple cell tower reporting (NBR)
- Temperature sensors
- Fuel monitoring
- Odometer
- RFID driver identification
- Battery status reporting

### Important Notes

⚠️ **Warning**: The H02 protocol name is used by many different manufacturers and devices. Features and message format support can vary significantly between devices, even those sold under the same model name.

### Port Configuration
- Default port: 5013 (Traccar)
- Protocol: h02

### Device Verification Tips

1. **Test Message Formats**
   - Send test commands to verify support
   - Monitor which message types the device sends
   - Check if device supports both text and binary

2. **Manufacturer Verification**
   - Text messages starting with `*HQ,` indicate standard implementation
   - Messages with `*hq,` (lowercase) may indicate variants

3. **Binary Format Detection**
   - 32-byte messages: Older devices
   - 45-byte messages: Newer devices with extended ID

4. **Feature Testing**
   - LBS support: Check for NBR messages
   - Command support: Test with known H02 commands

### Known Issues
- Some clones implement only partial H02 protocol
- Binary format interpretation may vary between manufacturers
- Command responses not standardized across all implementations

## Message Format Detection

Messages are identified by their starting character:
- `*` - Text-based messages
- `$` - Binary messages
- `X` - Special binary format (32 bytes)

## Text Message Formats

### Standard Position Message
```
*{manufacturer},{imei},{type},{time},{validity},{latitude},{hemisphere},{longitude},{hemisphere},{speed},{course},{date},{status}#
```

### Message Types

#### V1/V4 - Standard Position
```
*HQ,4210209006,V1,054048,A,2828.2297,N,07733.4332,E,000.5,047,080918,EEE7FBDF#
```
- **V1**: Standard position report
- **V4**: Enhanced position with additional data

#### NBR - Network Based Report (LBS)
```
*HQ,1600068860,NBR,120156,262,03,255,6,802,54702,46,802,5032,37,802,54782,30,081116,FFFFFBFF#
```
- Used for cell tower based positioning
- Format: MCC, MNC, count, followed by cell data (LAC, CID, signal)

#### LINK - Status Update
```
*HQ,1700086468,LINK,180902,15,0,84,0,0,240517,FFFFFBFF#
```
- Fields: time, RSSI, satellites, battery, steps, turnovers, date, status

#### V3 - Cell Tower Info
```
*HQ,353111080001055,V3,044855,28403,01,001450,011473,158,-62,0292,0,X,030817,FFFFFBFF#
```
- Contains MCC+MNC combined, cell count, and cell information

#### VP1 - Alternative Position
```
*hq,356327080425330,VP1,A,2702.7245,S,15251.9311,E,0.48,0.0000,080917#
```
- Simplified position format
- Note: lowercase "hq" prefix

#### HTBT - Heartbeat
```
*HQ,135790246811220,HTBT,100#
```
- Keep-alive message with battery percentage

## Binary Message Format

Binary messages start with `$` and come in two lengths:

### Short Format (32 bytes)
```
Offset | Length | Description
-------|--------|-------------
0      | 1      | Marker ('$')
1      | 5      | Device ID
6      | 6      | Time (BCD: HH MM SS DD MM YY)
12     | 9      | Latitude (BCD)
21     | 1      | Battery level
22     | 10     | Longitude (BCD)
32     | 1      | Flags
33     | 3      | Speed (BCD)
36     | 3      | Course (BCD)
39     | 4      | Status
```

### Long Format (45 bytes)
- Extended device ID (8 bytes instead of 5)
- Same structure otherwise, with offsets adjusted

## Coordinate Formats

The protocol supports multiple coordinate representations:

### Text Formats
1. **Decimal degrees**: `23.456789` or `-23.456789`
2. **Degrees and decimal minutes**: `2345.6789` (23° 45.6789')
3. **Degrees, minutes, decimal seconds**: `23456789` (23° 45' 67.89")
4. **Special format**: `-23-45.6789`

### Binary Format
- BCD encoded with custom parsing
- Hemisphere indicated by flags byte

## Status Field

32-bit status field with various flags:

| Bit | Description | Values |
|-----|-------------|---------|
| 0 | Vibration alarm | 0=alarm, 1=normal |
| 1 | SOS alarm | 0=alarm, 1=normal |
| 2 | Overspeed alarm | 0=alarm, 1=normal |
| 10 | Ignition | 0=off, 1=on |
| 18 | SOS (alternative) | 1=alarm |
| 19 | Power cut alarm | 0=alarm, 1=normal |

## Commands

### Supported Commands
- **Alarm Arm**: `*HQ,{id},SCF,{time},0,0#`
- **Alarm Disarm**: `*HQ,{id},SCF,{time},1,1#`
- **Engine Stop**: `*HQ,{id},S20,{time},1,1#`
- **Engine Resume**: `*HQ,{id},S20,{time},1,0#`
- **Set Interval**: `*HQ,{id},S71,{time},22,{seconds}#`

### Response Format
- **V1 ACK**: `*HQ,{id},V1,{hhmmss}#`
- **R12 ACK**: `*HQ,{id},R12,{yyyyMMddHHmmss}#`
- **NBR ACK**: `*HQ,{id},NBR,{hhmmss}#`

## Optional Fields

Messages may include additional data:
- Odometer (distance traveled)
- Temperature sensors
- Fuel level
- Altitude
- LAC/CID (cell tower IDs)
- Custom I/O values
- SIM card ICCID

## Time Formats

- **Text**: `HHMMSS` (6 digits)
- **Date**: `DDMMYY` (6 digits)
- **Binary**: BCD encoded bytes

## Validity Indicators

- `A` - Valid GPS fix
- `V` - Invalid GPS fix (no satellites)

## Example Messages

### Valid Position
```
*HQ,1234567890,V1,120000,A,2234.5678,N,11345.6789,E,012.3,045,010120,FFFFFBFF#
```

### Cell Tower Only
```
*HQ,1234567890,NBR,120000,460,00,255,4,17338,40988,25,17339,40989,20,17337,40987,15,17336,40986,10,010120,FFFFFBFF#
```

### Binary Position (Hex)
```
24 31 32 33 34 12 00 00 01 01 20 22 34 56 78 00 00 90 11 34 56 78 90 00 12 30 00 04 50 00 FF FF FB FF
```