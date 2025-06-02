# Navtelecom Protocol

The Navtelecom protocol is a flexible binary GPS tracking protocol developed by Navtelecom LLC, a Russian manufacturer of GLONASS/GPS monitoring equipment. It features dynamic field configuration through the FLEX protocol, allowing devices to optimize data transmission by sending only relevant fields.

## Protocol Overview

**Type:** Binary with flexible field configuration  
**Manufacturer:** Navtelecom LLC (Russia)  
**Primary Use:** Fleet management, vehicle tracking  
**Data Format:** Binary with bit-mask field selection  
**Bidirectional:** Yes (commands and responses)

## Message Structure

### Message Types
1. **Control Messages** (start with '@'/0x40):
   - Device identification (`*>S`)
   - FLEX configuration (`*>FLEX`, `*<FLEX`)
   - Command results (`*@C`)

2. **Position Messages** (start with '~'/0x7E):
   - Type 'A' for position data
   - Support for multiple position records

3. **Heartbeat** (0x7F):
   - Keepalive messages

### Control Message Format
```
[@][NTC][Receiver:4][Sender:4][Length:2][DataCRC:1][HeaderCRC:1][Payload:N]
```

### Position Message Format
```
[~][A][Count:1][Records:N][CRC8:1]
```

### FLEX Protocol Configuration
The FLEX protocol allows dynamic field selection:
- Protocol version and structure version
- Bit count (number of fields)
- Bit mask (each bit enables a field)

### Data Fields (255 possible fields)
The protocol supports up to 255 configurable fields:

#### Basic GPS Data (IDs 1-14)
- Index, Event, Timestamp
- Satellites, HDOP, Valid flag
- Latitude, Longitude (minutes × 0.0001)
- Speed, Course, Altitude

#### Power/Battery (IDs 19-20)
- External power voltage
- Battery voltage

#### Analog Inputs (IDs 21-26)
- ADC1 through ADC6

#### Digital I/O (IDs 29, 31)
- Digital inputs (16 bits)
- Digital outputs (16 bits)

#### Counters (IDs 33-34)
- Counter 1 and Counter 2

#### Fuel Sensors (IDs 38-44, 53-54, 78-83)
- Up to 7 fuel level sensors
- Fuel consumption data
- Fuel temperature sensors

#### Temperature Sensors (IDs 45-52, 163-166)
- Up to 12 temperature sensors

#### OBD Data (IDs 55-69)
- Engine RPM
- Coolant temperature
- Odometer
- Vehicle speed
- Fuel level
- Throttle position

#### Extended Sensors (IDs 167-170)
- Humidity sensors (4 channels)

#### User Data (IDs 207-255)
- Custom user-defined fields
- Various data sizes (1, 2, 4, 8 bytes)

## Key Features

- **Dynamic Field Selection**: FLEX protocol optimizes bandwidth
- **Multi-Sensor Support**: Extensive sensor integration
- **GLONASS/GPS**: Dual satellite system support
- **CRC Validation**: CRC8_EGTS for position data
- **Remote Configuration**: RCS (Remote Configuration Service)
- **Professional Interfaces**: CAN, RS-232/485, 1-Wire, Bluetooth

## Device Identification

### Manufacturer Information
**Navtelecom LLC**  
- Founded: Russia
- Specialization: GLONASS/GPS monitoring equipment
- Focus: Transportation and fleet management
- Certification: Russian government standards compliant

### Device Series

#### SMART Series (Cost-Effective)
- **SMART S-2330**: Basic GPS/GLONASS tracker
  - Simple and cost-effective solution
  - Internal antennas
  - Basic tracking functionality
  
- **SMART S-2332**: Enhanced tracker
  - GPS/GLONASS positioning
  - RS-232 and RS-485 interfaces
  - 1-Wire sensor support
  - External sensor connectivity
  
- **SMART S-2435**: Advanced smart tracker
  - Professional features
  - Multiple interface support
  - Enhanced sensor capabilities

#### START Series (Entry-Level)
- **START S-2010**: Compact fleet tracker
  - Internal GNSS and GSM antennas
  - Basic monitoring features
  - Compact form factor
  
