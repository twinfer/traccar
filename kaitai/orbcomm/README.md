# ORBCOMM Protocol

The ORBCOMM protocol is a satellite-based IoT communication system developed by ORBCOMM Inc., a global provider of satellite data communications services. Founded in 1993 and headquartered in Rochelle Park, New Jersey, ORBCOMM operates the world's largest commercial satellite network for IoT and M2M communications, serving over 2 million subscribers globally.

## Protocol Overview

**Type:** HTTP/JSON API with satellite messaging  
**Manufacturer:** ORBCOMM Inc. (USA)  
**Primary Use:** Global satellite IoT, asset tracking, remote monitoring  
**Data Format:** JSON over HTTP with structured payload fields  
**Network:** Satellite (VHF, L-band) + Cellular fallback  
**Coverage:** Global including oceans and polar regions

## Message Structure

### HTTP Request Format
```
GET /GLGW/2/RestMessages.svc/JSON/get_return_messages/
?access_id={ID}&password={PWD}&start_utc={UTC_TIME}
```

### JSON Response Structure
```json
{
  "ErrorID": 0,
  "NextStartUTC": "2022-02-17 08:44:45",
  "Messages": [
    {
      "ID": 10343663424,
      "MessageUTC": "2022-02-17 08:44:45",
      "ReceiveUTC": "2022-02-17 08:44:45", 
      "SIN": 126,
      "MobileID": "01452955SKYB444",
      "Payload": {
        "Name": "MovingIntervalSat",
        "SIN": 126,
        "MIN": 22,
        "Fields": [
          {"Name": "Latitude", "Value": "727668"},
          {"Name": "Longitude", "Value": "902276"},
          {"Name": "Speed", "Value": "0"},
          {"Name": "Heading", "Value": "361"},
          {"Name": "EventTime", "Value": "1645087473"}
        ]
      },
      "RegionName": "EMEARB6",
      "OTAMessageSize": 16,
      "CustomerID": 0,
      "Transport": 1,
      "MobileOwnerID": 60003097
    }
  ]
}
```

### Field Details
- **ErrorID**: 0 = success, non-zero = error code
- **NextStartUTC**: Next polling timestamp for continuous data retrieval
- **Messages**: Array of satellite terminal messages
- **ID**: Unique message identifier (64-bit)
- **MessageUTC**: Satellite transmission timestamp
- **ReceiveUTC**: Gateway receive timestamp
- **SIN**: Service Identification Number (message type)
- **MobileID**: Terminal identifier (15-character alphanumeric)
- **Payload**: Structured data from terminal
- **RegionName**: Satellite coverage region
- **OTAMessageSize**: Over-the-air message size in bytes
- **Transport**: 1 = satellite, 2 = cellular

### Service Identification Numbers (SIN)
- **SIN 0**: Modem registration
- **SIN 22**: Moving interval satellite report
- **SIN 23**: Stationary interval satellite report
- **SIN 126**: Position tracking data
- **SIN 127**: Emergency alert

### Payload Types

#### Position Tracking (MovingIntervalSat)
Common fields for location tracking:
- **Latitude**: Integer value ÷ 60,000 = degrees
- **Longitude**: Integer value ÷ 60,000 = degrees  
- **Speed**: Integer value in km/h
- **Heading**: 0-360 degrees (361 = invalid)
- **EventTime**: Unix timestamp

#### Modem Registration (modemRegistration)
Device identification fields:
- **hardwareMajorVersion**: Hardware revision
- **hardwareMinorVersion**: Hardware sub-revision
- **softwareMajorVersion**: Firmware version
- **softwareMinorVersion**: Firmware sub-version
- **product**: Device model identifier
- **wakeupPeriod**: Power management setting
- **lastResetReason**: Diagnostic information
- **virtualCarrier**: Network configuration
- **beam**: Satellite beam identifier

## Key Features

