# EGTS (ERA-GLONASS Telematics Standard) Protocol

The EGTS (ERA-GLONASS Telematics Standard) protocol is the official Russian Federation standard for emergency response and telematics systems. This government-mandated protocol supports comprehensive vehicle monitoring, automatic crash detection, emergency response coordination, and fleet management with full compliance to Russian Federation requirements.

## Protocol Overview

**Type:** Binary with multi-layer structure  
**Standard:** ERA-GLONASS Telematics Standard (Russian Federation)  
**Primary Use:** Emergency response, vehicle monitoring, government compliance  
**Data Format:** Layered binary with header, services frame, and CRC validation  
**Bidirectional:** Yes (commands, acknowledgments, and emergency responses)

## Message Structure

### EGTS Packet Format
```
[Protocol Ver:1][Security Key:1][Flags:1][Header Len:1][Encoding:1][Frame Len:2][Packet ID:2][Type:1][Header CRC:1][Services Frame:N][Frame CRC:2]
```

### Service Data Record Format
```
[Record Len:2][Record Num:2][Flags:1][Object ID:4?][Event ID:4?][Event Time:4?][Source Service:1][Recipient Service:1][Data:N]
```

### Service Data Types
- **SR_RECORD_RESPONSE (0)**: Record acknowledgment
- **SR_TERM_IDENTITY (1)**: Terminal identification (IMEI/IMSI)
- **SR_MODULE_DATA (2)**: Module information and versions
- **SR_VEHICLE_DATA (3)**: Vehicle identification data
- **SR_AUTH_PARAMS (4)**: Authentication parameters
- **SR_AUTH_INFO (5)**: Authentication information
- **SR_SERVICE_INFO (6)**: Service status information
- **SR_RESULT_CODE (7)**: Operation result codes
- **SR_POS_DATA (16)**: GPS positioning data
- **SR_EXT_POS_DATA (17)**: Extended positioning (HDOP, satellites)
- **SR_AD_SENSORS_DATA (18)**: Analog/digital sensor readings
- **SR_COUNTERS_DATA (19)**: Counter values
- **SR_STATE_DATA (20)**: Device state information
- **SR_LOOPIN_DATA (22)**: Loop-in positioning data
- **SR_ABS_DIG_SENS_DATA (23)**: Absolute digital sensor data
- **SR_ABS_AN_SENS_DATA (24)**: Absolute analog sensor data
- **SR_ABS_CNTR_DATA (25)**: Absolute counter data
- **SR_ABS_LOOPIN_DATA (26)**: Absolute loop-in data
- **SR_LIQUID_LEVEL_SENSOR (27)**: Fuel/liquid level sensors
- **SR_PASSENGERS_COUNTERS (28)**: Passenger counting systems

## Key Features

- **Emergency Response**: Automatic crash detection and emergency calling
- **Government Compliance**: Mandatory for all vehicles in Russian Federation
- **GLONASS Integration**: Primary satellite navigation system support
- **Multi-Service Architecture**: Modular service-based protocol design
- **Comprehensive Monitoring**: Vehicle state, sensors, and diagnostics
- **Bidirectional Communication**: Full command and control capabilities

## System Overview

### ERA-GLONASS Emergency Response System
**ERA-GLONASS** is Russia's comprehensive emergency response system, similar to Europe's eCall but specifically designed for the Russian Federation using GLONASS satellite navigation.

**Implementation Timeline:**
- **2009**: Presidential Committee resolution to create ERA-GLONASS
- **January 1, 2015**: Mandatory for all new car models in Russian market
- **January 1, 2017**: Required for all passenger and freight vehicles in Eurasian Economic Union

### System Components
**Infrastructure:**
- State Automated Information System managed by Ministry of Transport
- Distributed operator network with navigation platform
- Data transmission and cellular networks
- Emergency response contact centers

**Vehicle Components:**
- Automated emergency call devices (AECD)
- GLONASS/GPS positioning systems
- Crash detection sensors and algorithms
- SOS emergency buttons for manual activation

