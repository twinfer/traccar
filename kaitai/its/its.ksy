meta:
  id: its
  title: ITS GPS Tracker Protocol (Intelligent Tracking System)
  file-extension: its
  endian: be
  ks-version: 0.11
  
doc: |
  ITS (Intelligent Tracking System) GPS tracker protocol implementation supporting
  comprehensive vehicle tracking with advanced telemetry including GPS positioning,
  cellular network information, accelerometer data, and extensive system monitoring
  for professional fleet management and vehicle tracking applications.
  
  ## PROTOCOL FEATURES:
  
  ### Text Protocol Format:
  - Dollar sign ($) delimiter-based messages
  - Comma-separated fields with complex nested structure
  - Support for real-time and historical data modes
  - Advanced cellular network information (MCC, MNC, LAC, CID)
  - Multi-format coordinate encoding (DEG_HEM)
  - Comprehensive alarm and event management
  - Command response capability (ENGINE_STOP, ENGINE_RESUME)
  
  ### Message Structure:
  ```
  $[preamble],[event],[vendor],[firmware],[status],[event],[history],[imei],[status_code],[date],[time],[validity],[coordinates],[motion],[sensors],[io],[cellular],[extended_data]*
  ```
  
  ### Supported Features:
  - **Real-time/Historical**: Live tracking and data replay modes
  - **Advanced positioning**: GPS with PDOP/HDOP quality metrics
  - **Cellular triangulation**: Multiple cell tower information
  - **Motion analysis**: Speed, course, acceleration, tilt sensors
  - **System monitoring**: Ignition, charging, power, battery levels
  - **Digital I/O**: Multiple input/output states
  - **Event management**: Comprehensive alarm and trigger system
  - **Emergency features**: SOS, panic button, tampering detection
  - **Fleet management**: Odometer, fuel monitoring, driver behavior
  
  ## ALARM TYPES:
  - WD, EA: SOS Emergency
  - BL: Low Battery
  - HB: Harsh Braking
  - HA: Harsh Acceleration  
  - RT: Rapid Turns/Cornering
  - OS: Overspeed
  - TA: Tampering
  - BD: Power Cut
  - BR: Power Restored
  - IN: Ignition On
  - IF: Ignition Off
  
  ## GEOGRAPHICAL COVERAGE:
  Global deployment with advanced cellular network integration
  
  ## ESTIMATED DEPLOYMENT:
  - Professional fleet management systems
  - Emergency vehicle tracking
  - High-value asset monitoring
  - Commercial vehicle telematics

