meta:
  id: huabao
  title: Huabao JT/T 808 GPS Tracker Protocol
  file-extension: huabao
  endian: be

seq:
  - id: message
    type:
      switch-on: first_byte
      cases:
        0x7E: standard_frame
        0xE7: alternative_frame
        0x28: text_response  # '(' character
        _: unknown_format

types:
  standard_frame:
    seq:
      - id: start_delimiter
        contents: [0x7E]
      - id: escaped_content
        type: escaped_data
        
  alternative_frame:
    seq:
      - id: start_delimiter
        contents: [0xE7]
      - id: escaped_content
        type: escaped_data_alt
        
  text_response:
    seq:
      - id: opening_paren
        contents: [0x28]  # '('
      - id: content
        type: str
        encoding: ASCII
        terminator: 0x29  # ')'
        
  unknown_format:
    seq:
      - id: data
        size-eos: true
        
  escaped_data:
    seq:
      - id: raw_data
        size-eos: true
    instances:
      unescaped_data:
        value: 'unescape_standard(raw_data)'
      message_content:
        type: message_frame
        io: '_io_from_bytes(unescaped_data)'
        
  escaped_data_alt:
    seq:
      - id: raw_data
        size-eos: true
    instances:
      unescaped_data:
        value: 'unescape_alternative(raw_data)'
      message_content:
        type: message_frame
        io: '_io_from_bytes(unescaped_data)'
        
  message_frame:
    seq:
      - id: message_type
        type: u2
      - id: attributes
        type: u2
      - id: device_id
        size: device_id_length
      - id: sequence_number
        type: u2
        if: has_sequence_number
      - id: data
        size: data_length
      - id: checksum
        type: u1
      - id: end_delimiter
        type: u1
        
    instances:
      data_length:
        value: 'attributes & 0x3FF'
      is_fragmented:
        value: '(attributes & 0x2000) != 0'
      has_encryption:
        value: '(attributes & 0x400) != 0'
      has_sequence_number:
        value: 'message_type == 0x0200 or message_type == 0x0704 or message_type == 0x0900'
      device_id_length:
        value: 'end_delimiter == 0xE7 ? 7 : 6'
      parsed_data:
        type:
          switch-on: message_type
          cases:
            0x0001: terminal_response
            0x0002: heartbeat
            0x0100: terminal_register
            0x0102: terminal_auth
            0x0200: location_report
            0x0210: location_batch_type2
            0x0704: location_batch
            0x0900: transparent_data
            0x2070: acceleration_data
            0x5501: location_report_type2
            0x5502: location_report_blind
            0x8001: general_response
            0x8100: register_response
            0x8103: configuration_params
            0x8105: terminal_control
            0x8109: time_sync_response
            0x8300: text_message
            _: raw_data
        io: '_io_from_bytes(data)'
        
  terminal_response:
    seq:
      - id: response_sequence
        type: u2
      - id: response_message_type
        type: u2
      - id: result
        type: u1
        
  heartbeat:
    seq: []
    
  terminal_register:
    seq:
      - id: province_id
        type: u2
      - id: city_id
        type: u2
      - id: manufacturer_id
        size: 5
      - id: device_model
        size: 20
      - id: device_id
        size: 7
      - id: plate_color
        type: u1
      - id: plate_number
        type: str
        encoding: GBK
        size-eos: true
        
  terminal_auth:
    seq:
      - id: auth_code
        type: str
        encoding: ASCII
        size-eos: true
        
  location_report:
    seq:
      - id: alarm_flags
        type: u4
      - id: status_flags
        type: u4
      - id: latitude
        type: u4
      - id: longitude
        type: u4
      - id: altitude
        type: u2
      - id: speed
        type: u2
      - id: course
        type: u2
      - id: timestamp
        type: bcd_time
      - id: extensions
        type: extension_list
        size-eos: true
        
  location_batch:
    seq:
      - id: location_count
        type: u2
      - id: location_type
        type: u1
      - id: locations
        type: batch_location
        repeat: expr
        repeat-expr: location_count
        
  batch_location:
    seq:
      - id: length
        type: u2
      - id: data
        type: location_report
        size: length
        
  location_batch_type2:
    seq:
      - id: location_count
        type: u2
      - id: locations
        type: location_report_type2
        repeat: expr
        repeat-expr: location_count
        
  location_report_type2:
    seq:
      - id: alarm_flags
        type: u4
      - id: status_flags
        type: u4
      - id: latitude
        type: u4
      - id: longitude
        type: u4
      - id: altitude
        type: u2
      - id: speed
        type: u2
      - id: course
        type: u2
      - id: timestamp
        type: bcd_time
        
  location_report_blind:
    seq:
      - id: status_flags
        type: u4
      - id: latitude
        type: u4
      - id: longitude
        type: u4
      - id: altitude
        type: u2
      - id: speed
        type: u2
      - id: course
        type: u2
      - id: timestamp
        type: bcd_time
      - id: extensions
        type: extension_list
        size-eos: true
        
  transparent_data:
    seq:
      - id: transparent_type
        type: u1
      - id: content
        size-eos: true
        
  acceleration_data:
    seq:
      - id: samples
        type: acceleration_sample
        repeat: eos
        
  acceleration_sample:
    seq:
      - id: x_axis
        type: s2
      - id: y_axis
        type: s2
      - id: z_axis
        type: s2
      - id: timestamp
        type: u4
        
  general_response:
    seq:
      - id: response_sequence
        type: u2
      - id: response_message_type
        type: u2
      - id: result
        type: u1
        
  register_response:
    seq:
      - id: result
        type: u1
      - id: auth_code
        type: str
        encoding: ASCII
        size-eos: true
        if: result == 0
        
  configuration_params:
    seq:
      - id: parameter_count
        type: u1
      - id: parameters
        type: config_parameter
        repeat: expr
        repeat-expr: parameter_count
        
  config_parameter:
    seq:
      - id: param_id
        type: u4
      - id: param_length
        type: u1
      - id: param_value
        size: param_length
        
  terminal_control:
    seq:
      - id: command_type
        type: u1
      - id: command_data
        size-eos: true
        
  time_sync_response:
    seq:
      - id: current_time
        type: bcd_time
        
  text_message:
    seq:
      - id: flags
        type: u1
      - id: message_text
        type: str
        encoding: GBK
        size-eos: true
        
  raw_data:
    seq:
      - id: data
        size-eos: true
        
  bcd_time:
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
        
  extension_list:
    seq:
      - id: extensions
        type: extension_field
        repeat: eos
        
  extension_field:
    seq:
      - id: type
        type: u1
      - id: length
        type: u1
      - id: data
        size: length
        type:
          switch-on: type
          cases:
            0x01: odometer_data
            0x02: fuel_data
            0x30: rssi_data
            0x31: satellite_data
            0x51: temperature_data
            0x56: battery_level_data
            0x69: battery_voltage_data
            0x80: obd_data
            0xEB: network_data
            0xF3: advanced_obd_data
            _: raw_extension_data
            
  odometer_data:
    seq:
      - id: odometer
        type: u4
        
  fuel_data:
    seq:
      - id: fuel_level
        type: u2
        
  rssi_data:
    seq:
      - id: rssi
        type: u1
        
  satellite_data:
    seq:
      - id: satellite_count
        type: u1
        
  temperature_data:
    seq:
      - id: temperatures
        type: s2
        repeat: expr
        repeat-expr: '_parent.length / 2'
        
  battery_level_data:
    seq:
      - id: battery_level
        type: u1
        
  battery_voltage_data:
    seq:
      - id: battery_voltage
        type: u2
        
  obd_data:
    seq:
      - id: obd_values
        size-eos: true
        
  network_data:
    seq:
      - id: network_type
        type: u1
      - id: data_content
        size-eos: true
        type:
          switch-on: network_type
          cases:
            0x01: cell_tower_data
            0x02: wifi_data
            _: raw_network_data
            
  cell_tower_data:
    seq:
      - id: mcc
        type: u2
      - id: mnc
        type: u2
      - id: lac
        type: u2
      - id: cell_id
        type: u4
      - id: rssi
        type: u1
        
  wifi_data:
    seq:
      - id: wifi_count
        type: u1
      - id: wifi_aps
        type: wifi_access_point
        repeat: expr
        repeat-expr: wifi_count
        
  wifi_access_point:
    seq:
      - id: mac_address
        size: 6
      - id: rssi
        type: u1
        
  advanced_obd_data:
    seq:
      - id: obd_fields
        size-eos: true
        
  raw_extension_data:
    seq:
      - id: data
        size-eos: true
        
  raw_network_data:
    seq:
      - id: data
        size-eos: true