### Emergency Response Process
1. **Automatic Detection**: Frontal, side, or rear collision detection
2. **Severity Assessment**: Algorithm evaluates accident severity
3. **Position Determination**: GLONASS/GPS location acquisition
4. **Emergency Communication**: Automatic connection to ERA-GLONASS infrastructure
5. **Data Transmission**: EGTS protocol sends accident details
6. **Response Coordination**: Emergency services dispatch (ambulance, rescue, police)

## Device Identification

### Government Standards and Certification
**Russian Federation Standards:**
- UNECE Regulation 144 compliance (since 2018)
- Federal standards for collision detection algorithms
- Mandatory GLONASS support for indigenous infrastructure
- Ministry of Transport certification requirements

### Device Categories

#### Accident Emergency Call Components (AECC)
- **Core Processing Units**: Central emergency response controllers
- **Sensors and Modules**: Crash detection, positioning, communication
- **Government Certified**: Ministry of Transport approved components
- **Standard Compliance**: UNECE Regulation 144 conformity

#### Accident Emergency Call Devices (AECD)
- **Integrated Systems**: Complete in-vehicle emergency response units
- **Aftermarket Devices**: Retrofit emergency calling systems
- **OEM Integration**: Factory-installed emergency response systems
- **Fleet Variants**: Commercial vehicle emergency systems

#### Accident Emergency Call Systems (AECS)
- **Complete Infrastructure**: End-to-end emergency response solutions
- **Operator Networks**: Contact center and dispatch integration
- **Government Systems**: Ministry of Transport managed infrastructure
- **Regional Implementations**: Local emergency response networks

### Device ID and Authentication
- **IMEI Format**: Standard 15-digit cellular modem identifier
- **IMSI Support**: SIM card identification for cellular networks
- **Object ID**: 32-bit unique device identifier in EGTS protocol
- **Terminal ID**: Device-specific identification for system registration
- **Authentication Keys**: Cryptographic authentication for secure communication

### Physical Characteristics

#### Emergency Call Devices
- **Installation**: Integrated or aftermarket vehicle installation
- **Sensors**: 3-axis accelerometers for crash detection
- **Connectivity**: GLONASS/GPS + cellular (2G/3G/4G)
- **Power**: Vehicle 12V/24V with backup battery
- **Indicators**: LED status lights and audio feedback
- **Controls**: SOS emergency button for manual activation

#### Communication Modules
- **GLONASS Primary**: Mandatory Russian satellite navigation
- **GPS Secondary**: Backup positioning system
- **Cellular Network**: GSM/3G/4G for data transmission
- **Antenna Systems**: Integrated or external GNSS/cellular antennas

### Protocol Detection Features

#### EGTS Packet Identification
- **Protocol Version**: Version 1 standard identifier
- **Header Structure**: Fixed 10+ byte header format
- **CRC Validation**: Header and frame checksum verification
- **Service Types**: Multi-service architecture identification

#### Government Compliance Features
- **Mandatory Fields**: Required data elements for emergency response
- **Standardized Format**: Government-specified data structures
- **Authentication**: Secure communication protocols
- **Audit Trail**: Complete transaction logging for compliance

### Service Architecture

#### Authentication Service (1)
- **Device Registration**: Terminal identity and authentication
- **Credential Management**: Login/password authentication
- **Session Control**: Secure communication establishment
- **Compliance Verification**: Government standard validation

#### Teledata Service (2)
- **Position Reporting**: GPS/GLONASS location data
- **Sensor Data**: Vehicle sensors and diagnostic information
- **Emergency Events**: Crash detection and emergency response
- **Fleet Monitoring**: Commercial vehicle tracking capabilities

#### Commands Service (4)
- **Remote Control**: Vehicle command and control
- **Configuration Management**: Device parameter settings
- **Emergency Override**: Government emergency control capabilities
- **Maintenance Commands**: System maintenance and diagnostics

