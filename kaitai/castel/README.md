# Castel Protocol Documentation

## Overview

The Castel protocol is a sophisticated binary GPS tracking protocol with multiple variants supporting comprehensive vehicle diagnostics, OBD-II integration, and advanced fleet management features. It uses little-endian encoding and supports both TCP and UDP communication.

## Device Identification

### Manufacturer
**Castel** - GPS tracking and fleet management solutions provider

### Commercial Device Models

#### CT Series (Core Tracking)
- **CT100** - Basic vehicle tracker
- **CT200** - Advanced tracker with OBD
- **CT300** - Fleet management device
- **CT400** - Professional tracking system
- **CT500** - Enterprise solution with diagnostics

#### SC Series (Smart Connect)
- **SC100** - OBD-II integrated tracker
- **SC200** - Advanced diagnostics device
- **SC300** - Fleet analytics system
- **SC400** - Commercial vehicle tracker
- **SC500** - Heavy-duty vehicle monitoring

#### CC Series (Classic Connect)
- **CC100** - Legacy protocol support
- **CC200** - Basic tracking device
- **CC300** - Standard fleet tracker

#### MPIP Series (Mobile Positioning)
- **MPIP100** - Minimal tracking device
- **MPIP200** - Simple asset tracker

### Protocol Variants

| Protocol | Version | Header | Features |
|----------|---------|--------|----------|
| **SC Protocol** | 3, 4 | `@@` (0x4040) | Full OBD, alarms, comprehensive data |
| **CC Protocol** | 0, other | `$$` (0x2424) | Basic GPS, heartbeat, simple control |
| **MPIP Protocol** | -1 | `$$` (0x2424) | Minimal positioning data |

### Device ID Format
- Length: 20 bytes ASCII string
- Encoding: US-ASCII with null padding
- Example: `CASTEL123456789012` + null padding

### Device Identification Methods

1. **Protocol Version Detection**
   ```
   @@ header (0x4040) → SC Protocol (versions 3, 4)
   $$ header (0x2424) → CC/MPIP Protocol (other versions)
   ```

2. **Message Type Support Analysis**
   - **SC Protocol**: 0x1001-0xB001 range, comprehensive OBD
   - **CC Protocol**: 0x4001, 0x4206, 0x4583, 0x8001, 0x8206
   - **MPIP Protocol**: Minimal message set

3. **Feature Detection**
   - OBD support: SC protocol messages 0x4002, 0x4004, 0x4005
   - Alarm capability: SC protocol message 0x4007
   - Comprehensive data: SC protocol message 0x401F

### Port Configuration
- Default port: 5014 (Traccar)
- Protocol: castel

## Protocol Structure

### Frame Format

All messages use binary framing with variable headers:

#### SC Protocol Frame (@@)
```
+--------+--------+--------+--------+--------+---------+--------+--------+--------+--------+--------+--------+
| Header | Header | Length | Length |Version | Device ID (20 bytes)         | Msg Type| Msg Type| Payload| CRC16  | CR  LF |
|  0x40  |  0x40  |   LE   |   LE   |  1 b   |        ASCII/NULL             |   LE    |   LE    |  (var) |   LE   |0x0D 0A |
+--------+--------+--------+--------+--------+---------+--------+--------+--------+--------+--------+--------+
```

#### CC/MPIP Protocol Frame ($$)
```
+--------+--------+--------+--------+---------+--------+--------+--------+--------+--------+--------+
| Header | Header | Length | Length | Device ID (20 bytes)         | Msg Type| Msg Type| Payload| CRC16  | CR  LF |
|  0x24  |  0x24  |   LE   |   LE   |        ASCII/NULL             |   LE    |   LE    |  (var) |   LE   |0x0D 0A |
+--------+--------+--------+--------+---------+--------+--------+--------+--------+--------+--------+
```

