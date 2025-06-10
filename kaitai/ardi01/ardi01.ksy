meta:
  id: ardi01
  title: Ardi01 GPS Tracker Protocol
  file-extension: ardi01
  endian: be
  ks-version: 0.11
  
doc: |
  Ardi01 GPS tracker protocol implementation supporting vehicle tracking and monitoring
  with comprehensive telemetry data including GPS positioning, environmental sensors,
  and system status information for fleet management and asset tracking applications.
  
  ## PROTOCOL FEATURES:
  
  ### Text Protocol Format:
  - Comma-separated values (CSV) format
  - IMEI device identification
  - DateTime with YYYYMMDD HHMMSS format
  - Decimal coordinate system
  - Speed in km/h (converted to knots)
  - Course in degrees (0-360)
  - Altitude in meters (signed)
  - Satellite count for GPS validity
  - Event codes for various triggers
  - Battery level monitoring
  - Temperature sensor support
  
  ### Message Structure:
  ```
  [imei],[yyyymmdd],[hhmmss],[longitude],[latitude],[speed],[course],[altitude],[satellites],[event],[battery],[temperature]
  ```
  
  ### Supported Features:
  - **Real-time positioning**: GPS coordinates in decimal degrees
  - **GPS quality**: Satellite-based validity (3+ satellites required)
  - **Motion tracking**: Speed and heading monitoring
  - **Environmental monitoring**: Temperature sensor support
  - **System monitoring**: Battery level tracking
  - **Event management**: Configurable event codes
  - **3D positioning**: Altitude data for elevation tracking
  
  ## GPS VALIDITY:
  Position validity is determined by satellite count:
  - Valid: 3 or more satellites
  - Invalid: Less than 3 satellites
  
  ## GEOGRAPHICAL COVERAGE:
  Global deployment suitable for various tracking applications
  
  ## ESTIMATED DEPLOYMENT:
  - Fleet management systems
  - Asset tracking applications
  - Environmental monitoring solutions
  - Personal tracking devices

seq:
  - id: imei
    type: str
    terminator: ','
    encoding: ASCII
    doc: Device IMEI identifier
  - id: date_year
    type: str
    size: 4
    encoding: ASCII
    doc: Year (YYYY format)
  - id: date_month
    type: str
    size: 2
    encoding: ASCII
    doc: Month (MM format)
  - id: date_day
    type: str
    size: 2
    encoding: ASCII
    doc: Day (DD format)
  - id: time_hours
    type: str
    size: 2
    encoding: ASCII
    doc: Hours (HH format)
  - id: time_minutes
    type: str
    size: 2
    encoding: ASCII
    doc: Minutes (MM format)
  - id: time_seconds
    type: str
    size: 2
    encoding: ASCII
    doc: Seconds (SS format)
  - id: comma_1
    contents: ","
  - id: longitude
    type: str
    terminator: ','
    encoding: ASCII
    doc: Longitude in decimal degrees (signed)
  - id: latitude
    type: str
    terminator: ','
    encoding: ASCII
    doc: Latitude in decimal degrees (signed)
  - id: speed_kmh
    type: str
    terminator: ','
    encoding: ASCII
    doc: Speed in kilometers per hour
  - id: course_degrees
    type: str
    terminator: ','
    encoding: ASCII
    doc: Course over ground in degrees
  - id: altitude_meters
    type: str
    terminator: ','
    encoding: ASCII
    doc: Altitude in meters (signed)
  - id: satellite_count
    type: str
    terminator: ','
    encoding: ASCII
    doc: Number of satellites in view
  - id: event_code
    type: str
    terminator: ','
    encoding: ASCII
    doc: Event identifier code
  - id: battery_level
    type: str
    terminator: ','
    encoding: ASCII
    doc: Battery level percentage
  - id: temperature
    type: str
    size-eos: true
    encoding: ASCII
    doc: Temperature reading (signed)

instances:
  longitude_decimal:
    value: longitude.to_s.to_f
    doc: Longitude as decimal degrees
  latitude_decimal:
    value: latitude.to_s.to_f
    doc: Latitude as decimal degrees
  speed_knots:
    value: speed_kmh.to_s.to_f / 1.852
    doc: Speed converted to knots
  course_float:
    value: course_degrees.to_s.to_f
    doc: Course as floating point degrees
  altitude_float:
    value: altitude_meters.to_s.to_f
    doc: Altitude as floating point meters
  satellites:
    value: satellite_count.to_s.to_i
    doc: Satellite count as integer
  gps_valid:
    value: satellites >= 3
    doc: GPS validity based on satellite count
  event_id:
    value: event_code.to_s.to_i
    doc: Event code as integer
  battery_percent:
    value: battery_level.to_s.to_i
    doc: Battery level as percentage
  temperature_celsius:
    value: temperature.to_s.to_f
    doc: Temperature in Celsius
  datetime_string:
    value: |
      date_year + "-" + date_month + "-" + date_day + " " + 
      time_hours + ":" + time_minutes + ":" + time_seconds
    doc: Combined date and time string
    
enums:
  gps_validity:
    0: invalid
    1: valid
    
  common_events:
    0: normal_report
    1: sos_alarm
    2: power_on
    3: power_off
    4: low_battery
    5: geofence_enter
    6: geofence_exit
    7: overspeed
    8: harsh_acceleration
    9: harsh_braking
    10: panic_button