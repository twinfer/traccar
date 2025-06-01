# Cellocator Protocol

The Cellocator protocol is a sophisticated binary GPS tracking protocol developed by Cellocator, the technology division of Pointer Telocation. This Israeli-manufactured system specializes in vehicle security, stolen vehicle recovery, and advanced fleet management with comprehensive emergency response capabilities.

## Protocol Overview

**Type:** Binary with modular extensions  
**Manufacturer:** Cellocator (Pointer Telocation, Israel)  
**Primary Use:** Vehicle security, stolen vehicle recovery, fleet management  
**Data Format:** Fixed-length binary with modular extensions  
**Bidirectional:** Yes (commands and acknowledgments)

## Message Structure

### Standard Frame Format
```
[System Code:4][Message Type:1][Device ID:4][Communication Control:2][Packet Number:1][Auth Code:4][Data:N][Checksum:1]
```

### System Codes
- **MCGP**: Standard Cellocator protocol identifier
- **Alternative**: Non-standard variants exist

### Message Types
- **Type 0**: Status message (GPS position and vehicle data)
- **Type 3**: Programming message (configuration)
- **Type 7**: Serial log message (diagnostic data)
- **Type 8**: Serial message (variable length data)
- **Type 9**: Modular message (legacy modular format)
- **Type 11**: Modular extended (modern modular format)

## Key Features

- **Security Focus**: Advanced anti-theft and emergency response
- **Driver Authentication**: Multiple authentication methods
- **GSM Jamming Detection**: Anti-tampering capabilities
- **Emergency Response**: Panic button and crash detection
- **Modular Architecture**: Extensible with additional sensors
- **Asset Tracking**: Standalone battery-powered operation

## Device Identification

### Manufacturer Information
**Cellocator** (Pointer Telocation Ltd.)  
- Founded: 1997, Rosh HaAyin, Israel
- NASDAQ: PNTR (Pointer Telocation)
- Specialization: Vehicle security and telematics
- ISO 9001-2000 certified, VCA E-mark approved

### Commercial Device Models

#### CR Series (Fleet Management)
- **CR-200/CR-200B**: Compact entry-level device
  - Basic fleet management features
  - Stolen vehicle recovery capability
  - 2G/3G connectivity options
  - Compact form factor
  
- **CR-300/CR-300B**: Entry-level with enhanced features
  - 1000mAh rechargeable battery
  - GSM jamming detection
  - EU and North American variants
  - Enhanced security features
  
- **CR-400**: Next-generation LTE device
  - LTE Cat M1 with 2G fallback
  - BLE (Bluetooth Low Energy) connectivity
  - Crash detection algorithms
  - LED status indicators
  - 1000mAh battery capacity

#### CelloTrack Series (Asset Tracking)
- **CelloTrack**: Standalone GPS tracker
  - Battery-powered operation
  - Mobile asset tracking
  - No external power required
  - Robust outdoor design
  
- **CelloTrack Nano**: Modular solution
  - Wireless sensor network integration
  - Cargo and container monitoring
  - Expandable architecture
  - IoT sensor compatibility
  
- **CelloTrack Solar**: Solar-powered variant
  - Extended deployment capability
  - Self-sustaining power system
  - Outdoor harsh environment rated
  
- **CelloTrack 10Y**: Extended battery life
  - 10-year battery operation
  - Low-power consumption design
  - Long-term asset tracking
  
- **CelloTrack Container Lock**: Cargo security
  - Container monitoring specialization
  - Security and tamper detection
  - Supply chain visibility

#### Specialized Models
- **Cello-IQ**: Driver behavior monitoring
  - Eco-driving solutions
  - Three firmware versions available
  - Advanced analytics
  
- **Cello-CANiQ**: CAN bus integration
  - Vehicle diagnostics
  - OBD-II data extraction
  - Engine parameter monitoring
  
- **MultiSense**: Smart monitoring device
  - Temperature and humidity sensors
  - Light and impact detection
  - Movement monitoring
  - Environmental sensing

### Device ID Format
- **Device ID**: 32-bit unique identifier
- **IMEI Format**: Standard 15-digit IMEI
- **Authentication**: 32-bit authentication code in protocol
- **Physical Marking**: Model numbers clearly marked on casing

### Physical Characteristics

#### CR Series Specifications
- **Housing**: Robust plastic with IP protection
- **Indicators**: LED lights for GPS/GSM status (CR-400)
- **Battery**: 1000mAh rechargeable (CR-300/400)
- **Connectivity**: 2G/3G/4G depending on model
- **Size**: Compact form factor for discrete installation