### Field Breakdown
- **Header**: 2 bytes (`@@` or `$$`)
- **Length**: 2 bytes (little-endian), total message length
- **Version**: 1 byte (SC protocol only)
- **Device ID**: 20 bytes ASCII string with null padding
- **Message Type**: 2 bytes (little-endian)
- **Payload**: Variable length, message-specific
- **CRC**: 2 bytes (little-endian), CRC16-X25
- **Footer**: 2 bytes, `0x0D 0x0A` (CR LF)

## Message Types

### SC Protocol Messages (Header: @@)

#### Device Management
| Type | Name | Direction | Description |
|------|------|-----------|-------------|
| 0x1001 | Login | Device→Server | Device authentication |
| 0x9001 | Login Response | Server→Device | Login acknowledgment |
| 0x1002 | Logout | Device→Server | Device disconnection |
| 0x1003 | Heartbeat | Device→Server | Keep-alive signal |
| 0x9003 | Heartbeat Response | Server→Device | Heartbeat acknowledgment |

#### Position and Tracking
| Type | Name | Direction | Description |
|------|------|-----------|-------------|
| 0x4001 | GPS Data | Device→Server | Position report |
| 0x4008 | Cell Data | Device→Server | Cell tower positioning |
| 0x4009 | GPS Sleep | Device→Server | Low-power GPS mode |
| 0xB001 | Current Location | Device→Server | On-demand position |

#### OBD and Diagnostics
| Type | Name | Direction | Description |
|------|------|-----------|-------------|
| 0x4002 | PID Data | Device→Server | OBD parameter data |
| 0x4004 | Supported PID | Device→Server | Available OBD parameters |
| 0x4005 | OBD Data | Device→Server | Comprehensive OBD data |
| 0x4006 | DTCs Passenger | Device→Server | Passenger vehicle fault codes |
| 0x400B | DTCs Commercial | Device→Server | Commercial vehicle fault codes |

#### Sensors and Monitoring
| Type | Name | Direction | Description |
|------|------|-----------|-------------|
| 0x4003 | G-Sensor | Device→Server | Acceleration data |
| 0x400E | Fuel | Device→Server | Fuel level and consumption |
| 0x401F | Comprehensive | Device→Server | TLV-based multi-sensor data |

#### Alarms and Events
| Type | Name | Direction | Description |
|------|------|-----------|-------------|
| 0x4007 | Alarm | Device→Server | Alarm notification |
| 0xC007 | Alarm Response | Server→Device | Alarm acknowledgment |

#### Queries and Requests
| Type | Name | Direction | Description |
|------|------|-----------|-------------|
| 0x5101 | AGPS Request | Device→Server | Assisted GPS data request |
| 0xA002 | Query Response | Device→Server | Response to server query |

### CC Protocol Messages (Header: $$)

| Type | Name | Direction | Description |
|------|------|-----------|-------------|
| 0x4001 | Login | Device→Server | Device authentication |
| 0x8001 | Login Response | Server→Device | Login acknowledgment |
| 0x4206 | Heartbeat | Device→Server | Keep-alive signal |
| 0x8206 | Heartbeat Response | Server→Device | Heartbeat acknowledgment |
| 0x4583 | Petrol Control | Server→Device | Engine stop/start command |

## Data Structures

### Position Data (19 bytes)

```
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
|  Year  | Month  |  Day   |  Hour  | Minute | Second |    Latitude (4 bytes LE)     |   Longitude (4 bytes LE)     | Speed  | Speed  | Course | Course | Flags  |
|   1b   |   1b   |   1b   |   1b   |   1b   |   1b   |            int32              |            int32              |   LE   |   LE   |   LE   |   LE   |   1b   |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
```

#### Coordinate Conversion
- **Raw to Degrees**: `coordinate_raw / 3600000.0`
- **Hemisphere**: Flags bit 0 (longitude), bit 1 (latitude)
- **Sign**: 0=negative (West/South), 1=positive (East/North)

#### Speed and Course
- **Speed**: Raw value × 0.0194384 = knots (converted from cm/s)
- **Course**: Raw value × 0.1 = degrees

