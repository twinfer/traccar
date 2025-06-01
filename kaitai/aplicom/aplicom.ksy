meta:
  id: aplicom
  title: Aplicom GPS Tracker Protocol
  license: MIT
  ks-version: 0.11
  endian: le

doc: |
  Aplicom protocol supporting multiple message types (D, E, F, H) with complex
  binary format. Used by European fleet management systems with advanced CAN bus
  integration, tachograph support, and comprehensive vehicle diagnostics.

seq:
  - id: message
    type: aplicom_message

types:
  aplicom_message:
    seq:
      - id: protocol_type
        type: u1
        enum: protocol_types
      - id: version
        type: u1
      - id: device_id
        type:
          switch-on: has_extended_id
          cases:
            true: extended_device_id
            false: standard_device_id
      - id: length
        type: u2
      - id: selector
        type: u4
        if: has_selector
      - id: event
        type: u1
      - id: event_info
        type: u1
      - id: data
        type:
          switch-on: protocol_type
          cases:
            protocol_types::type_d: protocol_d_data
            protocol_types::type_e: protocol_e_data
            protocol_types::type_f: protocol_f_data
            protocol_types::type_h: protocol_h_data
        size: data_length
    instances:
      has_extended_id:
        value: (version & 0x80) != 0
      has_selector:
        value: (version & 0x40) != 0
      data_length:
        value: |
          length - (has_selector ? 10 : 7) - (has_extended_id ? 4 : 0)

  standard_device_id:
    seq:
      - id: unit_id
        type: u4
        if: false  # Read as 3 bytes
      - id: unit_id_bytes
        size: 3
    instances:
      unit_id_value:
        value: |
          (unit_id_bytes[0] << 16) | (unit_id_bytes[1] << 8) | unit_id_bytes[2]
      calculated_imei:
        value: |
          unit_id_value == 0 ? 0 :
          # Try TC65i calculation
          unit_id_value + 0x14143B4000000

  extended_device_id:
    seq:
      - id: unit_id
        type: u4
      - id: extended_part
        type: u4
    instances:
      imei:
        value: (unit_id << 24) | (extended_part >> 8)

  protocol_d_data:
    seq:
      - id: gps_valid_flag
        type: u1
        if: (selector & 0x0008) != 0
      - id: device_time
        type: u4
        if: (selector & 0x0004) != 0
      - id: gps_data
        type: gps_position_data
        if: (selector & 0x0008) != 0
      - id: speed_data
        type: speed_course_data
        if: (selector & 0x0010) != 0
      - id: inputs
        type: u1
        if: (selector & 0x0040) != 0
      - id: adc_values
        type: adc_data_block
        if: (selector & 0x0020) != 0
      - id: power_data
        type: power_voltage_data
        if: (selector & 0x8000) != 0
      - id: pulse_rate_1
        type: pulse_rate_data
        if: (selector & 0x10000) != 0
      - id: pulse_rate_2
        type: pulse_rate_data
        if: (selector & 0x20000) != 0
      - id: trip1
        type: u4
        if: (selector & 0x0080) != 0
      - id: trip2
        type: u4
        if: (selector & 0x0100) != 0
      - id: outputs
        type: u1
        if: (selector & 0x0040) != 0
      - id: driver_id
        type: driver_identification
        if: (selector & 0x0200) != 0
      - id: keypad
        type: u1
        if: (selector & 0x0400) != 0
      - id: altitude
        type: s2
        if: (selector & 0x0800) != 0
      - id: snapshot_counter
        type: u2
        if: (selector & 0x2000) != 0
      - id: state_flags
        size: 8
        if: (selector & 0x4000) != 0
      - id: cell_info
        size: 11
        if: (selector & 0x80000) != 0
      - id: event_data
        type: event_data_block
        if: (selector & 0x1000) != 0
    instances:
      selector:
        value: _parent.selector.as<u4>

  protocol_e_data:
    seq:
      - id: tachograph_event
        type: u2
        if: (selector & 0x0008) != 0
      - id: device_time
        type: u4
        if: (selector & 0x0004) != 0
      - id: tachograph_time
        type: tachograph_time_data
        if: (selector & 0x0010) != 0
      - id: work_state
        type: u1
      - id: driver1_state
        type: u1
      - id: driver2_state
        type: u1
      - id: tachograph_status
        type: u1
        if: (selector & 0x0020) != 0
      - id: obd_speed
        type: u2
        if: (selector & 0x0040) != 0
      - id: obd_odometer
        type: u4
        if: (selector & 0x0080) != 0
      - id: trip_odometer
        type: u4
        if: (selector & 0x0100) != 0
      - id: k_factor
        type: u2
        if: (selector & 0x8000) != 0
      - id: rpm
        type: u2
        if: (selector & 0x0200) != 0
      - id: extra_info
        type: u2
        if: (selector & 0x0400) != 0
      - id: vin
        type: str
        size: 18
        encoding: ASCII
        if: (selector & 0x0800) != 0
      - id: card1_data
        type: driver_card_data
        if: (selector & 0x2000) != 0
      - id: card2_data
        type: driver_card_data
        if: (selector & 0x4000) != 0
      - id: driver_records
        type: driver_records_data
        if: (selector & 0x10000) != 0
    instances:
      selector:
        value: _parent.selector.as<u4>
      obd_speed_kmh:
        value: (selector & 0x0040) != 0 ? obd_speed / 256.0 : 0
      obd_odometer_meters:
        value: (selector & 0x0080) != 0 ? obd_odometer * 5 : 0
      trip_odometer_meters:
        value: (selector & 0x0100) != 0 ? trip_odometer * 5 : 0
      rpm_value:
        value: (selector & 0x0200) != 0 ? rpm * 0.125 : 0

  protocol_f_data:
    seq:
      - id: device_time
        type: u4
        if: (selector & 0x0004) != 0
      - id: data_validity
        type: u1
      - id: rpm_data
        type: rpm_minmax_data
        if: (selector & 0x0008) != 0
      - id: engine_temp_data
        type: temperature_minmax_data
        if: (selector & 0x0010) != 0
      - id: engine_data
        type: engine_operational_data
        if: (selector & 0x0020) != 0
      - id: fuel_used
        type: u4
        if: (selector & 0x0040) != 0
      - id: odometer
        type: u4
        if: (selector & 0x0080) != 0
      - id: speed_data
        type: speed_analysis_data
        if: (selector & 0x0100) != 0
      - id: tachograph_data
        type: tachograph_analysis_data
        if: (selector & 0x0200) != 0
      - id: can_engine_data
        type: can_engine_block
        if: (selector & 0x0800) != 0
      - id: driver_id_data
        size: driver_id_length
        if: (selector & 0x2000) != 0
      - id: vehicle_data
        type: vehicle_status_data
        if: (selector & 0x4000) != 0
      - id: brake_data
        type: brake_suspension_data
        if: (selector & 0x8000) != 0
      - id: axle_data
        type: axle_weight_data
        if: (selector & 0x0400) != 0
    instances:
      selector:
        value: _parent.selector.as<u4>
      driver_id_length:
        value: _io.read_u1
        io: _parent._io
        if: (selector & 0x2000) != 0

  protocol_h_data:
    seq:
      - id: device_time
        type: u4
        if: (selector & 0x0004) != 0
      - id: reset_time
        type: u4
        if: (selector & 0x0040) != 0
      - id: snapshot_counter
        type: u2
        if: (selector & 0x2000) != 0
      - id: histogram_blocks
        type: histogram_block
        repeat: eos
    instances:
      selector:
        value: _parent.selector.as<u4>

  gps_position_data:
    seq:
      - id: fix_time
        type: u4
      - id: latitude_raw
        type: s4
      - id: longitude_raw
        type: s4
      - id: satellites
        type: u1
    instances:
      latitude:
        value: latitude_raw / 1000000.0
      longitude:
        value: longitude_raw / 1000000.0
      is_valid:
        value: (_parent.gps_valid_flag & 0x40) != 0

  speed_course_data:
    seq:
      - id: speed_kmh
        type: u1
      - id: max_speed_kmh
        type: u1
      - id: course_raw
        type: u1
    instances:
      course_degrees:
        value: course_raw * 2.0

  adc_data_block:
    seq:
      - id: adc1
        type: u2
      - id: adc2
        type: u2
      - id: adc3
        type: u2
      - id: adc4
        type: u2

  power_voltage_data:
    seq:
      - id: power_mv
        type: u2
      - id: battery_mv
        type: u2
    instances:
      power_voltage:
        value: power_mv * 0.001
      battery_voltage:
        value: battery_mv * 0.001

  pulse_rate_data:
    seq:
      - id: pulse_rate
        type: u2
      - id: pulse_count
        type: u4

  driver_identification:
    seq:
      - id: driver_id_high
        type: u2
      - id: driver_id_low
        type: u4
    instances:
      driver_id:
        value: (driver_id_high << 32) | driver_id_low

  event_data_block:
    seq:
      - id: event_data
        size-eos: true

  tachograph_time_data:
    seq:
      - id: seconds
        type: u1
      - id: minutes
        type: u1
      - id: hours
        type: u1
      - id: month
        type: u1
      - id: day
        type: u1
      - id: year
        type: u1
      - id: minute_offset
        type: s1
      - id: hour_offset
        type: s1

  driver_card_data:
    seq:
      - id: card_type
        type: u1
      - id: country_code
        type: u1
      - id: card_number
        type: str
        size: 20
        encoding: ASCII

  driver_records_data:
    seq:
      - id: driver_count
        type: u1
      - id: driver_entries
        type: driver_entry
        repeat: expr
        repeat-expr: driver_count

  driver_entry:
    seq:
      - id: driver_name
        type: str
        size: 22
        encoding: ASCII
      - id: driver_time
        type: u4

  rpm_minmax_data:
    seq:
      - id: rpm
        type: u2
      - id: rpm_max
        type: u2
      - id: rpm_min
        type: u2

  temperature_minmax_data:
    seq:
      - id: temp_current
        type: s2
      - id: temp_max
        type: s2
      - id: temp_min
        type: s2

  engine_operational_data:
    seq:
      - id: engine_hours
        type: u4
      - id: service_distance
        type: s4
      - id: driver_activity
        type: u1
      - id: throttle_position
        type: u1
      - id: fuel_level
        type: u1

  speed_analysis_data:
    seq:
      - id: obd_speed
        type: u1
      - id: speed_max
        type: u1
      - id: speed_min
        type: u1
      - id: hard_braking
        type: u1

  tachograph_analysis_data:
    seq:
      - id: tachograph_speed
        type: u1
      - id: driver1_state
        type: u1
      - id: driver2_state
        type: u1
      - id: tachograph_status
        type: u1
      - id: overspeed_count
        type: u1

  can_engine_block:
    seq:
      - id: engine_hours
        type: u4
      - id: rpm
        type: u2
      - id: obd_speed
        type: u2
      - id: fuel_used
        type: u4
      - id: fuel_level
        type: u1
    instances:
      engine_hours_value:
        value: engine_hours * 0.05
      rpm_value:
        value: rpm * 0.125
      speed_kmh:
        value: obd_speed / 256.0
      fuel_used_liters:
        value: fuel_used * 0.5
      fuel_level_percent:
        value: fuel_level * 0.4

  vehicle_status_data:
    seq:
      - id: torque
        type: u1
      - id: brake_pressure1
        type: u1
      - id: brake_pressure2
        type: u1
      - id: gross_weight
        type: u2
      - id: exhaust_fluid
        type: u1
      - id: retarder_torque_mode
        type: u1
      - id: retarder_torque
        type: u1
      - id: retarder_selection
        type: u1
      - id: tell_tale_block1
        size: 8
      - id: tell_tale_block2
        size: 8
      - id: tell_tale_block3
        size: 8
      - id: tell_tale_block4
        size: 8
    instances:
      brake_pressure1_kpa:
        value: brake_pressure1 * 8
      brake_pressure2_kpa:
        value: brake_pressure2 * 8
      gross_weight_kg:
        value: gross_weight * 10
      exhaust_fluid_percent:
        value: exhaust_fluid * 0.4
      retarder_selection_percent:
        value: retarder_selection * 0.4

  brake_suspension_data:
    seq:
      - id: parking_brake_status
        type: u1
      - id: door_status
        type: u1
      - id: door_details
        size: 8
      - id: alternator_status
        type: u1
      - id: selected_gear
        type: u1
      - id: current_gear
        type: u1
      - id: air_suspension
        size: 8

  axle_weight_data:
    seq:
      - id: axle_count
        type: u1
      - id: axle_weights
        type: u2
        repeat: expr
        repeat-expr: axle_count

  histogram_block:
    seq:
      - id: index
        type: u1
      - id: data_length
        type: u2
      - id: x_length
        type: u1
      - id: y_length
        type: u1
      - id: type_info
        type: histogram_type_info
        if: (_parent.selector & 0x0008) != 0
      - id: histogram_data
        type: histogram_data_values
      - id: total_value
        type: u4
      - id: limits
        type: histogram_limits
        if: (_parent.selector & 0x0010) != 0

  histogram_type_info:
    seq:
      - id: x_type
        type: u1
      - id: y_type
        type: u1
      - id: parameters
        type: u1

  histogram_data_values:
    seq:
      - id: values
        type:
          switch-on: _parent._parent.selector & 0x0020
          cases:
            0: u2
            _: u1
        repeat: expr
        repeat-expr: _parent.x_length * _parent.y_length

  histogram_limits:
    seq:
      - id: k_factor
        type: u1
      - id: x_limits
        type:
          switch-on: k_factor
          cases:
            1: s1
            2: s2
        repeat: expr
        repeat-expr: _parent.x_length - 1
      - id: y_limits
        type:
          switch-on: k_factor
          cases:
            1: s1
            2: s2
        repeat: expr
        repeat-expr: _parent.y_length - 1

enums:
  protocol_types:
    0x44: type_d      # 'D' - General purpose data
    0x45: type_e      # 'E' - Tachograph data
    0x46: type_f      # 'F' - Fleet management data
    0x48: type_h      # 'H' - Histogram data

  event_types:
    2: digital_input_change
    9: three_byte_event
    31: two_byte_event_1
    32: two_byte_event_2
    38: nine_four_byte_blocks
    113: four_byte_plus_one_byte
    119: event_data_hex
    121: eight_byte_event_1
    130: four_byte_incorrect
    142: eight_byte_event_2
    188: eb_trailer_data

  selector_flags_d:
    0x0004: device_time_present
    0x0008: gps_data_present
    0x0010: speed_data_present
    0x0020: adc_values_present
    0x0040: input_output_present
    0x0080: trip1_present
    0x0100: trip2_present
    0x0200: driver_id_present
    0x0400: keypad_present
    0x0800: altitude_present
    0x1000: event_data_present
    0x2000: snapshot_counter_present
    0x4000: state_flags_present
    0x8000: power_data_present
    0x10000: pulse_rate_1_present
    0x20000: pulse_rate_2_present
    0x80000: cell_info_present