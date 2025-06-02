# Ruptela Protocol

The Ruptela protocol is a binary GPS tracking protocol developed by JSC Ruptela, a Lithuanian telematics company founded in 2007. It features position records, extended I/O support, diagnostic trouble codes (DTC), and file/photo transmission capabilities with CRC16-KERMIT validation.

## Protocol Overview

**Type:** Binary with CRC16 validation  
**Manufacturer:** JSC Ruptela (Lithuania)  
**Primary Use:** Commercial vehicle tracking, fleet management  
**Data Format:** Length-prefixed binary frames  
**Bidirectional:** Yes (commands and responses)

## Message Structure

### Frame Format
```
[Length:2][IMEI:8][Type:1][Payload:N][CRC16:2]
```

### Field Details
- **Length**: 16-bit payload length (excludes length and CRC)
- **IMEI**: 64-bit device identifier
- **Type**: Message type identifier
- **Payload**: Type-specific data
- **CRC16**: CRC16-KERMIT checksum

### Message Types
- 0x01: Standard position records
- 0x02: Device configuration
- 0x03: Device version
- 0x04: Firmware update
- 0x05: Connection settings
- 0x06: Odometer settings
- 0x07: SMS via GPRS response
- 0x08: SMS via GPRS
- 0x09: Diagnostic trouble codes
- 0x0F: Identification
- 0x10: Heartbeat
- 0x11: I/O settings
- 0x25: File transfer (photos)
- 0x44: Extended records (16-bit I/O)

### Position Record Structure
1. **Timestamp**: 32-bit Unix time
2. **Timestamp Extension**: 8-bit precision
3. **Priority**: 8-bit reserved
4. **GPS Data**:
   - Longitude: 32-bit signed (÷10,000,000)
   - Latitude: 32-bit signed (÷10,000,000)
   - Altitude: 16-bit unsigned (÷10)
   - Course: 16-bit unsigned (÷100)
   - Satellites: 8-bit count
   - Speed: 16-bit km/h
   - HDOP: 8-bit (÷10)
5. **Event ID**: 8 or 16-bit
6. **I/O Data**: Four groups by value size
   - 1-byte values
   - 2-byte values
   - 4-byte values
   - 8-byte values

### Extended Records (0x44)
- 16-bit I/O parameter IDs
- Record extension byte:
  - High nibble: Merge record count
  - Low nibble: Current record number
- Enhanced sensor support

### DTC Format (0x09)
- Timestamp and location
- 5-byte ASCII trouble code
- Archive flag (2 = archived)

### File Transfer (0x25)
- Supports photo transmission
- Part-based transfer
- Filename and part tracking

## Key Features

- **CRC16-KERMIT**: Robust error detection
- **Extended I/O**: Up to 16-bit parameter IDs
- **DTC Support**: Vehicle diagnostics integration
- **Photo Transfer**: Camera/media support
- **Multi-Record**: Batch position transmission
- **Driver ID**: RFID/iButton support
- **CAN Integration**: J1939/OBD data reading

## Device Identification

### Company Information
**JSC Ruptela**  
- Founded: 2007 in Vilnius, Lithuania
- Founder: Andrius Rupšys (CEO)
- Employees: 150+ globally (from 3 initial)
- Markets: 120+ countries worldwide
- Awards: 2019 Frost & Sullivan Best Practices

### Global Presence
- **Headquarters**: Vilnius, Lithuania
- **Offices**: UAE, Mexico
- **Teams**: Africa, Asia, Brazil
- **Coverage**: Europe, Asia, Middle East, Africa, Americas

### Device Families

#### FM-Eco4 Series (Economy)
- **FM-Eco4**: Basic tracking device
  - 4th generation technology
  - Low cost, low power
  - GPS/GLONASS positioning
  - GPRS data transfer
  
- **FM-Eco4+**: Enhanced economy tracker
  - Improved features
  - Extended I/O capabilities
  - Better power management
  
- **FM-Eco4 light**: Compact tracker
  - Smallest Ruptela device
  - Minimal form factor
  - Essential tracking features

#### FM-Pro4 (Professional)
- **Target**: Heavy commercial vehicles
  - Trucks and buses
  - Agricultural machinery
  - Special equipment
- **Features**: 
  - 4th generation advanced
  - Low power consumption
  - Powerful processing
  - Extended functionality

#### FM-Tco4 (Total Cost of Ownership)
- **Focus**: Fleet efficiency
- **Features**:
  - Advanced telematics
  - GPS/GLONASS dual mode
  - Comprehensive I/O
  - TCO optimization tools

