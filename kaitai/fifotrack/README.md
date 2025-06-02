# Fifotrack Protocol

The Fifotrack protocol is a text-based GPS tracking protocol with binary photo transmission support, developed by Fifotrack Solution Co., Ltd. from Shenzhen, China. It features location reporting, alarm notifications, sensor integration, and unique photo upload capabilities through RS232 camera interfaces.

## Protocol Overview

**Type:** Text-based with binary photo support  
**Manufacturer:** Fifotrack Solution Co., Ltd. (China)  
**Primary Use:** Fleet management, personal tracking, asset monitoring  
**Data Format:** ASCII text with embedded binary for photos  
**Bidirectional:** Yes (commands and responses)

## Message Structure

### Request Format
```
$$<length>,<imei>,<index>,<type>,<data>*<checksum>\r\n
```

### Response Format
```
##<length>,<imei>,<content>*<checksum>\r\n
```

### Message Types
- **A01**: Standard location report
- **A03**: Extended location report (GPS/WiFi)
- **D05**: Photo metadata announcement
- **D06**: Photo data chunk transmission
- **B01, B03, B11**: Command responses

### Location Message Fields (A01)
1. **Alarm**: Optional alarm code
2. **DateTime**: YYMMDDHHMMSS format
3. **Validity**: A=valid, V=invalid
4. **Coordinates**: Decimal degrees
5. **Motion**: Speed (km/h), course, altitude
6. **Counters**: Odometer, engine hours
7. **Status**: Hex encoded (RSSI, satellites)
8. **I/O**: Digital inputs/outputs
9. **Cell Info**: MCC|MNC|LAC|CID
10. **ADC**: Pipe-separated analog values
11. **RFID**: Optional driver ID
12. **Sensors**: Optional additional data

### Photo Transmission Protocol
1. **Announcement** (D05): Device sends photo size and ID
2. **Request** (D06): Server requests chunks with offset
3. **Data Transfer**: Binary data in 1024-byte chunks
4. **Incremental Storage**: Server builds complete image

### Alarm Codes
- 2: SOS button
- 14: Low power
- 15: Power cut
- 16: Power restored
- 17: Low battery
- 18: Overspeed
- 20: GPS antenna cut
- 21: Vibration
- 23: Acceleration
- 24: Braking
- 27: Fatigue driving
- 30/32: Jamming
- 31: Fall down
- 33: Geofence exit
- 34: Geofence enter
- 35: Idle
- 40/41: Temperature
- 53: Power on
- 54: Power off

## Key Features

- **Photo Capability**: RS232 camera interface support
- **Multi-Positioning**: GPS and WiFi location
- **Sensor Integration**: Temperature, RFID, impulse detection
- **Power Management**: Multiple power-related alarms
- **Driver Safety**: Fatigue, acceleration, braking detection
- **Geofencing**: Entry/exit notifications
- **Anti-Theft**: Jamming detection, antenna cut alarm

## Device Identification

### Manufacturer Information
**Fifotrack Solution Co., Ltd.**  
- Location: Shenzhen, Guangdong, China
- Founded: GPS experts with 10+ years experience
- Specialization: Vehicle and personal GPS trackers
- Market: Global fleet management solutions

### Device Models

#### Personal Tracker
- **Q2**: Portable GPS tracker
  - Target: Kids, elderly, pets, assets
  - Battery: 15 days (24h interval)
  - Size: Compact design
  - Features: SOS button, fall detection

#### Basic Vehicle Tracker
- **A100**: Entry-level fleet tracker
  - Applications: Fleet, taxi, rental cars
  - Battery: 100h sleep, 10h active
  - Inputs: Basic I/O
  - Simple: Stable long-term operation

#### Advanced Vehicle Trackers
- **A300**: Multifunctional tracker
  - **Camera Support**: RS232 port
  - **RFID**: Driver identification
  - **Temperature**: Monitoring capability
  - **Inputs**: 4 digital, 2 analog
  - **1-Wire**: Protocol support
  - **Photo**: Picture taking capability