seq:
  - id: start_delimiter
    contents: "$"
  - id: preamble
    type: str
    terminator: ','
    encoding: ASCII
    doc: Message preamble (may include routing info)
  - id: event_field
    type: str
    terminator: ','
    encoding: ASCII
    doc: Event identifier field
  - id: vendor_info
    type: str
    terminator: ','
    encoding: ASCII
    if: has_vendor_info
    doc: Vendor identification
  - id: firmware_version
    type: str
    terminator: ','
    encoding: ASCII
    if: has_firmware_info
    doc: Firmware version string
  - id: status_code
    type: str
    terminator: ','
    encoding: ASCII
    doc: Device status code (2 characters)
  - id: event_number
    type: str
    terminator: ','
    encoding: ASCII
    if: has_event_number
    doc: Numeric event identifier
  - id: history_flag
    type: str
    terminator: ','
    encoding: ASCII
    doc: L (Live) or H (Historical) data
  - id: imei
    type: str
    terminator: ','
    encoding: ASCII
    doc: 15-digit IMEI device identifier
  - id: secondary_status
    type: str
    terminator: ','
    encoding: ASCII
    if: has_secondary_status
    doc: Secondary status field
  - id: vehicle_registration
    type: str
    terminator: ','
    encoding: ASCII
    if: has_vehicle_reg
    doc: Vehicle registration information
  - id: validity_flag
    type: str
    terminator: ','
    encoding: ASCII
    if: has_validity_flag
    doc: GPS validity indicator (0/1)
  - id: date_day
    type: str
    size: 2
    encoding: ASCII
    doc: Day (DD)
  - id: date_month
    type: str
    size: 2
    encoding: ASCII
    doc: Month (MM)
  - id: date_year
    type: str
    size: 4
    encoding: ASCII
    doc: Year (YYYY)
  - id: time_hours
    type: str
    size: 2
    encoding: ASCII
    doc: Hours (HH)
  - id: time_minutes
    type: str
    size: 2
    encoding: ASCII
    doc: Minutes (MM)
  - id: time_seconds
    type: str
    size: 2
    encoding: ASCII
    doc: Seconds (SS)
  - id: comma_time
    contents: ","
  - id: gps_validity
    type: str
    terminator: ','
    encoding: ASCII
    if: has_gps_validity
    doc: GPS validity (0/1/A/V)
  - id: latitude
    type: str
    terminator: ','
    encoding: ASCII
    doc: Latitude in degrees.minutes format
  - id: latitude_hemisphere
    type: str
    terminator: ','
    encoding: ASCII
    doc: N (North) or S (South)
  - id: longitude
    type: str
    terminator: ','
    encoding: ASCII
    doc: Longitude in degrees.minutes format
  - id: longitude_hemisphere
    type: str
    terminator: ','
    encoding: ASCII
    doc: E (East) or W (West)
  - id: speed_kmh
    type: str
    terminator: ','
    encoding: ASCII
    if: has_motion_data
    doc: Speed in km/h
  - id: course_degrees
    type: str
    terminator: ','
    encoding: ASCII
    if: has_motion_data
    doc: Course over ground in degrees
  - id: satellite_count
    type: str
    terminator: ','
    encoding: ASCII
    if: has_motion_data
    doc: Number of satellites in view
  - id: altitude_meters
    type: str
    terminator: ','
    encoding: ASCII
    if: has_extended_gps
    doc: Altitude in meters
  - id: pdop_value
    type: str
    terminator: ','
    encoding: ASCII
    if: has_extended_gps
    doc: Position Dilution of Precision
  - id: hdop_value
    type: str
    terminator: ','
    encoding: ASCII
    if: has_extended_gps
    doc: Horizontal Dilution of Precision
  - id: operator_name
    type: str
    terminator: ','
    encoding: ASCII
    if: has_extended_gps
    doc: Cellular operator name
  - id: ignition_state
    type: str
    terminator: ','
    encoding: ASCII
    if: has_extended_gps
    doc: Ignition status (0/1)
  - id: charging_state
    type: str
    terminator: ','
    encoding: ASCII
    if: has_extended_gps
    doc: Charging status (0/1)
  - id: power_voltage
    type: str
    terminator: ','
    encoding: ASCII
    if: has_extended_gps
    doc: Power supply voltage
  - id: battery_voltage
    type: str
    terminator: ','
    encoding: ASCII
    if: has_extended_gps
    doc: Battery voltage
  - id: emergency_state
    type: str
    terminator: ','
    encoding: ASCII
    if: has_extended_gps
    doc: Emergency button status (0/1)
  - id: cellular_info
    type: str
    terminator: ','
    encoding: ASCII
    if: has_extended_gps
    doc: Cellular network information (MCC,MNC,LAC,CID,Signal)
  - id: input_states
    type: str
    terminator: ','
    encoding: ASCII
    if: has_extended_gps
    doc: Digital input states (4-bit binary)
  - id: output_states
    type: str
    terminator: ','
    encoding: ASCII
    if: has_extended_gps
    doc: Digital output states (2-bit binary)
  - id: extended_data
    type: str
    terminator: '*'
    encoding: ASCII
    if: has_extended_data
    doc: Extended sensor and telemetry data
  - id: end_delimiter
    contents: "*"