#### CelloTrack Specifications
- **Protection**: IP67 waterproof rating
- **Power**: Long-life battery systems
- **Mounting**: Various attachment methods
- **Environmental**: Extended temperature range
- **Durability**: Designed for harsh outdoor conditions

### Protocol Detection Features

#### Message Identification
- **System Code**: "MCGP" identifier in first 4 bytes
- **Device Authentication**: Mandatory authentication codes
- **Checksum Validation**: Single-byte checksum for data integrity
- **Acknowledgment System**: Bidirectional communication

#### Security Features Detection
- **Anti-Jamming**: GSM jamming detection algorithms
- **Driver Authentication**: Multiple authentication methods supported
- **Emergency Events**: Panic button and crash detection capabilities
- **Tamper Detection**: Movement and impact sensors

### Authentication Methods

#### Driver Identification
- **Keypad Authentication**: Numeric driver ID entry
- **1-Wire Proximity**: Card/tag-based authentication
- **Dallas Keys**: Coded proximity keys
- **Multi-Factor**: Combined authentication methods

#### Security Protocols
- **Device Authentication**: Protocol-level authentication codes
- **Data Integrity**: Checksum validation
- **Anti-Theft**: Comprehensive security monitoring

## Protocol Data Types

### Status Message (Type 0)
- GPS positioning with satellite count
- Vehicle status and input monitoring
- Driver identification data
- Speed, course, and altitude
- Hardware/firmware version information
- Emergency and alarm status
- Odometer and trip data
- ADC (analog-to-digital) sensor readings

### Modular Extensions (Type 11)
- **I/O Module**: Digital and analog input/output monitoring
- **GPS Module**: Enhanced positioning data
- **Time Module**: Precise timestamp information
- **Sensor Modules**: Environmental and security sensors

### Programming (Type 3)
- Device configuration parameters
- Reporting intervals and thresholds
- Security settings and authentication
- Geofence definitions

## Advanced Features

### Security and Emergency
- **Stolen Vehicle Recovery**: Real-time tracking for theft recovery
- **Panic Button**: Emergency alert system
- **Crash Detection**: Automatic emergency response
- **GSM Jamming Detection**: Anti-tampering protection
- **Driver Authentication**: Prevent unauthorized use

### Fleet Management
- **Real-Time Tracking**: Continuous position monitoring
- **Geofencing**: Zone entry/exit notifications
- **Driver Behavior**: Speed, harsh driving detection
- **Vehicle Diagnostics**: Engine and system monitoring
- **Maintenance Scheduling**: Service interval tracking

### Asset Tracking
- **Standalone Operation**: Battery-powered deployment
- **Environmental Monitoring**: Temperature, humidity, light
- **Cargo Security**: Container and shipment protection
- **Long-Term Tracking**: Extended battery life models

### Integration Capabilities
- **CAN Bus**: Vehicle diagnostic integration
- **OBD-II**: Engine parameter monitoring
- **Sensor Networks**: IoT device integration
- **BLE Connectivity**: Modern wireless communication

## Common Applications

- **Stolen Vehicle Recovery**: Primary security application
- **Fleet Management**: Commercial vehicle tracking
- **Insurance Telematics**: Usage-based insurance programs
- **Leasing Companies**: Asset protection and monitoring
- **Emergency Services**: Public safety vehicle tracking
- **Asset Protection**: High-value equipment monitoring
- **Cold Chain**: Temperature-controlled logistics
- **Construction Equipment**: Heavy machinery tracking

## Platform Compatibility

- **Cellocator+ Platform**: Native web-based management
- **Third-Party Integration**: REST API and MQTT support
- **Fleet Management Systems**: Wide compatibility
- **Security Centers**: Emergency response integration
- **Insurance Platforms**: Telematics data integration

## Traccar Configuration

```xml
<entry key='cellocator.port'>5023</entry>
```

### Protocol Features
- **Automatic Acknowledgment**: Server responses to device messages
- **Alternative Format Support**: Multiple protocol variants
- **Modular Message Processing**: Extended data format support
- **Security Event Handling**: Emergency and alarm processing

### Installation Notes
- Uses `CellocatorFrameDecoder` for message framing
- Supports both TCP and UDP communication
- Includes encoder for bidirectional communication
- Automatic checksum validation and generation

The Cellocator protocol's emphasis on security, emergency response, and stolen vehicle recovery makes it particularly suitable for high-value assets, security-conscious fleet operations, and applications requiring robust anti-theft capabilities.