# Suntech Protocol Documentation

## Overview

The Suntech protocol is a hybrid GPS tracking protocol supporting both text-based and binary message formats. It's used by various Suntech GPS tracking devices and supports advanced features like crash detection, Bluetooth beacons, and comprehensive vehicle diagnostics.

## Device Identification

### Manufacturer
**Suntech** (ST Electronics) - Based in Singapore

### Commercial Device Models

#### ST300 Series
- **ST300** - Basic vehicle tracker
- **ST310U** - Entry-level vehicle tracker with basic GPS and jamming detection
- **ST340** - Advanced vehicle tracker with CAN
- **ST300R** - Ruggedized variant
- **ST300K** - Kit version

#### ST400 Series  
- **ST400** - Advanced asset tracker
- **ST410** - Enhanced features
- **ST419** - Professional model

#### ST500 Series
- **ST500** - High-end vehicle tracker
- **ST520** - Fleet management focused
- **ST540** - Premium model with extended I/O

#### ST600 Series
- **ST600** - Commercial vehicle tracker
- **ST650** - Heavy-duty variant

#### ST900 Series
- **ST910** - Specialized tracker

#### SA Series
- **SA200** - Asset tracking device

### IMEI Patterns
- Standard 15-digit IMEI format
- Example patterns from real devices:
  - `205027329`
  - `520000295`
  - `862470041866622`
- Device ID can be numeric string (8-9 digits) or full IMEI

### Device Identification Methods

1. **Message Prefix Analysis**
   ```
   ST300STT → ST300 series device with STT (status) message
   ALT → Alert message (newer universal format)
   UEX → Universal extended format
   ```

2. **Protocol Version Detection**
   - Embedded in messages as firmware version
   - Format: Major.Minor.Patch (e.g., "3.0.9", "1.0.2")

3. **Message Format Support**
   - **Legacy Format**: ST300STT, ST400, etc.
   - **Universal Format**: ALT, UEX, BLE, RES
   - **Binary Format**: ZIP (0x02), Standard binary (0x81/0x82)

### Feature Matrix by Series

| Series | GPS | LBS | CAN | OBD | Crash | BLE | Temp | Fuel |
|--------|-----|-----|-----|-----|-------|-----|------|------|
| ST300 | ✓ | ✓ | | | ✓ | | ✓ | |
| ST310U | ✓ | ✓ | | | | | | |
| ST340 | ✓ | ✓ | ✓ | ✓ | ✓ | | ✓ | ✓ |
| ST400 | ✓ | ✓ | | | | | ✓ | |
| ST500 | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| ST600 | ✓ | ✓ | ✓ | ✓ | ✓ | | ✓ | ✓ |
| ST900+ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |

### Common Features

#### All Models
- Real-time GPS tracking
- GSM/GPRS connectivity
- Cell tower (LBS) positioning fallback
- Digital I/O monitoring
- Battery/power monitoring
- Configurable reporting intervals

#### Advanced Models
- CAN bus data reading
- OBD-II diagnostic access
- Crash detection with G-force analysis
- Bluetooth beacon detection
- Temperature sensors
- Fuel level monitoring
- Driver behavior analysis
- Geofencing support

### Port Configuration
- Default port: 5011 (Traccar)
- Protocol: suntech

## Protocol Structure

### Message Format Detection

Messages are identified by their first byte(s):
- `0x02` → ZIP compressed binary format
- Second byte `0x00` → Standard binary format  
- ASCII text → Text format with prefixes

### Text Message Format

```
{PREFIX};{device_id};{sw_version};{status};{date};{time};{cell_id};{mcc};{mnc};{lac};{signal};{latitude};{longitude};{speed};{course};{satellites};{gps_valid};{additional_fields}
```

#### Common Text Prefixes
- **ST300STT** - ST300 series status report
- **ALT** - Alert message (universal format)
- **UEX** - Universal extended format
- **BLE** - Bluetooth beacon data
- **RES** - Response message
- **CMD** - Command acknowledgment
- **CRR** - Crash report

### Binary Message Formats

#### ZIP Format (0x02)
```
+--------+--------+--------+--------+--------+--------+
| Header | Length | Device | Time   | GPS    | Status |
|  0x02  | 2 bytes| 5 bytes| 4 bytes| 9 bytes| 4 bytes|
+--------+--------+--------+--------+--------+--------+
```

#### Standard Binary (0x81/0x82)
```
+--------+--------+--------+--------+--------+--------+
| Type   | Length | Device | Mask   | Basic  | Optional|
| 1 byte | 2 bytes| 5 bytes| 3 bytes| Data   | Data    |
+--------+--------+--------+--------+--------+--------+
```

## Message Types

### Location Reports

#### STT - Status Report
```
ST300STT;205027329;03;374;20150108;17:54:42;177b38;-23.566052;-046.477588;000.000;000.00;0;0;0;12.11;000000;1;0312
```

#### UEX - Universal Extended
```
UEX;1610020241;03FFFFFF;161;3.0.9;0;20240506;15:52:55;00006697;724;11;4EDA;33;-5.129240;-42.797868;0.00;0.00;11;1;00000001;00000000;24;GTSL|6|1|0|22574684|1|
```

### Event Reports

#### ALT - Alert Message  
```
ALT;0520000295;3FFFFF;52;1.0.2;0;20190703;01:03:24;00004697;732;101;0002;59;+4.682583;-74.128142;0.00;0.00;6;1;00000000;00000000;9;1;;4.1;12.92;103188
```

