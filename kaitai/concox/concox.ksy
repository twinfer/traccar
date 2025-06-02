meta:
  id: concox
  title: Concox GPS Tracker Protocol (GT06 Family)
  license: MIT
  ks-version: 0.11
  endian: be

doc: |
  Concox GPS tracker protocol supporting the GT06 family of devices.
  Uses binary messaging with standard (0x7878) and extended (0x7979) packet formats.
  Compatible with GT06N, GT06E, GT06D and other GT06 series trackers.

seq:
  - id: message
    type: concox_packet

types:
  concox_packet:
    seq:
      - id: start_bits
        type: u2
        doc: Packet start identifier (0x7878 or 0x7979)
      - id: length
        type:
          switch-on: start_bits
          cases:
            0x7878: u1
            0x7979: u2
        doc: Payload length (excluding start, length, and end)
      - id: protocol_number
        type: u1
        enum: protocol_types
        doc: Protocol/message type identifier
      - id: information_content
        size: >-
          (start_bits == 0x7878 ? length - 5 : length - 6)
        type:
          switch-on: protocol_number
          cases:
            protocol_types::login_message: login_info
            protocol_types::gps_positioning: gps_data
            protocol_types::gps_lbs_positioning: gps_lbs_data
            protocol_types::gps_lbs_status: gps_lbs_status_data
            protocol_types::heartbeat_data: heartbeat_data
            protocol_types::string_information: string_info
            protocol_types::alarm_data: alarm_data
            protocol_types::gps_positioning_data: gps_extended_data
            protocol_types::lbs_multiple_cell: lbs_multiple_data
            protocol_types::lbs_wifi: lbs_wifi_data
            protocol_types::lbs_extend_message: lbs_extend_data
            protocol_types::wifi_information: wifi_data
            protocol_types::command_information: command_data
            protocol_types::obd_information: obd_data
            protocol_types::gps_driver_behavior: driver_behavior_data
            _: generic_data
      - id: information_serial_number
        type: u2
        doc: Message sequence number
      - id: error_check
        type: u2
        doc: CRC16-CCITT checksum
      - id: stop_bits
        type: u2
        doc: Packet end marker (0x0D0A)
    instances:
      is_extended_format:
        value: start_bits == 0x7979
      device_id:
        value: >-
          protocol_number == protocol_types::login_message ?
          information_content.as<login_info>.imei_string :
          "unknown"

  login_info:
    seq:
      - id: terminal_id
        size: 8
        doc: Terminal IMEI (BCD encoded, 8 bytes)
      - id: type_identification_code
        type: u2
        doc: Device model identifier
      - id: time_zone_language
        type: u2
        if: _io.eof == false
        doc: Time zone and language settings
    instances:
      imei_string:
        value: bcd_to_string(terminal_id)
      device_model:
        value: type_identification_code

  gps_data:
    seq:
      - id: date_time
        type: datetime_info
      - id: gps_information_length
        type: u1
        doc: Length of GPS information
      - id: positioning_information
        type: positioning_info
    instances:
      timestamp:
        value: date_time.unix_timestamp
      latitude:
        value: positioning_information.latitude
      longitude:
        value: positioning_information.longitude
      valid:
        value: positioning_information.gps_valid

  gps_lbs_data:
    seq:
      - id: date_time
        type: datetime_info
      - id: gps_information_length
        type: u1
      - id: positioning_information
        type: positioning_info
      - id: lbs_information
        type: lbs_info
    instances:
      has_cellular_info:
        value: true

  gps_lbs_status_data:
    seq:
      - id: date_time
        type: datetime_info
      - id: gps_information_length
        type: u1
      - id: positioning_information
        type: positioning_info
      - id: lbs_information
        type: lbs_info
      - id: status_information
        type: status_info

  heartbeat_data:
    seq:
      - id: terminal_information
        type: u1
        doc: Terminal status flags
      - id: voltage_level
        type: u1
        doc: Battery voltage level (0-6)
      - id: gsm_signal_strength
        type: u1
        doc: GSM signal strength (0-4)
      - id: extended_port_status
        type: u2
        doc: Extended status and alarm information
    instances:
      oil_electricity_connected:
        value: (terminal_information & 0x01) != 0
      gps_tracking_on:
        value: (terminal_information & 0x02) != 0
      alarm_status:
        value: (terminal_information >> 3) & 0x07
      charging_status:
        value: (terminal_information & 0x40) == 0
      acc_high:
        value: (terminal_information & 0x80) != 0

  string_info:
    seq:
      - id: string_information
        type: u1
        doc: String type identifier
      - id: string_content
        size-eos: true
        type: str
        encoding: ASCII

  alarm_data:
    seq:
      - id: date_time
        type: datetime_info
      - id: gps_information_length
        type: u1
      - id: positioning_information
        type: positioning_info
      - id: lbs_information
        type: lbs_info
      - id: status_information
        type: status_info
      - id: alarm_type
        type: u1
        enum: alarm_types
    instances:
      alarm_description:
        value: alarm_type

  gps_extended_data:
    seq:
      - id: date_time
        type: datetime_info
      - id: gps_information_length
        type: u1
      - id: positioning_information
        type: positioning_info
      - id: course_status
        type: u2
        doc: Course and status information
      - id: gps_accuracy
        type: u2
        doc: GPS accuracy information

  lbs_multiple_data:
    seq:
      - id: date_time
        type: datetime_info
      - id: mcc
        type: u2
        doc: Mobile Country Code
      - id: mnc
        type: u1
        doc: Mobile Network Code
      - id: cell_count
        type: u1
        doc: Number of cell towers
      - id: cell_towers
        type: cell_tower_info
        repeat: expr
        repeat-expr: cell_count

  lbs_wifi_data:
    seq:
      - id: date_time
        type: datetime_info
      - id: lbs_information
        type: lbs_info
      - id: wifi_count
        type: u1
      - id: wifi_access_points
        type: wifi_access_point
        repeat: expr
        repeat-expr: wifi_count

  lbs_extend_data:
    seq:
      - id: date_time
        type: datetime_info
      - id: mcc
        type: u2
      - id: mnc
        type: u2
        doc: Mobile Network Code (extended format)
      - id: lac
        type: u4
        doc: Location Area Code (extended)
      - id: cell_id
        type: u4
        doc: Cell ID (extended)
      - id: signal_strength
        type: u1

  wifi_data:
    seq:
      - id: date_time
        type: datetime_info
      - id: mcc
        type: u2
      - id: mnc
        type: u1
      - id: wifi_count
        type: u1
      - id: wifi_access_points
        type: wifi_access_point
        repeat: expr
        repeat-expr: wifi_count

  command_data:
    seq:
      - id: command_type
        type: u1
      - id: command_content
        size-eos: true

  obd_data:
    seq:
      - id: date_time
        type: datetime_info
      - id: obd_information
        size-eos: true
        doc: OBD diagnostic data

  driver_behavior_data:
    seq:
      - id: date_time
        type: datetime_info
      - id: behavior_type
        type: u1
        enum: behavior_types
      - id: behavior_data
        size-eos: true

  generic_data:
    seq:
      - id: raw_data
        size-eos: true

  datetime_info:
    seq:
      - id: year
        type: u1
        doc: Year (add 2000)
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
    instances:
      unix_timestamp:
        value: >-
          ((year + 2000 - 1970) * 365 * 24 * 3600) +
          (month * 30 * 24 * 3600) +
          (day * 24 * 3600) +
          (hour * 3600) +
          (minute * 60) +
          second

  positioning_info:
    seq:
      - id: satellite_count
        type: u1
        doc: GPS satellite count (4 bits) + GPS validity (4 bits)
      - id: latitude
        type: u4
        doc: Latitude * 1800000 (degrees to minutes conversion)
      - id: longitude
        type: u4
        doc: Longitude * 1800000 (degrees to minutes conversion)
      - id: speed
        type: u1
        doc: Speed in km/h
      - id: course_status
        type: u2
        doc: Course (10 bits) + status flags (6 bits)
    instances:
      satellite_number:
        value: satellite_count & 0x0F
      gps_real_time:
        value: (satellite_count & 0x10) != 0
      gps_positioned:
        value: (satellite_count & 0x20) != 0
      latitude_degrees:
        value: >-
          (latitude / 1800000.0) * 
          ((course_status & 0x0400) == 0 ? 1 : -1)
      longitude_degrees:
        value: >-
          (longitude / 1800000.0) * 
          ((course_status & 0x0800) == 0 ? 1 : -1)
      course_degrees:
        value: course_status & 0x03FF
      gps_valid:
        value: (course_status & 0x1000) != 0
      differential_gps:
        value: (course_status & 0x2000) != 0

  lbs_info:
    seq:
      - id: mcc
        type: u2
        doc: Mobile Country Code
      - id: mnc
        type: u1
        doc: Mobile Network Code
      - id: lac
        type: u2
        doc: Location Area Code
      - id: cell_id
        size: 3
        doc: Cell ID (3 bytes)
    instances:
      cell_id_value:
        value: >-
          (cell_id[0] << 16) | (cell_id[1] << 8) | cell_id[2]

  status_info:
    seq:
      - id: terminal_information
        type: u1
        doc: Terminal status and alarm information
      - id: voltage_level
        type: u1
        doc: Battery voltage level
      - id: gsm_signal_strength
        type: u1
        doc: GSM signal strength
      - id: alarm
        type: u1
        enum: alarm_types
      - id: language
        type: u1
        doc: Language setting
    instances:
      oil_power_connected:
        value: (terminal_information & 0x01) != 0
      gps_signal_available:
        value: (terminal_information & 0x02) != 0
      alarm_type:
        value: (terminal_information >> 3) & 0x07
      charging:
        value: (terminal_information & 0x40) == 0
      acc_status:
        value: (terminal_information & 0x80) != 0

  cell_tower_info:
    seq:
      - id: lac
        type: u2
      - id: cell_id
        type: u2
      - id: signal_strength
        type: u1

  wifi_access_point:
    seq:
      - id: mac_address
        size: 6
        doc: MAC address (6 bytes)
      - id: signal_strength
        type: u1
        doc: WiFi signal strength