#### Flags Byte
| Bit | Description | Values |
|-----|-------------|--------|
| 0 | Longitude sign | 0=West, 1=East |
| 1 | Latitude sign | 0=South, 1=North |
| 2-3 | GPS validity | Various validity states |
| 4-7 | Satellite count | Number of GPS satellites |

### Statistical Data (30 bytes)

```
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
| ACC ON Time (4b LE)       | UTC Time (4b LE)          | Odometer (4b LE)          | Trip Odo (4b LE)          | Fuel Cons (4b LE)        | Curr Fuel |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
| Status (4b LE)            | Reserved (8 bytes)                                                                                                                        |
+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
```

#### Field Descriptions
- **ACC ON Time**: Cumulative ignition-on time (seconds)
- **UTC Time**: Unix timestamp (seconds since epoch)
- **Odometer**: Total distance traveled (meters)
- **Trip Odometer**: Trip distance (meters)
- **Fuel Consumption**: Total fuel consumed (milliliters)
- **Current Fuel Consumption**: Current rate (ml/hour)
- **Status**: Device status flags (32-bit)

### OBD Data Structure

#### PID Data Format
```
[PID_COUNT] [PID_ID_1] [PID_VALUE_1] [PID_ID_2] [PID_VALUE_2] ...
    1b         2b LE        1-4b         2b LE        1-4b
```

#### PID Value Lengths
| PID Range | Length | Examples |
|-----------|--------|----------|
| 0x01-0x1F | 1 byte | Engine load, coolant temp |
| 0x20-0x3F | 2 bytes | Fuel pressure, manifold pressure |
| 0x40-0x5F | 4 bytes | Fuel rate, distance with MIL on |
| 0x60+ | Variable | Manufacturer-specific |

#### Common OBD PIDs
- **0x04**: Engine load (%)
- **0x05**: Coolant temperature (°C)
- **0x0B**: Intake manifold pressure (kPa)
- **0x0C**: Engine RPM
- **0x0D**: Vehicle speed (km/h)
- **0x0F**: Intake air temperature (°C)
- **0x11**: Throttle position (%)
- **0x23**: Fuel rail pressure (kPa)
- **0x2F**: Fuel level (%)
- **0x5E**: Engine fuel rate (L/h)

### DTC (Diagnostic Trouble Code) Format

```
[DTC_COUNT] [DTC_CODE_1] [DTC_CODE_2] ...
    1b         4b LE        4b LE
```

#### DTC Code Interpretation
- **Format**: Standard OBD-II 5-character codes
- **Categories**: P (Powertrain), B (Body), C (Chassis), U (Network)
- **Encoding**: Binary representation of alpha-numeric code

### TLV (Tag-Length-Value) Structure

Used in comprehensive messages (0x401F):

```
[TAG] [TAG] [LENGTH] [LENGTH] [VALUE...]
  LE    LE      LE       LE        Nb
```

#### Common TLV Tags
| Tag | Description | Value Format |
|-----|-------------|--------------|
| 0x0002 | PID Data | OBD data block |
| 0x0004 | Supported Data Streams | Bit mask |
| 0x0005 | Snapshot Data | Various formats |
| 0x0006 | Passenger Fault Codes | DTC codes |
| 0x0007 | Alarm Data | Alarm information |
| 0x000B | Commercial Fault Codes | DTC codes |
| 0x0010-0x0014 | Temperature Sensors 1-5 | 2-byte signed (°C × 10) |
| 0x0020 | Main Power Voltage | 2-byte unsigned (mV) |
| 0x0021 | Backup Battery Voltage | 2-byte unsigned (mV) |

## Alarm Types