#### HCV5 (Heavy Commercial Vehicles)
- **Target**: Professional trucking
  - Trucks and buses
  - Agricultural equipment
  - Specialized machinery
- **Capabilities**:
  - CAN bus reading
  - J1939 support
  - Advanced diagnostics
  - Driver behavior monitoring

#### LCV5 (Light Commercial Vehicles)
- **Target**: Cars and vans
  - Light commercial vehicles
  - Passenger vehicles
  - Service fleets
- **Features**:
  - OBD-II data reading
  - Manufacturer-specific OBD
  - Driver behavior analysis
  - Fuel management

#### Trace5 (Asset Tracking)
- **Purpose**: Universal tracking
- **Applications**:
  - Asset monitoring
  - Container tracking
  - Equipment surveillance

### Technical Specifications

#### Connectivity
- **Cellular**: 2G/3G/4G options
- **GNSS**: GPS/GLONASS dual
- **Interfaces**: RS232, RS485, 1-Wire
- **CAN**: J1939, FMS, OBD-II
- **Bluetooth**: BLE 4.0+ (select models)

#### I/O Capabilities
- **Digital Inputs**: 4-8 channels
- **Digital Outputs**: 2-4 channels
- **Analog Inputs**: 2-4 channels
- **1-Wire**: Temperature, iButton
- **Frequency**: Pulse counting

#### Power
- **Voltage**: 10-30V DC typical
- **Backup**: Internal battery
- **Consumption**: Ultra-low power modes
- **Protection**: Reverse polarity, overvoltage

### Common I/O Parameters
- 2-5: Digital inputs (IN1-IN4)
- 13, 173: Motion detection
- 20-23: Analog inputs
- 29: Power voltage (mV)
- 30: Battery voltage (mV)
- 32: Device temperature
- 65, 163-164: Odometer
- 94, 166, 197: Engine RPM
- 95, 165: OBD speed
- 98, 205, 207: Fuel level
- 126-127: Driver ID (part 1-2)
- 155-156: Alternative driver ID
- 251, 409: Ignition status
- 760-761: Tag ID parts

### Quality Standards
- **Component Quality**: 99.9% reliability rate
- **Manufacturing**: High-quality components only
- **Testing**: Rigorous quality control
- **Durability**: Automotive-grade design
- **Certifications**: CE, E-Mark, FCC

## Common Applications

- **Fleet Management**: Real-time tracking and control
- **Fuel Monitoring**: Consumption and theft prevention
- **Driver Behavior**: Safety and efficiency analysis
- **Vehicle Diagnostics**: CAN/OBD data monitoring
- **Cold Chain**: Temperature-controlled transport
- **Agriculture**: Farm equipment tracking
- **Construction**: Heavy machinery management
- **Public Transport**: Bus and route optimization
- **Cargo Security**: Container and trailer tracking
- **Rental Vehicles**: Usage monitoring and control

## Protocol Implementation

### Frame Decoder
- Length field: First 2 bytes
- Offset: 2 bytes (skip length for payload)
- Maximum frame: Configurable

### CRC Calculation
- Algorithm: CRC16-KERMIT
- Polynomial: 0x1021
- Initial: 0x0000
- Final XOR: 0x0000

### Invalid Position
- Longitude = -2147483648 (INT_MIN)
- Latitude = -2147483648 (INT_MIN)
- Indicates no GPS fix

### Response Format
- Type + 100 for acknowledgment
- Example: 0x01 → 0x65 response

## Regional Excellence

### Lithuanian Innovation
- **Engineering**: Strong technical expertise
- **EU Standards**: Compliance and quality
- **Global Vision**: International from start
- **Innovation**: Continuous R&D investment

### Market Leadership
- **Fast Growth**: Top Lithuanian tech company
- **Awards**: Industry recognition
- **Quality**: Premium products, reasonable prices
- **Support**: Global service network

## Traccar Configuration

```xml
<entry key='ruptela.port'>5044</entry>
```

### Protocol Features
- **Binary Format**: Efficient data transfer
- **CRC Validation**: Error detection
- **Batch Records**: Multiple positions per message
- **Extended I/O**: Comprehensive sensor support
- **File Transfer**: Photo and document capability

The Ruptela protocol exemplifies Lithuanian engineering excellence, combining robust binary communication with comprehensive vehicle telematics features for global fleet management applications.