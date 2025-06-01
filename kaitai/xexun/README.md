# Xexun Protocol

The Xexun protocol is a GPS tracking protocol used by Xexun (Shenzhen Xexun Technology Co., Ltd.) devices. This protocol is based on NMEA GPRMC sentences with additional proprietary fields for device status, power information, and cellular network data.

## Protocol Overview

**Type:** Text-based ASCII (NMEA-based)  
**Manufacturer:** Xexun Technology Co., Ltd. (Shenzhen, China)  
**Primary Use:** Personal tracking, vehicle tracking, asset monitoring  
**Data Format:** Modified GPRMC with additional fields  
**Bidirectional:** Limited (primarily reporting)

## Message Structure

The protocol supports two main formats:

### Basic Format
```
GPRMC,[time],[validity],[lat],[NS],[lon],[EW],[speed],[course],[date],,,A*[checksum]\r\n,[signal],[alarm],imei:[imei],
```

### Full Format
```
[serial],[phone],GPRMC,[time],[validity],[lat],[NS],[lon],[EW],[speed],[course],[date],,,A*[checksum],[signal],[alarm], imei:[imei],[satellites],[altitude],[power_type]:[voltage]V,[charging],[gsm_signal],[mileage],[mcc],[mnc],[lac],[cell_id]
```

## Key Features

- **NMEA-based**: Built on standard GPRMC sentence structure
- **Two Format Modes**: Basic and full (extended) formats
- **Real-time Tracking**: Continuous position reporting
- **Status Alerts**: Movement, SOS, battery, ignition events
- **Power Monitoring**: Voltage levels and charging status
- **Cell Tower Info**: LAC/CID for GSM location
- **Altitude Reporting**: GPS altitude in full format
- **Mileage Tracking**: Odometer functionality

## Device Identification

### Commercial Device Models

#### TK102 Series
- **TK102**: Original personal/vehicle tracker
  - Dimensions: 64×46×17mm (2.5"×1.8"×0.65")
  - Weight: ~50g
  - Battery: 700mAh Li-ion (80 hours standby)
  - GSM: 850/900/1800/1900 MHz quad-band
  - GPS: SiRF Star III chipset
  - Sensitivity: -159dBm
  - USB rechargeable
  
- **TK102-2**: Enhanced version
  - Improved battery life
  - Updated GSM module (SIM900)
  - Same physical dimensions
  - FOTA support

- **TK102B**: Budget variant
  - Similar specs to TK102
  - Different firmware version

#### TK103 Series
- **TK103**: Vehicle/personal tracker
  - Larger form factor for vehicle installation
  - Battery: 1100mAh Li-ion
  - Additional I/O for vehicle integration
  - Engine cut-off capability
  - External GPS/GSM antennas
  
- **TK103-2**: Dual-SIM version
  - Battery: 1200mAh Li-ion
  - Dual SIM support for redundancy
  - Shaking sensor alert
  - Enhanced anti-theft features

- **TK103A/B**: Regional variants
  - Different GSM band configurations
  - Firmware variations

#### Other Models
- **XT009**: Motorcycle/vehicle tracker
- **XT107**: Asset tracker
- **TK201**: Personal tracker series
- **TK203**: Pet tracker

### Physical Characteristics
- **Form Factor**: Compact box design (TK102) or larger vehicle unit (TK103)
- **Power Input**: 12-24V DC (vehicle), USB 5V (personal)
- **Operating Temperature**: -20°C to +55°C
- **Storage Temperature**: -40°C to +85°C
- **Humidity**: 5%-95% non-condensing
- **Waterproofing**: Basic splash resistance

### Device Identification Methods

#### Protocol-Based Identification
- **IMEI Field**: Always present after "imei:" prefix
- **Serial Number**: 6-digit timestamp in full format
- **Phone Number**: Present in full format messages
- **Format Detection**:
  - Basic: No serial/phone prefix
  - Full: Starts with 6-digit serial

#### Alarm/Status Codes
```
Text Alarms:
"help me!" / "help me" - SOS button pressed
"low battery" - Battery below threshold
"move!" / "moved!" - Movement detected
"acc on" / "accstart" - Ignition on
"acc off" / "accstop" - Ignition off
```

#### Power Type Indicators
- **F:** Full power/External power
- **L:** Low battery power

### Protocol Detection Features

#### Message Patterns
- Always contains "GPRMC" or "GNRMC"
- IMEI field with "imei:" prefix
- Two-character checksum after asterisk
- Signal indicator (F/L) after checksum

#### Full Format Indicators
- 6-digit serial number at start
- Phone number field (may be empty)
- Extended fields after IMEI:
  - Satellite count
  - Altitude with decimal
  - Voltage with V suffix
  - Cell tower information

## Common Applications

- **Personal Safety**: Children, elderly, lone worker tracking
- **Vehicle Security**: Anti-theft and recovery
- **Fleet Management**: Basic vehicle tracking
- **Pet Tracking**: Collar-mounted units
- **Asset Protection**: Valuable cargo monitoring
- **Motorcycle Tracking**: Compact installation

## Platform Compatibility

- **Traccar**: Full protocol support
- **GPSWOX**: Device profiles available
- **GPS-Trace**: Integrated support
- **Navixy**: Official integration
- **Wialon**: Hardware database entries
- **GPSGate**: Compatible
- **Flespi**: Device type supported

## Traccar Configuration

```xml
<entry key='xexun.port'>5000</entry>
<entry key='xexun.extended'>false</entry>
```

The `extended` parameter determines whether the decoder expects full format messages.

### Protocol Variants
- **Basic Protocol**: Minimal GPRMC + IMEI
- **Full/Extended Protocol**: Complete telemetry data
- Some devices can switch between formats based on configuration

The Xexun protocol's simplicity and NMEA-based structure make it widely compatible, while the extended format provides comprehensive telemetry suitable for advanced tracking applications.