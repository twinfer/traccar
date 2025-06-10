# Dway GPS Tracker Protocol

## Overview

Dway is a comprehensive GPS tracking protocol designed for vehicle tracking and fleet management applications. It provides detailed telemetry data including GPS positioning, digital I/O monitoring, analog sensor inputs, and driver identification capabilities.

## Protocol Specifications

### Message Format
```
AA55,[index],[imei],[type],[yymmdd],[hhmmss],[latitude],[longitude],[altitude],[speed],[course],[input],[output],[flags],[battery],[adc1],[adc2],[driver]
```

**Example:**
```
AA55,1,123456789012345,0,240322,143045,-122.123456,37.654321,-15,65.5,180,0011,0001,101010,12500,3300,2800,12345
```

### Field Descriptions

#### Header Section
- **Header**: `AA55,` - Fixed message start delimiter
- **Message Index**: Sequence number for message ordering
- **IMEI**: 15-digit International Mobile Equipment Identity
- **Message Type**: Numeric type identifier

#### DateTime Section
- **Date**: YYMMDD format (2-digit year)
- **Time**: HHMMSS format (24-hour)

#### GPS Section
- **Latitude**: Decimal degrees (signed, negative for South)
- **Longitude**: Decimal degrees (signed, negative for West)
- **Altitude**: Meters above sea level (signed)
- **Speed**: Kilometers per hour (converted to knots in processing)
- **Course**: Degrees (0-360, clockwise from North)

#### Digital I/O Section
- **Input States**: 4-bit binary representation (e.g., "0011" = bits 0,1 active)
- **Output States**: 4-bit binary representation (e.g., "0001" = bit 0 active)
- **Status Flags**: Variable-length binary status indicators

#### Analog Section
- **Battery**: Battery voltage in millivolts
- **ADC1**: Analog input 1 voltage in millivolts
- **ADC2**: Analog input 2 voltage in millivolts

#### Identification
- **Driver ID**: Driver unique identifier

## Heartbeat Mechanism

The protocol includes a heartbeat mechanism for connection monitoring:

### Heartbeat Request
```
AA55,HB
```

### Heartbeat Response
```
55AA,HB,OK
```

## Supported Features

### Real-time Positioning
- **GPS Coordinates**: High-precision decimal degrees
- **3D Positioning**: Altitude tracking
- **Motion Monitoring**: Speed and course tracking
- **Position Validity**: Always marked as valid in protocol

### Digital I/O Monitoring
- **4 Digital Inputs**: Binary state monitoring
- **4 Digital Outputs**: Control and status outputs
- **Real-time Status**: Immediate state reporting
- **Bit-level Access**: Individual input/output bit states

### Analog Monitoring
- **Dual ADC Channels**: Two analog input channels
- **Voltage Monitoring**: Millivolt precision
- **Battery Tracking**: Main power supply monitoring
- **Sensor Integration**: External sensor support

### System Management
- **Message Sequencing**: Index-based message ordering
- **Driver Identification**: Unique driver tracking
- **Status Flags**: System status and alarm monitoring
- **Connection Health**: Heartbeat mechanism

## Message Types

| Type | Description |
|------|-------------|
| 0 | Normal Report | Regular position update |
| 1 | Alarm Report | Alert or emergency condition |
| 2 | Heartbeat | Connection keep-alive |
| 3 | Emergency | Emergency situation |
| 4 | Power On | Device startup |
| 5 | Power Off | Device shutdown |

## Digital I/O Bit Mapping

### Input States (4-bit binary)
- **Bit 0**: Digital Input 0
- **Bit 1**: Digital Input 1
- **Bit 2**: Digital Input 2
- **Bit 3**: Digital Input 3

### Output States (4-bit binary)
- **Bit 0**: Digital Output 0
- **Bit 1**: Digital Output 1
- **Bit 2**: Digital Output 2
- **Bit 3**: Digital Output 3

## Voltage Monitoring

### Battery Voltage Thresholds
- **Low Battery**: < 11.5V (11500 mV)
- **Normal**: 11.5V - 14.5V
- **High/Charging**: > 14.5V (14500 mV)

### ADC Channels
- **ADC1**: External sensor input
- **ADC2**: Secondary sensor input
- **Resolution**: Millivolt precision
- **Range**: Typically 0-5V or 0-12V

## Usage Examples