| Code | Alarm Type | Description |
|------|------------|-------------|
| 0x01 | SOS Alarm | Emergency button activated |
| 0x02 | Overspeed Alarm | Speed limit exceeded |
| 0x03 | Geofence Alarm | Enter/exit geofence area |
| 0x04 | Power Cut Alarm | Main power disconnected |
| 0x05 | Vibration Alarm | Unauthorized movement |
| 0x06 | Accident Alarm | Impact or collision detected |
| 0x07 | Low Battery Alarm | Battery voltage below threshold |
| 0x08 | GPS Antenna Alarm | GPS antenna disconnected |
| 0x09 | Device Fault Alarm | Internal device malfunction |

## CRC Calculation

Uses CRC16-X25 algorithm:
- Polynomial: 0x1021
- Initial value: 0x0000
- Final XOR: 0xFFFF
- Calculated over entire message excluding CRC and footer

```python
def crc16_x25(data):
    crc = 0x0000
    for byte in data:
        crc ^= byte
        for i in range(8):
            if crc & 0x0001:
                crc = (crc >> 1) ^ 0x8408
            else:
                crc = crc >> 1
    return crc ^ 0xFFFF
```

## Command and Control

### Engine Control (CC Protocol)
- **Command Type 0x4583**: Petrol Control
- **Values**: 0x00 = Stop engine, 0x01 = Resume engine
- **Response**: Acknowledgment from device

### Remote Commands
- **Location Request**: Query current position
- **Configuration Updates**: Update device parameters
- **Alarm Acknowledgments**: Confirm alarm reception

## Advanced Features

### OBD-II Integration
- **Real-time Monitoring**: Continuous engine parameter streaming
- **Fault Code Retrieval**: DTC reading and clearing
- **Performance Analytics**: Fuel efficiency, driving behavior
- **Maintenance Alerts**: Predictive maintenance scheduling

### Fleet Management
- **Driver Identification**: RFID/keypad integration
- **Route Monitoring**: Planned vs. actual route comparison
- **Fuel Management**: Consumption tracking and theft detection
- **Vehicle Diagnostics**: Comprehensive health monitoring

### Multi-sensor Support
- **Temperature Monitoring**: Up to 5 temperature sensors
- **G-sensor Integration**: Acceleration/deceleration detection
- **Fuel Level Sensors**: Analog fuel level monitoring
- **Power Management**: Main and backup power monitoring

## Example Messages

### SC Protocol Login
```
@@003420000010CASTEL1234567890123400010100{login_data}{CRC}\r\n
```

### GPS Position Report
```
@@004720000010CASTEL1234567890123400014001{position_19b}{statistics_30b}{CRC}\r\n
```

### OBD Data Report
```
@@006520000010CASTEL1234567890123400024002{position_19b}{statistics_30b}{obd_data}{CRC}\r\n
```

### Alarm Notification
```
@@005020000010CASTEL1234567890123400074007{position_19b}{statistics_30b}{alarm_data}{CRC}\r\n
```

### CC Protocol Heartbeat
```
$$002A00CASTEL1234567890123400064206{heartbeat_data}{CRC}\r\n
```

### Comprehensive Data (TLV)
```
@@009620000010CASTEL12345678901234001F401F{position_19b}{statistics_30b}{tlv_block}{CRC}\r\n
```

## Implementation Notes

### Frame Processing
1. **Header Detection**: Identify protocol variant by header bytes
2. **Length Validation**: Extract and validate message length
3. **Version Handling**: Process version byte for SC protocol
4. **Device ID Extraction**: ASCII string with null handling
5. **CRC Verification**: Validate message integrity

### Coordinate Processing
- **Raw Value Conversion**: Divide by 3,600,000 for degrees
- **Hemisphere Application**: Apply sign based on flags
- **Validation**: Check coordinate ranges and validity flags

### OBD Data Handling
- **PID Length Mapping**: Variable length based on PID value
- **Value Interpretation**: Apply scaling factors per PID
- **Unit Conversion**: Convert to standard units (metric/imperial)

### Error Handling
- **Invalid CRC**: Request retransmission
- **Malformed Data**: Log error and continue processing
- **Unknown Message Types**: Handle gracefully with raw data
- **Protocol Mismatches**: Auto-detect protocol variant