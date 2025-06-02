# CalAmp Protocol

The CalAmp protocol is a binary GPS tracking protocol developed by CalAmp Corporation, a leading provider of wireless communications solutions for mobile resource management applications. Founded in 1981 and headquartered in Irvine, California, CalAmp serves over 3 million subscribers worldwide with their LM Direct protocol.

## Protocol Overview

**Type:** Binary with optional headers  
**Manufacturer:** CalAmp Corporation (USA)  
**Primary Use:** Fleet management, asset tracking, mobile resource management  
**Data Format:** Binary frames with variable-length optional headers  
**Bidirectional:** Yes (commands and responses)

## Message Structure

### Frame Format
```
[Options Header:N][Service:1][Type:1][Sequence:2][Payload:N]
```

### Field Details
- **Options Header**: Variable-length optional fields (when first byte bit 7 set)
- **Service**: Service type (0=Unacknowledged, 1=Acknowledged, 2=Response)
- **Type**: Message type identifier
- **Sequence**: 16-bit sequence number for acknowledgment tracking
- **Payload**: Message-specific data

### Optional Headers
When the first byte has bit 7 set (0x80), optional headers are present:
- **Mobile ID**: Device identifier (IMEI, ESN, etc.)
- **Mobile ID Type**: Type of identifier used
- **Authentication**: Security credentials
- **Routing**: Message routing information
- **Forwarding**: Message forwarding data
- **Response Redirection**: Response routing

### Message Types
- 0x00: Null message
- 0x01: Acknowledgment
- 0x02: Event report (full position data)
- 0x03: ID report
- 0x04: User data
- 0x05: Application data
- 0x06: Configuration
- 0x07: Unit request
- 0x08: Locate report (position on demand)
- 0x09: User data with accumulators
- 0x0A: Mini event report (compact position)
- 0x0B: Mini user data

### Event Report Structure (Type 2)
1. **Timestamp**: 32-bit Unix time
2. **Fix Timestamp**: 32-bit GPS fix time
3. **Location Data**:
   - Latitude: 32-bit signed (×0.0000001 degrees)
   - Longitude: 32-bit signed (×0.0000001 degrees)
   - Altitude: 32-bit signed (×0.01 meters)
   - Speed: 32-bit unsigned (cm/s)
   - Heading: 16-bit unsigned (0.1 degrees)
4. **Status Data**:
   - Satellites: 8-bit count
   - Fix Status: 8-bit flags
   - Carrier: 16-bit identifier
   - RSSI: 16-bit signed dBm
   - Communication State: 8-bit modem status
   - HDOP: 8-bit (×0.1)
   - Input States: 8-bit digital inputs
   - Unit Status: 8-bit device flags
5. **Event Data**: Event index and code
6. **Accumulator Data**: Optional sensor data

### Mini Event Report Structure (Type 10)
Compact version for bandwidth efficiency:
1. **Timestamp**: 32-bit Unix time
2. **Location**: Latitude/longitude (32-bit each)
3. **Heading**: 16-bit course
4. **Speed**: 8-bit km/h
5. **Status**: Combined satellites and fix status
6. **Inputs**: 8-bit digital states
7. **Event**: 8-bit event code

### User Data Structure (Type 4)
1. **Message Route**: 8-bit routing
2. **Message ID**: 8-bit identifier
3. **Data Length**: 16-bit payload size
4. **User Data**: ASCII text data

## Key Features

- **Optional Headers**: Flexible device identification
- **Event-Driven**: Motion, geofence, panic events
- **Accumulator Support**: Sensor and counter data
- **Mini Messages**: Bandwidth-optimized reporting
- **Bidirectional**: Commands and responses
- **Authentication**: Optional security headers
- **Acknowledgment**: Reliable message delivery

## Device Identification

### Company Information
**CalAmp Corporation**  
- Founded: 1981 in Los Angeles, California
- Headquarters: Irvine, California, USA
- CEO: Jeff Gardner
- Employees: 1,000+ globally
- Revenue: $400M+ annually (2023)
- Markets: North America, Europe, South America

### Global Presence
- **Primary Markets**: USA, Canada, Mexico, Brazil
- **Verticals**: Transportation, construction, oil & gas, government
- **Partnerships**: Major carriers (Verizon, AT&T, T-Mobile)
- **Technology**: LTE Cat M1, LTE Cat 1, 3G, satellite

### Device Families

#### LMU Series (Location Management Units)

**LMU-1300M** (Top Priority - 11K+ units)
- **Technology**: LTE Cat M1/NB-IoT
- **Form Factor**: Compact sealed unit
- **Features**:
  - Dual-band GNSS (GPS/GLONASS)
  - 3-axis accelerometer
  - 4 digital inputs, 2 outputs
  - CAN/J1939 interface
  - IP67 rated enclosure
- **Applications**: Light commercial vehicles

**LMU-5530** (Advanced Fleet Gateway)
- **Technology**: LTE Cat 1 with 3G fallback
- **Features**:
  - Wi-Fi hotspot capability
  - Bluetooth Low Energy
  - Driver ID via RFID/Bluetooth
  - Advanced crash detection
  - OTA firmware updates
- **Applications**: Heavy-duty commercial vehicles

**LMU-3030** (Mid-Tier Vehicle Tracker)
- **Technology**: 3G/2G cellular
- **Features**:
  - Basic tracking and monitoring
  - Digital I/O expansion
  - J1939 CAN support
  - Compact form factor
- **Applications**: Fleet vehicles, assets

**LMU-1200** (Basic Fleet Tracking)
- **Technology**: 2G/3G cellular
- **Features**:
  - Essential GPS tracking
  - Digital inputs/outputs
  - Panic button support
  - Cost-effective solution