#### Firmware Service (9)
- **Over-the-Air Updates**: Remote firmware management
- **Version Control**: Software and firmware tracking
- **Security Updates**: Critical security patch distribution
- **Compliance Updates**: Government standard modifications

#### Emergency Call Service (10)
- **Automatic Emergency**: Crash-triggered emergency calls
- **Manual Emergency**: SOS button activation
- **Emergency Data**: Comprehensive accident information
- **Response Coordination**: Emergency services communication

### Advanced Features

#### Crash Detection Algorithms
- **Federal Standards**: Government-specified detection algorithms
- **Multi-Axis Sensing**: 3D acceleration monitoring
- **Impact Classification**: Frontal, side, and rear collision detection
- **Severity Assessment**: Automatic emergency severity evaluation

#### Emergency Response Integration
- **Contact Centers**: Direct connection to emergency operators
- **Voice Communication**: Two-way audio for emergency verification
- **Emergency Services**: Automatic dispatch of rescue, ambulance, police
- **Response Time Reduction**: Significant improvement in emergency response

#### Government Compliance Monitoring
- **Fleet Registration**: 7+ million vehicles currently registered
- **Call Statistics**: 10+ million calls processed (120k validated emergencies)
- **Mortality Reduction**: Demonstrated reduction in traffic accident fatalities
- **Safety Improvement**: Enhanced road safety through faster response times

### International Standards

#### UNECE Regulation 144
- **Russian Membership**: Active participation since 2018
- **International Compatibility**: Cross-border emergency response
- **Standard Harmonization**: Alignment with international practices
- **Technology Export**: ERA-GLONASS replication in other countries

#### Eurasian Economic Union
- **Regional Implementation**: Mandatory across member states
- **Cross-Border Support**: International emergency response coordination
- **Standard Adoption**: Common emergency response protocols
- **Infrastructure Sharing**: Regional emergency response networks

## Common Applications

- **Emergency Response**: Automatic crash detection and emergency calling
- **Government Compliance**: Mandatory vehicle safety system
- **Fleet Management**: Commercial vehicle monitoring and tracking
- **Insurance Telematics**: Accident documentation and claims processing
- **Public Safety**: Reduced emergency response times and improved safety
- **Transport Monitoring**: Government oversight of transportation systems
- **Border Security**: Vehicle tracking for national security
- **Environmental Monitoring**: Vehicle emissions and environmental impact

## System Statistics and Impact

- **Registered Vehicles**: 7+ million vehicles in ERA-GLONASS system
- **Emergency Calls**: 10+ million calls processed by contact centers
- **Validated Emergencies**: ~120,000 confirmed emergency situations
- **Response Time**: Significant reduction in emergency response times
- **Mortality Reduction**: Demonstrated decrease in traffic accident deaths
- **System Expansion**: Implementation in multiple countries beyond Russia

## Platform Compatibility

- **ERA-GLONASS Infrastructure**: Native government system integration
- **Navixy Platform**: Complete EGTS device integration and management
- **Third-Party Systems**: Open protocol for custom integrations
- **Government Networks**: Ministry of Transport system compatibility
- **Emergency Services**: Direct integration with rescue, ambulance, police

## Traccar Configuration

```xml
<entry key='egts.port'>5031</entry>
```

### Protocol Features
- **Multi-Service Support**: Authentication, teledata, commands, firmware, emergency
- **CRC Validation**: Header and frame checksum verification
- **Bidirectional Communication**: Full command and response capabilities
- **Object ID Tracking**: Flexible device identification methods
- **Emergency Response**: Automatic acknowledgment and response handling

### Installation Notes
- Uses `EgtsFrameDecoder` for packet framing and validation
- Supports TCP communication with government-standard protocols
- Automatic device identification via IMEI or object ID
- Complete emergency response event processing
- Government compliance logging and audit trails

The EGTS protocol's role as the official Russian Federation emergency response standard makes it essential for vehicle safety, government compliance, and emergency response coordination throughout Russia and the Eurasian Economic Union. Its comprehensive feature set supports both mandatory safety requirements and advanced fleet management capabilities.