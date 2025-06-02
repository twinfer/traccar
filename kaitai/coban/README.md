# Coban Protocol

The Coban protocol represents a family of budget-friendly GPS tracking devices that use standard text-based communication protocols, primarily GPS103 and TK103. Coban has become synonymous with affordable GPS tracking solutions, offering a wide range of clone and compatible devices that have made GPS tracking accessible to consumers and small businesses worldwide.

## Protocol Overview

**Type:** Text-based with comma-separated values  
**Manufacturer:** Coban Electronics and various Chinese OEMs  
**Primary Use:** Budget vehicle tracking, personal safety, asset monitoring  
**Data Format:** ASCII text with structured field format  
**Compatibility:** GPS103, TK103, GT06 protocols  
**Market Position:** Leading budget tracker brand globally

## Message Structure

### Standard Format
```
[IMEI],[Command],[Data Fields];
```

### Example Messages
```
358348070004631,tracker,150109081816,F,3723.2475,N,12158.3416,W,1.13,0.00,328.31,18;
358348070004631,help_me,150109081816,F,3723.2475,N,12158.3416,W,0.00,0.00;
358348070004631,alarm,move,150109081816,F,3723.2475,N,12158.3416,W,0.00,0.00;
```

### Field Structure
- **IMEI**: Device identifier (15 digits)
- **Command**: Message type (tracker, help_me, alarm, etc.)
- **Data**: Comma-separated fields specific to command type
- **Terminator**: Semicolon (;) message end

## Command Types

### Position Reports
- **tracker**: Regular position update
- **T1**: Periodic position report
- **login**: Device registration/login

### Emergency Messages
- **help_me**: SOS emergency alert
- **alarm**: Various alarm notifications
- **sos**: Panic button activation

### Status Messages
- **heartbeat**: Keep-alive message
- **low_battery**: Battery warning
- **ac_alarm**: Power disconnection

### Vehicle-Specific
- **move**: Movement detection
- **speed**: Overspeed alarm
- **acc**: Ignition status change
- **door**: Door sensor alarm

### Geofencing
- **stockade**: Geofence violation (enter/exit)

## Position Data Format

### GPS Fields (tracker command)
```
YYMMDDHHMMSS,Validity,Latitude,N/S,Longitude,E/W,Speed,Course,Altitude,Battery,Signal
```

### Field Details
- **DateTime**: YYMMDDHHMMSS format
- **Validity**: F (valid GPS) or L (invalid GPS)
- **Latitude**: DDMM.MMMM format
- **Hemisphere**: N (North) or S (South)
- **Longitude**: DDDMM.MMMM format
- **Hemisphere**: E (East) or W (West)
- **Speed**: Kilometers per hour
- **Course**: Degrees (0-360)
- **Altitude**: Meters above sea level
- **Battery**: Battery level indicator
- **Signal**: GSM signal strength

### Coordinate Conversion
```
Decimal = DD + MM.MMMM/60 × Hemisphere_Sign
```
Where Hemisphere_Sign = +1 for N/E, -1 for S/W

## Key Features

- **Budget-Friendly**: Extremely affordable GPS tracking
- **Global Compatibility**: Works with standard protocols
- **SMS Control**: Configuration via text messages
- **Multi-Platform**: Compatible with numerous tracking platforms
- **Clone-Friendly**: Widely replicated by manufacturers
- **Basic Functionality**: Essential tracking features
- **Easy Setup**: Simple configuration process
- **Reliable Communication**: Proven text-based protocol

## Device Identification

### Brand Background
**Coban Electronics**  
- **Market Position**: Budget GPS tracker pioneer
- **Origin**: China-based with global distribution
- **Strategy**: Affordable tracking for mass market
- **Clones**: Widely copied by other manufacturers
- **Compatibility**: Standard protocol compliance

