# Enfora Protocol

The Enfora protocol is a binary GPS tracking protocol with NMEA sentence encapsulation, developed by Enfora Inc., a pioneering M2M (Machine-to-Machine) communications company. The protocol transmits device identification and standard GPRMC GPS data within length-prefixed binary frames.

## Protocol Overview

**Type:** Binary with NMEA data encapsulation  
**Manufacturer:** Enfora Inc. (acquired by Novatel Wireless)  
**Primary Use:** Asset tracking, fleet management, M2M communications  
**Data Format:** Length-prefixed binary frames with ASCII content  
**Bidirectional:** Yes (commands and responses)

## Message Structure

### Frame Format
```
[Length:2][Index:2][Type:1][OptHeader:1][Body:N]
```

### Field Details
- **Length**: 16-bit big-endian, includes length field itself
- **Index**: 16-bit message sequence number
- **Type**: Command type byte
  - 0x00: Keep-alive
  - 0x02: GPS data
  - 0x04: Command
  - 0x08: Data type 8
  - 0x0A: Data type A
- **Optional Header**: Additional header byte (if frame >= 6 bytes)
- **Body**: Variable length payload

### GPS Data Body Structure
1. **Padding**: Variable spaces (0x20)
2. **IMEI**: 15 consecutive ASCII digits
3. **NMEA Data**: Standard GPRMC sentence
   - Format: `$GPRMC,time,status,lat,N/S,lon,E/W,speed,course,date,,,mode*checksum`
   - Terminated with CR+LF (0x0D 0x0A)

### Command Format
For outbound commands:
- Length = content length + 6
- Index = 0x0000
- Type = 0x04
- Optional header = 0x00
- Content = ASCII command (e.g., "AT$IOGP3=1")

## Key Features

- **NMEA Encapsulation**: Standard GPRMC sentences within binary frames
- **Flexible IMEI Location**: Device ID can appear anywhere in message
- **Length-Based Framing**: Reliable message boundaries
- **M2M Optimized**: Designed for machine-to-machine communications
- **Multi-Protocol**: TCP with length prefix, UDP without
- **AT Command Support**: Remote device configuration

## Device Identification

### Company History
**Enfora Inc.**  
- Founded: 1999 in Richardson, Texas, USA
- Acquired: November 2010 by Novatel Wireless for $64.5-70 million
- Revenue: $61.3 million (year ending September 2010)
- Focus: Wireless asset management and M2M communications
- Markets: Transportation, industrial automation, security, healthcare

### Device Families

#### Spider MT Series
Professional vehicle tracking platforms:
- **GSM2218**: Quad-band fleet management tracker
  - Certified platform
  - Complete GSM/GPRS functionality
  - Fleet management optimized
  
- **GSM2238/GSM2338 (MT-Gu)**: Advanced vehicle tracker
  - Dual/quad-band operation
  - Vehicle recovery features
  - Driver profiling
  - Fuel efficiency monitoring
  - Interactive communications
  
- **GSM5108**: Certified tracking platform
  - Dual/quad-band GSM/GPRS
  - Mobile tracking applications
  - Spider MT family member

#### Mini-MT Series
Compact tracking solutions:
- **GSM2428 Mini MT**: Highly sensitive GPS tracker
  - Compact form factor
  - GPRS connectivity
  - Essential tracking features

#### Enabler Series
Modular wireless platforms:
- **Enabler II Family**: Scalable M2M platforms
  - Dual/quad-band embedded
  - Modular architecture
  - Adaptable design
  - Best-selling product line

#### Spider AT Series
Asset tracking specialized:
- **Spider AT**: Fixed asset monitoring
  - GPS positioning
  - Cellular connectivity
  - Real-time data transmission
  - Asset management focus

### Device Capabilities

#### Core Features
- **GPS**: High-sensitivity receivers
- **Cellular**: GSM/GPRS dual/quad-band
- **Garmin FMI**: Fleet Management Interface support
- **Rules Engine**: Programmable logic
- **Network Router**: Built-in routing capabilities
- **Control Automation**: Flexible customization

#### Advanced Functions
- **Geo-fencing**: Virtual boundary monitoring
- **GPIO**: General purpose inputs/outputs
- **Internal Antennas**: Cost-effective installation
- **Auto-Registration**: Automatic network connection
- **Battery Backup**: Continued operation during outages
- **SMS Integration**: Commands and messaging

### Physical Characteristics

#### Connectivity
- **Cellular**: GSM 850/900/1800/1900 MHz
- **GPS**: Integrated receiver
- **Interfaces**: Serial, GPIO
- **Antennas**: Internal or external options

#### Environmental
- **Temperature**: Industrial grade operation
- **Power**: Vehicle power with backup
- **Enclosure**: Ruggedized for mobile use
- **Mounting**: Flexible installation options

### Protocol Detection Features

#### Frame Structure
- **Length Prefix**: Big-endian 16-bit
- **Index Field**: Sequential numbering
- **Type Byte**: Message classification
- **IMEI Pattern**: 15 consecutive digits
- **NMEA Marker**: "$GPRMC" substring

#### Data Patterns
- **Space Padding**: Multiple 0x20 bytes
- **ASCII Content**: Mixed binary/ASCII
- **NMEA Format**: Standard sentences
- **Checksum**: NMEA XOR validation

### M2M Innovation

#### Industry Leadership
- **Early Pioneer**: 1999 founding in M2M space
- **Differentiation**: Customized software/services
- **Integration**: Hardware/software solutions
- **Market Focus**: Value-added applications

#### Target Markets
- **Transportation**: Fleet tracking and management
- **Industrial**: Automation and monitoring
- **Security**: Asset protection and recovery
- **Healthcare**: Mobile medical equipment

## Common Applications

- **Fleet Management**: Commercial vehicle tracking
- **Asset Tracking**: High-value equipment monitoring
- **Vehicle Recovery**: Stolen vehicle location
- **Field Service**: Mobile workforce management
- **Supply Chain**: Cargo and container tracking
- **Utilities**: Remote meter reading
- **Oil & Gas**: Equipment monitoring
- **Agriculture**: Farm equipment tracking
- **Construction**: Heavy machinery management
- **Emergency Services**: First responder tracking

## Legacy and Evolution

### Novatel Wireless Acquisition
- **Date**: November 30, 2010
- **Value**: $64.5-70 million
- **Integration**: Operated as business unit
- **Leadership**: Mark Weinzierl joined senior management
- **Synergies**: Combined R&D and customer base

### Technology Impact
- **M2M Pioneer**: Early wireless data solutions
- **Innovation**: Programmable platforms
- **Market Creation**: Asset tracking category
- **Standards**: Industry protocol adoption

## Traccar Configuration

```xml
<entry key='enfora.port'>5043</entry>
```

### Protocol Features
- **Frame Decoder**: Length-field based (1024, 0, 2, -2, 2)
- **IMEI Detection**: Pattern matching for 15 digits
- **NMEA Parsing**: GPRMC sentence extraction
- **Command Encoding**: AT command support
- **Multi-Transport**: TCP and UDP variants

### Implementation Notes
- TCP uses length prefix for framing
- UDP relies on packet boundaries
- IMEI can appear anywhere in message
- Flexible parsing for various formats
- Legacy compatibility maintained

The Enfora protocol represents early M2M innovation, combining simple binary framing with standard NMEA data for reliable GPS tracking and remote asset management.