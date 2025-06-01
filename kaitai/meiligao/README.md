# Meiligao Protocol Documentation

## Overview

The Meiligao protocol is a binary GPS tracking protocol used by Chinese GPS tracking devices. It features robust binary framing, comprehensive vehicle diagnostics, multimedia support, and bidirectional communication capabilities.

## Device Identification

### Manufacturer
**Meiligao** - Chinese GPS tracking device manufacturer based in Shenzhen

### Commercial Device Models

#### MVT Series (Most Common)
- **MVT100** - Basic vehicle tracker
- **MVT340** - Advanced vehicle tracker with OBD
- **MVT380** - Fleet management device
- **MVT600** - Professional tracking device
- **MVT800** - High-end model with camera

#### GT Series
- **GT60** - Asset tracker
- **GT68** - Vehicle tracker with RFID
- **GT300** - Fleet management device
- **GT500** - Advanced tracking system

#### PT Series
- **PT201** - Personal tracker
- **PT301** - Vehicle/asset tracker
- **PT502** - Professional device
- **PT600** - Enterprise solution

#### OBD Series
- **OBD100** - OBD-II port tracker
- **OBD200** - Advanced OBD diagnostics
- **OBD300** - Fleet diagnostics device

### Compatible Manufacturers
The Meiligao protocol is also used by:
- **Concox** - Some models support Meiligao protocol
- **Coban** - Protocol-compatible devices
- **Various OEM manufacturers** - White-label devices
- **Rebranded devices** - Sold under different names

### IMEI/Device ID Patterns
- Device ID: 7 bytes BCD-encoded IMEI
- BCD encoding: 2 digits per byte with 0xF padding
- Example IMEI `123456789012345` encodes as: `[0x12, 0x34, 0x56, 0x78, 0x90, 0x12, 0x34, 0x5F]`
- Luhn checksum appended for 14-digit IMEIs

### Device Identification Methods

1. **Protocol Frame Detection**
   ```
   0x24 0x24 → Meiligao protocol header
   BCD device ID → IMEI extraction
   ```

2. **Message Type Support Analysis**
   Different device capabilities indicated by supported message types:
   - **Basic**: 0x9955 (position), 0x0001 (heartbeat)
   - **OBD**: 0x9901, 0x9902, 0x9903 (diagnostics)
   - **Multimedia**: 0x9988, 0x9977 (photo), 0x0800 (upload)
   - **Advanced**: 0x9966 (RFID), 0x6688 (retransmission)

3. **Feature Detection via Commands**
   - Photo capability: 0x4151 (take photo) support
   - OBD integration: OBD message type presence
   - RFID support: 0x9966 message support

### Port Configuration
- Default port: 5009 (Traccar)
- Protocol: meiligao
- Supports both TCP (with frame decoder) and UDP

## Protocol Structure

### Frame Format

All messages use consistent binary framing:

```
+--------+--------+--------+--------+-----------+--------+--------+--------+--------+--------+
| Header | Header | Length | Length | Device ID | Command| Command|  Data  |  CRC16 | CR  LF |
|  0x24  |  0x24  |  MSB   |  LSB   |(7 bytes)  |  MSB   |  LSB   | (var)  | (2 b)  |0x0D 0A |
+--------+--------+--------+--------+-----------+--------+--------+--------+--------+--------+
```

### Field Breakdown
- **Header**: 2 bytes, always `0x24 0x24` ("$$")
- **Length**: 2 bytes (big-endian), total message length including header
- **Device ID**: 7 bytes, BCD-encoded IMEI
- **Command Type**: 2 bytes (big-endian), message type identifier
- **Data**: Variable length, message-specific payload
- **CRC16**: 2 bytes, CRC16-CCITT-FALSE checksum
- **Terminators**: 2 bytes, `0x0D 0x0A` (CR LF)

### BCD Device ID Encoding

IMEI is encoded in 7 bytes using BCD (Binary Coded Decimal):
- Each byte contains 2 decimal digits (4 bits each)
- Padding with `0xF` indicates end of IMEI
- For 15-digit IMEI: Full digits + padding
- For 14-digit IMEI: Digits + Luhn checksum + padding

