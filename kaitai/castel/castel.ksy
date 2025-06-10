meta:
  id: castel
  title: Castel GPS Tracker Protocol
  file-extension: castel
  endian: le
  encoding: ASCII

seq:
  - id: message
    type: castel_frame

instances:
  # PID length mapping function based on Java implementation
  get_pid_length:
    params:
      - id: pid
        type: u1
    value: |
      # 1-byte PIDs
      (pid == 0x04 or pid == 0x05 or pid == 0x06 or pid == 0x07 or pid == 0x08 or pid == 0x09 or 
       pid == 0x0b or pid == 0x0d or pid == 0x0e or pid == 0x0f or pid == 0x11 or pid == 0x12 or 
       pid == 0x13 or pid == 0x1c or pid == 0x1d or pid == 0x1e or pid == 0x2c or pid == 0x2d or 
       pid == 0x2e or pid == 0x2f or pid == 0x30 or pid == 0x33 or pid == 0x43 or pid == 0x45 or 
       pid == 0x46 or pid == 0x47 or pid == 0x48 or pid == 0x49 or pid == 0x4a or pid == 0x4b or 
       pid == 0x4c or pid == 0x51 or pid == 0x52 or pid == 0x5a) ? 1 :
      # 2-byte PIDs  
      (pid == 0x02 or pid == 0x03 or pid == 0x0a or pid == 0x0c or pid == 0x10 or pid == 0x14 or 
       pid == 0x15 or pid == 0x16 or pid == 0x17 or pid == 0x18 or pid == 0x19 or pid == 0x1a or 
       pid == 0x1b or pid == 0x1f or pid == 0x21 or pid == 0x22 or pid == 0x23 or pid == 0x31 or 
       pid == 0x32 or pid == 0x3c or pid == 0x3d or pid == 0x3e or pid == 0x3f or pid == 0x42 or 
       pid == 0x44 or pid == 0x4d or pid == 0x4e or pid == 0x50 or pid == 0x53 or pid == 0x54 or 
       pid == 0x55 or pid == 0x56 or pid == 0x57 or pid == 0x58 or pid == 0x59) ? 2 :
      # 4-byte PIDs
      (pid == 0x00 or pid == 0x01 or pid == 0x20 or pid == 0x24 or pid == 0x25 or pid == 0x26 or 
       pid == 0x27 or pid == 0x28 or pid == 0x29 or pid == 0x2a or pid == 0x2b or pid == 0x34 or 
       pid == 0x35 or pid == 0x36 or pid == 0x37 or pid == 0x38 or pid == 0x39 or pid == 0x3a or 
       pid == 0x3b or pid == 0x40 or pid == 0x41 or pid == 0x4f) ? 4 :
      # Default to 1 byte for unknown PIDs
      1

