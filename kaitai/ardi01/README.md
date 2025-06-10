# Ardi01 GPS Tracker Protocol

## Overview

Ardi01 is a simple yet effective GPS tracking protocol designed for vehicle tracking and monitoring applications. It provides comprehensive telemetry data in a comma-separated format, making it easy to parse and integrate with various tracking systems.

## Protocol Specifications

### Message Format
```
[imei],[yyyymmdd],[hhmmss],[longitude],[latitude],[speed],[course],[altitude],[satellites],[event],[battery],[temperature]
```

**Example:**
```
123456789012345,20240322,143045,-122.123456,37.654321,65.5,180.0,150,8,0,85,-5
```

### Field Descriptions

#### Device Information
- **IMEI**: International Mobile Equipment Identity (15 digits)
- **DateTime**: YYYYMMDDHHMMSS format for precise timestamp

#### GPS Data
- **Longitude**: Decimal degrees (signed, negative for West)
- **Latitude**: Decimal degrees (signed, negative for South)
- **Speed**: Kilometers per hour (converted to knots in processing)
- **Course**: Degrees (0-360, clockwise from North)
- **Altitude**: Meters above sea level (signed)
- **Satellites**: Number of satellites in view (3+ required for validity)

#### System Data
- **Event**: Numeric event code for various triggers
- **Battery**: Battery level percentage (0-100)
- **Temperature**: Temperature reading in Celsius (signed)

## GPS Validity

Position validity is determined by satellite count:
- **Valid**: 3 or more satellites in view
- **Invalid**: Less than 3 satellites (poor GPS reception)

## Event Codes

| Code | Event | Description |
|------|-------|-------------|
| 0 | Normal Report | Regular position update |
| 1 | SOS Alarm | Emergency button pressed |
| 2 | Power On | Device startup |
| 3 | Power Off | Device shutdown |
| 4 | Low Battery | Battery level below threshold |
| 5 | Geofence Enter | Entered defined geofence |
| 6 | Geofence Exit | Exited defined geofence |
| 7 | Overspeed | Speed limit exceeded |
| 8 | Harsh Acceleration | Aggressive acceleration detected |
| 9 | Harsh Braking | Hard braking detected |
| 10 | Panic Button | Emergency panic activation |

## Supported Features

### Real-time Positioning
- **GPS Coordinates**: Decimal degrees format
- **Validity Check**: Satellite-based position quality
- **Time Synchronization**: Precise datetime stamping
- **3D Positioning**: Altitude tracking capability

### Motion Monitoring
- **Speed Tracking**: Real-time velocity monitoring
- **Course Tracking**: Direction of travel
- **Movement Analysis**: Support for driving behavior analysis

### Environmental Monitoring
- **Temperature Sensor**: External temperature readings
- **Battery Monitoring**: Power level tracking
- **System Events**: Various trigger conditions

### Device Management
- **IMEI Identification**: Unique device tracking
- **Event Logging**: Comprehensive event management
- **Status Monitoring**: System health tracking

## Usage Examples

### Basic Position Parsing
```python
# Example Ardi01 message
message = "123456789012345,20240322,143045,-122.123456,37.654321,65.5,180.0,150,8,0,85,-5"

# Parse with Kaitai
ardi01_msg = Ardi01.from_bytes(message.encode())
print(f"IMEI: {ardi01_msg.imei}")
print(f"DateTime: {ardi01_msg.datetime_string}")
print(f"Position: {ardi01_msg.latitude_decimal}, {ardi01_msg.longitude_decimal}")
print(f"Speed: {ardi01_msg.speed_knots} knots")
print(f"GPS Valid: {ardi01_msg.gps_valid}")
```

### System Monitoring
```python
# Check system status
print(f"Satellites: {ardi01_msg.satellites}")
print(f"Battery: {ardi01_msg.battery_percent}%")
print(f"Temperature: {ardi01_msg.temperature_celsius}°C")
print(f"Event: {ardi01_msg.event_id}")

# Check for alerts
if ardi01_msg.event_id == 1:
    print("SOS ALARM - Emergency situation!")
elif ardi01_msg.event_id == 4:
    print("LOW BATTERY WARNING")
elif ardi01_msg.event_id == 7:
    print("OVERSPEED ALERT")
```

### Data Validation
```python
# Validate GPS data
if ardi01_msg.gps_valid:
    print("GPS position is reliable")
    if ardi01_msg.satellites >= 6:
        print("Excellent GPS signal")
    elif ardi01_msg.satellites >= 4:
        print("Good GPS signal")
    else:
        print("Marginal GPS signal")
else:
    print("GPS position unreliable - indoor or poor reception")
```

## Implementation Notes

### Data Processing
1. **Message Parsing**: Split by comma delimiters
2. **Data Type Conversion**: Convert strings to appropriate numeric types
3. **Coordinate Handling**: Direct decimal degree format (no conversion needed)
4. **Unit Conversion**: Convert km/h to knots for speed
5. **Validity Check**: Verify satellite count for GPS reliability

### Error Handling
- **Missing Fields**: Handle incomplete messages gracefully
- **Invalid Data**: Validate numeric conversions
- **GPS Quality**: Check satellite count for position reliability
- **Range Validation**: Verify coordinate and speed ranges

### Frame Processing
- **Line-based**: Messages typically terminated by newline
- **CSV Format**: Standard comma-separated parsing
- **ASCII Encoding**: Text-based communication
- **Fixed Structure**: Predictable field order

## Integration with Traccar

This Kaitai specification complements the existing Traccar Java implementation:

- **Ardi01ProtocolDecoder.java**: Main message processor
- **LineBasedFrameDecoder**: Frame delimiter handling
- **StringDecoder/StringEncoder**: ASCII text processing

The Kaitai struct provides standardized parsing capabilities for cross-platform compatibility and automated parser generation.

## Market Presence

- Fleet management systems
- Asset tracking applications
- Environmental monitoring solutions
- Personal tracking devices
- Simple vehicle tracking implementations

## Technical Advantages

- **Simple Format**: Easy to parse and implement
- **Comprehensive Data**: GPS, system, and environmental monitoring
- **Compact**: Efficient data transmission
- **Reliable**: Built-in GPS validity checking
- **Extensible**: Event system for custom applications