# GoSafe GPS Tracker Protocol

## Overview

GoSafe is a comprehensive GPS tracking protocol that supports both text-based and binary message formats. It's widely used in fleet management, vehicle tracking, and asset monitoring applications across various industries.

## Protocol Specifications

### Text Protocol Format
```
*GS<version>,<imei>,<data>#
```

**Example:**
```
*GS06,123456789012345,121201A2934.0133N10627.2544E240.040331309A##
```

### Binary Protocol Format
```
[0xF8][version][type][imei(7)][timestamp(4)][event][mask(2)][data][0xF8]
```

**Frame Structure:**
- **Start Delimiter**: 0xF8
- **Protocol Version**: 1 byte
- **Message Type**: 1 byte (0x41 = event)
- **IMEI**: 7 bytes (uint32 + uint24)
- **Timestamp**: 4 bytes (seconds since 2000-01-01)
- **Event ID**: 1 byte (if event message)
- **Data Mask**: 2 bytes (indicates present sections)
- **Data Sections**: Variable length
- **End Delimiter**: 0xF8

### Escape Sequences (Binary)
- `0x1B 0x00` → `0x1B`
- `0x1B 0xE3` → `0xF8`

## Data Sections

### GPS Section
- **Validity**: A (valid) / V (invalid)
- **Satellites**: Number of satellites
- **Coordinates**: Latitude/longitude (degrees)
- **Speed**: km/h
- **Course**: Degrees (0-360)
- **Altitude**: Meters
- **HDOP/VDOP**: Dilution of precision

### GSM Section
- **Registration Status**: Network state
- **Signal Strength**: 0-31 scale
- **Cell Info**: MCC, MNC, LAC, CID
- **RSSI**: Signal strength

### COT (Counter) Section
- **Odometer**: Total distance
- **Engine Hours**: Format HH-MM-SS

### ADC (Analog) Section
- **Power**: Main voltage
- **Battery**: Backup voltage
- **ADC1/ADC2**: Additional inputs

### DTT (Digital I/O) Section
- **Status**: Device status flags
- **I/O State**: 8-bit digital I/O
  - Bit 0: Ignition
  - Bits 1-4: Inputs 1-4
  - Bits 5-7: Outputs 1-3
- **Geofence**: Enter/exit IDs
- **Event Status**: Current state

### Additional Sections
- **ETD**: Event data
- **OBD**: OBD-II diagnostics
- **TAG**: RFID/tag data
- **IWD**: Driver ID/temperature sensors
- **SYS**: System information

## Supported Manufacturers

### Primary Manufacturer
- **GoSafe Technology Co., Ltd.**
  - G1S, G2S, G737, G739, G758, G787, G866, G980

### Compatible OEM Manufacturers
- **OriginalGPS**: OG300, OG400 series
- **Fleet Complete**: FC100, FC200
- **Omnitracs**: XRS platform compatible
- **PacWest**: PW300, PW400
- **AssetTrackr**: AT100, AT200
- **FleetLocate**: FL300 series
- **GPSGate**: Various OEM devices
- **Wialon**: Compatible hardware

## Device Model Variants

| ID | Model | Description |
|----|-------|-------------|
| 0 | G1S | Basic GPS/GSM tracker |
| 1 | G2S | OBD-II enhanced tracker |
| 2 | G737 | Professional fleet device |
| 3 | G739 | Heavy-duty CAN bus tracker |
| 4 | G758 | Long-life asset tracker |
| 5 | G787 | Advanced telematics gateway |
| 6 | G866 | Motorcycle/bike tracker |
| 7 | G980 | High-end camera-equipped |
| 8+ | OEM variants | Various OEM implementations |

## Event Codes

| Code | Event | Description |
|------|-------|-------------|
| 0x01 | Ignition On | Vehicle started |
| 0x02 | Ignition Off | Vehicle stopped |
| 0x03 | Panic Button | Emergency activation |
| 0x04 | Geofence Enter | Entered geofence |
| 0x05 | Geofence Exit | Exited geofence |
| 0x06 | Overspeed | Speed limit exceeded |
| 0x07 | Low Battery | Battery level low |
| 0x08 | Power Disconnect | Main power lost |
| 0x09 | SOS Alarm | Emergency SOS |
| 0x0A | Idle Start | Vehicle idling |
| 0x0B | Idle End | Idling stopped |
| 0x0C | Engine Start | Engine started |
| 0x0D | Engine Stop | Engine stopped |
| 0x0E | Harsh Acceleration | Aggressive driving |
| 0x0F | Harsh Braking | Hard braking |
| 0x10 | Harsh Cornering | Sharp turn |
| 0x11 | Accident Detection | Collision detected |

## Usage Examples

### Text Message Parsing
```python
# Example text message
message = "*GS06,123456789012345,121201A2934.0133N10627.2544E240.040331309A#"

# Parse with Kaitai
gosafe_msg = Gosafe.from_bytes(message.encode())
print(f"IMEI: {gosafe_msg.text_message.imei}")
print(f"Protocol: {gosafe_msg.text_message.protocol_version}")
```

### Binary Message Parsing
```python
# Example binary message (after escape sequence processing)
binary_data = bytes([0xF8, 0x06, 0x41, ...])

# Parse with Kaitai
gosafe_msg = Gosafe.from_bytes(binary_data)
print(f"IMEI: {gosafe_msg.binary_message.imei_full}")
print(f"Timestamp: {gosafe_msg.binary_message.timestamp_unix}")
```

## Implementation Notes

### Frame Decoding
1. **Text Protocol**: Look for `*GS` start and `#` end
2. **Binary Protocol**: Handle escape sequences before parsing
3. **Multi-Position**: Text messages can contain multiple positions separated by `$`

### Coordinate Conversion
- **Text**: Degrees in decimal format
- **Binary**: Divide by 1,000,000 for degrees

### Timestamp Handling
- **Binary**: Add 946,684,800 to convert from GoSafe epoch (2000-01-01) to Unix epoch (1970-01-01)
- **Text**: Parse datetime fields according to protocol version

### Bitmask Processing
Binary protocol uses bitmasks to indicate which data sections are present:
- Bit 0: SYS section
- Bit 1: GPS section  
- Bit 2: GSM section
- Bit 3: COT section
- Bit 4: ADC section
- Bit 5: DTT section
- Bit 6: IWD section
- Bit 7: ETD section

## Integration with Traccar

This Kaitai specification complements the existing Traccar Java implementation:

- **GoSafeProtocolDecoder.java**: Main message processor
- **GoSafeFrameDecoder.java**: Frame delimiter and escape sequence handler
- **GoSafeProtocol.java**: Protocol definition and server setup

The Kaitai struct provides standardized binary parsing capabilities that can be used alongside or as an alternative to the Java implementation for cross-platform compatibility and automated parser generation.

## Market Presence

- **500,000+** active GoSafe devices globally
- **100+** fleet management companies
- Major tracking platform compatibility
- Popular in taxi, logistics, and construction industries
- Strong presence in North America, Europe, and Asia-Pacific markets