- **Global Coverage**: Satellite network reaches remote areas without cellular
- **Dual-Mode**: Automatic cellular/satellite fallback
- **Low Latency**: Faster than traditional satellite services
- **Small Messages**: Optimized for IoT data transmission
- **Bidirectional**: Two-way communication capability
- **Security**: Encrypted satellite transmission
- **Reliability**: 99.9% network availability
- **Long Battery Life**: Power-efficient terminals

## Device Identification

### Company Information
**ORBCOMM Inc.**  
- Founded: 1993 in Washington, D.C.
- Headquarters: Rochelle Park, New Jersey, USA
- CEO: Marc Eisenberg
- Employees: 650+ globally
- Revenue: $300M+ annually (2023)
- Stock: NASDAQ: ORBC

### Global Infrastructure
- **Satellites**: 30+ LEO satellites
- **Ground Stations**: 17 worldwide
- **Coverage**: Global including polar regions
- **Partners**: Inmarsat, u-blox, Quectel
- **Customers**: 150+ countries

### Satellite Networks

#### ORBCOMM Network (VHF)
- **Frequency**: 137-150 MHz VHF
- **Satellites**: ORBCOMM Generation 2 (OG2)
- **Orbit**: Low Earth Orbit (LEO)
- **Coverage**: Global with polar regions
- **Message Size**: Up to 6 KB uplink, 10 KB downlink

#### IsatData Pro (IDP) Network (L-band)
- **Frequency**: 1525-1559 MHz L-band
- **Satellites**: Inmarsat geostationary
- **Coverage**: Global (75°N to 75°S)
- **Message Size**: Up to 10 KB bidirectional
- **Latency**: <30 seconds typical

### Device Families

#### ST 2100 Satellite Terminal
- **Technology**: VHF satellite + GPS
- **Form Factor**: Compact, environmentally sealed
- **Features**:
  - Low power consumption (<1W average)
  - Flexible I/O interfaces
  - GPS/GNSS positioning
  - Temperature range: -40°C to +75°C
  - IP67 rating
- **Applications**: Asset tracking, remote monitoring

#### ST 6000 Series
- **Technology**: IsatData Pro (IDP) L-band
- **Features**:
  - Global Inmarsat satellite connectivity
  - Industrial-grade design
  - Enhanced messaging capacity
  - Lower latency than VHF
- **Applications**: Industrial IoT, SCADA systems

#### ST 9100 Dual-Mode Terminal
- **Technology**: Satellite + 4G LTE/3G/2G cellular
- **Features**:
  - Automatic network fallback
  - Programmable logic
  - Multiple I/O interfaces
  - Asset tracking and monitoring
  - Global coverage (land and sea)
- **Applications**: Fleet management, maritime tracking

#### OG2/OGi Satellite Modems
- **Form Factor**: Credit card size
- **Features**:
  - Interchangeable ORBCOMM/Inmarsat modems
  - Superior latency and power efficiency
  - Easy integration
  - Identical footprint for flexibility
- **Applications**: OEM integration, custom devices

### Technical Specifications

#### Communication Parameters
- **Uplink Power**: 5W maximum
- **Antenna**: Omnidirectional VHF or patch L-band
- **Protocol**: Proprietary packet-based
- **Encryption**: AES-256 satellite encryption
- **Error Correction**: Forward error correction

#### I/O Capabilities
- **Digital Inputs**: 4-8 channels
- **Digital Outputs**: 2-4 channels  
- **Analog Inputs**: 2-4 channels (0-5V)
- **Serial Interfaces**: RS232, RS485, CAN
- **Protocols**: Modbus, DNP3, custom

#### Power Management
- **Operating Voltage**: 8-32V DC
- **Power Consumption**: <1W average
- **Sleep Mode**: <10mA standby
- **External Power**: Solar, battery, vehicle
- **Backup Battery**: Internal lithium (days)

### Regional Coverage

#### ORBCOMM Regions
- **AMRRIB**: Americas (North/South America)
- **EMEARB**: Europe, Middle East, Africa
- **APACIB**: Asia Pacific
- **Global**: Combined coverage

#### Message Routing
Messages are routed based on satellite visibility and terminal location:
- Automatic beam selection
- Regional gateway processing
- Global message delivery

