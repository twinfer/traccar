# Ulbotech Protocol

The Ulbotech protocol is a comprehensive GPS tracking protocol developed by Ulbotech for advanced fleet management and vehicle diagnostics. This Chinese-manufactured system specializes in OBD-II integration, CAN bus communication, and driver behavior analysis with anti-theft capabilities.

## Protocol Overview

**Type:** Dual format (Binary and Text)  
**Manufacturer:** Ulbotech (China)  
**Primary Use:** Fleet management, vehicle diagnostics, driver behavior monitoring  
**Data Format:** Binary with F8 framing and text with asterisk prefix  
**Bidirectional:** Yes (commands and acknowledgments)

## Message Structure

### Binary Format
```
[Header:0xF8][Version:1][Type:1][IMEI:8][Timestamp:4][Data Blocks:N][Footer:0xF8]
```

### Text Format
```
*TS[Version:2],[Device ID:15],[Time:6][Date:6],[Command:N]#
```

### Data Block Types
- **0x01**: GPS positioning data
- **0x02**: LBS (cell tower) information
- **0x03**: Vehicle status and alarms
- **0x04**: Odometer readings
- **0x05**: ADC sensor values
- **0x06**: Geofence events
- **0x07**: OBD-II diagnostic data
- **0x08**: Fuel consumption
- **0x09**: OBD-II alarm conditions
- **0x0A**: Driver behavior analysis
- **0x0B**: CAN bus data
- **0x0C**: J1708 commercial vehicle data
- **0x0D**: Vehicle VIN information
- **0x0E**: RFID driver identification
- **0x10**: Event notifications

## Key Features

- **OBD-II Integration**: Complete engine diagnostics and parameter monitoring
- **CAN Bus Support**: SAE J1939 and J1708 protocol compatibility
- **Driver Behavior**: 8-type harsh driving detection and analysis
- **Anti-Theft**: Engine immobilizer and security features
- **Multiple Connectivity**: 2G/3G/4G, WiFi, and Bluetooth support
- **Modular Design**: Expandable with various sensor integrations

## Device Identification

### Manufacturer Information
**Ulbotech Technology Co., Ltd.**  
- Location: China
- Specialization: OBD-II GPS trackers and fleet management solutions
- Product Line: T-series OBD-II GPS trackers
- Connectivity: Multi-network support (GSM/3G/4G/WiFi/Bluetooth)

### Commercial Device Models

#### T356 Series (WiFi OBD Tracker)
- **T356**: WiFi-enabled OBD-II tracker
  - Built-in WiFi 802.11 b/g/n support
  - Optional Bluetooth Low Energy (BLE)
  - U-blox NEO-6M GPS with A-GPS
  - Internal 3-axis accelerometer
  - Flash storage for two weeks of data
  - FOTA (Firmware Over-The-Air) updates
  - Zero data cost when using WiFi

#### T361 Series (Basic OBD Tracker)
- **T361**: Standard OBD-II GPS tracker
  - Quad-band GPRS/GSM (850/900/1800/1900 MHz)
  - All OBD-II protocol support
  - 3-axis accelerometer for motion detection
  - Backup battery with disconnect alert
  - Engine immobilizer function
  - SAE J1939 CAN bus support

#### T363A Series (Bluetooth OBD Tracker)
- **T363A**: OBD tracker with Bluetooth 2.0
  - Integrated Bluetooth 2.0 connectivity
  - Engine cut (immobilizer) function
  - SAE J1939 CAN bus compatibility
  - Extended functionality via Bluetooth devices
  - Anti-theft and fleet management features
  - Mobile device integration

#### T371 Series (3G OBD Tracker)
- **T371**: 3G WCDMA OBD-II tracker
  - Telit xE910 family 3G module
  - U-blox MAX-7 GNSS (GPS + GLONASS)
  - 25mm×25mm high-gain active antenna
  - AssistNow A-GPS function
  - Real-time OBD data extraction
  - 8-type driving behavior detection
  - Anti-theft immobilizer

#### T373 Series (Advanced 3G Trackers)
- **T373A**: 3G tracker with Bluetooth 2.0
  - 3G WCDMA connectivity
  - Bluetooth 2.0 integration
  - OBD-II and SAE J1939 support
  - Immobilizer output function
  
- **T373B**: 3G tracker with Bluetooth 4.0 LE
  - 3G WCDMA connectivity
  - Bluetooth 4.0 Low Energy
  - Enhanced power efficiency
  - Advanced sensor integration

#### T376 Series (WiFi + 3G Tracker)
- **T376**: Dual connectivity OBD tracker
  - 3G WCDMA and WiFi support
  - OBD-II diagnostic capabilities
  - SAE J1939 CAN integration
  - Immobilizer function
  - Dual communication paths

#### T381 Series (4G OBD Tracker)
- **T381**: Next-generation 4G tracker
  - 4G LTE connectivity
  - WiFi data transmission
  - Three-axis accelerometer
  - OBD-II protocol support
  - Modern fleet management features

