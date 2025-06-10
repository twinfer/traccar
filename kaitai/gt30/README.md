# GT30 GPS Tracker Protocol

## Overview

GT30 is a GPS tracking protocol designed for real-time vehicle tracking and fleet management. It provides comprehensive telemetry data including GPS positioning, alarm states, and various tracking parameters suitable for commercial fleet applications.

## Protocol Specifications

### Message Format
```
$$[length][device_id][type][alarm][time][validity][lat][NS][lon][EW][speed][course][date]|[hdop]|[altitude][checksum]
```

**Example:**
```
$$0040123456789012340000A101530.123,A,2234.5678,N,11234.5678,E,12.34,123.45,220324|1.2|-123ABCD
```

### Message Structure

#### Header Section
- **Start Delimiter**: `$$` (2 bytes)
- **Length**: 4 hex digits indicating message length
- **Device ID**: 14-character ASCII device identifier
- **Message Type**: 4 hex bytes for message classification
- **Alarm Flag**: 1 byte optional alarm status

#### GPS Section
- **Time**: HHMMSS.SSS format with millisecond precision
- **Validity**: A (valid) / V (invalid) GPS fix
- **Latitude**: DDMM.MMMM format with N/S hemisphere
- **Longitude**: DDDMM.MMMM format with E/W hemisphere
- **Speed**: Knots (converted to km/h in processing)
- **Course**: Degrees (0-360)
- **Date**: DDMMYY format

#### Additional Data
- **HDOP**: Horizontal Dilution of Precision
- **Altitude**: Meters above sea level (signed integer)
- **Checksum**: 4-byte CRC for data integrity

## Alarm Types

| Code | Type | Description |
|------|------|-------------|
| 0x01 | SOS Emergency | Emergency button activation |
| 0x02 | SOS Emergency | Secondary emergency trigger |
| 0x03 | SOS Emergency | Tertiary emergency trigger |
| 0x10 | Low Battery | Battery level below threshold |
| 0x11 | Overspeed | Speed limit exceeded |
| 0x12 | Geofence | Geofence boundary violation |

## Supported Features

### Real-time Positioning
- **GPS Coordinates**: Decimal degrees with hemisphere indication
- **Validity Status**: GPS fix quality assessment
- **Time Synchronization**: Millisecond precision timestamps
- **Speed Monitoring**: Real-time velocity tracking
- **Course Tracking**: Direction of travel monitoring

### Signal Quality
- **HDOP Values**: Horizontal accuracy assessment
- **GPS Validity**: Real-time fix status
- **Altitude Data**: 3D positioning capability

### Alarm Management
- **Emergency Alerts**: SOS button support
- **System Monitoring**: Battery and power status
- **Behavioral Alerts**: Overspeed detection
- **Geofence Support**: Boundary violation alerts

## Device Compatibility

### Primary Use Cases
- **Fleet Management**: Commercial vehicle tracking
- **Asset Monitoring**: Equipment and cargo tracking
- **Emergency Services**: Emergency vehicle monitoring
- **Logistics**: Delivery and transportation tracking

### Deployment Scenarios
- Real-time fleet visibility
- Route optimization
- Driver behavior monitoring
- Emergency response systems
- Asset security and recovery

## Usage Examples

### Basic Position Parsing
```python
# Example GT30 message
message = "$$0040123456789012340000A101530.123,A,2234.5678,N,11234.5678,E,12.34,123.45,220324|1.2|-123ABCD"

# Parse with Kaitai
gt30_msg = Gt30.from_bytes(message.encode())
print(f"Device ID: {gt30_msg.device_id}")
print(f"GPS Valid: {gt30_msg.gps_valid}")
print(f"Latitude: {gt30_msg.latitude_decimal}")
print(f"Longitude: {gt30_msg.longitude_decimal}")
print(f"Speed: {gt30_msg.speed_kmh} km/h")
print(f"Altitude: {gt30_msg.altitude_int} meters")
```

### Alarm Detection
```python
# Check for alarms
if gt30_msg.alarm_type != "none":
    print(f"ALARM: {gt30_msg.alarm_type}")
    if gt30_msg.alarm_type == "sos":
        print("Emergency situation detected!")
    elif gt30_msg.alarm_type == "overspeed":
        print("Speed limit violation!")
```

## Implementation Notes

### Data Processing
1. **Message Validation**: Verify checksum and message structure
2. **Coordinate Conversion**: Convert DDMM.MMMM to decimal degrees
3. **Time Handling**: Combine date and time components
4. **Unit Conversion**: Convert knots to km/h for speed

### Error Handling
- **Invalid GPS**: Handle V (invalid) GPS status
- **Missing Data**: Process optional fields gracefully
- **Checksum Errors**: Validate message integrity
- **Malformed Messages**: Robust parsing for incomplete data

### Frame Processing
- **Line-based**: Messages terminated by newline
- **ASCII Protocol**: Text-based communication
- **Fixed Structure**: Predictable field positions
- **Delimiter Support**: Pipe-separated additional data

## Integration with Traccar

This Kaitai specification complements the existing Traccar Java implementation:

- **Gt30ProtocolDecoder.java**: Main message processor
- **LineBasedFrameDecoder**: Frame delimiter handling
- **StringDecoder/StringEncoder**: ASCII text processing

The Kaitai struct provides standardized parsing capabilities for cross-platform compatibility and automated parser generation.

## Market Presence

- Used in various fleet management systems
- Compatible with standard GPS tracking platforms
- Popular in logistics and transportation industries
- Suitable for commercial vehicle tracking applications

## GT Protocol Family

GT30 is part of the GT protocol family, which includes:

- **GT02**: Basic binary protocol with compact messaging
- **GT06**: Advanced binary protocol with many variants and extensive features
- **GT30**: Text-based protocol with human-readable format (this specification)

### Key Differences

| Protocol | Format | Complexity | Features | Use Case |
|----------|--------|------------|----------|----------|
| GT02 | Binary | Simple | Basic tracking | Entry-level devices |
| GT06 | Binary | Complex | Full-featured | Professional tracking |
| GT30 | Text | Medium | Alarm-focused | Fleet management |

Each protocol serves different market segments, with GT30 providing a good balance between readability and functionality for fleet management applications.