enums:
  message_type_enum:
    0x0001: terminal_general_response
    0x0002: heartbeat
    0x0100: terminal_register
    0x0102: terminal_authentication
    0x0200: location_report
    0x0210: location_batch_type2
    0x0704: location_batch
    0x0900: transparent_data
    0x2070: acceleration_data
    0x5501: location_report_type2
    0x5502: location_report_blind
    0x8001: general_response
    0x8100: terminal_register_response
    0x8103: configuration_parameters
    0x8105: terminal_control
    0x8109: time_sync_response
    0x8300: send_text_message
    
  alarm_type:
    0x00000001: emergency_button
    0x00000002: overspeed
    0x00000004: fatigue_driving
    0x00000008: dangerous_driving
    0x00000010: gnss_module_failure
    0x00000020: gnss_antenna_disconnected
    0x00000040: gnss_antenna_short_circuit
    0x00000080: terminal_main_power_undervoltage
    0x00000100: terminal_main_power_disconnected
    0x00000200: lcd_failure
    0x00000400: tts_module_failure
    0x00000800: camera_failure
    0x00010000: cumulative_driving_timeout
    0x00020000: parked_timeout
    0x00040000: entering_restricted_area
    0x00080000: leaving_restricted_area
    0x00100000: entering_route
    0x00200000: leaving_route
    0x00400000: insufficient_driving_time
    0x00800000: route_deviation
    0x01000000: vehicle_vss_failure
    0x02000000: vehicle_fuel_abnormal
    0x04000000: vehicle_stolen
    0x08000000: vehicle_illegal_ignition
    0x10000000: vehicle_illegal_displacement
    0x20000000: collision_rollover_alarm
    0x40000000: rollover_alarm
    0x80000000: illegal_door_opening