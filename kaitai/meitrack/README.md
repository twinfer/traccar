# Meitrack Protocol

The Meitrack protocol is a comprehensive GPS tracking protocol developed by Meitrack Group, a global provider of telematics and IoT solutions with over two decades of experience. This protocol supports both ASCII text and binary formats with extensive telemetry capabilities including vehicle diagnostics, temperature monitoring, and photo transmission.

## Protocol Overview

**Type:** Mixed Text/Binary  
**Manufacturer:** Meitrack Group  
**Primary Use:** Vehicle tracking, personal tracking, asset monitoring  
**Data Format:** ASCII text with comma separation, binary for specific commands  
**Bidirectional:** Yes (commands and responses)

## Message Structure

### Text Format
```
$$[flag][length],[imei],[command],[data fields...]*[checksum]\r\n
```

### Binary Format (CCC/CCE)
- **CCC**: Compact binary format for batch data
- **CCE**: Extended binary format with parameter-based structure
- **D00**: Photo data transmission packets
- **D03**: Photo request command
- **D82**: Configuration result message

## Key Features

- **Dual Format Support**: ASCII text and binary data formats
- **Photo Transmission**: Camera image capture and transmission
- **Temperature Monitoring**: Multiple temperature sensor support
- **Vehicle Diagnostics**: OBD-II data integration
- **Flexible Parameters**: Configurable data fields per device model
- **Batch Data Upload**: Efficient transmission of stored positions

## Device Identification

### Commercial Device Models

#### Vehicle GPS Trackers
- **MVT340**: Vehicle tracker with external GPS/GSM antennas
- **MVT380**: Advanced vehicle tracking with extended features
- **MVT600**: Multi-functional vehicle GPS tracker
- **MVT800**: Anti-theft vehicle tracker supporting dual protocols
- **MVT100**: Basic vehicle tracking solution

#### Personal/Portable Trackers
- **MT90 Series**: Handheld GPS/GLONASS tracker
  - MT90(V4): Entry-level with audio recording capability
  - Supports both GSM and FDD-LTE networks
  - Built-in speaker and microphone
  - Designed for children, elderly, and lone workers

#### OBD-II Plug & Play Trackers
- **TC68 Series**: Plug-and-play OBD-II trackers
  - TC68: Basic OBD-II tracker
  - TC68S: User-friendly variant
  - TC68L: 4G WiFi hotspot capability
  - No vehicle diagnostic data reading

#### Specialized Models
- **T1, T3**: Compact tracking solutions
- **T333**: Advanced features
- **T311, T322X, T355**: Various application-specific models
- **P66**: Specific use case tracker

### Physical Characteristics
- **External Antennas**: MVT series with external GPS/GSM antennas
- **OBD-II Connector**: TC68 series plug directly into vehicle port
- **Compact Design**: MT90 handheld form factor
- **LED Indicators**: Status and GPS fix indicators
- **Built-in Audio**: MT90 with speaker/microphone

### Device Identification Methods

#### Protocol-Based Identification
```
Login Message: $$A[length],[imei],AAC,[sequence]*[checksum]
Example: $$z27,861451040910625,AAC,1*D3
```

#### Model-Specific Features
- **Battery Calculation**: Device-specific voltage formulas
  - MVT340/MVT380: `voltage * 3.0 * 2.0 / 1024.0`
  - MT90: `voltage * 3.3 * 2.0 / 4096.0`
  - T1/T3/MVT100/MVT600/MVT800/TC68/TC68S: `voltage * 3.3 * 2.0 / 4096.0`

#### IMEI Format
- Standard 15-digit IMEI as device identifier
- Sent in login/authentication messages
- Used for device session establishment

### Protocol Detection Features

#### Message Type Identifiers
```
AAC: Login acknowledgment request
CCC: Binary batch data format
CCE: Extended binary format
D00: Photo data packet
D03: Photo request command
D82: Configuration result
```

#### Event Codes (Unique to Meitrack)
```
1: SOS alarm               78: Accident alarm
17: Low battery           90/91: Cornering
18: Low power            129: Harsh braking
19: Overspeed            130: Harsh acceleration
20: Geofence enter       135: Fatigue driving
21: Geofence exit
22: Power restored
23: Power cut
36: Tow alarm
37: Driver ID event
44: Jamming alarm
```

#### Extended Parameters (CCE Format)
- Temperature sensors (0x2A-0x31)
- Tag sensors with environmental data (0xFE73)
- Multi-battery monitoring (0xFEA8)
- Engine hours tracking (0xFEF4)

## Common Applications

- **Fleet Management**: Commercial vehicle tracking and diagnostics
- **Personal Safety**: Children, elderly, and lone worker protection
- **Vehicle Security**: Anti-theft and tow detection
- **Asset Tracking**: Equipment and valuable cargo monitoring
- **Temperature Monitoring**: Cold chain and sensitive cargo
- **Driver Behavior**: Harsh driving event detection

## Market Positioning

- **Global Provider**: Over 20 years in telematics industry
- **Award-winning**: Recognized for product quality
- **Wide Protocol Support**: Compatible with Meiligao protocol
- **Comprehensive Features**: From basic tracking to advanced telemetry
- **OEM Services**: Custom firmware and features available

## Traccar Configuration

```xml
<entry key='meitrack.port'>5020</entry>
```

### Model-Specific Configuration
The protocol automatically detects device models and applies appropriate:
- Battery voltage calculation formulas
- Power input scaling factors
- Temperature sensor decoding
- Custom parameter parsing

The Meitrack protocol's flexibility and comprehensive feature set make it suitable for diverse applications from basic personal tracking to advanced fleet management with environmental monitoring and driver behavior analysis.