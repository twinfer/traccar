# Concox Protocol

The Concox protocol is a binary GPS tracking communication standard developed by Concox (Jimi IoT), a leading Chinese telematics manufacturer based in Shenzhen. With over 15 years in the industry, Concox specializes in the GT06 family of GPS trackers, providing comprehensive fleet management and vehicle tracking solutions worldwide.

## Protocol Overview

**Type:** Binary with standard and extended packet formats  
**Manufacturer:** Concox Information Technology Co., Ltd. (Jimi IoT)  
**Primary Use:** Vehicle tracking, fleet management, personal safety  
**Data Format:** Binary frames with CRC16-CCITT validation  
**Packet Types:** Standard (0x7878) and Extended (0x7979)  
**Global Reach:** Distributed in 100+ countries

## Message Structure

### Packet Format
```
[Start:2][Length:1-2][Protocol:1][Information:N][Serial:2][CRC:2][Stop:2]
```

### Field Details
- **Start Bits**: 0x7878 (standard) or 0x7979 (extended)
- **Length**: Payload length (1 byte standard, 2 bytes extended)
- **Protocol**: Message type identifier
- **Information**: Message-specific data content
- **Serial**: 16-bit sequence number
- **CRC**: CRC16-CCITT error checking
- **Stop Bits**: 0x0D0A (CRLF terminator)

### Example Login Message
```
78 78 0F 01 12 34 56 78 90 12 34 56 01 23 00 01 8C DD 0D 0A
```

### Example GPS Message
```
78 78 22 12 0B 03 1D 0F 32 32 05 C9 02 7A C8 18 0C 46 58 60 00 14 00 01 CC 00 28 7D 00 1F 71 0D 0A
```

## Protocol Types

### Core Messages
- **0x01**: Login message (device registration)
- **0x12**: GPS positioning data
- **0x22**: GPS + LBS positioning
- **0x16**: GPS + LBS + Status information
- **0x23**: Heartbeat data
- **0x15**: String information
- **0x26**: Alarm data

### Extended Messages
- **0x17**: WiFi information
- **0x18**: LBS multiple cell towers
- **0x1C**: LBS + WiFi combined
- **0x1D**: LBS extended format
- **0x1E**: GPS + LBS extended
- **0x8C**: OBD diagnostic data
- **0x94**: Driver behavior analysis

### Command Messages
- **0x80**: Command response
- **0x82**: Oil/power cutoff command
- **0x83**: Oil/power resume command
- **0x84**: Time zone setting
- **0x85**: Device reboot command

## Key Features

- **Dual Packet Format**: Standard and extended for different data sizes
- **Comprehensive Tracking**: GPS, LBS, WiFi positioning
- **Vehicle Integration**: OBD-II support, fuel monitoring
- **Security Features**: SOS alarm, anti-theft protection
- **Remote Control**: Oil/power cutoff, configuration via SMS
- **Driver Behavior**: Harsh acceleration/braking detection
- **Multi-Sensor**: Temperature, vibration, door sensors
- **Global Coverage**: GSM/GPRS/3G/4G connectivity

## Device Identification

### Company Information
**Concox Information Technology Co., Ltd.**  
- Trade Name: Jimi IoT
- Founded: 2005 in Shenzhen, China
- Headquarters: Shenzhen, Guangdong Province
- Global Offices: United States, Europe
- Experience: 15+ years in telematics
- Focus: IoT solutions, GPS tracking, fleet management

### Market Presence
- **Global Reach**: 100+ countries
- **Product Range**: Vehicle trackers, personal trackers, IoT devices
- **Industries**: Fleet management, logistics, personal safety
- **Certifications**: CE, FCC, IC, RoHS compliance
- **Quality**: ISO 9001 certified manufacturing

### GT06 Device Family