### Common Payload Fields

#### Position Data
- **Latitude/Longitude**: ±90°/±180° (1/60000 degree resolution)
- **Speed**: 0-255 km/h
- **Heading**: 0-360° (361 = invalid GPS fix)
- **EventTime**: Unix timestamp (seconds since epoch)

#### Device Status
- **Battery**: Voltage and charge level
- **Signal**: Satellite signal strength
- **Temperature**: Internal device temperature
- **Motion**: Accelerometer status
- **Inputs**: Digital I/O states

#### IoT Sensors
- **Temperature**: External temperature probes
- **Pressure**: Hydraulic/pneumatic sensors
- **Fuel**: Tank level monitoring
- **Door**: Open/close status
- **Tamper**: Security alerts
- **Geofence**: Virtual boundary events

### Quality & Certifications
- **FCC Part 25**: Satellite communications
- **IC RSS-210**: Canadian satellite certification
- **CE Mark**: European conformity
- **IRIDIUM Ready**: Interoperability certified
- **MIL-STD-810**: Military environmental testing
- **ISO 9001**: Quality management system

## Common Applications

- **Maritime Tracking**: Vessel monitoring in remote oceans
- **Oil & Gas**: Remote wellhead and pipeline monitoring
- **Mining**: Equipment tracking in remote locations
- **Agriculture**: Precision farming and livestock monitoring
- **Transportation**: Container and cargo tracking
- **Utilities**: SCADA for remote infrastructure
- **Government**: Defense and emergency services
- **Environmental**: Weather stations and sensors
- **Aviation**: Aircraft tracking and telemetry
- **Construction**: Heavy equipment management

## Protocol Implementation

### HTTP Polling Mechanism
1. Client sends GET request with credentials
2. Server returns JSON response with messages
3. NextStartUTC provides next polling timestamp
4. Continuous polling retrieves new messages
5. Message acknowledgment via separate API

### Message Processing
1. Parse JSON response structure
2. Extract message metadata and payload
3. Process payload fields based on SIN/MIN
4. Convert coordinate values (÷60000)
5. Handle device registration vs. data messages

### Position Calculation
- **Latitude**: Integer value ÷ 60,000 = decimal degrees
- **Longitude**: Integer value ÷ 60,000 = decimal degrees
- **Speed**: Direct km/h value
- **Heading**: 0-360° (validate ≤360)
- **Timestamp**: Unix epoch seconds

### Error Handling
- **ErrorID 0**: Success, process messages
- **ErrorID ≠ 0**: Service error, retry with backoff
- **Empty Messages**: No new data, continue polling
- **Invalid Coordinates**: Use last known position

## Market Leadership

### Technology Innovation
- **First Commercial LEO**: Pioneer in commercial satellite IoT
- **Dual-Mode Devices**: Seamless cellular/satellite switching
- **Global Network**: Largest commercial satellite constellation
- **Low Latency**: Faster than traditional satellite services

### Competitive Advantages
- **Global Coverage**: Including polar regions and oceans
- **Proven Reliability**: 99.9% network availability
- **Power Efficiency**: Ultra-low power consumption
- **Regulatory Compliance**: Worldwide spectrum licensing

## Traccar Configuration

```xml
<entry key='orbcomm.port'>5074</entry>
<entry key='orbcomm.accessId'>your_access_id</entry>
<entry key='orbcomm.password'>your_password</entry>
<entry key='orbcomm.address'>api.orbcomm.com</entry>
<entry key='orbcomm.interval'>300000</entry>
```

### Protocol Features
- **HTTP/JSON API**: RESTful web service interface
- **Polling-Based**: Server-initiated data retrieval
- **Global Reach**: Satellite coverage everywhere
- **Flexible Payloads**: Customizable data structures
- **Dual-Mode Support**: Automatic network failover

The ORBCOMM protocol represents the leading satellite IoT communication platform, combining global coverage with reliable messaging for mission-critical applications in the world's most remote locations.