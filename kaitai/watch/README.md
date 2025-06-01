# Watch Protocol Documentation

## Overview

The Watch protocol is a text-based GPS tracking protocol specifically designed for smartwatches and wearable devices. It supports comprehensive health monitoring, two-way communication, multimedia transmission, and location tracking with specialized features for personal safety and family monitoring.

## Device Identification

### Manufacturers
Multiple manufacturers produce watches compatible with this protocol, primarily from China:

#### Common Brands
- **Xplora** - European children's smartwatch brand
- **Setracker** - Popular watch tracking app ecosystem
- **ZGPAX** - Smartwatch manufacturer
- **Wonlex** - Kids' smartwatch specialist
- **GW** Series - Generic smartwatch models
- **Q** Series - Children's GPS watches
- **Various OEM manufacturers** - White-label devices

#### Device Categories by Manufacturer Code

| Code | Manufacturer | Typical Devices | Features |
|------|--------------|-----------------|----------|
| **3G** | 3G-capable devices | Advanced smartwatches | Video calls, internet |
| **SG** | Setracker ecosystem | Children's watches | Basic tracking, SOS |
| **CS** | Generic Chinese | Budget smartwatches | Core features |
| **ZJ** | Zhongjing/Premium | High-end devices | Full health monitoring |
| **GH** | Generic brand | Various models | Standard features |
| **ZG** | Alternative brand | Mixed devices | Variable features |

### Commercial Device Models

#### Children's Watches (Most Common)
- **GW1000** - Basic GPS watch with SOS
- **GW2000** - Camera-enabled watch
- **Q12** - Popular children's model
- **Q50/Q60/Q80/Q90** - Progressive feature sets
- **DZ09** - Adult smartwatch (basic)
- **A1** - Fitness-focused watch

#### Advanced Models
- **T58** - Health monitoring focus
- **DT100** - Comprehensive health sensors
- **KT series** - Kids' watches with video calls
- **DF series** - Fitness tracking watches

### IMEI/Device ID Patterns
- Standard 15-digit IMEI format
- Device ID extraction from message header
- Example patterns:
  - `903185331912345`
  - `600541290212345`
  - `567890123456789`

### Device Identification Methods

1. **Manufacturer Code Detection**
   ```
   [3G*...] → 3G-capable device
   [SG*...] → Setracker ecosystem
   [CS*...] → Generic Chinese device
   [ZJ*...] → Premium device
   ```

2. **Message Type Support Analysis**
   Different devices support different message sets:
   - **Basic**: INIT, LK, UD, AL
   - **Health**: PULSE, HEART, BLOOD, TEMP, OXYGEN
   - **Multimedia**: IMG, TK, JXTK
   - **Advanced**: All message types

3. **Feature Detection via Status Messages**
   - Heart rate support: HEART/PULSE messages
   - Camera capability: IMG messages
   - Voice functionality: TK/JXTK messages
   - Advanced sensors: TEMP, OXYGEN messages

### Port Configuration
- Default port: 5005 (Traccar)
- Protocol: watch

## Protocol Structure

### Frame Format

All messages are enclosed in brackets with escape sequences:

```
[MANUFACTURER*DEVICE_ID*[INDEX*]LENGTH*CONTENT]
```

### Field Breakdown
- **MANUFACTURER** (2 chars): Device manufacturer code
- **DEVICE_ID** (variable): IMEI or device identifier
- **INDEX** (4 hex, optional): Message sequence number
- **LENGTH** (4 hex): Content length in bytes
- **CONTENT**: Message type and data

### Escape Sequences

Special characters are escaped using `}` (0x7D) prefix:
- `}` + `0x01` → `}` (literal brace)
- `}` + `0x02` → `[` (opening bracket)
- `}` + `0x03` → `]` (closing bracket)
- `}` + `0x04` → `,` (comma)
- `}` + `0x05` → `*` (asterisk)

## Message Types

### 1. System Messages

#### INIT - Device Initialization
```
[3G*9031853319*0001*0004*INIT]
```
- Sent on device startup
- Establishes connection with server
- May include device capabilities

#### LK - Heartbeat/Keep-Alive
```
[3G*9031853319*0001*000A*LK,0,100,64]
```
Format: `LK[,type,battery,steps,...]`
- **type**: Heartbeat type (optional)
- **battery**: Battery percentage (0-100)
- **steps**: Step count
- **Additional**: May include health data