- **A600**: Professional grade tracker
  - **4 RS232 Ports**: Multiple peripherals
  - **Camera Support**: Enhanced photo features
  - **RFID**: Advanced driver management
  - **Temperature**: Multi-sensor support
  - **1-Wire**: Extended protocol support
  - **Applications**: Complex fleet management

#### Other Models
- **A200**: Mid-range vehicle tracker
- **A500**: Advanced features
- **A700**: 3G version with 4 RS232 ports
- **Q1**: Earlier personal tracker model

### Physical Characteristics

#### Connectivity
- **RS232 Ports**: 1 (A300) to 4 (A600/A700)
- **1-Wire**: Temperature sensors, iButton
- **Digital I/O**: Multiple inputs/outputs
- **Analog Inputs**: ADC channels
- **Cellular**: 2G standard, 3G on A700

#### Power
- **Voltage**: 9-36V DC vehicle power
- **Battery**: Internal backup
  - A100: 100h sleep, 10h active
  - Q2: 15 days at 24h intervals
- **Protection**: Over-voltage, reverse polarity

#### Environmental
- **Temperature**: -20°C to +70°C operation
- **Humidity**: 5% to 95% non-condensing
- **Protection**: Automotive grade

### Protocol Detection Features

#### Message Structure
- **Start Marker**: `$$` for device messages
- **Response Marker**: `##` for server responses
- **Length Field**: Message size indicator
- **Checksum**: Simple sum validation
- **Terminator**: CR+LF (0x0D 0x0A)

#### Photo Transmission
- **Chunk Size**: 1024 bytes maximum
- **Binary in Text**: Base64-like encoding
- **Incremental**: Offset-based transfer
- **Verification**: Checksum per chunk

### Camera Integration

#### Supported Cameras
- **RS232 Interface**: Serial cameras
- **Resolution**: VGA typical
- **Trigger**: Event-based capture
- **Storage**: Server-side assembly

#### Photo Applications
- **Driver Verification**: Face capture
- **Incident Recording**: Accident photos
- **Security**: Theft documentation
- **Cargo**: Loading/unloading proof

### Quality Assurance
- **Warranty**: 2 years on all models
- **Manufacturing**: ISO certified facility
- **Testing**: Automotive standards
- **Support**: Global technical assistance

## Common Applications

- **Fleet Management**: Commercial vehicles
- **Public Transport**: Buses, school buses
- **Taxi Operations**: Dispatch and monitoring
- **Rental Cars**: Location and usage tracking
- **Insurance**: Usage-based policies
- **Personal Safety**: Children, elderly tracking
- **Asset Tracking**: High-value equipment
- **Cold Chain**: Temperature monitoring
- **Driver Management**: RFID identification
- **Security**: Anti-theft with photo evidence

## Regional Deployment

### Chinese Market
- **Compliance**: China GPS regulations
- **Language**: Chinese firmware options
- **Networks**: China Mobile, Unicom, Telecom
- **Integration**: Local platform support

### Global Markets
- **Certifications**: CE, FCC, RoHS
- **Languages**: Multi-language support
- **Networks**: Global GSM compatibility
- **Platforms**: Wialon, Navixy integration

## Traccar Configuration

```xml
<entry key='fifotrack.port'>5042</entry>
```

### Protocol Features
- **Frame Decoder**: Custom length-based framing
- **Photo Handler**: Incremental binary assembly
- **Command Support**: Bidirectional communication
- **Alarm Processing**: Comprehensive event handling
- **Multi-Format**: GPS and WiFi positioning

### Implementation Notes
- Text protocol with binary photo data
- Simple checksum validation
- Flexible field structure
- Efficient photo chunking
- Platform-agnostic design

The Fifotrack protocol's combination of text-based simplicity and binary photo capability makes it versatile for various tracking applications, from basic fleet management to advanced security systems requiring photographic evidence.