# Topflytech Protocol

The Topflytech protocol is a text-based GPS tracking communication standard developed by Topflytech Communication Technology Co., Ltd., a Chinese manufacturer specializing in innovative GNSS tracking solutions. Based in Shenzhen, Topflytech focuses on autonomous tracking with solar-powered devices, long battery life, and comprehensive IoT sensor integration.

## Protocol Overview

**Type:** Text-based with parenthesis-delimited messages  
**Manufacturer:** Topflytech Communication Technology Co., Ltd. (China)  
**Primary Use:** Asset tracking, fleet management, solar-powered monitoring  
**Data Format:** ASCII text with structured field format  
**Termination:** Parenthesis delimiter ')'  
**Specialization:** Solar power, BLE sensors, autonomous tracking

## Message Structure

### Frame Format
```
([IMEI][Type][Version][DeviceType][Data])
```

### Example Message
```
(880316890094910BP00XG00b600000000L00074b54S00000000R0C0F0014000100f0130531152205A0706.1395S11024.0965E000.0251.25)
```

### Field Details
- **Opening**: '(' character
- **IMEI**: Device identifier
- **Type**: Message type (B, P, S, A, C, H, L)
- **Version**: Protocol version (00, XG, SF, BL)
- **Device Type**: Device model identifier
- **Data**: Position and sensor information
- **Closing**: ')' character

### Message Types
- **B**: Basic position report
- **P**: Detailed positioning data
- **S**: Status report with diagnostics
- **A**: Alarm/event message
- **C**: Command response
- **H**: Heartbeat/keep-alive
- **L**: Location request response

## Position Data Format

### GPS Information
The protocol includes standard GPS data:
- **Date/Time**: YYMMDD HHMMSS format
- **Validity**: A (valid) or V (invalid)
- **Latitude**: DDMM.MMMM format with N/S indicator
- **Longitude**: DDDMM.MMMM format with E/W indicator
- **Speed**: Knots with decimal precision
- **Course**: Degrees with decimal precision

### Coordinate Conversion
```
Latitude = DD + MM.MMMM/60 × (N=+1, S=-1)
Longitude = DDD + MM.MMMM/60 × (E=+1, W=-1)
```

## Key Features

- **Solar-Powered**: Integrated solar charging capabilities
- **Long Battery Life**: 4,000-9,600 mAh battery options
- **BLE Sensors**: Temperature, humidity, door monitoring
- **Autonomous Tracking**: Minimal maintenance requirements
- **Weatherproof**: IP67 rating for outdoor applications
- **Asset Protection**: Tamper alerts and removal detection
- **Fleet Integration**: OBD-II and CAN bus support
- **Global Connectivity**: 4G LTE Cat-M1/Cat-1 options

## Device Identification

### Company Information
**Topflytech Communication Technology Co., Ltd.**  
- Founded: 2010s in Shenzhen, China
- Headquarters: Shenzhen, Guangdong Province
- Specialization: GNSS tracking solutions
- Focus: IoT innovation, autonomous tracking
- Growth: 600% device increase on flespi platform (2022)

### Market Position
- **Innovation Focus**: Solar power and autonomous tracking
- **Quality**: Professional-grade devices
- **Applications**: Asset tracking, fleet management, cold chain
- **Global Reach**: International distribution
- **Platform Support**: Compatible with major tracking platforms

### Device Portfolio

#### Asset Trackers (Battery-Powered)

**KnightX Series**
- **KnightX 300** (4G Cat-M1):
  - Battery: Rechargeable lithium
  - Positioning: GPS, WiFi, LBS hybrid
  - Reporting: 3-second intervals capability
  - Features: Movement alerts, temperature probe option
  - Buffer: Offline position storage
  - Applications: High-value asset tracking

- **KnightX 100**:
  - Features: Panic button integration
  - Battery: Advanced rechargeable design
  - Sensors: Optional temperature probe
  - Applications: Personal safety, asset protection

