# Granit Protocol

The Granit protocol is a binary GPS tracking protocol with ASCII headers developed for Eastern European markets. It features position reporting, archive data transmission, bidirectional commands, and XOR checksum validation.

## Protocol Overview

**Type:** Binary with ASCII headers  
**Manufacturer:** Santel Navigation / Various OEMs  
**Primary Use:** Vehicle tracking, fleet management  
**Data Format:** ASCII header + binary payload + checksum  
**Bidirectional:** Yes (commands and responses)

## Message Structure

### Frame Format
```
[Header:6][Data:N][*][Checksum:2][\r\n]
```

### Message Types
- **+RRCB~**: Current position report (device → server)
- **+DDAT~**: Archive data transmission (device → server)
- **BB+UGRC~**: Current position response (server → device)
- **BB+ARCF~**: Archive acknowledgment (server → device)
- **BB+IDNT**: Request identification (server → device)
- **BB+RESET**: Reboot command (server → device)
- **BB+RRCD**: Request position (server → device)
- **+IDNT:**: Device identification response (device → server)

### Position Record Structure (20 bytes)
1. **Flags** (1 byte):
   - Bit 7: Valid position (1 = valid)
   - Bit 6: Course high bit (bit 8 of course)
   - Bit 5: Longitude sign (0 = negative/West)
   - Bit 4: Latitude sign (0 = negative/South)
   - Bit 1: Alarm flag

2. **Satellite/PDOP** (1 byte):
   - High nibble: Number of satellites (0-15)
   - Low nibble: PDOP value (0-15)

3. **Coordinates** (6 bytes):
   - Longitude degrees (1 byte)
   - Latitude degrees (1 byte)
   - Longitude minutes (2 bytes LE) - value/60000
   - Latitude minutes (2 bytes LE) - value/60000

4. **Motion** (4 bytes):
   - Speed (1 byte) - km/h
   - Course low (1 byte) - degrees 0-255
   - Distance (2 bytes LE) - meters

5. **ADC Inputs** (5 bytes):
   - ADC1 low byte
   - ADC2 low byte
   - ADC3 low byte
   - ADC4 low byte
   - ADC high bits (bits 9-8 for all 4 channels)

6. **Additional** (3 bytes):
   - Altitude (1 byte) - multiply by 10 for meters
   - Outputs (1 byte) - 8 digital outputs as bits
   - Status (1 byte) - device status code

### Archive Data Format
- Base timestamp for block
- 6 position records (20 bytes each)
- Time increment between positions (2 bytes)
- Empty positions marked with 0xFE in first byte

## Key Features

- **Dual Satellite Support**: GPS and GLONASS capability
- **Archive Storage**: Local position storage with bulk transmission
- **Bidirectional Communication**: Commands and responses
- **Analog Inputs**: 4 channels with 10-bit resolution
- **Digital Outputs**: 8 controllable outputs
- **Checksum Validation**: XOR checksum for data integrity
- **SMS Commands**: Remote configuration via SMS

## Device Identification

### Manufacturer Information
**Santel Navigation**  
- Region: Eastern Europe (Russia, Belarus, Ukraine)
- Focus: Vehicle tracking and fleet management
- Market: Commercial transportation, logistics

### Navigator Series Models

#### Navigator.04x Series
- **Granit-Navigator 04**: Basic vehicle tracker
  - GPS/GLONASS dual positioning
  - Real-time tracking capability
  - Motion sensor included
  - Fuel monitoring support
  - Water-resistant design
  - Long battery life
  
- **Granit-Navigator 4.10**: Advanced model
  - High-sensitivity GLONASS/GPS receiver
  - Compact design
  - Enhanced weak signal performance
  - Additional equipment connectivity
  - Improved firmware features

#### Navigator V6
- **Granit Navigator V6**: Latest generation
  - Enhanced protocol support
  - Improved power management
  - Extended temperature range
  - Additional I/O capabilities

### Device ID Format
- **Device ID**: 16-bit identifier in protocol
- **Firmware**: "Navigator.04x Firmware version 0712GLN"
  - GLN suffix indicates GLONASS support
- **Identification**: "+IDNT: Navigator.04x  Firmware version  0712GLN *21"

### Physical Characteristics

#### Standard Features
- **Positioning**: GPS/GLONASS dual system
- **Sensitivity**: High-sensitivity receiver
- **Motion Detection**: Built-in accelerometer
- **Power**: Wide voltage range (8-40V)
- **Protection**: Water-resistant housing
- **Temperature**: -40°C to +85°C operation

#### Connectivity
- **GSM/GPRS**: 2G connectivity standard
- **SMS**: Remote configuration support
- **Serial**: RS-232 interface
- **Digital I/O**: 8 outputs, multiple inputs
- **Analog**: 4 ADC channels (10-bit)

### Protocol Detection Features

#### Message Identification
- **ASCII Headers**: Fixed 6-character headers
- **Binary Payload**: Little-endian encoding
- **Checksum**: XOR with ASCII hex representation
- **Terminator**: CR+LF (0x0D 0x0A)

#### Data Characteristics
- **Empty Marker**: 0xFE for unused position slots
- **Time Format**: Unix timestamp (seconds)
- **Coordinate Format**: Degrees + minutes/60000
- **Speed Unit**: km/h directly encoded

### Applications

#### Fleet Management
- **Real-time Tracking**: Continuous position updates
- **Route History**: Archive data storage
- **Fuel Monitoring**: ADC input for fuel sensors
- **Driver Behavior**: Speed and acceleration monitoring

#### Logistics
- **Cargo Security**: Alarm notifications
- **Temperature Control**: ADC for temperature sensors
- **Door Monitoring**: Digital input detection
- **Route Compliance**: Geofence support

#### Public Transport
- **Schedule Adherence**: Time-based reporting
- **Passenger Safety**: Emergency button support
- **Stop Detection**: Motion sensor integration
- **Route Optimization**: Historical data analysis

### Regional Considerations

#### Eastern European Market
- **GLONASS Priority**: Essential for Russia/CIS region
- **Cyrillic Support**: Native language interfaces
- **Local Regulations**: Compliance with regional laws
- **Climate Adaptation**: Extreme temperature tolerance

#### Network Coverage
- **2G Dependency**: Optimized for GSM/GPRS
- **Rural Operation**: Weak signal compensation
- **Data Efficiency**: Compressed archive transmission
- **SMS Fallback**: Configuration without data

## Common Applications

- **Commercial Vehicles**: Trucks, buses, delivery vans
- **Construction Equipment**: Excavators, loaders
- **Agricultural Machinery**: Tractors, harvesters
- **Emergency Services**: Ambulances, fire trucks
- **Municipal Fleets**: Service vehicles, snow plows
- **Personal Vehicles**: Anti-theft and monitoring

## Traccar Configuration

```xml
<entry key='granit.port'>5040</entry>
```

### Protocol Features
- **Frame Decoder**: Uses newline delimiter for message separation
- **Response Generation**: Automatic acknowledgment messages
- **SMS Support**: Remote command processing
- **Archive Handling**: Bulk position data processing
- **Checksum Validation**: XOR verification

The Granit protocol's focus on Eastern European markets, dual GPS/GLONASS support, and robust design makes it particularly suitable for harsh environments and areas where GLONASS coverage is critical.