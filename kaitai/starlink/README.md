# StarLink Protocol

The StarLink protocol is a configurable GPS tracking communication standard developed by StarLink Communications, designed for modular fleet management and vehicle tracking applications. The protocol features flexible field mapping, comprehensive vehicle diagnostics, and support for various sensor integrations including Dallas temperature sensors.

## Protocol Overview

**Type:** Text-based with configurable field format  
**Manufacturer:** StarLink Communications  
**Primary Use:** Fleet management, vehicle tracking, asset monitoring  
**Data Format:** ASCII text with comma-separated values  
**Configuration:** Flexible field mapping via format strings  
**Sensors:** Dallas temperature sensors, fuel monitoring, I/O expansion

## Message Structure

### Frame Format
```
$SLU[Device ID],[Type],[Index],[Data Fields]*[Checksum]
```

### Field Details
- **Header**: Dollar sign ($) followed by "SLU"
- **Device ID**: 6-character hex or 15-digit identifier
- **Type**: Message type (6 = event report)
- **Index**: Message sequence number
- **Data Fields**: Comma-separated values based on configuration
- **Checksum**: Two-character hex validation

### Example Message
```
$SLU031B2B,06,622,170329035057,01,170329035057,+3158.0018,+03446.6968,004.9,007,000099,1,1,0,0,0,0,0,0,,,14.176,03.826,,1,1,1,4*B0
```

### Configurable Field Format
The protocol uses configurable field tags to define data structure:
```
#EDT#,#EID#,#PDT#,#LAT#,#LONG#,#SPD#,#HEAD#,#ODO#,#IN1#,#IN2#,#IN3#,#IN4#,#OUT1#,#OUT2#,#OUT3#,#OUT4#,#LAC#,#CID#,#VIN#,#VBAT#,#DEST#,#IGN#,#ENG#
```

## Key Field Tags

### Timestamp Fields
- **#EDT#**: Event Device Time (device timestamp)
- **#PDT#**: Position Device Time (GPS timestamp)

### Position Fields
- **#LAT#**: Latitude (+/-DDMM.MMMM format)
- **#LONG#**: Longitude (+/-DDDMM.MMMM format)
- **#SPD#**: Speed in knots
- **#SPDK#**: Speed in km/h
- **#HEAD#**: Heading/course (0-359 degrees)
- **#ALT#**: Altitude in meters
- **#ALTD#**: Detailed altitude

### Event Fields
- **#EID#**: Event ID (trigger code)
- **#EDSC#**: Event description text

### Vehicle Fields
- **#ODO#**: Odometer reading
- **#ODOD#**: Detailed odometer (×1000)
- **#IGN#**: Ignition status (0/1)
- **#IGNL#**: Logical ignition status
- **#ENG#**: Engine status (0/1)

### Power Fields
- **#VIN#**: Input voltage (main power)
- **#VBAT#**: Battery voltage (backup)
- **#BATC#**: Battery charge percentage
- **#BATH#**: Battery health status

### Digital I/O Fields
- **#IN1#-#IN4#**: Digital inputs 1-4
- **#OUT1#-#OUT4#**: Digital outputs 1-4
- **#OUTA#-#OUTD#**: Alternative output naming

### GPS Fields
- **#SAT#**: Satellites visible
- **#SATN#**: Satellites visible (alternative)
- **#SATU#**: Satellites used in fix
- **#PDOP#**: Position Dilution of Precision

### Cellular Fields
- **#LAC#**: Location Area Code
- **#CID#**: Cell ID
- **#CSS#**: Cellular Signal Strength

### Sensor Fields
- **#TVI#**: Internal temperature
- **#CFL#**: Fuel level
- **#CFL2#**: Secondary fuel level
- **#TV1#-#TV4#**: Sensor voltages 1-4
- **#TS1#-#TS4#**: Sensor states 1-4
- **#TD1#-#TD2#**: Temperature data (protobuf encoded)

### Driver Fields
- **#DAL#**: Driver alert
- **#DID#**: Driver ID
- **#DRV#**: Driver status

## Coordinate Format

StarLink uses a specific coordinate format:
- **Format**: +/-DDMM.MMMM or +/-DDDMM.MMMM
- **Sign**: + for North/East, - for South/West
- **Parsing**: 
  - Degrees: Characters 1 to minutes index
  - Minutes: Decimal portion / 60
  - Result: Degrees + (Minutes/60)

