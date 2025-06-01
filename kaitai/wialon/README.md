# Wialon IPS Protocol

Wialon IPS (Internet Protocol for Sensors) is an open-source, text-based GPS tracking protocol developed by Gurtam for the Wialon satellite monitoring platform. This protocol is widely adopted across the GPS tracking industry and supports extensive sensor integration and telemetry data transmission.

## Protocol Overview

**Type:** Text-based ASCII  
**Developer:** Gurtam  
**License:** GNU FDL (Free Documentation License)  
**Primary Use:** Vehicle tracking, fleet management, asset monitoring  
**Data Format:** ASCII text with semicolon-separated fields  
**Bidirectional:** Yes (commands and responses)

## Message Structure

### Basic Format
```
[version];[imei]#[message_type]#[data]
```

### Message Types
- **L** - Login/Authentication
- **P** - Ping/Heartbeat
- **D** - Data packet (real-time position)
- **SD** - Short data packet (minimal data)
- **B** - Batch packet (multiple positions)
- **M** - Message response

### Position Data Format
```
DD;MM;YY;HH;MM;SS;DDMM.MMMM;N;DDDMM.MMMM;E;SPEED;COURSE;ALTITUDE;SATS;HDOP;INPUTS;OUTPUTS;ADC;IBUTTON;PARAMS
```

## Key Features

- **Open Source**: Freely available under GNU FDL license
- **Wide Compatibility**: Supported by 3,700+ GPS tracking device models
- **Extensive Sensors**: ADC, digital sensors, CAN-bus, cameras
- **Flexible Parameters**: Custom sensor data with type indicators
- **Network Support**: Cellular tower triangulation data
- **Batch Transmission**: Multiple positions in single message

## Device Identification

### Supported Manufacturers and Models

#### Primary Manufacturers Using Wialon IPS

**Mielta Technology** (Russian manufacturer, founded 2012)
- **Mielta M1**: 4,484+ units connected globally
- **Mielta M3**: 1,939+ units connected globally  
- **Mielta M7**: 94+ units connected
- All models natively support Wialon IPS protocol

**GlonassSoft**
- **UMKa302, UMKa310, UMKa311**: GPS/GLONASS tracking units
- Full Wialon IPS v1.1 and v2.0 support

**Gurtam (Protocol Developer)**
- **GPS Tag**: Software-based tracker for smartphones
- Native Wialon IPS implementation

**Elgato Communications**
- Various GPS tracking device models
- Wialon IPS protocol compatibility

**Positioning Universal**
- Multiple GPS tracking solutions
- Standardized Wialon IPS support

### Market Statistics
- **48,785 units** using Wialon IPS protocol globally
- Represents **49.69%** of all devices on Wialon platform
- Wide adoption across manufacturers due to open-source nature

### Device Detection Methods

#### Automatic Detection Service
- Use **id.wialon.net** detection service
- Point device to IP **193.193.165.167**
- Device appears in detection table when connected
- Provides device model and IMEI information

#### Manual Identification
1. **Check device documentation** for Wialon IPS support
2. **Review configuration software** for protocol options
3. **Contact manufacturer** for Wialon IPS compatibility
4. **Test connection** to Wialon IPS server

### IMEI-Based Identification
- **Primary Identifier**: 15-digit IMEI from GSM modem
- **Login Format**: IMEI sent in authentication packet
- **Unique ID**: Cannot be modified (hardware-based)
- **Version Support**: Both v1.1 and v2.0 protocols

### Protocol Detection Features

#### Configuration Requirements
```
Server IP: Platform-specific
Port: Usually 20332 or custom
Protocol: Wialon IPS v1.1 or v2.0
APN: Carrier-specific settings
Frequency: Configurable reporting intervals
```

#### Message Characteristics
- **ASCII Text**: Human-readable format
- **Delimiter Pattern**: Semicolon-separated fields
- **Response System**: Server acknowledgments required
- **Parameter Types**: Type indicators (1=integer, 2=double, 3=string)

### Supported Features
- **Real-time Tracking**: Live GPS position data
- **Blackbox Storage**: Local data buffering
- **Wi-Fi Positioning**: Alternative location methods
- **Digital Sensors**: I/O monitoring and control
- **CAN-bus Integration**: Vehicle diagnostics
- **Driver Identification**: iButton/RFID support
- **Camera Support**: Image transmission capability
- **Remote Management**: GPRS/SMS commands

## Common Applications

- **Fleet Management**: Commercial vehicle tracking
- **Personal Tracking**: Individual vehicle monitoring
- **Agricultural Monitoring**: Farm equipment tracking
- **Anti-theft Systems**: Vehicle security solutions
- **Asset Protection**: Equipment and cargo tracking

## Troubleshooting and Configuration

### Essential Configuration Steps
1. **GPS Antenna**: Ensure clear sky view for satellite reception
2. **Movement Test**: Some devices only transmit when moving
3. **Configuration Strings**: Verify no extra spaces in setup
4. **Cellular Signal**: Check network strength and APN settings
5. **Server Settings**: Correct IP address and port configuration

### Technical Support
- **Manufacturer Documentation**: Device-specific setup guides
- **Wialon Support**: hw@wialon.com for technical assistance
- **Community Forums**: Active user communities for troubleshooting
- **Detection Service**: Use id.wialon.net for device verification

## Traccar Configuration

```xml
<entry key='wialon.port'>5013</entry>
```

The Wialon IPS protocol's open-source nature, extensive manufacturer support, and comprehensive feature set make it an excellent choice for GPS tracking applications requiring standardized, reliable communication with broad device compatibility.