Example: IMEI `359672234567890`
```
Bytes: [0x35, 0x96, 0x72, 0x23, 0x45, 0x67, 0x89]
Final: [0x35, 0x96, 0x72, 0x23, 0x45, 0x67, 0x8F]  // with padding
```

## Message Types

### Device to Server Messages

#### 0x0001 - Heartbeat
```
$$0013359672234567890001FF
```
- Keep-alive signal
- No additional data
- Sent at regular intervals

#### 0x5000 - Login Request
```
$$0015359672234567895000LOGIN00
```
- Device authentication
- May contain device model info

#### 0x9955 - Position Report
```
$$0055359672234567899955112233.000,A,2234.5678,N,11345.6789,E,012.3,045.6,010420|1.5|123|0000|FF,FF|1A2B|25|12345|08
```
**Format**: `time,validity,lat,lat_hem,lon,lon_hem,speed,course,date|hdop|alt|status|adc1,adc2|cell|rssi|odo|sats`

#### 0x9999 - Alarm
```
$$005635967223456789999901112233.000,A,2234.5678,N,11345.6789,E,012.3,045.6,010420
```
- Alarm type byte + position data
- Various alarm codes (SOS, overspeed, etc.)

#### 0x9016 - Logged Position
```
$$0055359672234567899016 03 position1\ position2\ position3\
```
- Multiple stored positions
- Count byte followed by position entries
- Backslash-separated entries

#### 0x9966 - RFID Data
```
$$0063359672234567899966123456781234567890112233.000,A,2234.5678,N,11345.6789,E,012.3,045.6,010420
```
- 8-byte RFID tag + position data
- Driver identification capability

#### 0x6688 - Retransmission
```
$$0055359672234567896688 02 position1\ position2\
```
- Multiple position reports in single message
- Used for batch data transmission

#### 0x9901 - OBD Real-time Data
```
$$0055359672234567899901112233,RPM:1250,SPEED:65,COOLANT:89,LOAD:45,MAF:12.5
```
- Real-time engine parameters
- Comma-separated OBD values

#### 0x9902 - OBD Additional Data
```
$$0045359672234567899902FUEL_CONSUMED:123.5,FUEL_RATE:8.2,ENGINE_HOURS:1234
```
- Extended OBD diagnostics
- Fuel consumption, efficiency data

#### 0x9903 - DTC (Diagnostic Trouble Codes)
```
$$003535967223456789990303P0171,P0300,P0456
```
- Count byte + DTC codes
- Standard OBD-II fault codes

#### 0x0800 - Photo Upload Request
```
$$001535967223456789080000012
```
- Photo index (2 bytes)
- Requests photo upload capability

#### 0x9988 - Photo Data Packet
```
$$102435967223456789998800010002{JPEG_DATA_CHUNK}
```
- Photo index + packet index + JPEG data
- Multi-packet image transmission

#### 0x9977 - Position with Image
```
$$102435967223456789997712233.000,A,2234.5678,N,11345.6789,E,012.3,045.6,010420,{JPEG_DATA}
```
- Position data + embedded image
- Combined location and photo report

#### 0x0f80 - Upload Complete
```
$$001535967223456789f80001
```
- Upload completion notification
- Type byte indicates upload category

### Server to Device Commands

#### 0x4000 - Login Response
```
$$001535967223456789400000
```
- Login acknowledgment
- Result byte (0=success, other=error)

#### 0x4101 - Track on Demand
```
$$0013359672234567894101
```
- Request immediate position report
- No additional parameters

#### 0x4102 - Track by Interval
```
$$001735967223456789410200000300
```
- Set reporting interval
- Interval in seconds (4 bytes)

#### 0x4106 - Movement Alarm Setup
```
$$001535967223456789410601 05
```
- Enable/disable + sensitivity
- Movement detection configuration

#### 0x4114 - Output Control (Method 1)
```
$$001535967223456789411401 01
```
- Output number + state
- Individual output control

#### 0x4115 - Output Control (Method 2)
```
$$001535967223456789411500FF
```
- Output mask (2 bytes)
- Bitmask for multiple outputs

#### 0x4132 - Set Timezone
```
$$0015359672234567894132+0800
```
- Timezone offset (signed)
- Hours from UTC

