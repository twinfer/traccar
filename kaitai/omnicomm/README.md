# Omnicomm Protocol

The Omnicomm protocol is a sophisticated binary GPS tracking protocol developed by Omnicomm for advanced fleet management and fuel monitoring systems. This Russian-manufactured system specializes in comprehensive telematics with protobuf-based messaging, fuel-level sensors, CAN bus integration, and extensive vehicle diagnostics capabilities.

## Protocol Overview

**Type:** Binary with Protocol Buffers (protobuf) messaging  
**Manufacturer:** Omnicomm (Russia)  
**Primary Use:** Fleet management, fuel monitoring, advanced telematics  
**Data Format:** Binary frames with embedded protobuf messages  
**Bidirectional:** Yes (archive data exchange and commands)

## Message Structure

### Frame Format
```
[Prefix:0xC0][Type:1][Length:2][Data:N][CRC:2]
```

### Frame Escape Sequences
- **0xDB 0xDC** → 0xC0 (frame delimiter escape)
- **0xDB 0xDD** → 0xDB (escape character escape)

### Message Types
- **0x80**: Device identification (terminal registration)
- **0x85**: Archive inquiry (server requests data)
- **0x86**: Archive data (device sends stored data)
- **0x87**: Remove archive inquiry (cleanup command)

### Protobuf Message Groups
- **General (2)**: Basic device parameters and status
- **Photo (4)**: Image transmission blocks
- **NAV (5)**: GPS navigation data
- **UniDt (6)**: Universal analog/digital inputs
- **CanDt_J1939 (7)**: CAN bus J1939 diagnostic data
- **LLSDt (8)**: Fuel level sensor data (LLS/LLS-AF)
- **Other (9)**: Extended peripherals and sensors
- **ICONDt (10)**: ICON system integration data
- **OBDDt_J1979 (11)**: OBD-II diagnostic data
- **LOG (16)**: Debug and diagnostic logging

## Key Features

- **Fuel Monitoring**: High-precision capacitive fuel sensors (99.5% accuracy)
- **CAN Bus Integration**: J1939 and J1979 protocol support
- **Photo Transmission**: Block-based image transfer capability
- **Archive Management**: Efficient historical data storage and retrieval
- **Protobuf Messaging**: Compact and extensible binary format
- **Multi-Sensor Support**: Universal inputs, 1-wire temperature sensors
- **Advanced Diagnostics**: Comprehensive vehicle and engine monitoring

## Device Identification

### Manufacturer Information
**OMNICOMM LLC**  
- Founded: 1998, Russia
- Specialization: Satellite monitoring systems and fuel management
- Product Range: GPS trackers, fuel sensors, fleet management software
- Market Focus: Commercial fleets, fuel control, harsh environment applications

### Commercial Device Models

#### Profi Series (Professional Grade)
- **Omnicomm Profi 2.0**: High-end commercial tracker
  - IP54 protection rating for harsh environments
  - Cold region operation capability
  - 2G/3G/WiFi connectivity options
  - Maximum functionality and sensor support
  - Recommended for special assets and harsh conditions
  
- **Omnicomm Profi 3.0**: Advanced professional tracker
  - Enhanced connectivity options
  - Improved environmental protection
  - Extended temperature range operation
  - Advanced fuel monitoring capabilities

#### Optim Series (Optimal Performance)
- **Omnicomm Optim 2.0**: Balanced feature set
  - 32-channel GPS/GLONASS receiver
  - 150,000 event storage capacity
  - Quad-band GSM with GPRS
  - Standard fleet monitoring applications
  - Driver identification support
  
- **Omnicomm Optim 3.0**: Enhanced optimal tracker
  - Wide external equipment connectivity
  - Built-in accelerometer
  - Hardware odometer
  - Tamper detection sensor
  - External GPS/GSM antenna support
  - Truck and transport optimization

#### Smart Series (Cost-Effective)
- **Omnicomm Smart**: Entry-level fleet tracker
  - Basic transport monitoring functions
  - Affordable pricing structure
  - Essential fuel monitoring features
  - Minimum requirements applications

#### Light Series (Compact Solutions)
- **Omnicomm Light 3.2**: Compact tracker
  - Multiple inputs and interfaces
  - Driver identification support
  - Enhanced I/O compared to basic Light model
  - Small vehicle applications

#### Specialized Models
- **OMNICOMM PORT**: Offline data collection
  - Remote area operation without cellular coverage
  - Quarry and mining applications
  - Tunnel and underground facility support
  - Data synchronization when connectivity available

### Device ID Format
- **Device ID**: 32-bit unique identifier in protocol
- **Archive Index**: Sequential data storage indexing
- **Timestamp**: Unix-based timestamp with custom epoch
- **Priority Levels**: Message importance classification

### Physical Characteristics

#### Professional Grade (Profi Series)
- **Protection**: IP54 environmental rating
- **Temperature**: Extended range for cold regions
- **Housing**: Robust industrial-grade enclosure
- **Mounting**: Heavy-duty vehicle installation
- **Connectivity**: External antenna support

#### Standard Grade (Optim Series)
- **GPS/GLONASS**: 32-channel receiver
- **Memory**: 150,000 event storage capacity
- **Cellular**: Quad-band GSM with GPRS
- **Accelerometer**: Built-in 3-axis motion sensor
- **Tamper**: Device opening detection

#### Compact Grade (Smart/Light Series)
- **Form Factor**: Compact design for space-constrained installations
- **Power**: Low power consumption
- **I/O**: Multiple digital/analog inputs
- **Installation**: Simplified mounting options