types:
  castel_frame:
    seq:
      - id: header
        type: u2
      - id: length
        type: u2
      - id: version
        type: s1
        if: has_version
      - id: device_id
        size: 20
        type: str
        encoding: ASCII
      - id: message_type
        type: u2
      - id: payload
        size: payload_length
        type:
          switch-on: message_type
          cases:
            0x1001: sc_login
            0x9001: sc_login_response
            0x1002: sc_logout
            0x1003: sc_heartbeat
            0x9003: sc_heartbeat_response
            0x4001: sc_gps_or_cc_login
            0x8001: cc_login_response
            0x4002: sc_pid_data
            0x4003: sc_g_sensor
            0x4004: sc_supported_pid
            0x4005: sc_obd_data
            0x4006: sc_dtcs_passenger
            0x400B: sc_dtcs_commercial
            0x4007: sc_alarm
            0xC007: sc_alarm_response
            0x4008: sc_cell
            0x4009: sc_gps_sleep
            0x400E: sc_fuel
            0x401F: sc_comprehensive
            0x5101: sc_agps_request
            0xA002: sc_query_response
            0xB001: sc_current_location
            0x4206: cc_heartbeat
            0x4583: cc_petrol_control
            0x8206: cc_heartbeat_response
            _: raw_payload
      - id: crc
        type: u2
      - id: footer
        contents: [0x0D, 0x0A]  # \r\n
        
    instances:
      has_version:
        value: 'header == 0x4040'  # @@ header includes version
      payload_length:
        value: 'length - (has_version ? 30 : 29)'  # Total length minus fixed fields
      protocol_version:
        value: 'has_version ? version : (header == 0x2424 ? 0 : -1)'
        
  sc_login:
    seq:
      - id: login_data
        size-eos: true
        
  sc_login_response:
    seq:
      - id: response_code
        type: u1
        
  sc_logout:
    seq: []
    
  sc_heartbeat:
    seq:
      - id: heartbeat_data
        size-eos: true
        
  sc_heartbeat_response:
    seq: []
    
  sc_gps_or_cc_login:
    seq:
      - id: data
        size-eos: true
        type:
          switch-on: '_parent.protocol_version'
          cases:
            3: sc_gps_data
            4: sc_gps_data
            _: cc_login_data
            
  cc_login_response:
    seq:
      - id: response_code
        type: u1
        
  sc_gps_data:
    seq:
      - id: position
        type: position_data
      - id: statistics
        type: statistical_data
        
  cc_login_data:
    seq:
      - id: login_info
        size-eos: true
        
  sc_pid_data:
    seq:
      - id: position
        type: position_data
      - id: statistics
        type: statistical_data
      - id: obd_data
        type: obd_data_block
        
  sc_g_sensor:
    seq:
      - id: position
        type: position_data
      - id: statistics
        type: statistical_data
      - id: x_acceleration
        type: s2
      - id: y_acceleration
        type: s2
      - id: z_acceleration
        type: s2
        
  sc_supported_pid:
    seq:
      - id: position
        type: position_data
      - id: statistics
        type: statistical_data
      - id: supported_pids
        type: obd_supported_pids
        
  sc_obd_data:
    seq:
      - id: position
        type: position_data
      - id: statistics
        type: statistical_data
      - id: obd_data
        type: obd_data_block
        
  sc_dtcs_passenger:
    seq:
      - id: position
        type: position_data
      - id: statistics
        type: statistical_data
      - id: dtc_data
        type: dtc_codes
        
  sc_dtcs_commercial:
    seq:
      - id: position
        type: position_data
      - id: statistics
        type: statistical_data
      - id: dtc_data
        type: dtc_codes
        
  sc_alarm:
    seq:
      - id: position
        type: position_data
      - id: statistics
        type: statistical_data
      - id: alarm_data
        type: alarm_info
        
  sc_alarm_response:
    seq:
      - id: alarm_ack
        type: u2
        
  sc_cell:
    seq:
      - id: position
        type: position_data
      - id: statistics
        type: statistical_data
      - id: cell_data
        type: cellular_info
        
  sc_gps_sleep:
    seq:
      - id: position
        type: position_data
      - id: statistics
        type: statistical_data
        
  sc_fuel:
    seq:
      - id: position
        type: position_data
      - id: statistics
        type: statistical_data
      - id: fuel_data
        type: fuel_info
        
  sc_comprehensive:
    seq:
      - id: position
        type: position_data
      - id: statistics
        type: statistical_data
      - id: tlv_data
        type: tlv_data_block
        size-eos: true
        
  sc_agps_request:
    seq:
      - id: agps_request_data
        size-eos: true
        
  sc_query_response:
    seq:
      - id: query_data
        size-eos: true
        
  sc_current_location:
    seq:
      - id: position
        type: position_data
      - id: statistics
        type: statistical_data
        
  cc_heartbeat:
    seq:
      - id: heartbeat_data
        size-eos: true
        
  cc_petrol_control:
    seq:
      - id: control_command
        type: u1
        
  cc_heartbeat_response:
    seq: []
    
  raw_payload:
    seq:
      - id: data
        size-eos: true
        
  position_data:
    seq:
      - id: year
        type: u1
      - id: month
        type: u1
      - id: day
        type: u1
      - id: hour
        type: u1
      - id: minute
        type: u1
      - id: second
        type: u1
      - id: latitude_raw
        type: u4
      - id: longitude_raw
        type: u4
      - id: speed_raw
        type: u2
      - id: course_raw
        type: u2
      - id: flags
        type: u1
        
    instances:
      latitude:
        value: '(flags & 0x02) == 0 ? -(latitude_raw / 3600000.0) : (latitude_raw / 3600000.0)'
      longitude:
        value: '(flags & 0x01) == 0 ? -(longitude_raw / 3600000.0) : (longitude_raw / 3600000.0)'
      speed_knots:
        value: 'speed_raw * 0.0194384'  # Convert from cm/s to knots
      course_degrees:
        value: 'course_raw * 0.1'
      satellites:
        value: '(flags >> 4) & 0x0F'
      gps_valid:
        value: '(flags & 0x0C) != 0'
        
  statistical_data:
    seq:
      - id: acc_on_time
        type: u4
      - id: utc_time
        type: u4
      - id: odometer
        type: u4
      - id: trip_odometer
        type: u4
      - id: fuel_consumption
        type: u4
      - id: current_fuel_consumption
        type: u2
      - id: status
        type: u4
      - id: reserved
        size: 8
        
  obd_data_block:
    seq:
      - id: pid_count
        type: u1
      - id: pids
        type: obd_pid_entry
        repeat: expr
        repeat-expr: pid_count
        
  obd_pid_entry:
    seq:
      - id: pid_id
        type: u2
      - id: pid_value
        type:
          switch-on: pid_value_length
          cases:
            1: u1
            2: u2
            4: u4
            _: u1
            
    instances:
      pid_value_length:
        value: 'get_pid_length(pid_id & 0xFF)'
        
  obd_supported_pids:
    seq:
      - id: supported_data
        size-eos: true
        
  dtc_codes:
    seq:
      - id: dtc_count
        type: u1
      - id: dtcs
        type: dtc_entry
        repeat: expr
        repeat-expr: dtc_count
        
  dtc_entry:
    seq:
      - id: dtc_code
        type: u4
        
  alarm_info:
    seq:
      - id: alarm_type
        type: u1
      - id: alarm_data
        size-eos: true
        
  cellular_info:
    seq:
      - id: mcc
        type: u2
      - id: mnc
        type: u2
      - id: lac
        type: u2
      - id: cell_id
        type: u4
      - id: signal_strength
        type: u1
        
  fuel_info:
    seq:
      - id: fuel_level
        type: u2
      - id: fuel_consumption
        type: u4
        
  tlv_data_block:
    seq:
      - id: tlv_entries
        type: tlv_entry
        repeat: eos
        
  tlv_entry:
    seq:
      - id: tag
        type: u2
      - id: length
        type: u2
      - id: value
        size: length
        type:
          switch-on: tag
          cases:
            0x0002: tlv_pid_data
            0x0004: tlv_supported_streams
            0x0005: tlv_snapshot_data
            0x0006: tlv_passenger_dtcs
            0x0007: tlv_alarm_data
            0x000B: tlv_commercial_dtcs
            0x0010: tlv_temperature_1
            0x0011: tlv_temperature_2
            0x0012: tlv_temperature_3
            0x0013: tlv_temperature_4
            0x0014: tlv_temperature_5
            0x0020: tlv_power_voltage
            0x0021: tlv_battery_voltage
            _: tlv_raw_data
            
  tlv_pid_data:
    seq:
      - id: obd_data
        type: obd_data_block
        
  tlv_supported_streams:
    seq:
      - id: stream_data
        size-eos: true
        
  tlv_snapshot_data:
    seq:
      - id: snapshot_info
        size-eos: true
        
  tlv_passenger_dtcs:
    seq:
      - id: dtc_data
        type: dtc_codes
        
  tlv_alarm_data:
    seq:
      - id: alarm_info
        type: alarm_info
        
  tlv_commercial_dtcs:
    seq:
      - id: dtc_data
        type: dtc_codes
        
  tlv_temperature_1:
    seq:
      - id: temperature
        type: s2
        
  tlv_temperature_2:
    seq:
      - id: temperature
        type: s2
        
  tlv_temperature_3:
    seq:
      - id: temperature
        type: s2
        
  tlv_temperature_4:
    seq:
      - id: temperature
        type: s2
        
  tlv_temperature_5:
    seq:
      - id: temperature
        type: s2
        
  tlv_power_voltage:
    seq:
      - id: voltage
        type: u2
        
  tlv_battery_voltage:
    seq:
      - id: voltage
        type: u2
        
  tlv_raw_data:
    seq:
      - id: data
        size-eos: true

