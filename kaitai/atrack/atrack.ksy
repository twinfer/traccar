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
      - id: field_id
        type: str
        size: 2
        encoding: ASCII
      - id: field_data
        type:
          switch-on: field_id
          cases:
            '"SA"': satellite_count_field      # Satellite count
            '"MT"': motion_status_field        # Motion status  
            '"MV"': main_voltage_field         # Main voltage
            '"BV"': battery_voltage_field      # Battery voltage
            '"GQ"': gsm_signal_field          # GSM signal strength
            '"CE"': cell_id_field             # Cell ID
            '"LC"': location_area_field       # Location area code
            '"CN"': country_network_field     # Country/Network codes
            '"PC"': pulse_count_field         # Pulse count
            '"AT"': altitude_field            # Altitude
            '"RP"': rpm_field                 # RPM
            '"GS"': gps_signal_field          # GPS signal
            '"DT"': archive_flag_field        # Archive flag
            '"VN"': vehicle_id_field          # Vehicle ID/VIN
            '"TR"': throttle_field            # Throttle position
            '"ET"': engine_temp_field         # Engine temperature
            '"FL"': fuel_level_field          # Fuel level
            '"FC"': fuel_consumption_field    # Fuel consumption
            '"AV1"': adc_field               # ADC value
            '"CD"': iccid_field              # SIM card ICCID
            '"EH"': engine_hours_field       # Engine hours
            '"IA"': intake_temp_field        # Intake air temperature
            '"EL"': engine_load_field        # Engine load
            '"HA"': harsh_accel_field        # Harsh acceleration
            '"HB"': harsh_brake_field        # Harsh braking
            '"HC"': harsh_corner_field       # Harsh cornering
            '"BC"': beacon_data_field        # Beacon data
            '"RL"': rxlev_field              # RX level
            '"MF"': mass_air_flow_field      # Mass air flow
            '"ML"': mil_status_field         # MIL status
            '"CI"': custom_info_field        # Custom info
            '"NC"': neighbor_cell_field      # Neighbor cell info
            '"SM"': max_speed_field          # Max speed
            '"GL"': google_link_field        # Google link
            '"MA"': mac_address_field        # MAC address
            '"PD"': pending_code_field       # Pending code
            '"CM"': imsi_field               # IMSI
            '"GN"': g_sensor_field           # G-sensor data
            '"GV"': g_force_field            # G-force data
            '"ME"': imei_field               # IMEI
            '"MP"': manifold_pressure_field  # Manifold pressure
            '"EO"': odometer_field           # Odometer
            # J1939 fields
            '"JO1"' to '"JO12"': j1939_byte_field
            '"JH1"' to '"JH12"': j1939_short_field  
            '"JL1"' to '"JL4"': j1939_int_field
            '"JS1"' to '"JS4"': j1939_string_field
            '"JN1"' to '"JN5"': j1939_int_field
            # ZOxx fields (1-byte values)
            '"ZO1"' to '"ZO17"': zo_byte_field
            # ZHxx fields (2-byte values)  
            '"ZH1"' to '"ZH3"': zh_short_field
            # ZLxx fields (4-byte values)
            '"ZL1"' to '"ZL4"': zl_int_field
            # ZSxx fields (string values)
            '"ZS1"': zs_string_field
            # Input fields
            '"IN0"' to '"IN3"': input_field
            _: raw_custom_data

  # Basic field types
  satellite_count_field:
    seq:
      - id: count
        type: u1

  motion_status_field:
    seq:
      - id: is_moving
        type: u1

  main_voltage_field:
    seq:
      - id: voltage_raw
        type: u2
    instances:
      voltage_volts:
        value: voltage_raw * 0.1

  battery_voltage_field:
    seq:
      - id: voltage_raw
        type: u2
    instances:
      voltage_volts:
        value: voltage_raw * 0.1

  gsm_signal_field:
    seq:
      - id: signal_strength
        type: u1

  cell_id_field:
    seq:
      - id: cell_id
        type: u4

  location_area_field:
    seq:
      - id: lac
        type: u2

  country_network_field:
    seq:
      - id: combined_codes
        type: u4
    instances:
      mobile_country_code:
        value: combined_codes / 100
      mobile_network_code:
        value: combined_codes % 100

  pulse_count_field:
    seq:
      - id: count
        type: u4

  altitude_field:
    seq:
      - id: altitude_meters
        type: u4

  rpm_field:
    seq:
      - id: engine_rpm
        type: u2

  gps_signal_field:
    seq:
      - id: signal_strength
        type: u1

  archive_flag_field:
    seq:
      - id: is_archived
        type: u1

  vehicle_id_field:
    seq:
      - id: vin
        type: string_field

  # Extended field types
  throttle_field:
    seq:
      - id: throttle_position
        type: u1

  engine_temp_field:
    seq:
      - id: temperature_raw
        type: u2
    instances:
      temperature_celsius:
        value: temperature_raw

  fuel_level_field:
    seq:
      - id: fuel_level_raw
        type: u1
    instances:
      fuel_level_percent:
        value: fuel_level_raw

  fuel_consumption_field:
    seq:
      - id: consumption_raw
        type: u4
    instances:
      consumption_liters:
        value: consumption_raw

  adc_field:
    seq:
      - id: adc_value
        type: u2

  iccid_field:
    seq:
      - id: iccid
        type: string_field

  engine_hours_field:
    seq:
      - id: hours_raw
        type: u4
    instances:
      hours_decimal:
        value: hours_raw * 0.1

  intake_temp_field:
    seq:
      - id: temperature
        type: u1

  engine_load_field:
    seq:
      - id: load_percent
        type: u1

  harsh_accel_field:
    seq:
      - id: is_harsh_accel
        type: u1

  harsh_brake_field:
    seq:
      - id: is_harsh_brake
        type: u1

  harsh_corner_field:
    seq:
      - id: is_harsh_corner
        type: u1

  beacon_data_field:
    seq:
      - id: beacon_mode
        type: u1
      - id: beacon_mask
        type: u1
      - id: beacon_data
        type: beacon_entry
        repeat: until
        repeat-until: _io.eof

  beacon_entry:
    seq:
      - id: beacon_id
        size: 6
        if: _parent.beacon_mask & 0x80
      - id: major
        type: u2
        if: _parent.beacon_mode == 1 and _parent.beacon_mask & 0x40
      - id: minor
        type: u2
        if: _parent.beacon_mode == 1 and _parent.beacon_mask & 0x20
      - id: tx_power
        type: u1
        if: _parent.beacon_mode == 1 and _parent.beacon_mask & 0x10
      - id: rssi
        type: u1
        if: _parent.beacon_mode == 1 and _parent.beacon_mask & 0x08

  # Photo data structure
  photo_data_field:
    seq:
      - id: photo_segment
        type: u2

  # Simple field types for various protocols
  rxlev_field:
    seq:
      - id: rxlev
        type: u1

  mass_air_flow_field:
    seq:
      - id: flow_rate
        type: u2

  mil_status_field:
    seq:
      - id: mil_status
        type: u1

  custom_info_field:
    seq:
      - id: info
        type: string_field

  neighbor_cell_field:
    seq:
      - id: cell_info
        type: string_field

  max_speed_field:
    seq:
      - id: max_speed
        type: u2

  google_link_field:
    seq:
      - id: link
        type: string_field

  mac_address_field:
    seq:
      - id: mac_address
        type: string_field

  pending_code_field:
    seq:
      - id: pending_code
        type: u1

  imsi_field:
    seq:
      - id: imsi
        type: u8

  g_sensor_field:
    seq:
      - id: g_sensor_data
        size: 60

  g_force_field:
    seq:
      - id: g_force_data
        size: 6

  imei_field:
    seq:
      - id: imei
        type: u8

  manifold_pressure_field:
    seq:
      - id: pressure
        type: u1

  odometer_field:
    seq:
      - id: odometer_miles
        type: u4
    instances:
      odometer_meters:
        value: odometer_miles * 1609.34

  # J1939 field types
  j1939_byte_field:
    seq:
      - id: value
        type: u1

  j1939_short_field:
    seq:
      - id: value
        type: u2

  j1939_int_field:
    seq:
      - id: value
        type: u4

  j1939_string_field:
    seq:
      - id: value
        type: string_field

  # ZOxx field types (1-byte values)
  zo_byte_field:
    seq:
      - id: value
        type: u1

  # ZHxx field types (2-byte values)
  zh_short_field:
    seq:
      - id: value
        type: u2

  # ZLxx field types (4-byte values)
  zl_int_field:
    seq:
      - id: value
        type: u4

  # ZSxx field types (string values)
  zs_string_field:
    seq:
      - id: value
        type: string_field

  # Input field types
  input_field:
    seq:
      - id: input_state
        type: u1

  raw_custom_data:
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