### Basic Position Parsing
```python
# Example Dway message
message = "AA55,1,123456789012345,0,240322,143045,-122.123456,37.654321,-15,65.5,180,0011,0001,101010,12500,3300,2800,12345"

# Parse with Kaitai
dway_msg = Dway.from_bytes(message.encode())
print(f"IMEI: {dway_msg.imei}")
print(f"DateTime: {dway_msg.datetime_string}")
print(f"Position: {dway_msg.latitude_decimal}, {dway_msg.longitude_decimal}")
print(f"Speed: {dway_msg.speed_knots} knots")
print(f"Altitude: {dway_msg.altitude_meters} meters")
```

### Digital I/O Monitoring
```python
# Check digital inputs
print("Digital Inputs:")
print(f"  Input 0: {'ACTIVE' if dway_msg.input_bit_0 else 'INACTIVE'}")
print(f"  Input 1: {'ACTIVE' if dway_msg.input_bit_1 else 'INACTIVE'}")
print(f"  Input 2: {'ACTIVE' if dway_msg.input_bit_2 else 'INACTIVE'}")
print(f"  Input 3: {'ACTIVE' if dway_msg.input_bit_3 else 'INACTIVE'}")

# Check digital outputs
print("Digital Outputs:")
print(f"  Output 0: {'ACTIVE' if dway_msg.output_bit_0 else 'INACTIVE'}")
print(f"  Output 1: {'ACTIVE' if dway_msg.output_bit_1 else 'INACTIVE'}")
print(f"  Output 2: {'ACTIVE' if dway_msg.output_bit_2 else 'INACTIVE'}")
print(f"  Output 3: {'ACTIVE' if dway_msg.output_bit_3 else 'INACTIVE'}")
```

### Analog Monitoring
```python
# Check analog inputs and battery
print(f"Battery: {dway_msg.battery_volts:.3f}V")
print(f"ADC1: {dway_msg.adc1_volts:.3f}V")
print(f"ADC2: {dway_msg.adc2_volts:.3f}V")

# Battery status
if dway_msg.battery_volts < 11.5:
    print("WARNING: Low battery!")
elif dway_msg.battery_volts > 14.5:
    print("INFO: Battery charging")
else:
    print("INFO: Battery normal")
```

### System Information
```python
# System details
print(f"Message Index: {dway_msg.message_index_int}")
print(f"Message Type: {dway_msg.message_type_int}")
print(f"Driver ID: {dway_msg.driver_id}")
print(f"Status Flags: {dway_msg.status_binary:08b}")
```

### Heartbeat Handling
```python
# Check for heartbeat message
if message == "AA55,HB":
    print("Heartbeat received - responding with 55AA,HB,OK")
    response = "55AA,HB,OK\r\n"
```

## Implementation Notes

### Data Processing
1. **Message Parsing**: Split by comma delimiters after header
2. **Data Type Conversion**: Convert strings to appropriate numeric types
3. **Coordinate Handling**: Direct decimal degree format (no conversion needed)
4. **Unit Conversion**: Convert km/h to knots for speed
5. **Binary Processing**: Parse binary strings for I/O states
6. **Voltage Scaling**: Convert millivolts to volts

### Error Handling
- **Heartbeat Detection**: Handle heartbeat messages separately
- **Missing Fields**: Process incomplete messages gracefully
- **Invalid Data**: Validate numeric conversions
- **Binary Format**: Verify binary string formats
- **Range Validation**: Check coordinate and voltage ranges

### Frame Processing
- **Line-based**: Messages typically terminated by newline
- **ASCII Protocol**: Text-based communication
- **Fixed Header**: Always starts with "AA55,"
- **Heartbeat Support**: Special handling for HB messages

## Integration with Traccar

This Kaitai specification complements the existing Traccar Java implementation:

- **DwayProtocolDecoder.java**: Main message processor
- **LineBasedFrameDecoder**: Frame delimiter handling
- **StringDecoder/StringEncoder**: ASCII text processing

The Kaitai struct provides standardized parsing capabilities for cross-platform compatibility and automated parser generation.

## Market Presence

- Fleet management systems
- Vehicle tracking applications
- Driver behavior monitoring
- Asset tracking solutions
- Industrial vehicle monitoring
- Construction equipment tracking

## Technical Advantages

- **Simple Format**: Easy to parse and implement
- **Comprehensive I/O**: Extensive digital and analog monitoring
- **Driver Management**: Built-in driver identification
- **Real-time Monitoring**: Continuous position and status updates
- **Heartbeat Support**: Connection health monitoring
- **Voltage Precision**: Millivolt-level analog measurements