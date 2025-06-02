meta:
  id: continental
  title: Continental Automotive Telematics Protocol
  license: MIT
  ks-version: 0.11
  endian: be

doc: |
  Continental automotive telematics protocol supporting VDO tracking devices,
  tachographs, and telematics control units. Features binary messaging with
  position data, vehicle diagnostics, and fleet management capabilities.

seq:
  - id: message
    type: continental_packet

types:
  continental_packet:
    seq:
      - id: header
        type: u2
        doc: Packet header identifier (0x5356)
      - id: length
        type: u2
        doc: Message length including header
      - id: software_version
        type: u1
        doc: Device software version
      - id: serial_number
        type: u4
        doc: Device serial number (device identifier)
      - id: product_type
        type: u1
        doc: Product type identifier
      - id: message_type
        type: u1
        enum: message_types
      - id: payload
        size: length - 10
        type:
          switch-on: message_type
          cases:
            message_types::msg_status: status_message
            message_types::msg_keepalive: keepalive_message
            message_types::msg_ack: ack_message
            message_types::msg_nack: nack_message
    instances:
      device_id:
        value: serial_number.to_s
      is_valid_header:
        value: header == 0x5356

  status_message:
    doc: |
      Status message containing position data, vehicle diagnostics,
      and sensor information from Continental telematics devices.
    seq:
      - id: fix_time
        type: u4
        doc: GPS fix timestamp (Unix seconds)
      - id: position_data
        type: position_data
      - id: course
        type: u2
        doc: Course/heading in degrees (0-359)
      - id: speed_kph
        type: u2
        doc: Speed in kilometers per hour
      - id: gps_valid
        type: u1
        doc: GPS validity flag (>0 = valid)
      - id: device_time
        type: u4
        doc: Device timestamp (Unix seconds)
      - id: event_code
        type: u2
        doc: Event trigger code
      - id: input_states
        type: u2
        doc: Digital input states (bit field)
      - id: output_states
        type: u2
        doc: Digital output states (bit field)
      - id: battery_level
        type: u1
        doc: Battery level (0-255)
      - id: device_temperature
        type: s1
        doc: Device temperature in Celsius
      - id: reserved
        type: u2
        doc: Reserved field
      - id: odometer
        type: u4
        if: _io.eof == false
        doc: Odometer reading (optional)
      - id: engine_hours
        type: u4
        if: _io.eof == false
        doc: Engine hours (optional)
    instances:
      gps_fix_valid:
        value: gps_valid > 0
      ignition_on:
        value: (input_states & 0x01) != 0
      unix_fix_time:
        value: fix_time
      unix_device_time:
        value: device_time
      latitude:
        value: position_data.latitude
      longitude:
        value: position_data.longitude

  position_data:
    doc: |
      Position data with support for both standard and extended coordinate formats.
      Extended format provides higher precision for coordinates.
    seq:
      - id: latitude_raw
        type: u4
        doc: Raw latitude value
      - id: longitude_raw
        type: u4
        doc: Raw longitude value
    instances:
      is_extended_format:
        value: (latitude_raw & 0x08000000) != 0
      latitude_signed:
        value: >-
          is_extended_format ? 
          (latitude_raw | (((latitude_raw & 0x08000000) != 0) ? 0xF0000000 : 0)) :
          (latitude_raw | (((latitude_raw & 0x00800000) != 0) ? 0xFF000000 : 0))
      longitude_signed:
        value: >-
          is_extended_format ? 
          (longitude_raw | (((longitude_raw & 0x08000000) != 0) ? 0xF0000000 : 0)) :
          (longitude_raw | (((longitude_raw & 0x00800000) != 0) ? 0xFF000000 : 0))
      latitude:
        value: latitude_signed / (is_extended_format ? 360000.0 : 3600.0)
      longitude:
        value: longitude_signed / (is_extended_format ? 360000.0 : 3600.0)

  keepalive_message:
    doc: Keep-alive message for connection maintenance
    seq:
      - id: keepalive_data
        size-eos: true

  ack_message:
    doc: Acknowledgment message
    seq:
      - id: ack_data
        size-eos: true

  nack_message:
    doc: Negative acknowledgment message
    seq:
      - id: nack_data
        size-eos: true

enums:
  message_types:
    0x00: msg_keepalive
    0x02: msg_status
    0x06: msg_ack
    0x15: msg_nack

  product_types:
    0x01: vdo_tachograph
    0x02: telematics_control_unit
    0x03: vdo_link
    0x04: fleet_management
    0x05: tolling_device

  event_codes:
    0x0000: normal_report
    0x0001: ignition_on
    0x0002: ignition_off
    0x0003: power_on
    0x0004: power_off
    0x0005: panic_button
    0x0006: speed_limit_violation
    0x0007: geofence_enter
    0x0008: geofence_exit
    0x0009: harsh_acceleration
    0x000A: harsh_braking
    0x000B: sharp_turn
    0x000C: tow_detection
    0x000D: vehicle_theft
    0x000E: maintenance_due
    0x000F: driver_fatigue
    0x0010: eco_driving_score
    0x0011: fuel_theft
    0x0012: temperature_alert
    0x0013: door_open
    0x0014: driver_id_change

  input_bits:
    0: ignition
    1: door_1
    2: door_2
    3: panic_button
    4: seat_belt
    5: hand_brake
    6: reverse_gear
    7: auxiliary_1
    8: auxiliary_2
    9: auxiliary_3
    10: auxiliary_4
    11: reserved_11
    12: reserved_12
    13: reserved_13
    14: reserved_14
    15: reserved_15

  output_bits:
    0: engine_block
    1: horn
    2: lights
    3: siren
    4: central_lock
    5: auxiliary_output_1
    6: auxiliary_output_2
    7: auxiliary_output_3
    8: reserved_8
    9: reserved_9
    10: reserved_10
    11: reserved_11
    12: reserved_12
    13: reserved_13
    14: reserved_14
    15: reserved_15

  precision_levels:
    standard: coordinate_3600_divisor
    extended: coordinate_360000_divisor