#### GT06N (Standard Model)
- **Technology**: 2G GSM/GPRS with GPS
- **Features**:
  - Built-in GPS and GSM antennas
  - Towing sensor and vibration alarm
  - SOS emergency button
  - Remote fuel/power cutoff
  - Geo-fencing capabilities
  - 450mAh backup battery
  - Voice monitoring capability
- **Applications**: Private cars, small fleet vehicles

#### GT06E (Enhanced Model)
- **Technology**: 3G-ready GPS tracker
- **Features**:
  - Enhanced connectivity options
  - Improved GPS sensitivity
  - Extended battery life
  - Advanced alarm features
- **Applications**: Fleet management, commercial vehicles

#### GT06D (Deluxe Model)
- **Technology**: Advanced tracking with additional sensors
- **Features**:
  - Door sensor integration
  - Temperature monitoring
  - Enhanced security features
  - Multi-zone geo-fencing
- **Applications**: High-value vehicle protection

#### GT06 Pro (Professional)
- **Technology**: Professional-grade tracking
- **Features**:
  - OBD-II diagnostics integration
  - CAN bus data reading
  - Driver behavior analysis
  - Fleet management tools
- **Applications**: Commercial fleets, logistics

#### GT06 4G (Next Generation)
- **Technology**: 4G LTE connectivity
- **Features**:
  - High-speed data transmission
  - Cloud-based configuration
  - Real-time streaming capabilities
  - Enhanced positioning accuracy
- **Applications**: Modern fleet operations

### Technical Specifications

#### Communication
- **Cellular**: 2G/3G/4G depending on model
- **Frequencies**: 
  - GSM 850/900/1800/1900 MHz
  - UMTS 2100/1900/850 MHz (3G models)
  - LTE Cat 1 (4G models)
- **Protocols**: TCP/UDP over GPRS/3G/4G
- **Backup**: SMS fallback communication

#### Positioning
- **GPS**: L1 C/A code, 1575.42 MHz
- **Sensitivity**: -159 dBm tracking, -148 dBm cold start
- **Accuracy**: <2.5m CEP (50% circular error probability)
- **TTFF**: <45s cold start, <35s warm start, <1s hot start
- **Assisted GPS**: A-GPS support for faster fix

#### Power Management
- **Operating Voltage**: 9-36V DC (vehicle power)
- **Backup Battery**: 3.7V Li-ion, 450-1000mAh depending on model
- **Standby Current**: <5mA in sleep mode
- **Operating Current**: <60mA during transmission
- **Battery Life**: 3-7 days standby (depending on usage)

### Coordinate Encoding

Concox uses a specific coordinate format:
- **Raw Format**: Latitude/Longitude × 1,800,000 (degrees to minutes × 30,000)
- **Sign Bits**: Course_Status field bits 10-11
- **Conversion**: (Raw_Value / 1,800,000) × Sign
- **Resolution**: Approximately 0.56 meters at equator

### Alarm Types

#### Security Alarms
- **0x01**: SOS distress signal
- **0x02**: Power cut alarm
- **0x03**: Vibration/shock alarm
- **0x04**: Geo-fence entry
- **0x05**: Geo-fence exit
- **0x06**: Overspeed alarm
- **0x07**: Movement alarm

#### System Alarms
- **0x08**: GPS blind area
- **0x09**: Low power warning
- **0x0A**: Power off alarm
- **0x0B**: SIM card problem
- **0x0C**: GPS antenna disconnect
- **0x10**: SIM door open
- **0x11**: GPS jamming detected

### Driver Behavior Detection

#### Behavior Types
- **0x01**: Harsh acceleration
- **0x02**: Harsh braking
- **0x03**: Sharp cornering
- **0x04**: Collision detection
- **0x05**: Rollover detection
- **0x06**: Rapid lane change

### Status Information

#### Terminal Status Bits
- Bit 0: Oil/electricity connection
- Bit 1: GPS tracking status
- Bit 2: Alarm status
- Bits 3-5: Alarm type
- Bit 6: Charging status (0=charging)
- Bit 7: ACC status