Example: "+3158.0018" = +31 + (58.0018/60) = +31.9667 degrees

## Event Codes

### Common Events
- **1**: Position report
- **4**: SOS/Panic button
- **6**: Overspeed violation
- **7**: Geofence enter
- **8**: Geofence exit
- **9**: Power cut/disconnect
- **11**: Low battery
- **16**: Unknown RFID card
- **19**: Power restore
- **20**: RFID driver identification
- **24**: Ignition on
- **25**: Ignition off
- **26**: Tow detection
- **33**: External device event
- **34**: Device startup
- **36**: SOS button
- **42**: Cellular jamming detected

### Alarm Mapping
- Event 6 → ALARM_OVERSPEED
- Event 7 → ALARM_GEOFENCE_ENTER
- Event 8 → ALARM_GEOFENCE_EXIT
- Event 9 → ALARM_POWER_CUT
- Event 11 → ALARM_LOW_BATTERY
- Event 26 → ALARM_TOW
- Event 36 → ALARM_SOS
- Event 42 → ALARM_JAMMING

## Key Features

- **Configurable Format**: Flexible field mapping
- **Multi-Sensor Support**: Dallas temperature sensors
- **Comprehensive I/O**: 4 inputs, 4 outputs
- **Fuel Monitoring**: Dual fuel level sensors
- **Driver ID**: RFID/iButton support
- **Cellular Info**: LAC/CID location
- **Protobuf Integration**: Temperature sensor data
- **Event-Driven**: Real-time alarm notifications
- **Diagnostic Data**: Vehicle health monitoring

## Device Identification

### Company Information
**StarLink Communications**  
- Focus: Modular GPS tracking solutions
- Markets: Fleet management, asset tracking
- Technology: 2G/3G/4G cellular, satellite options
- Sensors: Dallas temperature, fuel, environmental

### Global Presence
- **Primary Markets**: International fleet operators
- **Technology**: GSM quad-band, 3G/4G capable
- **Integration**: Platform-agnostic design
- **Compatibility**: Multiple tracking software platforms

### Device Portfolio

#### StarLink Tracker Models

**StarLink Tracker Standard**
- **Technology**: 2G Quad-band GSM
- **Features**:
  - Embedded antennas
  - Cellular jamming detection
  - Extensive diagnostics
  - Fuel theft notifications
  - Modular configuration
- **Applications**: Fleet vehicles, asset tracking

**StarLink Tracker SF (3G/4G)**
- **Technology**: 3G/4G cellular with 2G fallback
- **Features**:
  - Dallas temperature sensor support
  - Enhanced connectivity options
  - Wi-Fi and Bluetooth capability
  - CAN bus integration
  - Voice communication support
- **Applications**: Advanced fleet management

#### Modular Configurations
Possible device configurations include:
- **Connectivity**: Wi-Fi, Bluetooth, CAN
- **Communication**: Voice capability
- **Identification**: Driver ID systems
- **Sensors**: Temperature, fuel, environmental
- **I/O**: Digital inputs/outputs expansion

### Technical Specifications

#### Communication
- **Cellular**: 2G/3G/4G with quad-band GSM
- **Protocol**: Configurable text-based messaging
- **Backup**: Multiple network fallback options
- **Security**: Cellular jamming detection

#### Sensor Integration
- **Temperature**: Dallas DS18B20 sensors
- **Fuel**: Analog fuel level monitoring
- **Environmental**: Humidity, voltage monitoring
- **Digital I/O**: 4 inputs, 4 outputs standard
- **CAN Bus**: Vehicle diagnostic integration

#### Power Management
- **Operating Voltage**: 8-32V DC
- **Backup Battery**: Internal lithium backup
- **Power Monitoring**: Input voltage tracking
- **Low Power**: Sleep mode operation

### Temperature Sensor Support

#### Dallas Sensor Integration
StarLink devices support Dallas DS18B20 temperature sensors with:
- **1-Wire Interface**: Multiple sensors per bus
- **Unique ID**: Each sensor has hardware ID
- **Protobuf Encoding**: Base64 encoded sensor data
- **Precision**: 0.1°C resolution
- **Additional Data**: Humidity, voltage, state