#### 0x4151 - Take Photo
```
$$001535967223456789415100012
```
- Photo index (2 bytes)
- Remote camera trigger

#### 0x8801 - Photo Upload Response
```
$$001735967223456789880100010002 00
```
- Photo index + packet index + result
- Acknowledgment for photo packets

#### 0x4902 - Reboot Device
```
$$0013359672234567894902
```
- Remote device restart
- No additional parameters

## Position Data Format

### Basic Position String
```
HHMMSS.SSS,V,DDMM.MMMM,N,DDDMM.MMMM,E,SPD,CRS,DDMMYY
```

### Extended Position String
```
HHMMSS.SSS,V,DDMM.MMMM,N,DDDMM.MMMM,E,SPD,CRS,DDMMYY|HDOP|ALT|STATUS|ADC1,ADC2|CELL|RSSI|ODO|SAT|DRIVER
```

#### Field Descriptions
- **Time**: HHMMSS.SSS format (hours, minutes, seconds, milliseconds)
- **Validity**: A=valid GPS, V=invalid GPS
- **Latitude**: DDMM.MMMM format (degrees + decimal minutes)
- **Lat Hemisphere**: N=North, S=South
- **Longitude**: DDDMM.MMMM format (degrees + decimal minutes)
- **Lon Hemisphere**: E=East, W=West
- **Speed**: km/h (decimal)
- **Course**: Degrees 0-360
- **Date**: DDMMYY format

#### Extended Fields (Pipe-separated)
- **HDOP**: Horizontal dilution of precision
- **Altitude**: Meters above sea level
- **Status**: 4-digit hexadecimal status flags
- **ADC**: Analog input values (hex, comma-separated)
- **Cell**: Cell tower ID (hex)
- **RSSI**: Signal strength (hex)
- **Odometer**: Distance traveled (hex or decimal)
- **Satellites**: Number of GPS satellites (hex)
- **Driver**: RFID driver ID

### Status Flags (4-digit Hex)

| Bit | Description | Values |
|-----|-------------|--------|
| 0 | GPS status | 0=invalid, 1=valid |
| 1 | GPS position | 0=normal, 1=differential |
| 2 | East/West | 0=East, 1=West |
| 3 | North/South | 0=North, 1=South |
| 4-7 | Reserved | |
| 8 | ACC status | 0=off, 1=on |
| 9 | Engine status | 0=off, 1=on |
| 10-11 | Reserved | |
| 12-15 | Alarm flags | Various alarm conditions |

## Alarm Codes

| Code | Alarm Type | Description |
|------|------------|-------------|
| 0x01 | SOS | Emergency button pressed |
| 0x10 | Low Battery | Battery voltage below threshold |
| 0x11 | Overspeed | Speed limit exceeded |
| 0x12 | Movement | Unauthorized movement detected |
| 0x13 | Geofence | Enter/exit geofence area |
| 0x14 | Accident | Impact or collision detected |
| 0x50 | Power Off | Main power disconnected |
| 0x53 | GPS Antenna Cut | GPS antenna cable severed |
| 0x72 | Hard Braking | Sudden deceleration detected |
| 0x73 | Hard Acceleration | Aggressive acceleration detected |

## OBD Data Format

### Real-time OBD (0x9901)
```
timestamp,RPM:value,SPEED:value,COOLANT:value,LOAD:value,MAF:value,...
```

### Common OBD Parameters
- **RPM**: Engine revolutions per minute
- **SPEED**: Vehicle speed (km/h)
- **COOLANT**: Coolant temperature (°C)
- **LOAD**: Engine load percentage
- **MAF**: Mass airflow rate (g/s)
- **THROTTLE**: Throttle position percentage
- **FUEL_PRESSURE**: Fuel rail pressure
- **INTAKE_TEMP**: Intake air temperature

### Additional OBD (0x9902)
```
FUEL_CONSUMED:liters,FUEL_RATE:l/h,ENGINE_HOURS:hours,DISTANCE:km
```

### DTC Format (0x9903)
```
count,DTC1,DTC2,DTC3,...
```
- Standard OBD-II trouble codes (P0xxx, B0xxx, C0xxx, U0xxx)

## Photo Transfer Protocol

