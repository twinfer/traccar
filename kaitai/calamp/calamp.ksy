meta:
  id: calamp
  title: CalAmp GPS Tracker Protocol
  license: MIT
  ks-version: 0.11
  endian: be

doc: |
  CalAmp LM Direct protocol supporting GPS tracking devices with event reports,
  locate reports, user data, and mini event reports. Features optional headers
  for device identification, authentication, and routing.

seq:
  - id: message
    type: calamp_packet

types:
  calamp_packet:
    seq:
      - id: options_header
        type: options_header
        if: _io.pos == 0 and _io.read_u1 & 0x80 != 0
        doc: Optional headers when first byte has bit 7 set
      - id: service_type
        type: u1
        enum: service_types
      - id: message_type
        type: u1
        enum: message_types
      - id: sequence_number
        type: u2
        doc: Message sequence number for acknowledgment
      - id: payload
        type:
          switch-on: message_type
          cases:
            message_types::msg_event_report: position_payload
            message_types::msg_locate_report: position_payload
            message_types::msg_mini_event_report: mini_position_payload
            message_types::msg_user_data: user_data_payload
            message_types::msg_user_data_acc: position_payload
            message_types::msg_id_report: generic_payload
            message_types::msg_app_data: generic_payload
            message_types::msg_config: generic_payload
            message_types::msg_unit_request: generic_payload
        size-eos: true
    instances:
      device_id:
        value: options_header.mobile_id
        if: has_options_header
      has_options_header:
        value: _io.pos == 0 and (_io.peek_u1(0) & 0x80) != 0

  options_header:
    seq:
      - id: options_byte
        type: u1
        doc: Bit field for present optional headers
      - id: mobile_id_field
        type: mobile_id_field
        if: (options_byte & 0x01) != 0
      - id: mobile_id_type_field
        type: mobile_id_type_field
        if: (options_byte & 0x02) != 0
      - id: authentication_field
        type: authentication_field
        if: (options_byte & 0x04) != 0
      - id: routing_field
        type: routing_field
        if: (options_byte & 0x08) != 0
      - id: forwarding_field
        type: forwarding_field
        if: (options_byte & 0x10) != 0
      - id: response_redirection_field
        type: response_redirection_field
        if: (options_byte & 0x20) != 0
    instances:
      mobile_id:
        value: mobile_id_field.mobile_id
        if: (options_byte & 0x01) != 0

  mobile_id_field:
    seq:
      - id: length
        type: u1
      - id: mobile_id
        size: length
        type: str
        encoding: ASCII

  mobile_id_type_field:
    seq:
      - id: length
        type: u1
      - id: mobile_id_type
        size: length

  authentication_field:
    seq:
      - id: length
        type: u1
      - id: authentication_data
        size: length

  routing_field:
    seq:
      - id: length
        type: u1
      - id: routing_data
        size: length

  forwarding_field:
    seq:
      - id: length
        type: u1
      - id: forwarding_data
        size: length

  response_redirection_field:
    seq:
      - id: length
        type: u1
      - id: response_redirection_data
        size: length

  position_payload:
    seq:
      - id: timestamp
        type: u4
        doc: Unix timestamp (seconds since epoch)
      - id: fix_timestamp
        type: u4
        doc: GPS fix timestamp
      - id: latitude_raw
        type: s4
      - id: longitude_raw
        type: s4
      - id: altitude_raw
        type: s4
      - id: speed_raw
        type: u4
      - id: heading
        type: u2
      - id: satellites
        type: u1
      - id: fix_status
        type: u1
        doc: GPS fix status and validity flags
      - id: carrier
        type: u2
        doc: Carrier identification
      - id: rssi
        type: s2
        doc: Received signal strength indicator
      - id: comm_state
        type: u1
        doc: Communication state
      - id: hdop
        type: u1
        doc: Horizontal dilution of precision
      - id: inputs
        type: u1
        doc: Digital input states
      - id: unit_status
        type: u1
        doc: Unit status flags
      - id: event_data
        type: event_data
        if: _parent.message_type == message_types::msg_event_report
      - id: accumulator_data
        type: accumulator_data
        if: _io.eof == false
    instances:
      latitude:
        value: latitude_raw * 0.0000001
      longitude:
        value: longitude_raw * 0.0000001
      altitude:
        value: altitude_raw * 0.01
      speed_knots:
        value: speed_raw * 0.0360036  # Convert from cm/s to knots
      ignition_on:
        value: (inputs & 0x01) != 0
      valid_fix:
        value: (fix_status & 0x08) == 0
      unix_time:
        value: timestamp

  mini_position_payload:
    seq:
      - id: timestamp
        type: u4
        doc: Unix timestamp (seconds since epoch)
      - id: latitude_raw
        type: s4
      - id: longitude_raw
        type: s4
      - id: heading
        type: u2
      - id: speed_kph
        type: u1
        doc: Speed in km/h
      - id: fix_status_satellites
        type: u1
        doc: High 4 bits = satellites, low 4 bits = fix status
      - id: comm_state
        type: u1
        doc: Communication state
      - id: inputs
        type: u1
        doc: Digital input states
      - id: event_code
        type: u1
        doc: Event code for mini event report
      - id: accumulator_data
        type: accumulator_data
        if: _io.eof == false
    instances:
      latitude:
        value: latitude_raw * 0.0000001
      longitude:
        value: longitude_raw * 0.0000001
      satellites:
        value: (fix_status_satellites >> 4) & 0x0F
      valid_fix:
        value: (fix_status_satellites & 0x20) == 0
      ignition_on:
        value: (inputs & 0x01) != 0
      unix_time:
        value: timestamp

  event_data:
    seq:
      - id: event_index
        type: u1
      - id: event_code
        type: u1

  accumulator_data:
    seq:
      - id: accumulator_config
        type: u1
        doc: High 2 bits = type, low 6 bits = count
      - id: append_data
        type: u1
        doc: Append data byte
      - id: threshold_mask
        type: threshold_mask
        if: accumulator_type == 1
      - id: accumulators
        type: u4
        repeat: expr
        repeat-expr: accumulator_count
    instances:
      accumulator_type:
        value: (accumulator_config >> 6) & 0x03
      accumulator_count:
        value: accumulator_config & 0x3F

  threshold_mask:
    seq:
      - id: threshold
        type: u4
      - id: mask
        type: u4

  user_data_payload:
    seq:
      - id: message_route
        type: u1
      - id: message_id
        type: u1
      - id: data_length
        type: u2
      - id: user_data
        size: data_length
        type: str
        encoding: ASCII

  generic_payload:
    seq:
      - id: data
        size-eos: true

enums:
  service_types:
    0: unacknowledged
    1: acknowledged  
    2: response

  message_types:
    0: msg_null
    1: msg_ack
    2: msg_event_report
    3: msg_id_report
    4: msg_user_data
    5: msg_app_data
    6: msg_config
    7: msg_unit_request
    8: msg_locate_report
    9: msg_user_data_acc
    10: msg_mini_event_report
    11: msg_mini_user_data

  event_codes:
    1: power_up
    2: power_down
    3: time_out
    4: low_battery
    5: motion_start
    6: motion_stop
    7: heading_change
    8: panic
    9: external_input_1
    10: external_input_2
    11: external_input_3
    12: external_input_4
    13: external_input_change
    14: geofence_enter
    15: geofence_exit
    16: speed_limit_violation
    17: tow_detected
    18: harsh_acceleration
    19: harsh_braking
    20: harsh_cornering

  input_bits:
    0: ignition
    1: input_1
    2: input_2
    3: input_3
    4: input_4
    5: reserved_5
    6: reserved_6
    7: reserved_7