**WarriorX Series**
- **WarriorX 300 & WarriorX 100**:
  - Construction: Rugged outdoor design
  - Battery: 4,000mAh or 8,000mAh options
  - Rating: IP67 waterproof (5m/15h tested)
  - Features: Removal alerts, tamper detection
  - Applications: Harsh environment tracking

#### Solar-Powered Trackers

**SolarX Series**
- **SolarX 310** (4G Cat-M1):
  - Power: Solar + large internal battery
  - Applications: Trailers, containers, equipment
  - Charging: High-efficiency solar panels
  - Autonomy: Extended operation without maintenance

- **SolarX 110** (4G Cat-1):
  - Connectivity: 4G Cat-1 cellular
  - Power: Solar charging system
  - Applications: Asset tracking, logistics

- **SolarX 120**:
  - Configuration: Basic solar-powered tracker
  - Applications: Cost-effective asset monitoring

**SolarGuardX Series**
- **SolarGuardX 200**:
  - Form Factor: GPS-enabled padlock
  - Power: Solar charging
  - Security: Physical lock + GPS tracking
  - Applications: Container/trailer security

- **SolarGuardX 100** (4G Cat-M1):
  - Features: Advanced solar tracking
  - Connectivity: Cat-M1 low-power cellular
  - Applications: Remote asset monitoring

#### Vehicle Trackers (Hardwired)

**TLW2 Series**
- **TLW2-6BL**:
  - I/O: 6 inputs/outputs
  - Features: Ignition detection, relay control
  - Integration: BLE sensor support
  - Applications: Advanced fleet management

- **TLW2-2BL**:
  - Configuration: Basic hardwired tracker
  - Features: Ignition detection, output relay
  - Sensors: Temperature, humidity monitoring
  - Applications: Standard fleet tracking

- **TLW2-12B**:
  - Popularity: 4,000+ devices on flespi platform
  - Features: Comprehensive I/O capabilities
  - Applications: Commercial fleet management

#### OBD-II Trackers

**TorchX Series**
- **TorchX 100**:
  - Technology: Plug & Play OBD-II
  - CAN Bus: Advanced vehicle data reading
  - Data: VIN, odometer, fuel level, diagnostics
  - WiFi: Hotspot capability
  - Applications: Fleet management, telematics

#### Other Popular Models

**TLP Series**
- **TLP1-SF**:
  - Growth: 1,000+ devices added to flespi platform
  - Features: Solar Family protocol support
  - Applications: Autonomous tracking

- **TLP2-SFB** (4G Cat-M1):
  - Connectivity: Cat-M1 cellular
  - Protocol: Solar Family with BLE
  - Applications: Advanced asset tracking

### Technical Specifications

#### Communication
- **Cellular**: 4G LTE Cat-M1, Cat-1, 3G/2G fallback
- **Positioning**: GPS, GLONASS, WiFi, LBS
- **Protocols**: TCP/UDP, MQTT, HTTP
- **BLE**: Bluetooth Low Energy sensor integration

#### Power Management
- **Solar**: High-efficiency solar panels
- **Battery**: 4,000-9,600 mAh lithium options
- **Charging**: Intelligent power management
- **Autonomy**: Extended operation periods
- **Low Power**: Cat-M1 power optimization

#### Environmental Ratings
- **Waterproof**: IP67 rating (standard)
- **Temperature**: -25°C to +70°C operating
- **Shock**: Industrial-grade construction
- **Vibration**: Automotive testing standards

### BLE Sensor Integration

#### Supported Sensors
- **Temperature/Humidity**: Environmental monitoring
- **Door Sensors**: Access control monitoring
- **Fuel Sensors**: Tank level monitoring
- **Pressure Sensors**: Hydraulic system monitoring
- **Motion Sensors**: Vibration and movement detection
- **Light Sensors**: Ambient light monitoring

