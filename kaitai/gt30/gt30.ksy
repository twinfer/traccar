meta:
  id: gt30
  title: GT30 GPS Tracker Protocol
  file-extension: gt30
  endian: be
  ks-version: 0.11
  
doc: |
  GT30 GPS tracker protocol implementation supporting real-time vehicle tracking
  with comprehensive telemetry data including GPS positioning, alarm states,
  and various tracking parameters for fleet management applications.
  
  ## PROTOCOL FEATURES:
  
  ### Text Protocol Format:
  - Header: $$ + 4-byte length + 14-byte device ID
  - Message type identifier (4 hex bytes)
  - Optional alarm status indicator
  - GPS data with timestamp and coordinates
  - Speed, course, and altitude information
  - HDOP (Horizontal Dilution of Precision)
  - 4-byte CRC checksum for data integrity
  
  ### Message Structure:
  ```
  $$[length][device_id][type][alarm][time][validity][lat][NS][lon][EW][speed][course][date]|[hdop]|[altitude][checksum]
  ```
  
  ### Supported Features:
  - **Real-time positioning**: GPS coordinates with validity indication
  - **Alarm management**: SOS, low battery, overspeed, geofence alerts
  - **Motion tracking**: Speed and course monitoring
  - **Time synchronization**: Precise timestamp with millisecond resolution
  - **Signal quality**: HDOP values for GPS accuracy assessment
  - **Altitude tracking**: Elevation data for 3D positioning
  
  ## ALARM TYPES:
  - 0x01, 0x02, 0x03: SOS Emergency
  - 0x10: Low Battery Warning
  - 0x11: Overspeed Alert
  - 0x12: Geofence Violation
  
  ## GEOGRAPHICAL COVERAGE:
  Global deployment with strong presence in commercial fleet applications
  
  ## ESTIMATED DEPLOYMENT:
  - Used in various fleet management systems
  - Compatible with standard GPS tracking platforms
  - Popular in logistics and transportation industries

seq:
  - id: header
    contents: "$$"
  - id: length
    type: u2
    doc: Message length in hexadecimal
  - id: device_id
    type: str
    size: 14
    encoding: ASCII
    doc: 14-character device identifier
  - id: message_type
    type: u2
    doc: Message type identifier (4 hex bytes)
  - id: alarm_flag
    type: u1
    if: has_alarm
    doc: Alarm status indicator
  - id: time_hours
    type: u1
    doc: Hours (00-23)
  - id: time_minutes
    type: u1
    doc: Minutes (00-59)
  - id: time_seconds
    type: u1
    doc: Seconds (00-59)
  - id: time_milliseconds
    type: u2
    doc: Milliseconds (000-999)
  - id: comma_1
    contents: ","
  - id: validity
    type: str
    size: 1
    encoding: ASCII
    doc: GPS validity (A=valid, V=invalid)
  - id: comma_2
    contents: ","
  - id: latitude_degrees
    type: str
    terminator: ','
    encoding: ASCII
    doc: Latitude degrees and minutes
  - id: latitude_hemisphere
    type: str
    size: 1
    encoding: ASCII
    doc: N (North) or S (South)
  - id: comma_3
    contents: ","
  - id: longitude_degrees
    type: str
    terminator: ','
    encoding: ASCII
    doc: Longitude degrees and minutes
  - id: longitude_hemisphere
    type: str
    size: 1
    encoding: ASCII
    doc: E (East) or W (West)
  - id: comma_4
    contents: ","
  - id: speed_knots
    type: str
    terminator: ','
    encoding: ASCII
    doc: Speed in knots
  - id: course_degrees
    type: str
    terminator: ','
    encoding: ASCII
    doc: Course over ground in degrees
  - id: date_day
    type: u1
    doc: Day (01-31)
  - id: date_month
    type: u1
    doc: Month (01-12)
  - id: date_year
    type: u1
    doc: Year (last 2 digits)
  - id: separator_1
    contents: "|"
  - id: hdop_value
    type: str
    terminator: '|'
    encoding: ASCII
    doc: Horizontal Dilution of Precision
  - id: altitude_meters
    type: str
    size: 4
    encoding: ASCII
    doc: Altitude in meters (signed)
  - id: checksum
    type: u2
    doc: CRC checksum for data integrity

instances:
  has_alarm:
    value: true  # GT30 protocol typically includes alarm field
  gps_valid:
    value: validity == "A"
  latitude_decimal:
    value: |
      latitude_degrees.to_s.length > 4 ? 
      (latitude_degrees.to_s.substring(0, latitude_degrees.to_s.length - 7).to_f + 
       latitude_degrees.to_s.substring(latitude_degrees.to_s.length - 7).to_f / 60.0) *
      (latitude_hemisphere == "S" ? -1 : 1) : 0.0
  longitude_decimal:
    value: |
      longitude_degrees.to_s.length > 5 ? 
      (longitude_degrees.to_s.substring(0, longitude_degrees.to_s.length - 7).to_f + 
       longitude_degrees.to_s.substring(longitude_degrees.to_s.length - 7).to_f / 60.0) *
      (longitude_hemisphere == "W" ? -1 : 1) : 0.0
  speed_kmh:
    value: speed_knots.to_s.to_f * 1.852
  hdop_float:
    value: hdop_value.to_s.to_f
  altitude_int:
    value: altitude_meters.to_s.to_i
  alarm_type:
    value: |
      has_alarm ? 
      (alarm_flag == 0x01 or alarm_flag == 0x02 or alarm_flag == 0x03 ? "sos" :
       alarm_flag == 0x10 ? "low_battery" :
       alarm_flag == 0x11 ? "overspeed" :
       alarm_flag == 0x12 ? "geofence" : "unknown") : "none"

enums:
  validity_status:
    0x41: valid      # 'A'
    0x56: invalid    # 'V'
    
  hemisphere_ns:
    0x4E: north      # 'N'
    0x53: south      # 'S'
    
  hemisphere_ew:
    0x45: east       # 'E'
    0x57: west       # 'W'
    
  alarm_code:
    0x01: sos_1
    0x02: sos_2
    0x03: sos_3
    0x10: low_battery
    0x11: overspeed
    0x12: geofence_violation