### Global Impact
- **Accessibility**: Made GPS tracking affordable worldwide
- **Market Share**: Significant presence in budget segment
- **Distribution**: Available through multiple channels
- **Support**: Community-driven documentation
- **Platform Support**: Compatible with major tracking software

### Popular Device Models

#### TK103 Series (Classic)
- **TK103A**: Basic vehicle tracker
  - Features: GPS tracking, SMS alerts, basic alarms
  - Power: 12V vehicle power with backup battery
  - Installation: Hardwired installation
  - Applications: Car tracking, fleet management

- **TK103B**: Enhanced version
  - Features: Improved GPS sensitivity, additional alarms
  - Communication: GSM/GPRS quad-band
  - Applications: Commercial vehicle tracking

#### GPS103 Series (Standard)
- **GPS103**: Generic GPS tracker
  - Features: Real-time tracking, geofencing, SOS
  - Form Factor: Compact design
  - Power: Rechargeable lithium battery
  - Applications: Personal tracking, asset monitoring

#### Coban-Branded Models
- **Coban 103**: Basic tracker clone
- **Coban 104**: Enhanced features version
- **Coban 106**: Vehicle-specific model
- **Coban 203**: Personal safety tracker
- **Coban 303**: Motorcycle/bike tracker

#### Compatible Clone Models
- **GT02**: Ultra-compact tracker
- **GT06**: Binary protocol version
- **H02**: Alternative text protocol
- **Various OEM**: Hundreds of compatible devices

### Technical Specifications

#### Communication
- **Cellular**: GSM/GPRS 850/900/1800/1900 MHz
- **Protocols**: GPS103, TK103, GT06 (binary variant)
- **Data**: TCP/UDP over GPRS
- **SMS**: Two-way SMS communication
- **Commands**: AT command compatible

#### Positioning
- **GPS**: L1 C/A code, 1575.42 MHz
- **Sensitivity**: -159 dBm (tracking)
- **Accuracy**: 5-10 meters typical
- **Cold Start**: <45 seconds
- **Hot Start**: <1 second
- **Assisted GPS**: Basic A-GPS support

#### Power Management
- **Vehicle Power**: 9-36V DC input
- **Backup Battery**: 3.7V Li-ion (varies by model)
- **Standby**: 48-72 hours typical
- **Tracking**: 6-12 hours active use
- **Sleep Mode**: Ultra-low power consumption

### SMS Command System

#### Basic Configuration
- **APN Setting**: `APN,[APN_NAME],[USERNAME],[PASSWORD]`
- **Server Setting**: `ADMINIP,[IP_ADDRESS],[PORT]`
- **Tracking Interval**: `T[SECONDS]` (e.g., T30 for 30 seconds)
- **Phone Authorization**: `A[PHONE_NUMBER]`

#### Tracking Commands
- **Single Location**: `G123456` (password + G)
- **Start Tracking**: `T[INTERVAL]123456`
- **Stop Tracking**: `NOTN123456`
- **SOS Numbers**: `1[PHONE_NUMBER]123456`

#### Security Commands
- **Arm**: `ARM123456` (enable alarms)
- **Disarm**: `DISARM123456` (disable alarms)
- **Engine Stop**: `STOP123456` (if relay connected)
- **Engine Resume**: `RESUME123456`

#### Geofencing
- **Set Geofence**: `STOCKADE[LAT],[LON],[RADIUS]123456`
- **Delete Geofence**: `NOSTOCKADE123456`
- **Speed Limit**: `SPEED[KMH]123456`

### Common Applications

#### Vehicle Tracking
- **Personal Cars**: Individual vehicle monitoring
- **Small Fleets**: Budget fleet management
- **Taxi Services**: Driver and vehicle tracking
- **Delivery**: Package and driver monitoring

#### Asset Protection
- **Motorcycle Tracking**: Theft prevention
- **Boat/RV Tracking**: Recreational vehicle monitoring
- **Equipment**: Construction and farm equipment
- **Cargo**: Basic shipment tracking