enums:
  protocol_types:
    0x01: login_message
    0x02: location_request
    0x03: heartbeat_data
    0x04: answer_phone
    0x05: string_information
    0x07: handshaking_packet
    0x08: user_packet
    0x10: gps_positioning
    0x11: gps_offline_positioning
    0x12: gps_lbs_positioning
    0x13: gps_lbs_offline_positioning
    0x14: gps_lbs_status
    0x15: string_packet
    0x16: alarm_data
    0x17: gps_positioning_data
    0x18: gps_positioning_packet
    0x19: lbs_multiple_cell
    0x1a: lbs_information
    0x1b: lbs_phone_message
    0x1c: lbs_wifi
    0x1d: lbs_extend_message
    0x1e: gps_lbs_extend_message
    0x1f: wifi_information
    0x2a: command_information
    0x2c: obd_information
    0x2d: gps_driver_behavior
    0x80: command_result
    0x81: get_version
    0x82: disconnect_oil_power
    0x83: resume_oil_power
    0x84: set_time_zone
    0x85: reboot_gps

  alarm_types:
    0x00: normal
    0x01: sos_distress
    0x02: power_cut_alarm
    0x03: vibration_alarm
    0x04: fence_in_alarm
    0x05: fence_out_alarm
    0x06: overspeed_alarm
    0x07: movement_alarm
    0x08: gps_blind_area_alarm
    0x09: power_low_alarm
    0x0a: power_off_alarm
    0x0b: sim_problem
    0x0c: gps_open_circuit
    0x0d: gps_short_circuit
    0x0e: power_low_protect
    0x0f: power_off_protect
    0x10: sim_door_open
    0x11: gps_receiver_jam

  behavior_types:
    0x01: harsh_acceleration
    0x02: harsh_braking  
    0x03: sharp_turn
    0x04: collision_detection
    0x05: rollover_detection
    0x06: rapid_lane_change

  device_models:
    0x0001: gt06n
    0x0002: gt06e
    0x0003: gt06d
    0x0004: gt06_pro
    0x0005: gt06_4g

  language_codes:
    0x01: chinese
    0x02: english

  voltage_levels:
    0x00: power_off
    0x01: extremely_low
    0x02: very_low
    0x03: low
    0x04: medium
    0x05: high
    0x06: highest

  gsm_signal_levels:
    0x00: no_signal
    0x01: very_weak
    0x02: weak
    0x03: good
    0x04: strong