# ITS GPS Tracker Protocol (Intelligent Tracking System)

## Overview

ITS (Intelligent Tracking System) is a sophisticated GPS tracking protocol designed for professional fleet management and vehicle tracking applications. It provides comprehensive telemetry data including advanced GPS positioning, cellular network information, accelerometer data, and extensive system monitoring capabilities.

## Protocol Specifications

### Message Format
```
$[preamble],[event],[vendor],[firmware],[status],[event],[history],[imei],[status_code],[date],[time],[validity],[coordinates],[motion],[sensors],[io],[cellular],[extended_data]*
```

**Example:**
```
$,WD,ITS,v2.1,WD,123,L,123456789012345,WD,22,03,2024,14,30,45,A,3723.4567,N,12158.7890,W,65.5,180.0,8,150.5,1.2,0.8,Operator,1,1,12.5,3.8,0,120,456,789,A1B2,1234,AB,*
```

### Field Descriptions

#### Header Section
- **Start Delimiter**: `$` character
- **Preamble**: Optional routing or system information
- **Event**: Event identifier or message type
- **Vendor**: Device manufacturer identifier
- **Firmware**: Firmware version string
- **Status**: Primary status/alarm code (2 characters)
- **Event Number**: Numeric event identifier
- **History Flag**: L (Live) or H (Historical) data mode

#### Device Information
- **IMEI**: 15-digit International Mobile Equipment Identity
- **Status Code**: Secondary status indicator
- **Vehicle Registration**: Optional vehicle identifier

#### DateTime Section
- **Date**: DDMMYYYY format
- **Time**: HHMMSS format
- **Validity**: GPS validity indicator (0/1/A/V)

#### GPS Section
- **Coordinates**: Degrees.minutes format with hemisphere
- **Speed**: Kilometers per hour
- **Course**: Degrees (0-360)
- **Satellites**: Number of satellites in view
- **Altitude**: Meters above sea level
- **PDOP/HDOP**: Position/Horizontal Dilution of Precision

#### System Monitoring
- **Operator**: Cellular network operator
- **Ignition**: Engine ignition status (0/1)
- **Charging**: Battery charging status (0/1)
- **Power**: Main power voltage
- **Battery**: Battery voltage
- **Emergency**: Emergency button status (0/1)

#### Cellular Network
- **Cell Info**: MCC,MNC,LAC,CID,Signal strength format
- **Multiple Towers**: Support for neighboring cell towers

#### Digital I/O
- **Input States**: 4-bit binary representation
- **Output States**: 2-bit binary representation

#### Extended Data
- **Odometer**: Distance traveled (meters)
- **ADC Inputs**: Analog sensor readings
- **Accelerometer**: X,Y,Z acceleration values
- **Tilt Sensors**: Tilt X and Y angles

## Alarm Types

| Code | Type | Description |
|------|------|-------------|
| WD | SOS Emergency | Wireless emergency alarm |
| EA | Emergency Alarm | General emergency trigger |
| EMR | Emergency Type | Emergency message type |
| BL | Low Battery | Battery level below threshold |
| HB | Harsh Braking | Aggressive braking detected |
| HA | Harsh Acceleration | Rapid acceleration detected |
| RT | Rapid Turn | Sharp cornering/turning |
| OS | Overspeed | Speed limit exceeded |
| TA | Tampering | Device tampering detected |
| BD | Power Cut | Main power disconnected |
| BR | Power Restored | Main power reconnected |
| IN | Ignition On | Engine started |
| IF | Ignition Off | Engine stopped |

## Supported Features

### Advanced Positioning
- **GPS Coordinates**: High-precision positioning
- **Quality Metrics**: PDOP/HDOP accuracy indicators
- **Validity Checking**: Multiple validation methods
- **3D Positioning**: Altitude tracking
- **Satellite Monitoring**: Signal quality assessment

### Cellular Network Integration
- **Cell Tower Info**: MCC, MNC, LAC, CID data
- **Multiple Towers**: Neighboring cell information
- **Signal Strength**: Network quality monitoring
- **Operator Identification**: Carrier information

### Motion Analysis
- **Speed Monitoring**: Real-time velocity tracking
- **Course Tracking**: Direction of travel
- **Acceleration**: 3-axis G-sensor data
- **Tilt Detection**: Vehicle orientation monitoring
- **Driving Behavior**: Harsh driving detection