instances:
  has_vendor_info:
    value: preamble.length == 0 or not preamble.starts_with("01")
  has_firmware_info:
    value: has_vendor_info
  has_event_number:
    value: status_code.length > 0 and status_code.to_s.matches("[0-9A-F]+")
  has_secondary_status:
    value: true  # Usually present in ITS protocol
  has_vehicle_reg:
    value: false  # Optional field
  has_validity_flag:
    value: true  # Usually present
  has_gps_validity:
    value: true  # GPS validity field
  has_motion_data:
    value: true  # Speed, course, satellites typically present
  has_extended_gps:
    value: true  # Extended GPS data usually present
  has_extended_data:
    value: true  # Extended sensor data
  is_historical:
    value: history_flag == "H"
  is_live:
    value: history_flag == "L"
  gps_valid:
    value: |
      (has_validity_flag and validity_flag == "1") or
      (has_gps_validity and (gps_validity == "1" or gps_validity == "A"))
  latitude_decimal:
    value: |
      latitude.to_s.length > 4 ?
      (latitude.to_s.substring(0, latitude.to_s.index(".") - 2).to_f +
       latitude.to_s.substring(latitude.to_s.index(".") - 2).to_f / 60.0) *
      (latitude_hemisphere == "S" ? -1 : 1) : 0.0
  longitude_decimal:
    value: |
      longitude.to_s.length > 5 ?
      (longitude.to_s.substring(0, longitude.to_s.index(".") - 2).to_f +
       longitude.to_s.substring(longitude.to_s.index(".") - 2).to_f / 60.0) *
      (longitude_hemisphere == "W" ? -1 : 1) : 0.0
  speed_knots:
    value: has_motion_data ? speed_kmh.to_s.to_f / 1.852 : 0.0
  course_float:
    value: has_motion_data ? course_degrees.to_s.to_f : 0.0
  satellites:
    value: has_motion_data ? satellite_count.to_s.to_i : 0
  altitude_float:
    value: has_extended_gps ? altitude_meters.to_s.to_f : 0.0
  pdop_float:
    value: has_extended_gps ? pdop_value.to_s.to_f : 0.0
  hdop_float:
    value: has_extended_gps ? hdop_value.to_s.to_f : 0.0
  ignition_on:
    value: has_extended_gps ? ignition_state == "1" : false
  charging_active:
    value: has_extended_gps ? charging_state == "1" : false
  power_volts:
    value: has_extended_gps ? power_voltage.to_s.to_f : 0.0
  battery_volts:
    value: has_extended_gps ? battery_voltage.to_s.to_f : 0.0
  emergency_active:
    value: has_extended_gps ? emergency_state == "1" : false
  datetime_string:
    value: |
      date_year + "-" + date_month + "-" + date_day + " " +
      time_hours + ":" + time_minutes + ":" + time_seconds
  alarm_type:
    value: |
      (status_code == "WD" or status_code == "EA") ? "sos" :
      status_code == "BL" ? "low_battery" :
      status_code == "HB" ? "harsh_braking" :
      status_code == "HA" ? "harsh_acceleration" :
      status_code == "RT" ? "rapid_turn" :
      status_code == "OS" ? "overspeed" :
      status_code == "TA" ? "tampering" :
      status_code == "BD" ? "power_cut" :
      status_code == "BR" ? "power_restored" :
      status_code == "IN" ? "ignition_on" :
      status_code == "IF" ? "ignition_off" : "normal"

enums:
  validity_status:
    0x30: invalid    # '0'
    0x31: valid      # '1'
    0x41: valid      # 'A'
    0x56: invalid    # 'V'
    
  hemisphere_ns:
    0x4E: north      # 'N'
    0x53: south      # 'S'
    
  hemisphere_ew:
    0x45: east       # 'E'
    0x57: west       # 'W'
    
  history_mode:
    0x4C: live       # 'L'
    0x48: historical # 'H'
    
  alarm_codes:
    # Emergency alarms
    wd: sos_emergency
    ea: emergency_alarm
    emr: emergency_type
    
    # System alarms
    bl: low_battery
    bd: power_cut
    br: power_restored
    ta: tampering
    
    # Motion alarms
    hb: harsh_braking
    ha: harsh_acceleration
    rt: rapid_turn
    os: overspeed
    
    # Status indicators
    in: ignition_on
    if: ignition_off
    
  digital_states:
    0: inactive
    1: active
    2: undefined