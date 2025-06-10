meta:
  id: dway
  title: Dway GPS Tracker Protocol
  file-extension: dway
  endian: be
  ks-version: 0.11
  
doc: |
  Dway GPS tracker protocol implementation supporting vehicle tracking and monitoring
  with comprehensive telemetry data including GPS positioning, digital I/O monitoring,
  analog sensor inputs, and driver identification for fleet management applications.
  
  ## PROTOCOL FEATURES:
  
  ### Text Protocol Format:
  - Header: AA55 + message index + IMEI
  - Message type classification
  - Date and time in YYMMDD HHMMSS format
  - Decimal coordinate system (signed)
  - Speed in km/h (converted to knots)
  - Course in degrees (0-360)
  - Digital input/output states (4-bit binary each)
  - Status flags (variable length binary)
  - Battery voltage monitoring
  - Dual ADC channels for analog sensors
  - Driver identification field
  - Heartbeat mechanism (AA55,HB)
  
  ### Message Structure:
  ```
  AA55,[index],[imei],[type],[yymmdd],[hhmmss],[latitude],[longitude],[altitude],[speed],[course],[input],[output],[flags],[battery],[adc1],[adc2],[driver]
  ```
  
  ### Supported Features:
  - **Real-time positioning**: GPS coordinates in decimal degrees
  - **Digital I/O monitoring**: 4-bit input and output states
  - **Analog sensing**: Dual ADC channels for external sensors
  - **System monitoring**: Battery voltage tracking
  - **Driver management**: Driver identification support
  - **Status flags**: System status and alarm indicators
  - **3D positioning**: Altitude tracking capability
  - **Heartbeat support**: Connection monitoring mechanism
  
  ## HEARTBEAT MECHANISM:
  - Request: AA55,HB
  - Response: 55AA,HB,OK
  
  ## GEOGRAPHICAL COVERAGE:
  Global deployment suitable for fleet management applications
  
  ## ESTIMATED DEPLOYMENT:
  - Fleet management systems
  - Vehicle tracking applications
  - Driver behavior monitoring
  - Asset tracking solutions

seq:
  - id: header
    contents: "AA55,"
  - id: message_index
    type: str
    terminator: ','
    encoding: ASCII
    doc: Message sequence index
  - id: imei
    type: str
    terminator: ','
    encoding: ASCII
    doc: Device IMEI identifier
  - id: message_type
    type: str
    terminator: ','
    encoding: ASCII
    doc: Message type identifier
  - id: date_year
    type: str
    size: 2
    encoding: ASCII
    doc: Year (YY format)
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
  - id: comma_date
    contents: ","
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
  - id: comma_time
    contents: ","
  - id: latitude
    type: str
    terminator: ','
    encoding: ASCII
    doc: Latitude in decimal degrees (signed)
  - id: longitude
    type: str
    terminator: ','
    encoding: ASCII
    doc: Longitude in decimal degrees (signed)
  - id: altitude
    type: str
    terminator: ','
    encoding: ASCII
    doc: Altitude in meters (signed)
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
  - id: input_states
    type: str
    terminator: ','
    encoding: ASCII
    doc: Digital input states (4-bit binary)
  - id: output_states
    type: str
    terminator: ','
    encoding: ASCII
    doc: Digital output states (4-bit binary)
  - id: status_flags
    type: str
    terminator: ','
    encoding: ASCII
    doc: System status flags (variable length binary)
  - id: battery_millivolts
    type: str
    terminator: ','
    encoding: ASCII
    doc: Battery voltage in millivolts
  - id: adc1_millivolts
    type: str
    terminator: ','
    encoding: ASCII
    doc: ADC channel 1 reading in millivolts
  - id: adc2_millivolts
    type: str
    terminator: ','
    encoding: ASCII
    doc: ADC channel 2 reading in millivolts
  - id: driver_id
    type: str
    size-eos: true
    encoding: ASCII
    doc: Driver unique identifier

instances:
  latitude_decimal:
    value: latitude.to_s.to_f
    doc: Latitude as decimal degrees
  longitude_decimal:
    value: longitude.to_s.to_f
    doc: Longitude as decimal degrees
  altitude_meters:
    value: altitude.to_s.to_f
    doc: Altitude as floating point meters
  speed_knots:
    value: speed_kmh.to_s.to_f / 1.852
    doc: Speed converted to knots
  course_float:
    value: course_degrees.to_s.to_f
    doc: Course as floating point degrees
  input_binary:
    value: input_states.to_s.to_i(2)
    doc: Input states as binary integer
  output_binary:
    value: output_states.to_s.to_i(2)
    doc: Output states as binary integer
  status_binary:
    value: status_flags.to_s.to_i(2)
    doc: Status flags as binary integer
  battery_volts:
    value: battery_millivolts.to_s.to_f / 1000.0
    doc: Battery voltage in volts
  adc1_volts:
    value: adc1_millivolts.to_s.to_f / 1000.0
    doc: ADC1 voltage in volts
  adc2_volts:
    value: adc2_millivolts.to_s.to_f / 1000.0
    doc: ADC2 voltage in volts
  message_index_int:
    value: message_index.to_s.to_i
    doc: Message index as integer
  message_type_int:
    value: message_type.to_s.to_i
    doc: Message type as integer
  datetime_string:
    value: |
      "20" + date_year + "-" + date_month + "-" + date_day + " " + 
      time_hours + ":" + time_minutes + ":" + time_seconds
    doc: Combined date and time string
  # Digital input bit states
  input_bit_0:
    value: (input_binary & 0x01) != 0
    doc: Digital input 0 state
  input_bit_1:
    value: (input_binary & 0x02) != 0
    doc: Digital input 1 state
  input_bit_2:
    value: (input_binary & 0x04) != 0
    doc: Digital input 2 state
  input_bit_3:
    value: (input_binary & 0x08) != 0
    doc: Digital input 3 state
  # Digital output bit states
  output_bit_0:
    value: (output_binary & 0x01) != 0
    doc: Digital output 0 state
  output_bit_1:
    value: (output_binary & 0x02) != 0
    doc: Digital output 1 state
  output_bit_2:
    value: (output_binary & 0x04) != 0
    doc: Digital output 2 state
  output_bit_3:
    value: (output_binary & 0x08) != 0
    doc: Digital output 3 state
    
types:
  heartbeat_message:
    seq:
      - id: header
        contents: "AA55,"
      - id: command
        contents: "HB"
    doc: Heartbeat request message
    
  heartbeat_response:
    seq:
      - id: header
        contents: "55AA,"
      - id: command
        contents: "HB,"
      - id: status
        contents: "OK"
    doc: Heartbeat response message

enums:
  digital_state:
    0: inactive
    1: active
    
  message_types:
    0: normal_report
    1: alarm_report
    2: heartbeat
    3: emergency
    4: power_on
    5: power_off
    
  voltage_ranges:
    # Common voltage thresholds for monitoring
    low_battery: 11500     # 11.5V in millivolts
    normal_battery: 12000  # 12.0V in millivolts
    high_battery: 14500    # 14.5V in millivolts