#### TKQ/TKQ2 - Acknowledgment
```
[3G*9031853319*0001*0003*TKQ]
```
- Acknowledges received commands
- TKQ2 variant for extended responses

### 2. Location Messages

#### UD/UD2 - Position Updates
```
[3G*9031853319*004E*UD2,220322,055105,A,22.761162,N,114.360192,E,0,0,47,14,100,64,0,0,00000008,0,0]
```

**Format**: `UD[2],date,time,validity,lat,lat_hem,lon,lon_hem,speed,course,alt,sats,rssi,battery,steps,tumbles,status[,cell_data,wifi_data]`

**Field Details**:
- **date**: DDMMYY format
- **time**: HHMMSS format  
- **validity**: A=valid, V=invalid
- **lat/lon**: Decimal degrees
- **lat_hem/lon_hem**: N/S, E/W
- **speed**: km/h
- **course**: Degrees (0-360)
- **alt**: Altitude in meters
- **sats**: Number of satellites
- **rssi**: GSM signal strength
- **battery**: Battery percentage
- **steps**: Step counter
- **tumbles**: Fall detection counter
- **status**: Hex status flags

#### Network Variants
- **UD_LTE**: LTE network position
- **UD_WCDMA**: 3G network position

#### AL - Alarm Position
```
[3G*9031853319*0001*0058*AL,SOS,220322,055105,A,22.761162,N,114.360192,E,0,0,47,14,100,64,0,0,00010000]
```
- Includes alarm type before position data
- Triggered by various alarm conditions

#### WT - Watch Position
```
[3G*9031853319*0001*0048*WT,220322,055105,A,22.761162,N,114.360192,E,0,0,47,14,100,64,0,0,00000000]
```
- Watch-specific position report format

### 3. Health Monitoring Messages

#### HEART/PULSE - Heart Rate
```
[ZJ*1234567890*0001*0009*HEART,72]
[3G*9031853319*0001*0008*PULSE,75]
```
- Heart rate in beats per minute
- Continuous or on-demand monitoring

#### BLOOD/BPHRT - Blood Pressure
```
[ZJ*1234567890*0001*000C*BLOOD,120,80]
[3G*9031853319*0001*000E*BPHRT,118,78,72]
```
- **BLOOD**: Systolic, diastolic pressure
- **BPHRT**: Systolic, diastolic, heart rate

#### TEMP/BTEMP2 - Temperature
```
[ZJ*1234567890*0001*0009*TEMP,36.5]
[3G*9031853319*0001*000C*BTEMP2,98.6,F]
```
- Body temperature measurement
- May include unit (C/F)

#### OXYGEN - Blood Oxygen
```
[ZJ*1234567890*0001*000A*OXYGEN,98]
```
- Blood oxygen saturation percentage

### 4. Multimedia Messages

#### IMG - Image Data
```
[CS*1234567890*0001*1024*IMG,{binary_image_data}]
```
- Photo capture from watch camera
- Binary data transmission

#### TK - Audio Message
```
[CS*1234567890*000E*0256*TK,#!AMR{binary_audio_data}]
```
- Voice message recording
- AMR audio format common
- Binary audio data follows format header

#### JXTK - Multi-part Audio
```
[CS*1234567890*0001*0128*JXTK,1,3,{partial_audio_data}]
```
- Large audio files split into parts
- Format: JXTK,part_number,total_parts,data

## Cell Tower and WiFi Data

### Cell Tower Format
```
cell_count,timing_advance,mcc,mnc,lac1,cid1,rssi1,lac2,cid2,rssi2,...
```

Example: `3,0,460,0,4E20,12AB34CD,25,4E20,12AB35CE,22,4E20,12AB36CF,18`

### WiFi Access Points Format
```
wifi_count,name1,mac1,rssi1,name2,mac2,rssi2,...
```

Example: `2,HOME_WIFI,AA:BB:CC:DD:EE:FF,75,OFFICE_WIFI,11:22:33:44:55:66,68`

## Status Flags (Hex Format)

The status field uses hexadecimal bit flags:

| Bit | Value | Alarm Type | Description |
|-----|-------|------------|-------------|
| 0 | 0x00000001 | Low Battery | Battery below threshold |
| 1 | 0x00000002 | Geofence Exit | Left safe zone |
| 2 | 0x00000004 | Geofence Enter | Entered restricted zone |
| 3 | 0x00000008 | Moving | Motion detected |
| 4 | 0x00000010 | Fall Down | Basic fall detection |
| 14 | 0x00004000 | Power Cut | External power disconnected |
| 16 | 0x00010000 | SOS Alarm | Emergency button pressed |
| 17 | 0x00020000 | SOS Auto | Automatic SOS trigger |
| 20 | 0x00100000 | Device Removal | Watch removed from wrist |
| 21 | 0x00200000 | Fall Level 1 | Mild fall detected |
| 22 | 0x00400000 | Fall Level 2 | Severe fall detected |