### Device ID Format
- **IMEI Format**: Standard 15-digit IMEI in binary messages
- **Device ID**: ASCII device identifier in text messages
- **Binary IMEI**: 8-byte hex-encoded IMEI with leading digit removal
- **Physical Marking**: Model numbers clearly printed on OBD connector

### Physical Characteristics

#### OBD Connector Design
- **Interface**: Standard OBD-II 16-pin connector
- **Installation**: Plug-and-play into vehicle diagnostic port
- **Indicators**: LED lights for GPS/GSM/Power status
- **Size**: Compact form factor for discrete installation
- **Power**: Direct 12V/24V from vehicle OBD port

#### Connectivity Options
- **Cellular**: Multi-band GSM/3G/4G support
- **WiFi**: 802.11 b/g/n wireless networking
- **Bluetooth**: 2.0/4.0 LE for device pairing
- **GPS**: U-blox modules with A-GPS assistance
- **Antenna**: Internal GPS and cellular antennas

### Protocol Detection Features

#### Binary Message Identification
- **Header**: 0xF8 start byte identifier
- **Framing**: F8-to-F8 message boundaries
- **Escape Sequences**: F7 00 = F7, F7 0F = F8
- **Checksum**: CRC16-XMODEM validation

#### Text Message Identification
- **Prefix**: Asterisk (*) message start
- **Protocol**: "TS" protocol identifier
- **Terminator**: Hash (#) message end
- **Format**: Fixed field comma-separated structure

### Advanced Diagnostic Features

#### OBD-II Integration
- **Protocol Support**: All standard OBD-II protocols
- **Parameter Access**: Real-time engine data (RPM, speed, temperature)
- **Diagnostic Codes**: DTC reading and clearing
- **Fuel Monitoring**: Consumption and level tracking
- **Engine Hours**: Accurate engine runtime calculation

#### CAN Bus Capabilities
- **SAE J1939**: Heavy-duty vehicle standard support
- **SAE J1708/J1587**: Legacy commercial vehicle protocols
- **Custom Parameters**: Manufacturer-specific data extraction
- **High-Speed CAN**: Modern vehicle network integration

#### Driver Behavior Analysis
- **Rapid Acceleration**: Sudden speed increase detection
- **Rough Braking**: Hard deceleration monitoring
- **Harsh Cornering**: Sharp turning analysis
- **No Warm-Up**: Engine start without warm-up period
- **Long Idle**: Extended idling detection
- **Fatigue Driving**: Continuous driving patterns
- **Rough Terrain**: Vibration and impact analysis
- **High RPM**: Engine over-rev monitoring

### Security Features

#### Anti-Theft Protection
- **Engine Immobilizer**: Remote engine disable capability
- **Disconnect Alert**: OBD removal notification
- **Backup Battery**: Power loss detection and reporting
- **Tamper Detection**: Device manipulation alerts

#### Driver Authentication
- **RFID Support**: Driver identification cards/tags
- **Authorization System**: Authorized driver validation
- **Driver Behavior Linking**: Performance tied to specific drivers

### Integration Capabilities

#### Fleet Management Systems
- **GPSWOX Compatibility**: Full integration with GPSWOX platform
- **Third-Party APIs**: REST and MQTT protocol support
- **Real-Time Tracking**: Live vehicle monitoring
- **Historical Reporting**: Trip and behavior analysis

#### Mobile Applications
- **iOS/Android Apps**: Native mobile applications
- **Bluetooth Connectivity**: Direct device configuration
- **WiFi Management**: Local network setup and control
- **Remote Commands**: Over-the-air device control

## Common Applications

- **Fleet Management**: Commercial vehicle tracking and optimization
- **Driver Training**: Behavior analysis and improvement programs
- **Insurance Telematics**: Usage-based insurance data collection
- **Vehicle Diagnostics**: Preventive maintenance scheduling
- **Fuel Management**: Consumption monitoring and theft prevention
- **Asset Protection**: Anti-theft and recovery systems
- **Compliance Monitoring**: Hours of service and safety regulations
- **Teen Driving**: Young driver monitoring and coaching

## Platform Compatibility

- **GPSWOX**: Native platform support with full feature access
- **Navixy**: Complete device integration and management
- **Geotab**: Fleet management platform compatibility
- **Third-Party Systems**: Open API for custom integrations
- **Mobile Platforms**: iOS and Android application support

## Traccar Configuration

```xml
<entry key='ulbotech.port'>5028</entry>
```

### Protocol Features
- **Dual Format Support**: Binary and text message processing
- **Frame Decoding**: F8 escape sequence handling
- **Automatic Acknowledgment**: Server response to device messages
- **OBD Data Processing**: Complete diagnostic parameter extraction
- **CAN Bus Integration**: J1939 and J1708 protocol support

### Installation Notes
- Uses `UlbotechFrameDecoder` for binary message framing
- Supports TCP communication with CRC validation
- Includes encoder for bidirectional communication
- Automatic device identification via IMEI extraction

The Ulbotech protocol's focus on OBD-II integration, CAN bus communication, and comprehensive driver behavior analysis makes it particularly suitable for professional fleet management, commercial vehicle monitoring, and applications requiring detailed vehicle diagnostics and driver performance evaluation.