### Photo Upload Process
1. **Request**: Device sends photo upload request (0x0800)
2. **Response**: Server acknowledges with photo upload response (0x8801)
3. **Data**: Device sends photo data in packets (0x9988)
4. **Confirm**: Server acknowledges each packet
5. **Complete**: Device sends upload complete (0x0f80)

### Photo Packet Structure
- **Photo Index**: Unique photo identifier
- **Packet Index**: Sequential packet number (starts from 1)
- **JPEG Data**: Raw JPEG image data chunk
- **Packet Size**: Up to ~1000 bytes per packet

## CRC Calculation

CRC16-CCITT-FALSE algorithm:
- Polynomial: 0x1021
- Initial value: 0xFFFF
- Final XOR: 0x0000
- Calculated over entire message excluding CRC and terminators

```python
def calculate_crc16(data):
    crc = 0xFFFF
    for byte in data:
        crc ^= (byte << 8)
        for i in range(8):
            if crc & 0x8000:
                crc = (crc << 1) ^ 0x1021
            else:
                crc = crc << 1
            crc &= 0xFFFF
    return crc
```

## Device Configuration

### Common Configuration Parameters
- **Reporting Interval**: Position update frequency
- **Movement Sensitivity**: Motion detection threshold
- **Geofence Setup**: Virtual boundary configuration
- **Alarm Settings**: Enable/disable various alarms
- **Output Control**: Relay/GPIO management
- **Timezone**: Local time configuration

### RFID Integration
- 8-byte RFID tag identification
- Driver management and identification
- Access control integration
- Fleet driver tracking

### Advanced Features
- **Remote Camera Control**: Photo capture on demand
- **Two-way Audio**: Voice communication (some models)
- **Fuel Monitoring**: ADC-based fuel level sensing
- **Temperature Sensors**: Environmental monitoring
- **Harsh Driving Detection**: Acceleration/braking analysis

## Example Message Sequences

### Device Registration
```
Device → Server: $$001535967223456789500000        (Login Request)
Server → Device: $$001535967223456789400000        (Login Response - Success)
Device → Server: $$001335967223456789000100        (Heartbeat)
```

### Normal Operation
```
Device → Server: $$0055359672234567899955112233.000,A,2234.5678,N,11345.6789,E,012.3,045.6,010420|1.5|123|0000
Device → Server: $$001335967223456789000100        (Heartbeat)
Device → Server: $$0055359672234567899955112234.000,A,2234.5679,N,11345.6790,E,015.7,048.2,010420|1.4|124|0000
```

### Alarm Sequence
```
Device → Server: $$005635967223456789999901112235.000,A,2234.5680,N,11345.6791,E,085.3,052.1,010420  (SOS Alarm)
Server → Device: $$001535967223456789410100        (Track on Demand)
Device → Server: $$0055359672234567899955112236.000,A,2234.5681,N,11345.6792,E,082.1,051.8,010420|1.3|125|0001
```

### Photo Transfer
```
Device → Server: $$001535967223456789080000012      (Photo Upload Request)
Server → Device: $$001735967223456789880100010000 00 (Photo Upload Response)
Device → Server: $$102435967223456789998800010001{JPEG_CHUNK_1} (Photo Data Packet 1)
Server → Device: $$001735967223456789880100010001 00 (Acknowledge Packet 1)
Device → Server: $$102435967223456789998800010002{JPEG_CHUNK_2} (Photo Data Packet 2)
...
Device → Server: $$001535967223456789f80001        (Upload Complete)
```

## Implementation Notes

### Frame Processing
1. **Synchronization**: Look for 0x24 0x24 header
2. **Length Validation**: Extract message length
3. **CRC Verification**: Validate message integrity
4. **Device ID Extraction**: Decode BCD IMEI
5. **Command Parsing**: Route by command type

### Data Parsing
- **Position Data**: Split by commas and pipes
- **Coordinate Conversion**: Degrees-minutes to decimal
- **Status Decoding**: Hex to binary flag analysis
- **Timestamp Handling**: Local time zone considerations

### Error Handling
- **CRC Mismatch**: Request retransmission
- **Invalid Coordinates**: Use last known position
- **Malformed Data**: Log and continue processing
- **Missing Fields**: Apply defaults where appropriate