#### Sensor Capabilities
- **Range**: 100m BLE communication
- **Battery**: Long-life sensor batteries
- **Protocols**: BLE 4.0+ standard
- **Data**: Real-time sensor telemetry
- **Alerts**: Threshold-based alarms

### Applications by Industry

#### Logistics & Transportation
- **Container Tracking**: Global cargo monitoring
- **Trailer Tracking**: Fleet optimization
- **Asset Management**: Equipment utilization
- **Cold Chain**: Temperature-controlled transport

#### Construction & Heavy Equipment
- **Equipment Tracking**: Machinery monitoring
- **Theft Prevention**: Security alerts
- **Utilization**: Usage optimization
- **Maintenance**: Preventive scheduling

#### Agriculture
- **Equipment Monitoring**: Farm machinery tracking
- **Livestock**: Animal tracking applications
- **Irrigation**: Water system monitoring
- **Crop Monitoring**: Environmental sensors

#### Energy & Utilities
- **Solar Installations**: Panel monitoring
- **Remote Assets**: Infrastructure tracking
- **Pipeline Monitoring**: Pressure and flow
- **Grid Management**: Distribution assets

### Quality & Certifications
- **CE Mark**: European conformity
- **FCC**: US electromagnetic compatibility
- **IC**: Canadian certification
- **RoHS**: Environmental compliance
- **IP67**: Waterproof rating
- **Automotive**: Vehicle integration standards

## Common Applications

- **Asset Tracking**: High-value equipment and cargo monitoring
- **Fleet Management**: Vehicle tracking and optimization
- **Cold Chain**: Temperature-controlled logistics
- **Solar Installations**: Remote renewable energy monitoring
- **Construction**: Heavy equipment tracking and security
- **Agriculture**: Farm equipment and livestock monitoring
- **Container Tracking**: Global shipping and logistics
- **Trailer Tracking**: Transportation asset management
- **Equipment Rental**: Usage monitoring and theft prevention
- **Emergency Services**: Critical asset tracking

## Protocol Implementation

### Message Parsing
1. Verify opening parenthesis '('
2. Extract IMEI and message type
3. Parse protocol version and device type
4. Extract position data using regex pattern
5. Validate closing parenthesis ')'

### Position Processing
1. Parse date/time fields (YYMMDD HHMMSS)
2. Extract GPS validity flag (A/V)
3. Convert coordinates from DDMM.MMMM format
4. Process speed (knots) and course (degrees)
5. Calculate decimal coordinates with hemisphere

### Data Validation
1. Check message format integrity
2. Validate coordinate ranges
3. Verify GPS validity flag
4. Check timestamp reasonableness
5. Validate device IMEI format

### Sensor Integration
1. Process BLE sensor data
2. Extract temperature/humidity readings
3. Monitor door and security sensors
4. Handle fuel and pressure sensors
5. Generate sensor-based alarms

## Market Innovation

### Technology Leadership
- **Solar Integration**: Leading solar-powered tracking
- **Autonomous Operation**: Minimal maintenance design
- **Sensor Ecosystem**: Comprehensive BLE integration
- **Long Battery Life**: Extended operation capability

### Competitive Advantages
- **Power Efficiency**: Solar charging and low power consumption
- **Durability**: Rugged outdoor construction
- **Flexibility**: Multiple device configurations
- **Innovation**: Continuous product development

## Traccar Configuration

```xml
<entry key='topflytech.port'>5073</entry>
```

### Protocol Features
- **Text-Based Format**: Human-readable ASCII messages
- **Solar Power**: Autonomous charging capability
- **BLE Sensors**: Comprehensive monitoring ecosystem
- **Asset Focus**: Specialized for asset tracking applications
- **Environmental Monitoring**: Temperature and condition tracking

The Topflytech protocol represents innovative GPS tracking technology focused on autonomous operation, solar power, and comprehensive sensor integration for modern asset tracking and fleet management applications.