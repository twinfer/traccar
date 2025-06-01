meta:
  id: ulbotech
  title: Ulbotech GPS Tracker Protocol
  license: MIT
  ks-version: 0.11
  endian: le

doc: |
  Ulbotech protocol supporting dual format communication (binary and text).
  Features comprehensive vehicle diagnostics including OBD-II, CAN bus, J1708,
  driver behavior analysis, RFID support, and geofencing capabilities.

seq:
  - id: message
    type:
      switch-on: message_format
      cases:
        message_format::binary: binary_message
        message_format::text: text_message

instances:
  message_format:
    value: _io.read_u1_at(0) == 0xf8 ? message_format::binary : message_format::text

types:
  binary_message:
    seq:
      - id: header
        contents: [0xf8]
      - id: version
        type: u1
      - id: message_type
        type: u1
      - id: imei
        size: 8
      - id: timestamp
        type: u4
      - id: data_blocks
        type: data_block
        repeat: eos
      - id: footer
        contents: [0xf8]
    instances:
      device_id:
        value: imei.to_s[1:]
      unix_timestamp:
        value: (timestamp & 0x7fffffff) + 946684800
      datetime:
        value: unix_timestamp

  data_block:
    seq:
      - id: block_type
        type: u1
        enum: data_types
      - id: block_length
        type:
          switch-on: block_type
          cases:
            data_types::canbus: u2
            _: u1
      - id: block_data
        type:
          switch-on: block_type
          cases:
            data_types::gps: gps_data
            data_types::lbs: lbs_data
            data_types::status: status_data
            data_types::odometer: odometer_data
            data_types::adc: adc_data
            data_types::geofence: geofence_data
            data_types::obd2: obd2_data
            data_types::fuel: fuel_data
            data_types::obd2_alarm: obd2_alarm_data
            data_types::harsh_driver: harsh_driver_data
            data_types::canbus: canbus_data
            data_types::j1708: j1708_data
            data_types::vin: vin_data
            data_types::rfid: rfid_data
            data_types::event: event_data
        size: block_length

  gps_data:
    seq:
      - id: latitude_raw
        type: s4
      - id: longitude_raw
        type: s4
      - id: speed_raw
        type: u2
      - id: course_raw
        type: u2
      - id: hdop_raw
        type: u2
    instances:
      latitude:
        value: latitude_raw / 1000000.0
      longitude:
        value: longitude_raw / 1000000.0
      speed_kmh:
        value: speed_raw
      speed_knots:
        value: speed_raw * 0.539957
      course_degrees:
        value: course_raw
      hdop:
        value: hdop_raw * 0.01
      valid:
        value: hdop_raw < 9999

  lbs_data:
    seq:
      - id: mcc
        type: u2
      - id: mnc
        type: u2
      - id: lac
        type: u2
      - id: cell_id
        type:
          switch-on: _parent.block_length
          cases:
            11: u4
            _: u2
      - id: signal_strength
        type: u1
      - id: extra_data
        size-eos: true
        if: _parent.block_length > 9 and _parent.block_length != 11
    instances:
      rssi:
        value: -(signal_strength)

  status_data:
    seq:
      - id: status_flags
        type: u2
      - id: alarm_flags
        type: u2
    instances:
      ignition_on:
        value: (status_flags >> 9) & 1 != 0
      power_off_alarm:
        value: (alarm_flags >> 0) & 1 != 0
      movement_alarm:
        value: (alarm_flags >> 1) & 1 != 0
      overspeed_alarm:
        value: (alarm_flags >> 2) & 1 != 0
      geofence_alarm:
        value: (alarm_flags >> 4) & 1 != 0
      sos_alarm:
        value: (alarm_flags >> 10) & 1 != 0

  odometer_data:
    seq:
      - id: odometer_value
        type: u4
    instances:
      odometer_km:
        value: odometer_value / 1000.0

  adc_data:
    seq:
      - id: adc_values
        type: adc_value
        repeat: expr
        repeat-expr: _parent.block_length / 2

  adc_value:
    seq:
      - id: raw_value
        type: u2
    instances:
      channel_id:
        value: (raw_value >> 12) & 0x0f
      adc_reading:
        value: raw_value & 0x0fff
      voltage:
        value: |(
          channel_id == 0 ? adc_reading * (100 + 10) / 4096.0 - 10 :
          channel_id == 2 ? adc_reading * (100 + 10) / 4096.0 - 10 :
          channel_id == 3 ? adc_reading * (100 + 10) / 4096.0 - 10 :
          adc_reading
        )
      temperature:
        value: channel_id == 1 ? adc_reading * (125 + 55) / 4096.0 - 55 : 0
      fuel_level:
        value: |(
          channel_id >= 5 and channel_id <= 9 ? adc_reading * 2000 / 4096.0 : 0
        )

  geofence_data:
    seq:
      - id: geofence_in
        type: u4
      - id: geofence_alarm
        type: u4

  obd2_data:
    seq:
      - id: obd_parameters
        type: obd_parameter
        repeat: eos

  obd_parameter:
    seq:
      - id: parameter_header
        type: u1
      - id: mode_and_pid
        type: u1
      - id: parameter_data
        size: parameter_length - 1
    instances:
      parameter_length:
        value: (parameter_header >> 4) & 0x0f
      mode:
        value: mode_and_pid & 0x0f
      pid:
        value: parameter_header & 0xf0

  fuel_data:
    seq:
      - id: fuel_consumption_raw
        type: u4
    instances:
      fuel_consumption_liters:
        value: fuel_consumption_raw / 10000.0

  obd2_alarm_data:
    seq:
      - id: alarm_parameters
        type: obd_parameter
        repeat: eos

  harsh_driver_data:
    seq:
      - id: behavior_flags
        type: u1
    instances:
      rapid_acceleration:
        value: (behavior_flags >> 0) & 1 != 0
      rough_braking:
        value: (behavior_flags >> 1) & 1 != 0
      harsh_course:
        value: (behavior_flags >> 2) & 1 != 0
      no_warm_up:
        value: (behavior_flags >> 3) & 1 != 0
      long_idle:
        value: (behavior_flags >> 4) & 1 != 0
      fatigue_driving:
        value: (behavior_flags >> 5) & 1 != 0
      rough_terrain:
        value: (behavior_flags >> 6) & 1 != 0
      high_rpm:
        value: (behavior_flags >> 7) & 1 != 0

  canbus_data:
    seq:
      - id: can_frame_data
        size-eos: true

  j1708_data:
    seq:
      - id: j1708_parameters
        type: j1708_parameter
        repeat: eos

  j1708_parameter:
    seq:
      - id: mark_byte
        type: u1
      - id: parameter_id
        type: u1
      - id: parameter_value
        size: parameter_length - 1
    instances:
      parameter_length:
        value: mark_byte & 0x3f
      parameter_type:
        value: (mark_byte >> 6) & 0x03
      extended_id:
        value: parameter_type == 3 ? parameter_id + 256 : parameter_id

  vin_data:
    seq:
      - id: vin_string
        size-eos: true
        type: str
        encoding: ascii

  rfid_data:
    seq:
      - id: rfid_tag
        size: _parent.block_length - 1
        type: str
        encoding: ascii
      - id: authorized_flag
        type: u1
    instances:
      is_authorized:
        value: authorized_flag != 0

  event_data:
    seq:
      - id: event_code
        type: u1
      - id: event_mask
        type: u4
        if: _parent.block_length > 1

  text_message:
    seq:
      - id: message_content
        size-eos: true
        type: str
        encoding: ascii
    instances:
      protocol_version:
        value: message_content.substring(4, 6)
      device_id:
        value: |(
          message_content.index_of(',') > 0 ? 
          message_content.substring(message_content.index_of(',') + 1, 
          message_content.index_of(',', message_content.index_of(',') + 1)) : ""
        )
      timestamp_part:
        value: |(
          message_content.index_of(',', message_content.index_of(',') + 1) > 0 ?
          message_content.substring(message_content.index_of(',', message_content.index_of(',') + 1) + 1,
          message_content.index_of(',', message_content.index_of(',', message_content.index_of(',') + 1) + 1)) : ""
        )
      command_part:
        value: |(
          message_content.index_of(',', message_content.index_of(',', message_content.index_of(',') + 1) + 1) > 0 ?
          message_content.substring(message_content.index_of(',', message_content.index_of(',', message_content.index_of(',') + 1) + 1) + 1,
          message_content.index_of('#')) : ""
        )

