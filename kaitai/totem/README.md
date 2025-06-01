# Totem Protocol

The Totem protocol is a versatile GPS tracking protocol used by Totem Technology/Toman Technology devices. This protocol supports multiple message formats including ASCII text-based and binary formats with comprehensive features like OBD-II data, RFID support, and various alarm types.

## Protocol Overview

**Type:** Text-based ASCII with binary variants  
**Manufacturer:** Totem Technology / Toman Technology  
**Primary Use:** Vehicle tracking, fleet management, asset monitoring  
**Data Format:** Multiple patterns with pipe-delimited fields  
**Bidirectional:** Yes (acknowledgments required)

## Message Structure

All messages start with `$$` header followed by different patterns:

### Pattern 1 - GPRMC Format
```
$$[length][imei]|[alarm]$GPRMC,[time],[validity],[lat],[lon],[speed],[course],[date]...*[checksum]|[fields...]
```

### Pattern 2 - Standard Format
```
$$[length][imei]|[alarm][date][time]|[validity]|[lat]|[NS]|[lon]|[EW]|[speed]|[course]|[hdop]|[io]|[battery]...
```

### Pattern 3 - Compact Format
```
$$[length][imei]|[alarm][datetime][io][charging][battery][power][adc1][adc2][temp1][temp2][lac][cid][validity][sat][course][speed][pdop][odometer][lat][lon][serial][checksum]
```

### Pattern 4 - Binary Format
```
$$[0000][type][imei]|[status][datetime]...[lat][lon][serial][checksum]
```

Special subtypes:
- **E2**: RFID data message
- **E5**: OBD-II data message

## Key Features

- **Multiple Message Formats**: Four main patterns plus special formats
- **OBD-II Support**: Engine diagnostics and vehicle data (E5 messages)
- **RFID Integration**: Driver/asset identification (E2 messages)
- **Comprehensive Alarms**: 14+ alarm types including SOS, geofence, power
- **Cell Tower Data**: LAC/CID with optional MCC/MNC
- **ADC Channels**: Up to 4 analog inputs
- **Temperature Sensors**: Dual temperature monitoring
- **Power Management**: Sleep modes with backup battery

## Device Identification

### Commercial Device Models

#### AT Series Vehicle Trackers
- **AT03**: Basic vehicle GPS tracker
- **AT04**: Enhanced vehicle tracking
- **AT05**: Advanced features with OBD-II support
  - Quad-band GSM (850/900/1800/1900 MHz)
  - u-blox GPS module
  - 300mAh backup battery
  - Supports RFID, iButton, fuel sensors
  - GPS/GLONASS/BeiDou/Galileo support
  - 3-axis accelerometer
  - DC 9-50V input
  
- **AT06**: Voice communication capability
  - Similar to AT05 with voice features
  - 900mAh backup battery (7-10 hours)
  - Microphone for voice monitoring
  
- **AT07**: 3G/4G connectivity
  - 3G/4G LTE support
  - STM32F103RBT6 MCU
  - 800mAh backup battery
  - 16MB flash memory (4000+ records)
  - OTA firmware updates
  - Dimensions: 89×55×25mm
  - Weight: 100g
  - Operating temp: -20°C to +60°C

- **AT09**: Latest 4G model (similar to AT07)

### Physical Characteristics
- **Form Factor**: Compact box design
- **Power Input**: DC 9-50V (varies by model)
- **Backup Battery**: 300-900mAh Li-Polymer
- **Operating Temperature**: -20°C to +60°C
- **Humidity**: 5% to 95% non-condensing
- **Typical Dimensions**: ~90×55×25mm

### Device Identification Methods

#### Protocol-Based Identification
- **IMEI**: Sent after length field, terminated by `|`
- **Message Pattern**: Identifies device capabilities
  - Pattern 1: Basic devices
  - Pattern 4 with E2/E5: Advanced models with RFID/OBD
- **Serial Number**: 4-digit field in most messages

#### Alarm Type Mapping
```
Pattern 1-3 Alarms:        Pattern 4 Alarms:
0x01: SOS                  0x01: SOS
0x10: Low Battery          0x02: Overspeed
0x11: Overspeed           0x04: Geofence Exit
0x30: Parking              0x05: Geofence Enter
0x42: Geofence Exit        0x06: Tow
0x43: Geofence Enter       0x07: GPS Antenna Cut
                           0x10-0x13: Power alarms
                           0x40-0x43: Motion alarms
```

### Protocol Detection Features

#### Message Type Indicators
- **$$**: Protocol header (all messages)
- **$GPRMC**: Pattern 1 (NMEA-style)
- **00xx**: Pattern 4 (length prefix)
- **E2**: RFID message type
- **E5**: OBD-II message type

#### Status Bit Fields (Pattern 4)
```
Bit 0: SOS alarm
Bit 1: Ignition status
Bit 2: Overspeed alarm
Bit 3: Charging status
Bit 4: Geofence exit
Bit 5: Geofence enter
Bit 6: GPS antenna cut
Bit 8-10: Digital outputs
Bit 19: Valid fix (or bit 17 in some versions)
```

## Common Applications

- **Fleet Management**: Commercial vehicle tracking
- **Personal Vehicles**: Anti-theft and monitoring
- **Driver Management**: RFID-based driver identification
- **Vehicle Diagnostics**: OBD-II data collection
- **Asset Tracking**: Equipment and valuable cargo
- **Geofencing**: Zone-based alerts and reporting

## Platform Compatibility

- **Traccar**: Full protocol support
- **Gurtam Wialon**: Integrated support
- **GPSGate**: Compatible
- **GPS-Server**: Supported
- **Navixy**: Platform integration
- **GPSWOX**: Device profiles available
- **Plaspy**: Satellite tracking support

## Traccar Configuration

```xml
<entry key='totem.port'>5007</entry>
```

### Response Requirements
The protocol requires acknowledgments:
- **Pattern 4**: `$$0014AA[last 6 chars][checksum]`
- **Other Patterns**: `ACK OK\r\n`

The Totem protocol's flexibility with multiple message formats and comprehensive feature set makes it suitable for diverse tracking applications from basic vehicle monitoring to advanced fleet management with driver identification and vehicle diagnostics.