- **START S-2012**: Basic compact tracker
  - Internal antennas
  - Essential tracking features
  - Cost-optimized design
  
- **START S-2013**: Enhanced basic tracker
  - 2G connectivity
  - Bluetooth support
  - 130+ mAh backup battery
  - Internal GNSS/GSM antennas

#### SIGNAL Series (Professional)
- **SIGNAL S-2613**: Professional fleet tracker
  - External antenna interfaces
  - Discrete inputs/outputs
  - RS-485 for sensors
  - Advanced monitoring capabilities
  
- **SIGNAL S-2654**: Advanced vehicle tracker
  - Telemetry data processing
  - Driver behavior monitoring
  - Professional interfaces
  - Extended functionality
  
- **SIGNAL S-4752**: Professional 4G tracker
  - 4G LTE with 3G/2G fallback
  - External GSM/GPS antennas
  - 1-Wire interface
  - CAN bus support
  - RS-232/485 interfaces
  - Complex monitoring solutions

### Physical Characteristics

#### Antenna Options
- **Internal**: Integrated GNSS/GSM antennas (START/SMART series)
- **External**: Professional antenna connectors (SIGNAL series)
- **Sensitivity**: High-sensitivity GLONASS/GPS receivers

#### Connectivity
- **Cellular**: 2G, 3G, 4G LTE (model dependent)
- **Interfaces**: RS-232, RS-485, 1-Wire, CAN bus
- **Bluetooth**: 4.0 support on select models
- **Digital I/O**: Multiple discrete inputs/outputs

#### Power
- **Supply**: Wide voltage range for vehicles
- **Backup**: Internal battery (130+ mAh typical)
- **Monitoring**: Voltage measurement capabilities

### Protocol Detection Features

#### Message Identification
- **Control Prefix**: '@' (0x40) + "NTC"
- **Position Prefix**: '~' (0x7E) + 'A'
- **Heartbeat**: Single 0x7F byte
- **Checksums**: XOR for control, CRC8_EGTS for position

#### FLEX Configuration
- **Dynamic Fields**: Bit-mask based selection
- **Bandwidth Optimization**: Send only relevant data
- **Version Control**: Protocol and structure versioning
- **Field Count**: Up to 255 possible fields

### CAN Bus Integration
- **CAN-LOG Adapter**: Professional CAN data reading
- **CANTEC Adapter**: Alternative CAN interface
- **J1939 Support**: Commercial vehicle protocols
- **OBD-II**: Passenger vehicle diagnostics

### Remote Services
- **RCS**: Remote Configuration Service
- **FLEX Emulator**: Protocol testing tool
- **Visual Representation**: Data transfer visualization
- **Quick Implementation**: Developer support tools

## Common Applications

- **Fleet Management**: Commercial vehicle tracking
- **Transportation**: Cargo and passenger transport
- **Government**: GLONASS compliance requirements
- **Agriculture**: Field equipment monitoring
- **Construction**: Heavy machinery tracking
- **Logistics**: Supply chain management
- **Public Transport**: Bus and route optimization
- **Personal Vehicles**: Anti-theft and monitoring

## Regional Considerations

### Russian Market Focus
- **GLONASS Priority**: Government requirement compliance
- **ERA-GLONASS**: Emergency response integration
- **Certification**: Russian standards compliance
- **Language Support**: Russian interface options

### Technical Standards
- **GOST Compliance**: Russian technical standards
- **Customs Union**: EAC certification
- **Government Approval**: Transportation ministry compliance
- **Military Standards**: Enhanced reliability options

## Traccar Configuration

```xml
<entry key='navtelecom.port'>5041</entry>
```

### Protocol Features
- **Frame Decoder**: Custom binary frame handling
- **FLEX Support**: Dynamic field configuration
- **CRC Validation**: CRC8_EGTS checksum verification
- **Multi-Position**: Batch position processing
- **Command Support**: Bidirectional communication

The Navtelecom protocol's FLEX configuration system and extensive sensor support make it ideal for complex fleet management applications requiring customizable data transmission and comprehensive vehicle monitoring in Russian and CIS markets.