#### Sensor Data Format (TD1/TD2)
Temperature data is encoded as protobuf and base64 encoded:
```protobuf
message mEventReport_TDx {
  required uint32 SensorNumber = 1;
  optional string SensorID = 3;
  optional sint32 Temperature = 4;  // ×10
  optional uint32 Humidity = 5;     // ×10
  optional uint32 Voltage = 9;      // ×1000
}
```

### Configuration Examples

#### Basic Fleet Tracking
```
Format: #EDT#,#EID#,#PDT#,#LAT#,#LONG#,#SPD#,#HEAD#,#ODO#,#IGN#,#VIN#,#VBAT#
```

#### Advanced Diagnostics
```
Format: #EDT#,#EID#,#PDT#,#LAT#,#LONG#,#SPD#,#HEAD#,#ODO#,#IN1#,#IN2#,#IN3#,#IN4#,#OUT1#,#OUT2#,#OUT3#,#OUT4#,#LAC#,#CID#,#VIN#,#VBAT#,#DEST#,#IGN#,#ENG#
```

#### Temperature Monitoring
```
Format: #EDT#,#EID#,#PDT#,#LAT#,#LONG#,#SPD#,#HEAD#,#ODO#,#TVI#,#TD1#,#TD2#,#CFL#
```

### Quality & Certifications
- **CE Mark**: European conformity
- **FCC**: US electromagnetic compatibility
- **IC**: Canadian certification
- **RoHS**: Environmental compliance
- **Automotive**: Vehicle integration standards

## Common Applications

- **Fleet Management**: Commercial vehicle tracking
- **Cold Chain**: Temperature-controlled transport
- **Construction**: Heavy equipment monitoring
- **Agriculture**: Farm vehicle and equipment tracking
- **Logistics**: Supply chain visibility
- **Emergency Services**: First responder vehicles
- **Public Transport**: Bus and taxi monitoring
- **Rental Vehicles**: Usage tracking and security
- **Asset Protection**: High-value equipment monitoring
- **Environmental Monitoring**: Remote sensor networks

## Protocol Implementation

### Message Parsing
1. Verify header "$SLU"
2. Extract device ID, type, and index
3. Split data fields by comma
4. Apply configured field format
5. Parse coordinates and timestamps
6. Validate checksum

### Field Processing
1. Match data values to format tags
2. Apply appropriate data type conversion
3. Parse coordinates using +/-DDMM.MMMM format
4. Decode timestamps based on configured format
5. Process protobuf-encoded sensor data

### Event Handling
1. Extract event ID from #EID# field
2. Map event codes to alarm types
3. Set ignition state for events 24/25
4. Process RFID data for event 20
5. Handle driver identification

### Coordinate Conversion
```
Function parseCoordinate(value):
  minutesIndex = position of '.' - 2
  degrees = parse(value[1:minutesIndex])
  minutes = parse(value[minutesIndex:]) / 60
  result = degrees + minutes
  return value[0] == '+' ? result : -result
```

## Market Position

### Technology Advantages
- **Flexibility**: Configurable field formats
- **Modularity**: Expandable hardware platform
- **Compatibility**: Platform-agnostic design
- **Reliability**: Proven in harsh environments

### Competitive Features
- **Sensor Integration**: Built-in Dallas sensor support
- **Jamming Detection**: Cellular security monitoring
- **Fuel Monitoring**: Advanced theft detection
- **Driver ID**: RFID/iButton integration

## Traccar Configuration

```xml
<entry key='starlink.port'>5084</entry>
<entry key='starlink.format'>#EDT#,#EID#,#PDT#,#LAT#,#LONG#,#SPD#,#HEAD#,#ODO#,#IN1#,#IN2#,#IN3#,#IN4#,#OUT1#,#OUT2#,#OUT3#,#OUT4#,#LAC#,#CID#,#VIN#,#VBAT#,#DEST#,#IGN#,#ENG#</entry>
<entry key='starlink.dateFormat'>yyMMddHHmmss</entry>
```

### Device-Specific Configuration
Format and date format can be configured per device using device attributes.

### Protocol Features
- **Text-Based Format**: Human-readable ASCII messages
- **Configurable Fields**: Flexible data structure
- **Comprehensive Diagnostics**: Full vehicle monitoring
- **Sensor Integration**: Temperature and environmental sensors
- **Real-Time Alarms**: Event-driven notifications

The StarLink protocol represents a flexible approach to GPS tracking, combining configurable messaging with comprehensive vehicle diagnostics and sensor integration for diverse fleet management applications.