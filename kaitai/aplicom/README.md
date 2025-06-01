# Aplicom Protocol

The Aplicom protocol is a sophisticated binary GPS tracking protocol developed by Aplicom, a Finnish telematics manufacturer with over 30 years of experience. This protocol supports multiple message types with advanced fleet management features, CAN bus integration, and comprehensive vehicle diagnostics.

## Protocol Overview

**Type:** Binary with multiple subtypes (D, E, F, H)  
**Manufacturer:** Aplicom Oy (Finland)  
**Primary Use:** Professional fleet management, logistics, industrial IoT  
**Data Format:** Complex binary with selectable data fields  
**Bidirectional:** Yes (commands and comprehensive data)

## Message Structure

### Frame Format
```
[Protocol Type:1][Version:1][Device ID:3-7][Length:2][Selector:3?][Event:1][Event Info:1][Data:N]
```

### Protocol Types
- **Type D (0x44)**: General purpose GPS/vehicle data
- **Type E (0x45)**: Tachograph and driver activity data  
- **Type F (0x46)**: Fleet management and CAN bus data
- **Type H (0x48)**: Histogram and statistical data

### Version Flags
- **Bit 7 (0x80)**: Extended device ID (7 bytes vs 3 bytes)
- **Bit 6 (0x40)**: Selector field present (3 additional bytes)

## Key Features

- **Multi-Protocol Support**: D/E/F/H message types for different data
- **Advanced CAN Integration**: J1939 protocol support with comprehensive diagnostics
- **Tachograph Support**: Digital tachograph data and driver activity monitoring
- **Configurable Data**: Selector-based field inclusion for bandwidth optimization
- **Event Handling**: Comprehensive event system with detailed data
- **EBS Support**: Electronic braking system integration (trailer applications)

## Device Identification

### Manufacturer Information
**Aplicom Oy** - Finnish telematics specialist  
- Founded: 1990s in Finland
- Tagline: "Sustainable telematics from Finland"
- Focus: Professional-grade telematics solutions
- Market: European fleet management, global logistics

### Commercial Device Models

#### A9 Series (Current Generation)
- **A9 PRO**: Compact 4G LTE vehicle computer
  - Dimensions: 61×112×13mm, Weight: 70g
  - Power: 6.8-32Vdc, IP31 rating
  - 3D accelerometer, dual processors
  
- **A9 NEX**: Advanced vehicle computer with GPS/GLONASS
  - Enhanced processing capabilities
  - Extensive I/O options
  - OTA configuration support
  
- **A9 TRIX**: 3G unit with high-speed data transfer
  - Up to 7.2 Mbps downlink speed
  - Enhanced connectivity options
  
- **A9 IPEX**: IP67-rated trailer telematics unit
  - Waterproof/dustproof construction
  - Optional 4000mAh battery
  - Trailer EBS integration
  
- **A9 Quick**: Plug-and-play vehicle unit
  - Easy installation and removal
  - Portable configuration

#### T Series (IoT Generation)
- **T10**: Compact 4G LTE Cat-M tracker
  - 5G technology compatible
  - Low power consumption
  
- **T10 G**: Enhanced Cat-M connectivity
  - GPS/GLONASS positioning
  - NB-IoT capability
  
- **T20**: 4G IoT device for mobile equipment
  - Industrial monitoring focus
  - Extended environmental range

#### Legacy Series
- **TC65/TC65i**: Older generation 2G/GPRS devices
  - Cinterion TC65i modules
  - GSM/GPRS communication
  - Still supported in protocol

### Device ID Patterns

#### IMEI Calculation Methods
The protocol uses specific IMEI base patterns for device identification:

**TC65i v1.1 devices:**
```
IMEI = 0x14143B4000000 + Unit_ID
Base: 20165000000000000 (decimal)
```

**TC65 v2.0 devices:**
```
IMEI = 0x1437207000000 + Unit_ID  
Base: 5625000000000000 (decimal)
```

**TC65 v2.8 devices:**
```
IMEI = 358244010000000 + ((Unit_ID + 0xA8180) & 0xFFFFFF)
Offset: 0xA8180 (688512 decimal)
```

All IMEIs are validated using Luhn algorithm checksum.

### Protocol Detection Features

#### Message Identification
- **Alive Messages**: Numeric characters sent as keep-alive (skipped by decoder)
- **Frame Headers**: Single character protocol type (D/E/F/H)
- **Version Byte**: Indicates device capabilities and frame structure
- **Selector System**: Configurable data field inclusion