### Protocol Detection Features

#### Frame Identification
- **Prefix**: 0xC0 start byte identifier
- **Escape Sequences**: DB-based character escaping
- **CRC Validation**: 16-bit frame integrity check
- **Archive Management**: Sequential data retrieval system

#### Protobuf Message Structure
- **Compact Format**: Efficient binary encoding
- **Extensible**: Forward/backward compatibility
- **Grouped Data**: Logical message organization
- **Optional Fields**: Conditional data inclusion

### Advanced Sensor Integration

#### Fuel Level Sensors (LLS/LLS-AF)
- **Technology**: High-precision capacitive sensors
- **Accuracy**: 99.5% measurement precision
- **Protection**: IP69K ingress protection rating
- **Temperature**: Integrated temperature compensation
- **Multi-Tank**: Support for up to 8 fuel tanks
- **Calibration**: Advanced calibration algorithms

#### CAN Bus Integration
- **J1939 Support**: Commercial vehicle standard
- **J1979 Support**: OBD-II passenger vehicle standard
- **SPN Parameters**: Comprehensive diagnostic parameters
- **Real-Time**: Live engine and vehicle data
- **Fault Codes**: Diagnostic trouble code reading

#### Universal Inputs (UniDt)
- **Analog Inputs**: 6 universal analog channels
- **Digital Inputs**: Configurable digital I/O
- **1-Wire Sensors**: Temperature sensor support
- **Voltage Monitoring**: Power supply monitoring
- **Custom Sensors**: Flexible sensor integration

### Peripheral Device Support

#### Photo Transmission System
- **Block Transfer**: Efficient image segmentation
- **Camera Integration**: External camera support
- **Status Monitoring**: Image capture status tracking
- **Storage Management**: Local image storage
- **Quality Control**: Image validation and error handling

#### Driver Identification
- **iButton Support**: Dallas semiconductor keys
- **RFID Integration**: Contactless identification
- **Card Readers**: Magnetic stripe and chip cards
- **Biometric**: Fingerprint reader support
- **Access Control**: Unauthorized usage prevention

#### Passenger Counting (APC)
- **IRMA Sensors**: Infrared passenger detection
- **Multiple Doors**: Multi-door counting support
- **Real-Time**: Live passenger flow monitoring
- **Public Transport**: Bus and transit applications
- **Data Validation**: Counting accuracy verification

### Advanced Features

#### Generator Monitoring (GenComm)
- **Multi-Generator**: Support for up to 3 generators
- **Electrical Parameters**: Voltage, current, frequency monitoring
- **Fuel Systems**: Generator fuel consumption tracking
- **Alarm Systems**: Comprehensive alarm monitoring
- **Power Analysis**: Active, reactive, and apparent power

#### Weight Control Systems
- **Axle Monitoring**: Individual axle weight measurement
- **Load Limits**: Overload detection and prevention
- **Real-Time**: Continuous weight monitoring
- **Commercial Vehicles**: Truck and trailer applications
- **Compliance**: Legal weight limit enforcement

#### Advanced Driver Assistance (ADAS)
- **MobileEye Integration**: Collision avoidance systems
- **Safe Driving**: Driver behavior analysis
- **Event Detection**: Harsh driving event identification
- **Risk Assessment**: Driver performance scoring
- **Training Support**: Driver improvement programs

### Environmental Capabilities

#### Harsh Environment Operation
- **Temperature Range**: Extended cold region operation
- **Vibration Resistance**: Heavy machinery applications
- **Dust Protection**: Mining and construction environments
- **Moisture Protection**: Marine and outdoor applications
- **Chemical Resistance**: Industrial environment compatibility

#### Remote Area Support
- **Offline Storage**: Extended local data storage
- **Satellite Communication**: Optional satellite connectivity
- **WiFi Capability**: Local area network integration
- **Data Synchronization**: Efficient bulk data transfer
- **Power Management**: Extended battery operation

## Common Applications

- **Fleet Management**: Comprehensive commercial vehicle monitoring
- **Fuel Control**: High-precision fuel theft prevention
- **Mining Operations**: Heavy equipment tracking in remote areas
- **Public Transportation**: Bus and transit fleet optimization
- **Cold Storage**: Refrigerated transport monitoring
- **Construction**: Heavy machinery and equipment tracking
- **Long-Haul Transport**: Interstate and international trucking
- **Fuel Distribution**: Tank truck and fuel delivery monitoring

## System Integration

- **OMNICOMM Online**: Native cloud platform
- **Third-Party Systems**: Open API integration
- **Navixy Platform**: Complete fleet management integration
- **Custom Solutions**: API-based custom development
- **Enterprise Systems**: ERP and business system integration

## Traccar Configuration

```xml
<entry key='omnicomm.port'>5034</entry>
```

### Protocol Features
- **Archive Management**: Historical data retrieval and cleanup
- **Protobuf Processing**: Native protobuf message parsing
- **Multi-Service**: Comprehensive telematics data extraction
- **Automatic Acknowledgment**: Device communication management
- **Error Handling**: Robust message validation and error recovery

### Installation Notes
- Uses `OmnicommFrameDecoder` for escape sequence handling
- Requires protobuf library for message parsing
- Supports TCP communication with CRC validation
- Automatic device identification via device ID
- Archive data management with sequential processing

The Omnicomm protocol's focus on fuel monitoring, CAN bus integration, and harsh environment operation makes it particularly suitable for commercial fleet management, fuel-sensitive operations, and applications requiring high-precision sensor data and comprehensive vehicle diagnostics.