# GT02 GPS Tracker Protocol

## Overview

GT02 is a binary GPS tracking protocol designed for efficient, compact communication with GPS tracking devices. It provides essential tracking functionality including GPS positioning, system monitoring, and command response capabilities with minimal bandwidth usage.

## Protocol Specifications

### Message Format
```
[header(2)][length(1)][power(1)][gsm(1)][imei(8)][index(2)][type(1)][payload][crc(2)]
```

**Example Binary Structure:**
```
54 68 15 00 45 [8-byte IMEI] 00 01 10 [GPS payload] [CRC]
```

### Frame Structure

#### Header Section
- **Header**: 2-byte protocol header (varies by implementation)
- **Length**: 1 byte indicating payload size
- **Power Level**: Device power status (0 for location messages)
- **GSM Signal**: Signal strength indicator
- **IMEI**: 8 bytes containing device identification
- **Message Index**: 2-byte sequence number
- **Message Type**: 1 byte type identifier

#### Message Types

| Type | Name | Description |
|------|------|-------------|
| 0x10 | Data | GPS position and movement data |
| 0x1A | Heartbeat | Device status and connectivity |
| 0x1C | Response | Command execution results |

### GPS Data Message (0x10)

#### GPS Payload Structure
- **Date**: Day, Month, Year (DD/MM/YY)
- **Time**: Hour, Minute, Second (HH:MM:SS)
- **Latitude**: 4-byte raw coordinate value
- **Longitude**: 4-byte raw coordinate value
- **Speed**: 1 byte in km/h
- **Course**: 2 bytes in degrees
- **Reserved**: 3 bytes
- **Flags**: 4-byte status and validity flags

#### Coordinate Conversion
- **Raw to Decimal**: `raw_value / (60.0 * 30000.0)`
- **Hemisphere Correction**: Based on flags bits 1 (latitude) and 2 (longitude)
- **Validity**: Flag bit 0 indicates GPS fix status

#### Status Flags
- **Bit 0**: GPS validity (1 = valid, 0 = invalid)
- **Bit 1**: Latitude hemisphere (1 = North, 0 = South)
- **Bit 2**: Longitude hemisphere (1 = East, 0 = West)

### Heartbeat Message (0x1A)

Heartbeat messages contain no additional payload. Status information is provided in the header:
- **Power Level**: Device power status
- **GSM Signal**: Network signal quality

### Response Message (0x1C)

Response messages contain command execution results:
- **Length**: 1 byte indicating response data length
- **Data**: Variable-length ASCII response text

## Supported Features

### Real-time Positioning
- **GPS Coordinates**: High-precision positioning
- **Validity Checking**: GPS fix status indication
- **Time Synchronization**: Precise datetime stamping
- **Motion Tracking**: Speed and course monitoring

### System Monitoring
- **Power Status**: Device power level monitoring
- **Signal Quality**: GSM network strength
- **Connection Health**: Heartbeat mechanism
- **Message Sequencing**: Reliable delivery tracking

### Communication
- **Compact Protocol**: Efficient binary encoding
- **Two-way Communication**: Command and response support
- **Frame Integrity**: CRC checksum validation
- **Sequence Tracking**: Message ordering and delivery

## Usage Examples

### Basic Position Parsing
```python
# Example GT02 binary message
binary_data = bytes([0x54, 0x68, 0x15, 0x00, 0x45, ...])  # GPS data message

# Parse with Kaitai
gt02_msg = Gt02.from_bytes(binary_data)
print(f"IMEI: {gt02_msg.imei}")
print(f"Message Type: {gt02_msg.message_type}")
print(f"Message Index: {gt02_msg.message_index}")

if gt02_msg.message_type == Gt02.MessageTypes.data:
    gps = gt02_msg.payload
    print(f"DateTime: {gps.datetime_string}")
    print(f"Position: {gps.latitude_signed}, {gps.longitude_signed}")
    print(f"Speed: {gps.speed_knots} knots")
    print(f"Course: {gps.course_degrees}°")
    print(f"GPS Valid: {gps.gps_valid}")
```

### Heartbeat Monitoring
```python
# Check for heartbeat message
if gt02_msg.message_type == Gt02.MessageTypes.heartbeat:
    heartbeat = gt02_msg.payload
    print(f"Power Level: {heartbeat.power_status}")
    print(f"Signal Strength: {heartbeat.signal_strength}")
    print("Device heartbeat received")
```

### Command Response Handling
```python
# Handle command response
if gt02_msg.message_type == Gt02.MessageTypes.response:
    response = gt02_msg.payload
    print(f"Command Result: {response.result}")
```

### Status Monitoring
```python
# Monitor device status
print(f"Power Level: {gt02_msg.power_level}")
print(f"GSM Signal: {gt02_msg.gsm_signal}")
print(f"Device IMEI: {gt02_msg.imei}")
```

## Implementation Notes

### Frame Processing
1. **Length-based Framing**: Use LengthFieldBasedFrameDecoder with parameters:
   - `lengthFieldOffset = 2` (after 2-byte header)
   - `lengthFieldLength = 1` (1-byte length field)
   - `lengthAdjustment = 2` (add 2 for CRC)
   - `initialBytesToStrip = 0` (keep all bytes)

2. **Binary Processing**: All data in big-endian format
3. **Checksum Validation**: Verify CRC for message integrity
4. **IMEI Extraction**: Convert 8-byte binary to decimal string

### Coordinate Processing
1. **Raw Conversion**: Divide by (60.0 * 30000.0) for decimal degrees
2. **Hemisphere Correction**: Apply sign based on flag bits
3. **Validity Check**: Use flag bit 0 for GPS fix status
4. **Precision**: High-precision coordinate encoding

### Error Handling
- **Invalid GPS**: Handle GPS invalid status gracefully
- **Malformed Messages**: Validate message structure
- **Checksum Errors**: Verify data integrity
- **Unknown Types**: Handle unsupported message types

### Response Protocol
- **Heartbeat Response**: Send acknowledgment (0x54, 0x68, 0x1A, 0x0D, 0x0A)
- **Command Acknowledgment**: Process response messages
- **Error Handling**: Handle communication failures

## Integration with Traccar

This Kaitai specification complements the existing Traccar Java implementation:

- **Gt02ProtocolDecoder.java**: Main binary message processor
- **LengthFieldBasedFrameDecoder**: Frame boundary detection
- **Binary data handling**: Efficient parsing of compact protocol

The Kaitai struct provides standardized parsing capabilities for cross-platform compatibility and automated parser generation.

## Market Presence

- Entry-level GPS tracking devices
- Basic fleet management systems
- Cost-effective vehicle monitoring solutions
- Simple asset tracking applications
- Budget-conscious tracking deployments

## Technical Advantages

- **Compact Protocol**: Minimal bandwidth usage
- **Binary Efficiency**: Fast parsing and processing
- **Simple Structure**: Easy to implement and maintain
- **Reliable Communication**: Checksum validation and sequencing
- **Basic Functionality**: Essential tracking features without complexity
- **Cost Effective**: Suitable for budget tracking applications

## GT Protocol Family

GT02 is part of the GT protocol family, which includes:

- **GT02**: Basic binary protocol (this specification)
- **GT06**: Advanced binary protocol with many variants and features
- **GT30**: Text-based protocol with different message structure

Each protocol serves different market segments and feature requirements, with GT02 being the simplest and most cost-effective option.