#### Device Communication Patterns
- Binary protocol with little-endian encoding
- Configurable reporting intervals and data fields
- CAN bus data integration for vehicle diagnostics
- Tachograph data for commercial vehicle compliance

### Physical Characteristics

#### A9 Series Specifications
- **Housing**: PC/ABS plastic, various IP ratings
- **Antennas**: Internal GPS/GLONASS and cellular
- **Power**: 12V/24V vehicle systems
- **Temperature**: Extended operating range
- **Mounting**: Various options including magnetic, adhesive

#### Build Quality Indicators
- **Robust Construction**: European engineering standards
- **Component Quality**: High-grade electronics and connectors
- **Labeling**: Clear model identification and certification marks
- **Documentation**: Comprehensive technical specifications

## Protocol Data Types

### Type D - General Vehicle Data
- GPS positioning with satellite count
- Speed, course, and altitude
- Digital/analog inputs and outputs
- Power/battery voltage monitoring
- Trip counters and odometer
- Driver identification (keypad/card)
- Event data with configurable detail

### Type E - Tachograph Data
- Tachograph events and status
- Driver card information (2 cards)
- Work states and activity periods
- OBD speed and odometer
- VIN (Vehicle Identification Number)
- Driver records and time tracking
- Commercial vehicle compliance data

### Type F - Fleet Management
- Engine parameters (RPM, temperature, hours)
- Fuel consumption and level monitoring
- Advanced CAN bus diagnostics
- Vehicle performance analytics
- Brake system data
- Axle weight information
- Environmental parameters

### Type H - Statistical Data
- Histogram data for behavior analysis
- Speed/RPM distribution patterns
- Acceleration/deceleration profiles
- Usage statistics and trends

## Advanced Features

### CAN Bus Integration
- **J1939 Protocol**: Standard commercial vehicle communication
- **Engine Diagnostics**: Real-time parameter monitoring
- **Fuel Management**: Consumption tracking and theft detection
- **Performance Analysis**: Driver behavior and vehicle efficiency

### Tachograph Support
- **Digital Tachograph**: EU regulation compliance
- **Driver Cards**: Automatic identification and activity tracking
- **Work/Rest Periods**: Legal compliance monitoring
- **Data Download**: Remote tachograph data retrieval

### Fleet Management
- **Route Optimization**: Historical data for route planning
- **Maintenance Scheduling**: Engine hours and service intervals
- **Driver Safety**: Harsh driving detection and reporting
- **Compliance Reporting**: Regulatory requirement fulfillment

### Trailer Integration
- **EBS Data**: Electronic braking system monitoring
- **Cargo Monitoring**: Temperature, door status, loading
- **Asset Tracking**: Standalone trailer tracking capability
- **Multi-Axle Support**: Weight distribution monitoring

## Common Applications

- **Commercial Fleet Management**: Trucks, buses, delivery vehicles
- **Logistics Operations**: Container and trailer tracking
- **Construction Equipment**: Heavy machinery monitoring
- **Cold Chain Logistics**: Temperature-controlled transport
- **Public Transportation**: Bus and taxi fleet management
- **Emergency Services**: Ambulance and fire department vehicles
- **Industrial Equipment**: Mobile equipment tracking

## Platform Compatibility

- **Aplicom Silver Cloud**: Native cloud platform for T-Series
- **Fleet Management Systems**: Integration via REST API
- **Third-party Platforms**: Wide compatibility with tracking software
- **Custom Integration**: Development tools and documentation available

## Traccar Configuration

```xml
<entry key='aplicom.port'>5020</entry>
<entry key='aplicom.can'>true</entry>
```

### Protocol Features
- **CAN Data Decoding**: Enable with `aplicom.can` setting
- **Event Processing**: Advanced event data interpretation
- **Multi-Message Support**: All protocol types (D/E/F/H)
- **Device Auto-Detection**: IMEI calculation from Unit ID

### Installation Notes
- Uses `AplicomFrameDecoder` for proper message framing
- Supports both 3-byte and 7-byte device identification
- Handles "alive" message filtering automatically
- Configurable selector-based data field processing

The Aplicom protocol's sophisticated design and comprehensive feature set make it ideal for professional fleet management applications requiring detailed vehicle diagnostics, regulatory compliance, and advanced analytics capabilities.