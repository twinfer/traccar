# JT600 Protocol

The JT600 protocol is a versatile GPS tracking protocol used primarily by Jointech (Shenzhen Joint Technology Co., Ltd.) devices. This protocol supports both binary and text message formats with features including RFID integration, temperature sensors, and multiple positioning modes.

## Protocol Overview

**Type:** Mixed Binary/Text  
**Manufacturer:** Jointech (Shenzhen Joint Technology Co., Ltd.)  
**Primary Use:** Personal tracking, vehicle tracking, asset monitoring  
**Data Format:** Binary packets and text messages with parentheses  
**Bidirectional:** Yes (commands and responses)

## Message Structure

### Binary Format
```
Header: '$' (0x24)
Device ID: 5 bytes BCD
Protocol Version: 1 byte (if long format)
Packet Info: 1 byte (version in upper nibble)
Length: 2 bytes
Data Records: Variable
Sequence Index: 1 byte
```

### Text Format
```
(device_id,message_type,parameters...)
```

Message types include:
- **W01**: Basic position report
- **U01/U02/U03/U06**: Extended position with cell tower info
- **P45**: RFID event with position
- **WLNET,5**: Peripheral sensor data

## Key Features

- **Dual Format Support**: Binary and ASCII text protocols
- **Solar Power Support**: Extended battery life with solar charging
- **Sensor Integration**: Temperature, humidity, and other sensors
- **RFID Support**: Driver identification and access control
- **Waterproof Design**: IP65/IP67 rated devices
- **Response System**: Acknowledgment messages for reliable communication

## Device Identification

### Commercial Device Models

#### Jointech GPS Trackers
- **JT600**: Portable/personal GPS tracker
  - Solar powered with extended battery life
  - IP65 waterproof rating
  - Dimensions: 96mm × 51mm × 22mm
  - Two-way voice communication
  - Standby time: Over 2 months
  
- **JT601**: Vehicle/asset tracking variant (limited info available)
- **JT606**: Enhanced model (specifications not widely documented)
- **JT100**: Entry-level tracker (specifications not widely documented)

#### Related Jointech Models
- **JT701**: GPS padlock with tracking **[FULLY SUPPORTED]**
  - 12000 mAh battery
  - RFID unlock capability
  - Dual SIM support
  - IP67 waterproof
  - Remote lock/unlock commands
  - Tamper detection and security alarms
  - Unauthorized access monitoring
  
- **JT704**: Container tracking
  - 3-year standby capability
  - Designed for shipping containers
  - GPS/AGPS/LBS positioning

### Company Background
- **Manufacturer**: Shenzhen Joint Technology Co., Ltd.
- **Location**: Rm518, 404bldg, Shangbu Industry Zone, Futian District, Shenzhen, Guangdong, China
- **Experience**: Over 17 years in GPS tracking industry
- **Distribution**: Products in 80+ countries
- **Platform**: Jointech Cloud Tracking Platform with iOS/Android apps

### Physical Characteristics
- **Form Factor**: Handheld/portable design
- **Power**: Solar panel with rechargeable battery
- **Waterproofing**: IP65/IP67 ratings
- **Size**: Compact design (JT600: 96×51×22mm)
- **Installation**: Portable, magnetic mount, or vehicle installation

### Device Identification Methods

#### Protocol-Based Identification
- **Binary Format**: 5-byte BCD device ID after '$' header
- **Text Format**: Device ID as first parameter in parentheses
- **Terminal ID**: Used instead of IMEI for some models
- **Response Messages**: 
  - Binary: "(P35)" or "(P69,0,index)"
  - Text: "(S39)" for U01-U03, "(S20)" for U06

#### Binary Format Versions
```
Version 1: Basic GPS data with cell tower info
Version 2: Fuel monitoring and detailed status
Version 3: Multiple fuel tank support
Long Format: Extended data with odometer and satellite count
```

### Protocol Detection Features

#### Message Type Indicators
- **Binary**: Starts with '$' (0x24)
- **Text**: Starts with '(' (0x28)
- **W01**: Basic position report
- **U-Series**: Extended reports with status
- **P45**: RFID events
- **Peripherals**: Contains "WLNET,5,"

#### Status and Alarm Codes
```
Binary Status Flags:
0x0002: Geofence enter      0x0800: Low battery
0x0004: Geofence exit       0x4000: Fault alarm
0x0008: Power cut           0x0020: Response required
0x0010: Vibration           0x0080: Device blocked

Text Mode Alarms:
SOS, Power cut, Vibration, Movement
Overspeed, Low battery, GPS antenna issues

JT701 Padlock-Specific Alarms:
Tamper detection, Unauthorized access, RFID validation
Lock mechanism fault, Remote unlock events
```

## Common Applications

- **Personal Tracking**: Elderly care, child safety, lone workers
- **Vehicle Monitoring**: Basic vehicle tracking and security
- **Asset Protection**: Mobile equipment and valuable cargo
- **Fleet Management**: Small fleet tracking solutions
- **Container Tracking**: Shipping and logistics (JT701/JT704)
- **Access Control**: RFID-based vehicle/area access
- **Padlock Security**: GPS-enabled padlocks with remote monitoring (JT701)
- **Cargo Protection**: Tamper-resistant container security

## Platform Compatibility

- **Wialon**: Full integration support
- **GPSWOX**: Compatible with tracking platform
- **TeraTrack**: Supported device
- **Plaspy**: Satellite tracking compatibility
- **Flotilla IoT**: Partner hardware device
- **GPS-Trace**: Platform integration

## Traccar Configuration

```xml
<entry key='jt600.port'>5027</entry>
```

### Protocol Variants
The JT600 protocol automatically detects:
- Binary vs text message format
- Short vs long binary format
- Protocol version for extended features
- Message type for appropriate parsing

## JT701 Padlock Enhanced Features

### RFID Security System
- **P45 Message Enhancement**: Extended event source codes for padlock operations
- **RFID Card Management**: Validation and tracking of authorized access cards
- **Event Source Mapping**:
  - `1`: RFID unlock event
  - `2`: Manual unlock (backup key)
  - `3`: Remote unlock (SMS/server command)
  - `4`: Unauthorized access attempt
  - `5`: Tamper detection triggered

### Security Monitoring
- **Real-time Alerts**: Immediate notification of security events
- **Lock Status Tracking**: Current lock state (locked/unlocked)
- **Access Logging**: Complete audit trail of unlock events
- **Battery Monitoring**: 12000mAh battery status and charging
- **Location Tracking**: GPS position during security events

### Command Support
- **Remote Lock/Unlock**: Server-initiated lock operations
- **RFID Management**: Add/remove authorized cards
- **Security Configuration**: Enable/disable security modes
- **Status Queries**: Real-time lock and battery status

### Enhanced Status Flags
```
0x0040: Lock status (unlocked when set)
0x1000: Tamper alarm detected
0x2000: Unauthorized access alarm
0x8000: Lock mechanism fault
```

The JT600 protocol's flexibility with both binary efficiency and text readability, combined with solar power capabilities and sensor integration, makes it suitable for diverse tracking applications from personal safety to asset monitoring in remote locations. The enhanced JT701 support provides enterprise-grade security features for high-value cargo and asset protection.