#### Voltage Levels (0-6 scale)
- 0: Power off
- 1: Extremely low (<10%)
- 2: Very low (10-25%)
- 3: Low (25-50%)
- 4: Medium (50-75%)
- 5: High (75-90%)
- 6: Highest (90-100%)

### Configuration via SMS

#### Basic Commands
- **APN Setting**: `APN123456 [APN_NAME]`
- **Server Setting**: `ADMINIP123456 [IP] [PORT]`
- **Tracking Interval**: `TIMER123456 [SECONDS]`
- **Time Zone**: `TIMEZONE123456 [OFFSET]`
- **SOS Number**: `SOS123456 [PHONE_NUMBER]`

#### Advanced Commands
- **Geo-fence**: `STOCKADE123456 [LAT] [LON] [RADIUS]`
- **Speed Limit**: `SPEED123456 [KMH]`
- **Power Cut**: `DYD123456` (oil/power cutoff)
- **Power Resume**: `HFYD123456` (restore oil/power)
- **Reset**: `RESET123456` (factory reset)

### Quality & Certifications
- **CE Mark**: European conformity
- **FCC Part 15**: US electromagnetic compatibility
- **IC RSS-210**: Canadian certification
- **RoHS**: Environmental compliance
- **ISO 9001**: Quality management system
- **E-Mark**: Automotive approval (select models)

## Common Applications

- **Fleet Management**: Commercial vehicle tracking and monitoring
- **Personal Safety**: Individual GPS trackers for elderly/children
- **Asset Protection**: High-value equipment and cargo tracking
- **Logistics**: Supply chain visibility and delivery optimization
- **Car Rental**: Usage monitoring and theft prevention
- **Emergency Services**: First responder vehicle coordination
- **Construction**: Heavy equipment tracking and utilization
- **Agriculture**: Farm vehicle and equipment monitoring
- **Public Transport**: Bus and taxi fleet management
- **Insurance**: Usage-based insurance (UBI) programs

## Protocol Implementation

### Message Parsing
1. Verify start bits (0x7878 or 0x7979)
2. Read length field (1 or 2 bytes)
3. Extract protocol type and payload
4. Validate CRC16-CCITT checksum
5. Verify stop bits (0x0D0A)

### Login Processing
1. Extract IMEI from BCD-encoded terminal ID
2. Decode device model from type identification
3. Store time zone and language settings
4. Register device session
5. Send acknowledgment response

### GPS Data Processing
1. Parse date/time structure (YY/MM/DD HH:MM:SS)
2. Decode positioning information with coordinate conversion
3. Extract satellite count and GPS validity
4. Process course and speed information
5. Handle cellular tower data if present

### Alarm Handling
1. Extract alarm type from status or dedicated field
2. Map alarm code to alarm description
3. Process GPS location if available
4. Store alarm with timestamp and location
5. Trigger appropriate notifications

## Market Position

### Technology Advantages
- **Cost-Effective**: Competitive pricing for mass market
- **Reliable**: Proven technology with millions deployed
- **Comprehensive**: Full-featured tracking capabilities
- **Global Support**: Worldwide distributor network

### Competitive Features
- **Easy Configuration**: SMS-based setup and control
- **Multi-Technology**: GPS, LBS, WiFi positioning
- **Vehicle Integration**: OBD-II and CAN bus support
- **Security Focus**: Anti-theft and emergency features

## Traccar Configuration

```xml
<entry key='gt06.port'>5023</entry>
```

### Protocol Features
- **Binary Format**: Efficient data transmission
- **Dual Packet Types**: Standard and extended formats
- **Comprehensive Tracking**: Multiple positioning technologies
- **Vehicle Integration**: OBD-II and diagnostics support
- **Real-Time Alarms**: Immediate event notifications

The Concox protocol represents reliable and cost-effective GPS tracking technology from a leading Chinese manufacturer, combining proven binary communication with comprehensive vehicle monitoring capabilities for global fleet management applications.