### System Monitoring
- **Power Management**: Voltage monitoring
- **Battery Status**: Charge level and health
- **Ignition Control**: Engine state tracking
- **Emergency Features**: SOS and panic buttons
- **Digital I/O**: Multiple input/output monitoring

### Fleet Management
- **Odometer**: Distance tracking
- **Historical Data**: Data replay capability
- **Event Logging**: Comprehensive event management
- **Command Support**: Engine stop/resume commands

## Usage Examples

### Basic Position Parsing
```python
# Example ITS message
message = "$,GPS,ITS,v2.1,,123,L,123456789012345,,22,03,2024,14,30,45,A,3723.4567,N,12158.7890,W,65.5,180.0,8*"

# Parse with Kaitai
its_msg = Its.from_bytes(message.encode())
print(f"IMEI: {its_msg.imei}")
print(f"DateTime: {its_msg.datetime_string}")
print(f"Position: {its_msg.latitude_decimal}, {its_msg.longitude_decimal}")
print(f"Speed: {its_msg.speed_knots} knots")
print(f"GPS Valid: {its_msg.gps_valid}")
```

### Alarm Detection
```python
# Check for alarms
print(f"Alarm Type: {its_msg.alarm_type}")
if its_msg.alarm_type == "sos":
    print("EMERGENCY - SOS alarm detected!")
elif its_msg.alarm_type == "harsh_braking":
    print("WARNING - Harsh braking detected")
elif its_msg.alarm_type == "overspeed":
    print("ALERT - Speed limit exceeded")
```

### System Status Monitoring
```python
# Check system status
if its_msg.has_extended_gps:
    print(f"Ignition: {'ON' if its_msg.ignition_on else 'OFF'}")
    print(f"Charging: {'YES' if its_msg.charging_active else 'NO'}")
    print(f"Power: {its_msg.power_volts}V")
    print(f"Battery: {its_msg.battery_volts}V")
    print(f"Emergency: {'ACTIVE' if its_msg.emergency_active else 'INACTIVE'}")
    print(f"Satellites: {its_msg.satellites}")
    print(f"HDOP: {its_msg.hdop_float}")
```

### Historical vs Live Data
```python
# Check data mode
if its_msg.is_historical:
    print("Historical data replay")
elif its_msg.is_live:
    print("Live tracking data")
```

## Implementation Notes

### Frame Processing
1. **Delimiter Detection**: Messages start with `$` and end with `*`
2. **Multi-frame Support**: Handle multiple messages in buffer
3. **Checksum Validation**: Binary and text checksum support
4. **Variable Length**: Flexible field presence based on device configuration

### Data Processing
1. **Coordinate Conversion**: Convert degrees.minutes to decimal degrees
2. **Time Handling**: Combine date and time fields
3. **Unit Conversion**: Convert km/h to knots for speed
4. **Cellular Parsing**: Extract MCC, MNC, LAC, CID from cell string
5. **Binary Conversion**: Parse binary input/output states

### Error Handling
- **Invalid GPS**: Handle V (invalid) and 0 (invalid) GPS status
- **Missing Fields**: Process optional fields gracefully
- **Malformed Cellular**: Handle corrupted cell tower data
- **Incomplete Messages**: Robust parsing for partial data

### Command Support
The ITS protocol supports remote commands:
- **ENGINE_STOP**: Remote engine immobilization
- **ENGINE_RESUME**: Restore engine operation
- **Response Format**: Configurable command responses

## Integration with Traccar

This Kaitai specification complements the existing Traccar Java implementation:

- **ItsProtocolDecoder.java**: Main message processor with complex parsing logic
- **ItsFrameDecoder.java**: Frame delimiter and message boundary detection
- **StringDecoder/StringEncoder**: ASCII text processing

The Kaitai struct provides standardized parsing capabilities that can handle the complex, variable-length nature of ITS messages for cross-platform compatibility.

## Market Presence

- Professional fleet management systems
- Emergency vehicle tracking
- High-value asset monitoring
- Commercial vehicle telematics
- Advanced driver assistance systems (ADAS)
- Insurance telematics applications

## Technical Advantages

- **Comprehensive Data**: Extensive telemetry coverage
- **Flexible Format**: Variable field presence based on configuration
- **Cellular Integration**: Advanced network location capabilities
- **Command Support**: Two-way communication for fleet control
- **High Precision**: Multiple accuracy metrics and validation
- **Emergency Features**: Robust alarm and emergency handling