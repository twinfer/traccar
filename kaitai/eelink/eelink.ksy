meta:
  id: eelink
  title: Eelink GPS Tracking Protocol
  license: MIT
  ks-version: 0.11
  endian: be

doc: |
  Eelink GPS tracking protocol supporting both legacy and modern message formats.
  Used by various Eelink GPS tracker devices with extensive telemetry capabilities.
  Supports cellular network info, WiFi positioning, OBD-II data, and environmental sensors.

seq:
  - id: messages
    type: message_wrapper
    repeat: eos

types:
  message_wrapper:
    seq:
      - id: udp_header
        type: udp_header_info
        if: has_udp_header
      - id: message
        type: message_packet
    instances:
      has_udp_header:
        value: _io.size >= 6 and _io.read_bytes(2) == [0x45, 0x4c]  # "EL"

  udp_header_info:
    seq:
      - id: signature
        contents: ['E', 'L']
      - id: length
        type: u2
      - id: reserved
        type: u2
      - id: device_id_raw
        size: 8
    instances:
      device_id:
        value: device_id_raw[1:]  # Skip first byte

  message_packet:
    seq:
      - id: header
        contents: [0x67, 0x67]
      - id: message_type
        type: u1
      - id: length
        type: u2
      - id: sequence_number
        type: u2
      - id: payload
        size: length - 2
        type:
          switch-on: message_type
          cases:
            0x01: login_message
            0x02: gps_message_old
            0x03: heartbeat_message
            0x04: alarm_message_old
            0x05: state_message_old
            0x06: sms_message
            0x07: obd_message
            0x12: normal_message_new
            0x14: warning_message_new
            0x15: report_message_new
            0x16: command_message_new
            0x17: obd_data_message
            0x18: obd_body_message
            0x19: obd_code_message
            0x1e: camera_info_message
            0x1f: camera_data_message
            0x80: downlink_message
            0x81: data_message
            _: raw_payload

  login_message:
    seq:
      - id: device_id
        size: 8
      - id: additional_data
        size-eos: true

  gps_message_old:
    seq:
      - id: position_data
        type: position_data_old

  heartbeat_message:
    seq:
      - id: status
        type: u2
        if: _io.size >= 2

  alarm_message_old:
    seq:
      - id: position_data
        type: position_data_old
      - id: alarm_code
        type: u1

  state_message_old:
    seq:
      - id: position_data
        type: position_data_old
      - id: status_type
        type: u1
      - id: device_time
        type: u4
        if: status_type == 0x01 or status_type == 0x02 or status_type == 0x03
      - id: status
        type: u2
        if: _io.size >= (_io.pos + 2)

  sms_message:
    seq:
      - id: message_data
        size-eos: true

  obd_message:
    seq:
      - id: timestamp
        type: u4
        if: _io.size > 4
      - id: obd_data
        type: obd_data_section
        if: _io.size > 4
      - id: status
        type: u2
        if: _io.size == 4

  normal_message_new:
    seq:
      - id: position_data
        type: position_data_new

  warning_message_new:
    seq:
      - id: position_data
        type: position_data_new
      - id: alarm_code
        type: u1

  report_message_new:
    seq:
      - id: position_data
        type: position_data_new
      - id: report_type
        type: u1

  command_message_new:
    seq:
      - id: command_data
        size-eos: true

  obd_data_message:
    seq:
      - id: obd_info
        size-eos: true

  obd_body_message:
    seq:
      - id: body_data
        size-eos: true

  obd_code_message:
    seq:
      - id: code_data
        size-eos: true

  camera_info_message:
    seq:
      - id: camera_info
        size-eos: true

  camera_data_message:
    seq:
      - id: camera_data
        size-eos: true

  downlink_message:
    seq:
      - id: message_type
        type: u1
      - id: uid
        type: u4
      - id: response_text
        type: str
        encoding: UTF-8
        size-eos: true

  data_message:
    seq:
      - id: data_content
        size-eos: true

  raw_payload:
    seq:
      - id: data
        size-eos: true

  position_data_old:
    seq:
      - id: timestamp
        type: u4
      - id: latitude_raw
        type: s4
      - id: longitude_raw
        type: s4
      - id: speed_raw
        type: u1
      - id: course
        type: u2
      - id: cell_info
        type: cell_tower_info
      - id: validity_flags
        type: u1
      - id: status
        type: u2
        if: _io.size >= (_io.pos + 2)
      - id: battery_voltage_raw
        type: u2
        if: _io.size >= (_io.pos + 8)
      - id: rssi
        type: u2
        if: _io.size >= (_io.pos + 6)
      - id: adc1
        type: u2
        if: _io.size >= (_io.pos + 4)
      - id: adc2
        type: u2
        if: _io.size >= (_io.pos + 2)
    instances:
      latitude:
        value: latitude_raw / 1800000.0
      longitude:
        value: longitude_raw / 1800000.0
      speed_kmh:
        value: speed_raw
      battery_voltage:
        value: battery_voltage_raw * 0.001
      is_valid:
        value: (validity_flags & 0x01) != 0

  position_data_new:
    seq:
      - id: timestamp
        type: u4
      - id: data_flags
        type: u1
      - id: gps_data
        type: gps_data_section
        if: (data_flags & 0x01) != 0
      - id: network_data
        type: network_data_section
        if: (data_flags & 0xfe) != 0
      - id: status_data
        type: status_data_section
        if: _parent.message_type == 0x12 or _parent.message_type == 0x14 or _parent.message_type == 0x15
      - id: extended_data
        type: extended_data_section
        if: _parent.message_type == 0x12 and _io.size > _io.pos

  gps_data_section:
    seq:
      - id: latitude_raw
        type: s4
      - id: longitude_raw
        type: s4
      - id: altitude
        type: s2
      - id: speed_raw
        type: u2
      - id: course
        type: u2
      - id: satellites
        type: u1
    instances:
      latitude:
        value: latitude_raw / 1800000.0
      longitude:
        value: longitude_raw / 1800000.0
      speed_kmh:
        value: speed_raw

  network_data_section:
    seq:
      - id: cell_data
        type: cell_tower_extended
        if: (_parent.data_flags & 0x02) != 0
      - id: neighbor_cells
        type: neighbor_cell_data
        repeat: expr
        repeat-expr: |
          (_parent.data_flags & 0x04) != 0 ? 1 :
          (_parent.data_flags & 0x08) != 0 ? 2 : 0
      - id: wifi_data
        type: wifi_access_point
        repeat: expr
        repeat-expr: |
          (_parent.data_flags & 0x10) != 0 ? 1 :
          (_parent.data_flags & 0x20) != 0 ? 2 :
          (_parent.data_flags & 0x40) != 0 ? 3 : 0
      - id: lte_data
        type: lte_network_data
        if: (_parent.data_flags & 0x80) != 0

  cell_tower_info:
    seq:
      - id: mcc
        type: u2
      - id: mnc
        type: u2
      - id: lac
        type: u2
      - id: cell_id
        type: u3

  cell_tower_extended:
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

  neighbor_cell_data:
    seq:
      - id: lac
        type: u2
      - id: cell_id
        type: u4
      - id: signal_strength
        type: u1

  wifi_access_point:
    seq:
      - id: mac_address
        size: 6
      - id: signal_strength
        type: u1

  lte_network_data:
    seq:
      - id: radio_access_technology
        type: u1
      - id: cell_count
        type: u1
      - id: base_info
        type: lte_base_info
        if: cell_count > 0
      - id: neighbor_cells
        type: lte_neighbor_cell
        repeat: expr
        repeat-expr: cell_count

  lte_base_info:
    seq:
      - id: mcc
        type: u2
      - id: mnc
        type: u2
      - id: lac
        type: u2
      - id: tac
        type: u2
      - id: cell_id
        type: u4
      - id: timing_advance
        type: u2

  lte_neighbor_cell:
    seq:
      - id: physical_cell_id
        type: u2
      - id: earfcn
        type: u2
      - id: rssi
        type: u1

  status_data_section:
    seq:
      - id: status_flags
        type: u2
    instances:
      is_valid:
        value: (status_flags & 0x0001) != 0
      has_ignition:
        value: (status_flags & 0x0002) != 0
      ignition_on:
        value: (status_flags & 0x0004) != 0
      has_armed:
        value: (status_flags & 0x0008) != 0
      is_armed:
        value: (status_flags & 0x0010) != 0
      has_blocked:
        value: (status_flags & 0x0020) != 0
      is_blocked:
        value: (status_flags & 0x0040) != 0
      has_charge:
        value: (status_flags & 0x0080) != 0
      is_charging:
        value: (status_flags & 0x0100) != 0
      is_moving:
        value: (status_flags & 0x0200) != 0
      gps_available:
        value: (status_flags & 0x0400) != 0

  extended_data_section:
    seq:
      - id: battery_voltage_raw
        type: u2
        if: _io.size >= (_io.pos + 2)
      - id: adc_data
        type: adc_readings
        if: _io.size >= (_io.pos + 4)
      - id: odometer
        type: u4
        if: _io.size >= (_io.pos + 4)
      - id: counters
        type: counter_data
        if: _io.size >= (_io.pos + 4)
      - id: step_data
        type: step_counter_data
        if: _io.size >= (_io.pos + 4)
      - id: environmental
        type: environmental_data
        if: _io.size >= (_io.pos + 12)
      - id: temperature2_raw
        type: s2
        if: _io.size >= (_io.pos + 2)
      - id: beacon_data
        type: beacon_section
        if: _io.size >= (_io.pos + 2)
    instances:
      battery_voltage:
        value: battery_voltage_raw * 0.001
      temperature2_celsius:
        value: temperature2_raw / 16.0

  adc_readings:
    seq:
      - id: adc0
        type: u2
      - id: adc1
        type: u2

  counter_data:
    seq:
      - id: gsm_counter
        type: u2
      - id: gps_counter
        type: u2

  step_counter_data:
    seq:
      - id: steps
        type: u2
      - id: walking_time
        type: u2

  environmental_data:
    seq:
      - id: temperature_raw
        type: s2
      - id: humidity_raw
        type: u2
      - id: illuminance_raw
        type: u4
      - id: co2_level
        type: u4
    instances:
      temperature_celsius:
        value: temperature_raw / 256.0
      humidity_percent:
        value: humidity_raw * 0.1
      illuminance_lux:
        value: illuminance_raw / 256.0

  beacon_section:
    seq:
      - id: beacon_count
        type: u1
      - id: beacon_id
        type: u1
      - id: beacons
        type: beacon_data
        repeat: expr
        repeat-expr: beacon_count

  beacon_data:
    seq:
      - id: beacon_id
        size: 6
      - id: signal_level
        type: u1
      - id: reserved
        type: u1
      - id: model
        type: u1
      - id: version
        type: u1
      - id: battery_raw
        type: u2
      - id: temperature_raw
        type: s2
      - id: data_value
        type: u2
    instances:
      battery_voltage:
        value: battery_raw * 0.001
      temperature_celsius:
        value: temperature_raw / 256.0

  obd_data_section:
    seq:
      - id: obd_parameters
        type: obd_parameter
        repeat: eos

  obd_parameter:
    seq:
      - id: pid
        type: u1
      - id: value
        type: s4

enums:
  message_types:
    0x01: login
    0x02: gps_old
    0x03: heartbeat
    0x04: alarm_old
    0x05: state_old
    0x06: sms
    0x07: obd
    0x12: normal_new
    0x14: warning_new
    0x15: report_new
    0x16: command_new
    0x17: obd_data
    0x18: obd_body
    0x19: obd_code
    0x1e: camera_info
    0x1f: camera_data
    0x80: downlink
    0x81: data

  alarm_types:
    0x01: power_off
    0x02: sos
    0x03: low_battery
    0x04: vibration
    0x08: gps_antenna_cut
    0x09: gps_antenna_open
    0x25: device_removing
    0x81: low_speed
    0x82: overspeed
    0x83: geofence_enter
    0x84: geofence_exit
    0x85: accident
    0x86: fall_down