- **Applications**: Entry-level fleet tracking

**LMU-4200** (Heavy-Duty Tracker)
- **Technology**: Ruggedized 3G/4G
- **Features**:
  - Military-grade durability
  - Extended temperature range
  - Multiple CAN interfaces
  - Advanced diagnostics
- **Applications**: Construction, mining, agriculture

**LMU-800** (Compact Vehicle Tracker)
- **Technology**: 2G/3G cellular
- **Features**:
  - Ultra-compact design
  - Low power consumption
  - Basic I/O capabilities
  - Easy installation
- **Applications**: Personal vehicles, small fleet

#### TTU Series (Trailer Tracking Units)

**TTU-1230** (Trailer Tracking Unit)
- **Technology**: LTE Cat M1
- **Features**:
  - Solar charging capability
  - Long battery life (5+ years)
  - Door sensor integration
  - Tamper detection
- **Applications**: Trailers, containers, cargo

#### VTG Series (Vehicle Telematics Gateway)

**VTG-350** (Vehicle Telematics Gateway)
- **Technology**: 4G LTE with 3G fallback
- **Features**:
  - Full telematics platform
  - ECM data extraction
  - Driver behavior monitoring
  - Fuel management
- **Applications**: Commercial fleet management

### Technical Specifications

#### Connectivity
- **Cellular**: 2G/3G/4G LTE, Cat M1, NB-IoT
- **GNSS**: GPS, GLONASS, Galileo (select models)
- **Interfaces**: CAN (J1939, J1708), RS232, 1-Wire
- **Wireless**: Wi-Fi, Bluetooth, RFID
- **Satellite**: Iridium (select models)

#### I/O Capabilities
- **Digital Inputs**: 2-8 channels (programmable)
- **Digital Outputs**: 1-4 channels
- **Analog Inputs**: 1-4 channels (0-5V, 4-20mA)
- **CAN Ports**: 1-2 high-speed CAN
- **Serial Ports**: RS232/RS485

#### Power Management
- **Operating Voltage**: 8-32V DC
- **Sleep Current**: <1mA (ultra-low power)
- **Internal Battery**: Backup power (hours to days)
- **Solar Charging**: Integrated (TTU series)
- **Power Management**: Intelligent sleep modes

### Common Event Codes
- 1: Power up
- 2: Power down  
- 3: Timeout
- 4: Low battery
- 5: Motion start
- 6: Motion stop
- 7: Heading change
- 8: Panic button
- 9-12: External inputs 1-4
- 13: Input state change
- 14: Geofence enter
- 15: Geofence exit
- 16: Speed limit violation
- 17: Tow detected
- 18: Harsh acceleration
- 19: Harsh braking
- 20: Harsh cornering

### Input/Output Mapping
- Bit 0: Ignition detection
- Bit 1: Digital input 1
- Bit 2: Digital input 2
- Bit 3: Digital input 3  
- Bit 4: Digital input 4
- Bits 5-7: Reserved/device-specific

### Quality & Certifications
- **FCC Part 15**: Electromagnetic compatibility
- **IC (Industry Canada)**: Canadian certification
- **PTCRB**: Cellular certification
- **CE Mark**: European conformity
- **RoHS**: Environmental compliance
- **E-Mark**: Automotive qualification

## Common Applications

- **Fleet Management**: Vehicle tracking and driver monitoring
- **Asset Tracking**: Equipment and cargo monitoring
- **Cold Chain**: Temperature-controlled logistics
- **Construction**: Heavy equipment management
- **Oil & Gas**: Remote asset monitoring
- **Government**: Public safety and emergency services
- **Agriculture**: Farm equipment tracking
- **Waste Management**: Route optimization
- **Public Transit**: Bus and rail monitoring
- **Emergency Services**: First responder tracking

## Protocol Implementation

### Message Parsing
- Optional headers require bit checking
- Service type determines acknowledgment needs
- Sequence numbers track message flow
- Multiple message types in single connection

### Position Calculation
- Latitude/longitude: signed integer ÷ 10,000,000
- Altitude: signed integer ÷ 100 (centimeters to meters)
- Speed: unsigned integer × 0.0360036 (cm/s to knots)
- Heading: unsigned integer ÷ 10 (0.1 degree resolution)

### Event Processing
- Event codes indicate trigger conditions
- Accumulator data provides sensor values
- Input states show digital I/O status
- Status flags indicate device health

### Communication Flow
1. Device connects via TCP/UDP
2. Optional ID message with device identifier
3. Event reports sent on triggers
4. Server acknowledges if required
5. Commands sent from server as needed

## Market Leadership

### Technology Innovation
- **Pioneer**: Early cellular M2M adoption
- **Standards**: Contributed to telematics protocols
- **Integration**: OEM partnerships with vehicle manufacturers
- **Cloud Platform**: CalAmp Applications Cloud

### Competitive Advantages
- **Reliability**: Proven in harsh environments
- **Scalability**: Millions of devices deployed
- **Integration**: Deep vehicle system access
- **Support**: Global technical assistance

## Traccar Configuration

```xml
<entry key='calamp.port'>5082</entry>
```

### Protocol Features
- **Binary Format**: Efficient data transmission
- **Variable Headers**: Flexible device identification
- **Event-Driven**: Real-time notification system
- **Accumulator Support**: Comprehensive sensor data
- **Mini Messages**: Bandwidth optimization

The CalAmp protocol represents mature telematics technology from a leading American manufacturer, combining reliable binary communication with comprehensive fleet management capabilities for enterprise-grade tracking applications.