enums:
  header_type:
    0x4040: version_header    # @@
    0x2424: simple_header     # $$
    
  message_type_enum:
    # SC Protocol Messages
    0x1001: sc_login
    0x9001: sc_login_response
    0x1002: sc_logout
    0x1003: sc_heartbeat
    0x9003: sc_heartbeat_response
    0x4001: sc_gps
    0x4002: sc_pid_data
    0x4003: sc_g_sensor
    0x4004: sc_supported_pid
    0x4005: sc_obd_data
    0x4006: sc_dtcs_passenger
    0x400B: sc_dtcs_commercial
    0x4007: sc_alarm
    0xC007: sc_alarm_response
    0x4008: sc_cell
    0x4009: sc_gps_sleep
    0x400E: sc_fuel
    0x401F: sc_comprehensive
    0x5101: sc_agps_request
    0xA002: sc_query_response
    0xB001: sc_current_location
    # CC Protocol Messages
    0x8001: cc_login_response
    0x4206: cc_heartbeat
    0x4583: cc_petrol_control
    0x8206: cc_heartbeat_response
    
  protocol_version_enum:
    -1: mpip_protocol
    0: cc_protocol
    3: sc_protocol_v3
    4: sc_protocol_v4
    
  alarm_type_enum:
    0x01: sos_alarm
    0x02: overspeed_alarm
    0x03: geofence_alarm
    0x04: power_cut_alarm
    0x05: vibration_alarm
    0x06: accident_alarm
    0x07: low_battery_alarm
    0x08: gps_antenna_alarm
    0x09: device_fault_alarm
    
  tlv_tag_enum:
    0x0002: pid_data
    0x0004: supported_data_streams
    0x0005: snapshot_data
    0x0006: passenger_fault_codes
    0x0007: alarm_data
    0x000B: commercial_fault_codes
    0x0010: temperature_sensor_1
    0x0011: temperature_sensor_2
    0x0012: temperature_sensor_3
    0x0013: temperature_sensor_4
    0x0014: temperature_sensor_5
    0x0020: main_power_voltage
    0x0021: backup_battery_voltage