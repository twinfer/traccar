meta:
  id: atrack
  title: Atrack Binary Protocol
  license: MIT
  ks-version: 0.11
  endian: be

doc: |
  Atrack binary GPS tracking protocol used by various GPS trackers.
  Supports both standard and custom data formats with configurable fields.
  Common in fleet management and asset tracking applications.

seq:
  - id: header
    type: header_info
  - id: data_records
    type: data_record
    repeat: until
    repeat-until: _io.eof

types:
  header_info:
    seq:
      - id: prefix
        contents: ['@', '?']
        if: is_binary_format
      - id: checksum
        type: u2
        if: is_binary_format
      - id: length
        type: u2
        if: is_binary_format
      - id: sequence_number
        type: u2
        if: is_binary_format
      - id: device_id
        type: u8
        if: is_binary_format
    instances:
      is_binary_format:
        value: _io.size > 20

  data_record:
    seq:
      - id: timestamp
        type: timestamp_info
      - id: device_time
        type: u4
        if: not use_long_date
      - id: send_time
        type: u4
        if: not use_long_date
      - id: longitude_raw
        type: s4
      - id: latitude_raw
        type: s4
      - id: course
        type: u2
      - id: report_type
        type: u1
      - id: odometer_raw
        type: u4
      - id: hdop_raw
        type: u2
      - id: input_status
        type: u1
      - id: speed_raw
        type: u2
      - id: output_status
        type: u1
      - id: adc_value_raw
        type: u2
      - id: driver_id
        type: string_field
      - id: temperature1_raw
        type: s2
      - id: temperature2_raw
        type: s2
      - id: message
        type: string_field
      - id: custom_data
        type: custom_data_section
        if: has_custom_data
    instances:
      use_long_date:
        value: false  # configurable via protocol settings
      has_custom_data:
        value: true   # configurable via protocol settings
      longitude:
        value: longitude_raw * 0.000001
      latitude:
        value: latitude_raw * 0.000001
      odometer_meters:
        value: odometer_raw * 100
      hdop:
        value: hdop_raw * 0.1
      speed_kmh:
        value: speed_raw
      temperature1_celsius:
        value: temperature1_raw * 0.1
      temperature2_celsius:
        value: temperature2_raw * 0.1
      adc_voltage:
        value: adc_value_raw * 0.001

  timestamp_info:
    seq:
      - id: year
        type: u2
        if: _parent.use_long_date
      - id: month
        type: u1
        if: _parent.use_long_date
      - id: day
        type: u1
        if: _parent.use_long_date
      - id: hour
        type: u1
        if: _parent.use_long_date
      - id: minute
        type: u1
        if: _parent.use_long_date
      - id: second
        type: u1
        if: _parent.use_long_date
      - id: fix_time_unix
        type: u4
        if: not _parent.use_long_date
    instances:
      fix_time_epoch:
        value: |
          _parent.use_long_date ?
          ((year - 1970) * 365 + (year - 1970) / 4) * 86400 + (month - 1) * 2678400 + (day - 1) * 86400 + hour * 3600 + minute * 60 + second :
          fix_time_unix

  string_field:
    seq:
      - id: value
        type: strz
        encoding: ASCII

  custom_data_section:
    seq:
      - id: format_indicator
        type: string_field
        if: not has_predefined_format
      - id: custom_fields
        type: custom_field
        repeat: until
        repeat-until: _io.eof or (_io.pos >= _parent._io.size)
    instances:
      has_predefined_format:
        value: false  # configurable via protocol settings

  custom_field:
    seq:
      - id: field_type
        type: u1
      - id: field_data
        type:
          switch-on: field_type
          cases:
            0x53: satellite_count    # SA
            0x4d: motion_status      # MT
            0x4d: main_voltage       # MV
            0x42: battery_voltage    # BV
            0x47: gsm_signal         # GQ
            0x43: cell_id           # CE
            0x4c: location_area     # LC
            0x43: country_network   # CN
            0x50: pulse_count       # PC
            0x41: altitude          # AT
            0x52: rpm               # RP
            0x47: gps_signal        # GS
            0x44: archive_flag      # DT
            0x56: vehicle_id        # VN
            _: raw_data

  satellite_count:
    seq:
      - id: count
        type: u1

  motion_status:
    seq:
      - id: is_moving
        type: u1

  main_voltage:
    seq:
      - id: voltage_raw
        type: u2
    instances:
      voltage_volts:
        value: voltage_raw * 0.1

  battery_voltage:
    seq:
      - id: voltage_raw
        type: u2
    instances:
      voltage_volts:
        value: voltage_raw * 0.1

  gsm_signal:
    seq:
      - id: signal_strength
        type: u1

  cell_id:
    seq:
      - id: id
        type: u4

  location_area:
    seq:
      - id: lac
        type: u2

  country_network:
    seq:
      - id: combined_codes
        type: u4
    instances:
      mobile_country_code:
        value: combined_codes / 100
      mobile_network_code:
        value: combined_codes % 100

  pulse_count:
    seq:
      - id: count
        type: u4

  altitude:
    seq:
      - id: altitude_meters
        type: u4

  rpm:
    seq:
      - id: engine_rpm
        type: u2

  gps_signal:
    seq:
      - id: signal_strength
        type: u1

  archive_flag:
    seq:
      - id: is_archived
        type: u1

  vehicle_id:
    seq:
      - id: vin
        type: string_field

  raw_data:
    seq:
      - id: data
        size-eos: true

enums:
  report_types:
    0: heartbeat
    1: sos_alarm
    2: power_on
    3: power_off
    4: enter_geofence
    5: exit_geofence
    6: movement_alarm
    7: overspeed_alarm
    8: low_battery
    9: gps_antenna_cut
    10: gps_antenna_open
    11: power_cut
    12: power_low
    13: temperature_high
    14: temperature_low
    15: jamming_alarm