## Command and Response Flow

### Typical Session
1. **Device connects and sends INIT**
2. **Server acknowledges connection**
3. **Device sends periodic LK heartbeats**
4. **Device sends UD position updates**
5. **Health data sent via HEART, TEMP, etc.**
6. **Alarms trigger AL messages**

### Server Commands (Examples)
- `PW,{password},IP,{server},{port}#` - Set server
- `PW,{password},RESET#` - Factory reset
- `PW,{password},SOS1,{phone_number}#` - Set SOS contact
- `PW,{password},CENTER,{phone_number}#` - Set monitoring center

## Health Monitoring Features

### Continuous Monitoring
- **Heart Rate**: Real-time or scheduled measurements
- **Temperature**: Body temperature tracking
- **Step Counting**: Daily activity monitoring
- **Sleep Tracking**: Movement-based sleep analysis

### Medical Features (Advanced Models)
- **Blood Pressure**: Cuff-free estimation
- **Blood Oxygen**: SpO2 monitoring
- **Stress Levels**: HRV-based analysis
- **Medication Reminders**: Alert system

## Safety and Security Features

### Personal Safety
- **SOS Button**: One-touch emergency
- **Fall Detection**: Automatic emergency calls
- **Geofencing**: Safe zone monitoring
- **Voice Monitoring**: Silent listening mode

### Family Monitoring
- **Real-time Tracking**: Continuous location
- **Two-way Calling**: Voice communication
- **Text Messages**: Simple messaging
- **Remote Camera**: Photo capture commands

### Child-Specific Features
- **School Mode**: Limited functionality during class
- **Friend Requests**: Controlled contact management
- **Rewards System**: Gamified activity tracking
- **Parental Controls**: Feature restrictions

## Device Configuration

### Network Settings
- **APN Configuration**: Carrier settings
- **Server Settings**: Tracking server details
- **Update Intervals**: Position reporting frequency

### Personal Settings
- **Contacts**: Phone book management
- **Alarms**: Medication/activity reminders
- **Language**: Display language selection
- **Time Zone**: Local time configuration

### Safety Settings
- **Geofences**: Safe/unsafe area definition
- **SOS Contacts**: Emergency contact list
- **Fall Sensitivity**: Detection threshold
- **Auto-answer**: Incoming call handling

## Example Message Sequences

### Device Registration
```
[3G*9031853319*0001*0004*INIT]
[3G*9031853319*0002*000A*LK,0,85,1245]
```

### Normal Operation
```
[3G*9031853319*0003*004E*UD2,220322,055105,A,22.761162,N,114.360192,E,0,0,47,14,100,1245,0,0,00000000]
[3G*9031853319*0004*0008*HEART,72]
[3G*9031853319*0005*000A*LK,0,83,1267]
```

### Emergency Sequence
```
[3G*9031853319*0006*0058*AL,SOS,220322,055205,A,22.761162,N,114.360192,E,0,0,47,14,98,1267,0,1,00010000]
[3G*9031853319*0007*0256*TK,#!AMR{emergency_audio_message}]
```

### Health Monitoring
```
[ZJ*1234567890*0001*0009*TEMP,36.8]
[ZJ*1234567890*0002*000C*BLOOD,118,76]
[ZJ*1234567890*0003*000A*OXYGEN,97]
[ZJ*1234567890*0004*0008*HEART,74]
```

## Implementation Notes

### Message Processing
1. **Frame Extraction**: Find `[` and `]` delimiters
2. **Escape Processing**: Handle `}` escape sequences
3. **Field Parsing**: Split by `*` separators
4. **Content Parsing**: Parse message-specific data

### Data Validation
- **IMEI Verification**: Standard Luhn checksum
- **GPS Validation**: Coordinate range checking
- **Health Data Limits**: Physiological value ranges
- **Timestamp Validation**: Date/time format checking

### Error Handling
- **Malformed Messages**: Graceful degradation
- **Missing Fields**: Default value assignment
- **Invalid Coordinates**: Last known position retention
- **Network Errors**: Retry mechanisms