enums:
  message_format:
    0: binary
    1: text

  data_types:
    0x01: gps
    0x02: lbs
    0x03: status
    0x04: odometer
    0x05: adc
    0x06: geofence
    0x07: obd2
    0x08: fuel
    0x09: obd2_alarm
    0x0a: harsh_driver
    0x0b: canbus
    0x0c: j1708
    0x0d: vin
    0x0e: rfid
    0x10: event

  status_flags:
    0: input_1
    1: input_2
    2: input_3
    3: input_4
    4: input_5
    5: input_6
    6: input_7
    7: input_8
    8: charge_status
    9: ignition_status
    10: door_status
    11: engine_status
    12: ac_status
    13: battery_low
    14: gps_antenna
    15: gsm_antenna

  alarm_types:
    0: power_off
    1: movement
    2: overspeed
    3: reserved_3
    4: geofence
    5: reserved_5
    6: reserved_6
    7: reserved_7
    8: reserved_8
    9: reserved_9
    10: sos
    11: reserved_11
    12: reserved_12
    13: reserved_13
    14: reserved_14
    15: reserved_15

  driver_behavior:
    0: rapid_acceleration
    1: rough_braking
    2: harsh_course
    3: no_warm_up
    4: long_idle
    5: fatigue_driving
    6: rough_terrain
    7: high_rpm

  adc_channels:
    0: main_power
    1: temperature_sensor
    2: backup_battery
    3: external_adc_1
    4: reserved_4
    5: fuel_sensor_1
    6: fuel_sensor_2
    7: fuel_sensor_3
    8: fuel_sensor_4
    9: fuel_sensor_5