#### CRR - Crash Report
```
CRR;862470041866622;129;89;3.1.8;1;20201110;14:06:59;0000B1EC;732;101;2533;18;+10.823201;+106.629639;0.00;180.00;16;1;00000001;00000000;24;4;3;-2.1;-0.7;-9.6;0.0;-1.4;0.7
```

### Bluetooth Data

#### BLE - Beacon Report
```
BLE;862470041866622;129;89;3.1.8;1;20201110;14:06:59;0000B1EC;732;101;2533;18;+10.823201;+106.629639;0.00;180.00;16;1;00000001;00000000;24;BLE,1,C412F7C50A80;APRSBF,1,01
```

## Field Descriptions

### Common Fields
- **device_id**: Device identifier (numeric or IMEI)
- **sw_version**: Firmware version
- **status**: Device status code
- **date**: YYYYMMDD format
- **time**: HH:MM:SS format
- **cell_id**: Cell tower ID (hex)
- **mcc**: Mobile Country Code  
- **mnc**: Mobile Network Code
- **lac**: Location Area Code
- **signal**: GSM signal strength
- **latitude**: Decimal degrees (signed)
- **longitude**: Decimal degrees (signed)
- **speed**: Speed in km/h
- **course**: Direction in degrees
- **satellites**: Number of GPS satellites
- **gps_valid**: GPS fix validity (0/1)

### Status Codes
- **0**: Normal
- **1**: Over speed
- **2**: Input trigger
- **3**: Output trigger
- **4**: Geofence enter
- **5**: Geofence exit
- **6**: Power on
- **7**: Power off
- **24**: Crash detected

### Extended Fields (UEX/ALT)
- **io_status**: Digital I/O status (hex)
- **analog_status**: Analog input status (hex)
- **reason**: Event trigger reason
- **custom_data**: Device-specific data
- **voltage**: Battery voltage
- **power**: External power voltage
- **odometer**: Distance traveled

### Crash Data (CRR)
- **crash_type**: Type of crash detected
- **confidence**: Detection confidence level
- **g_force_x**: X-axis G-force at impact
- **g_force_y**: Y-axis G-force at impact  
- **g_force_z**: Z-axis G-force at impact
- **delta_v**: Change in velocity
- **pre_crash_speed**: Speed before impact
- **post_crash_speed**: Speed after impact

## Binary Data Formats

### ZIP GPS Data (BCD Encoded)
- **Latitude**: Degrees + minutes with decimal precision
- **Longitude**: Degrees + minutes with decimal precision
- **Course**: 0-360 degrees
- **Speed**: km/h
- **Flags**: GPS validity and hemisphere indicators

### Binary Field Mask
3-byte mask indicating presence of optional fields:
- Bit 0: ADC values (4 × 2-byte values)
- Bit 1: RPM data
- Bit 2: Temperature sensor
- Bit 3: Digital input status

## Protocol Configuration

### Text Protocol Type
- **Type 0**: Basic format
- **Type 1**: Extended format with additional fields

### HBM Level (Heartbeat Mode)
- **Level 1**: Basic heartbeat
- **Level 2**: Extended heartbeat with diagnostics

### Include Flags
- **includeAdc**: Include ADC readings
- **includeRpm**: Include RPM data  
- **includeTemp**: Include temperature data

## Time Handling

- All timestamps in UTC
- Date format: YYYYMMDD
- Time format: HH:MM:SS
- Binary timestamps: Unix epoch (seconds since 1970-01-01)

## Coordinate Format

### Text Format
- Decimal degrees with sign prefix
- Positive: North/East
- Negative: South/West
- Precision: 6 decimal places

### Binary Format
- Signed magnitude representation
- Minutes-based encoding with decimal precision
- Hemisphere indicated by sign bit

## Example Messages

### Normal Position Report
```
ST300STT;205027329;03;374;20150108;17:54:42;177b38;-23.566052;-046.477588;000.000;000.00;0;0;0;12.11;000000;1;0312
```

### Overspeed Alert
```
ALT;0520000295;3FFFFF;52;1.0.2;1;20190703;01:03:24;00004697;732;101;0002;59;+4.682583;-74.128142;85.50;0.00;6;1;00000000;00000000;1;1;;4.1;12.92;103188
```

### Crash Detection
```  
CRR;862470041866622;129;89;3.1.8;1;20201110;14:06:59;0000B1EC;732;101;2533;18;+10.823201;+106.629639;0.00;180.00;16;1;00000001;00000000;24;4;3;-2.1;-0.7;-9.6;0.0;-1.4;0.7
```

### Bluetooth Beacon Data
```
BLE;862470041866622;129;89;3.1.8;1;20201110;14:06:59;0000B1EC;732;101;2533;18;+10.823201;+106.629639;0.00;180.00;16;1;00000001;00000000;24;BLE,1,C412F7C50A80;APRSBF,1,01
```

## Advanced Features

### Crash Detection
- 3-axis accelerometer monitoring
- Configurable G-force thresholds
- Delta-V calculation
- Confidence scoring
- Automatic emergency response

### Bluetooth Integration
- iBeacon detection
- BLE sensor support
- RFID/NFC integration
- Driver identification

### Vehicle Integration
- CAN bus data access
- OBD-II diagnostics
- Fuel monitoring
- Engine parameters
- Driver behavior scoring

### Fleet Management
- Route optimization
- Maintenance scheduling
- Driver performance monitoring
- Fuel efficiency tracking
- Harsh driving detection