#### Personal Safety
- **Elderly Monitoring**: Location tracking for seniors
- **Child Safety**: School and activity monitoring
- **Lone Workers**: Basic safety monitoring
- **Emergency Response**: SOS functionality

#### Budget Solutions
- **Developing Markets**: Affordable tracking solutions
- **Small Businesses**: Cost-effective fleet management
- **Personal Use**: DIY tracking projects
- **Backup Systems**: Secondary tracking devices

### Platform Compatibility

#### Major Platforms
- **Traccar**: Full support via GPS103/TK103 protocols
- **GPS-Trace**: Native compatibility
- **GPSWOX**: Extensive Coban device support
- **Navixy**: Multiple Coban models supported
- **RedGPS**: Standard protocol support

#### DIY Platforms
- **OpenGTS**: Open-source compatibility
- **Custom Solutions**: Easy protocol implementation
- **Mobile Apps**: Numerous compatible apps
- **Web Platforms**: Simple integration

### Quality Considerations

#### Advantages
- **Affordability**: Extremely low cost
- **Availability**: Widely available globally
- **Compatibility**: Standard protocol compliance
- **Documentation**: Community support
- **Simplicity**: Easy to understand and implement

#### Limitations
- **Build Quality**: Variable manufacturing quality
- **Accuracy**: Basic GPS performance
- **Features**: Limited advanced capabilities
- **Support**: Minimal manufacturer support
- **Reliability**: Inconsistent across clone devices

### Market Evolution

#### Early Days (2010-2015)
- **Innovation**: Pioneered budget GPS tracking
- **Adoption**: Rapid global market penetration
- **Standards**: Established common protocols
- **Ecosystem**: Created clone manufacturer industry

#### Current Status (2020+)
- **Maturity**: Stable budget tracker market
- **Competition**: Numerous manufacturers and clones
- **Evolution**: Some models adding 4G/IoT features
- **Platform**: Continued compatibility focus

## Protocol Implementation

### Message Parsing
1. Extract IMEI identifier
2. Parse command type
3. Split data fields by comma
4. Validate field count and format
5. Convert coordinates and timestamps

### Position Processing
1. Parse date/time (YYMMDDHHMMSS)
2. Check GPS validity flag (F/L)
3. Convert coordinates from DDMM.MMMM format
4. Extract speed, course, and altitude
5. Process battery and signal information

### Alarm Handling
1. Identify alarm type from command
2. Extract position data if available
3. Map alarm codes to descriptions
4. Generate appropriate notifications
5. Store alarm with context information

### SMS Integration
1. Parse incoming SMS commands
2. Validate authorization codes
3. Execute configuration changes
4. Send response confirmations
5. Update device settings

## Traccar Configuration

### Protocol Selection
```xml
<!-- Most common: GPS103 protocol -->
<entry key='gps103.port'>5001</entry>

<!-- Alternative: TK103 protocol -->
<entry key='tk103.port'>5002</entry>

<!-- Binary variant: GT06 protocol -->
<entry key='gt06.port'>5023</entry>
```

### Device Configuration
Coban devices typically need:
1. **APN Configuration**: Set carrier APN settings
2. **Server Address**: Configure tracking server IP/port
3. **Authorized Numbers**: Set control phone numbers
4. **Tracking Interval**: Configure reporting frequency
5. **Password**: Set device access password

### Protocol Features
- **Text-Based Format**: Human-readable ASCII messages
- **SMS Control**: Complete SMS command system
- **Multi-Protocol**: Compatible with several standards
- **Budget Focus**: Optimized for cost-effectiveness
- **Global Compatibility**: Works worldwide with basic setup

The Coban protocol ecosystem represents the democratization of GPS tracking technology, making vehicle and asset tracking accessible to millions of users worldwide through affordable, reliable, and easy-to-use devices that have become the foundation of the budget GPS tracking market.