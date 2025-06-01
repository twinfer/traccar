meta:
  id: omnicomm
  title: Omnicomm GPS Tracker Protocol
  license: MIT
  ks-version: 0.11
  endian: le

doc: |
  Omnicomm protocol supporting advanced fleet management with protobuf-based
  binary messaging. Features comprehensive telematics including fuel monitoring,
  CAN bus integration, J1939/J1979 OBD support, passenger counting, photo transmission,
  and advanced driver assistance systems.

seq:
  - id: message
    type: omnicomm_packet

types:
  omnicomm_packet:
    seq:
      - id: prefix
        contents: [0xc0]
      - id: message_type
        type: u1
        enum: message_types
      - id: data_length
        type: u2
      - id: data
        size: data_length
        type:
          switch-on: message_type
          cases:
            message_types::msg_identification: identification_data
            message_types::msg_archive_data: archive_data
            message_types::msg_archive_inquiry: archive_inquiry
            message_types::msg_remove_archive_inquiry: remove_archive_inquiry
      - id: checksum
        type: u2

  identification_data:
    seq:
      - id: device_id
        type: u4
    instances:
      device_identifier:
        value: device_id.to_s

  archive_inquiry:
    seq:
      - id: inquiry_index
        type: u4

  remove_archive_inquiry:
    seq:
      - id: remove_index
        type: u4

  archive_data:
    seq:
      - id: archive_index
        type: u4
      - id: timestamp
        type: u4
      - id: priority
        type: u1
      - id: protobuf_messages
        type: protobuf_message
        repeat: eos
    instances:
      unix_timestamp:
        value: timestamp

  protobuf_message:
    seq:
      - id: message_length
        type: u2
      - id: protobuf_data
        size: message_length
        type: omnicomm_protobuf_message

  omnicomm_protobuf_message:
    seq:
      - id: raw_protobuf_data
        size-eos: true
    instances:
      message_ids:
        value: "extract_field(1)"
      has_general:
        value: "has_field(2)"
      has_photo:
        value: "has_field(4)"
      has_nav:
        value: "has_field(5)"
      has_uni_dt:
        value: "has_field(6)"
      has_can_dt_j1939:
        value: "has_field(7)"
      has_lls_dt:
        value: "has_field(8)"
      has_other:
        value: "has_field(9)"
      has_icon_dt:
        value: "has_field(10)"
      has_obd_dt_j1979:
        value: "has_field(11)"
      has_log:
        value: "has_field(16)"

  general_data:
    seq:
      - id: time
        type: u4
        if: _parent.has_general
      - id: id_fas
        type: u4
        if: _parent.has_general
      - id: id_drv
        size: 8
        if: _parent.has_general
      - id: flags
        type: u4
        if: _parent.has_general
      - id: mileage
        type: u4
        if: _parent.has_general
      - id: v_imp
        type: u2
        if: _parent.has_general
      - id: t_imp
        type: u2
        if: _parent.has_general
      - id: u_board
        type: u4
        if: _parent.has_general
      - id: bat_life
        type: u4
        if: _parent.has_general
      - id: sum_acc
        type: s4
        if: _parent.has_general
      - id: phone
        size: 6
        if: _parent.has_general
      - id: amtr_x
        type: s4
        if: _parent.has_general
      - id: amtr_y
        type: s4
        if: _parent.has_general
      - id: amtr_z
        type: s4
        if: _parent.has_general
      - id: tacho_card_id
        size: 16
        if: _parent.has_general
      - id: accel_status
        type: u4
        if: _parent.has_general
      - id: hours_koef
        type: u4
        if: _parent.has_general
      - id: gsm_signal_quality
        type: u4
        if: _parent.has_general
      - id: wifi_signal_quality
        type: u4
        if: _parent.has_general
    instances:
      ignition_on:
        value: _parent.has_general ? (flags >> 0) & 1 != 0 : false
      gsm_connected:
        value: _parent.has_general ? (flags >> 1) & 1 != 0 : false
      gps_valid:
        value: _parent.has_general ? (flags >> 2) & 1 != 0 : false
      roaming:
        value: _parent.has_general ? (flags >> 3) & 1 != 0 : false
      backup_power:
        value: _parent.has_general ? (flags >> 4) & 1 != 0 : false
      panic_button:
        value: _parent.has_general ? (flags >> 5) & 1 != 0 : false
      device_tamper:
        value: _parent.has_general ? (flags >> 6) & 1 != 0 : false
      discrete_output:
        value: _parent.has_general ? (flags >> 7) & 1 != 0 : false
      voice_call_button:
        value: _parent.has_general ? (flags >> 8) & 1 != 0 : false
      gps_jamming:
        value: _parent.has_general ? (flags >> 9) & 1 != 0 : false
      gsm_jamming:
        value: _parent.has_general ? (flags >> 10) & 1 != 0 : false
      battery_fault:
        value: _parent.has_general ? (flags >> 11) & 1 != 0 : false
      voltage:
        value: _parent.has_general ? u_board * 0.1 : 0
      battery_level:
        value: _parent.has_general ? bat_life : 0
      rpm:
        value: _parent.has_general ? t_imp : 0
      speed_sensor:
        value: _parent.has_general ? v_imp : 0
      odometer_meters:
        value: _parent.has_general ? mileage * 0.1 : 0
      acceleration_sum:
        value: _parent.has_general ? sum_acc * 0.01 : 0

  photo_data:
    seq:
      - id: pos_blk
        type: u4
        if: _parent.has_photo
      - id: sz_photo
        type: u4
        if: _parent.has_photo
      - id: size_blk
        type: u4
        if: _parent.has_photo
      - id: img_dat
        size: size_blk
        if: _parent.has_photo
      - id: id_ph
        type: u4
        if: _parent.has_photo
      - id: img_stat
        type: u1
        if: _parent.has_photo
    instances:
      block_position:
        value: _parent.has_photo ? pos_blk : 0
      total_photo_size:
        value: _parent.has_photo ? sz_photo : 0
      current_block_size:
        value: _parent.has_photo ? size_blk : 0
      photo_id:
        value: _parent.has_photo ? id_ph : 0
      image_status:
        value: _parent.has_photo ? img_stat : 0

  nav_data:
    seq:
      - id: lat
        type: s4
        if: _parent.has_nav
      - id: lon
        type: s4
        if: _parent.has_nav
      - id: gps_vel
        type: u2
        if: _parent.has_nav
      - id: gps_dir
        type: u2
        if: _parent.has_nav
      - id: gps_n_sat
        type: u1
        if: _parent.has_nav
      - id: gps_alt
        type: s2
        if: _parent.has_nav
      - id: gps_time
        type: u4
        if: _parent.has_nav
    instances:
      latitude:
        value: _parent.has_nav ? lat * 0.0000001 : 0
      longitude:
        value: _parent.has_nav ? lon * 0.0000001 : 0
      speed_kmh:
        value: _parent.has_nav ? gps_vel * 0.1 : 0
      speed_knots:
        value: _parent.has_nav ? speed_kmh * 0.539957 : 0
      course_degrees:
        value: _parent.has_nav ? gps_dir : 0
      satellites:
        value: _parent.has_nav ? gps_n_sat : 0
      altitude_meters:
        value: _parent.has_nav ? gps_alt * 0.1 : 0
      timestamp:
        value: _parent.has_nav ? (gps_time + 1230768000) : 0

  uni_dt_data:
    seq:
      - id: uni_val_0
        type: s4
        if: _parent.has_uni_dt
      - id: uni_val_1
        type: s4
        if: _parent.has_uni_dt
      - id: uni_val_2
        type: s4
        if: _parent.has_uni_dt
      - id: uni_val_3
        type: s4
        if: _parent.has_uni_dt
      - id: uni_val_4
        type: s4
        if: _parent.has_uni_dt
      - id: uni_val_5
        type: s4
        if: _parent.has_uni_dt

  can_dt_j1939_data:
    seq:
      - id: spn_values
        size-eos: true
        if: _parent.has_can_dt_j1939
    instances:
      parking_brake:
        value: "extract_spn(70)"
      accelerator_pedal:
        value: "extract_spn(91) * 0.4"
      fuel_level_1:
        value: "extract_spn(96) * 0.4"
      oil_pressure:
        value: "extract_spn(100) * 4"
      coolant_temperature:
        value: "extract_spn(110) - 40"
      fuel_temperature:
        value: "extract_spn(174) - 40"
      oil_temperature:
        value: "extract_spn(175) - 273"
      daily_fuel_consumption:
        value: "extract_spn(182) * 0.5"
      instantaneous_fuel_economy:
        value: "extract_spn(184) / 512.0"
      engine_speed:
        value: "extract_spn(190) * 0.125"
      daily_distance:
        value: "extract_spn(244) * 0.125"
      total_distance:
        value: "extract_spn(245) * 0.125"
      total_engine_hours:
        value: "extract_spn(247) * 0.05"
      total_fuel_used:
        value: "extract_spn(250) * 0.5"
      brake_pedal_position:
        value: "extract_spn(521) * 0.4"
      clutch_pedal_position:
        value: "extract_spn(522) * 0.4"
      cruise_control_status:
        value: "extract_spn(527)"
      brake_pedal_switch:
        value: "extract_spn(597)"
      clutch_pedal_switch:
        value: "extract_spn(598)"
      distance_to_service:
        value: "extract_spn(914) * 5 - 160635"
      hours_to_service:
        value: "extract_spn(916) - 32127"
      vehicle_speed:
        value: "extract_spn(1624) / 256.0"
      door_status:
        value: "extract_spn(1821)"
      seatbelt_status:
        value: "extract_spn(1856)"

  lls_dt_data:
    seq:
      - id: fuel_sensors
        type: lls_sensor
        repeat: expr
        repeat-expr: 8
        if: _parent.has_lls_dt

  lls_sensor:
    seq:
      - id: t_lls
        type: s1
      - id: c_lls
        type: u4
      - id: f_lls
        type: s1
    instances:
      temperature:
        value: t_lls
      level:
        value: c_lls
      status:
        value: f_lls

  obd_dt_j1979_data:
    seq:
      - id: vehicle_speed
        type: u4
        if: _parent.has_obd_dt_j1979
      - id: distance_since_dtc_cleared
        type: u4
        if: _parent.has_obd_dt_j1979
      - id: engine_runtime_since_dtc_cleared
        type: u4
        if: _parent.has_obd_dt_j1979
      - id: control_module_voltage
        type: u4
        if: _parent.has_obd_dt_j1979
      - id: engine_rpm
        type: u4
        if: _parent.has_obd_dt_j1979
      - id: fuel_level_input
        type: u4
        if: _parent.has_obd_dt_j1979
      - id: engine_fuel_rate
        type: u4
        if: _parent.has_obd_dt_j1979
      - id: engine_oil_temperature
        type: u4
        if: _parent.has_obd_dt_j1979
      - id: engine_coolant_temperature
        type: u4
        if: _parent.has_obd_dt_j1979
      - id: malfunction_indicator_lamp
        type: u4
        if: _parent.has_obd_dt_j1979
      - id: vin_number
        size: 18
        type: str
        encoding: ascii
        if: _parent.has_obd_dt_j1979
      - id: fuel_rate_quantity
        type: u4
        if: _parent.has_obd_dt_j1979
    instances:
      speed_kmh:
        value: _parent.has_obd_dt_j1979 ? vehicle_speed & 0xff : 0
      distance_km:
        value: _parent.has_obd_dt_j1979 ? ((vehicle_speed >> 8) & 0xff) * 256 + (vehicle_speed & 0xff) : 0
      runtime_minutes:
        value: _parent.has_obd_dt_j1979 ? ((engine_runtime_since_dtc_cleared >> 8) & 0xff) * 256 + (engine_runtime_since_dtc_cleared & 0xff) : 0
      module_voltage:
        value: _parent.has_obd_dt_j1979 ? (((control_module_voltage >> 8) & 0xff) * 256 + (control_module_voltage & 0xff)) / 1000.0 : 0
      rpm:
        value: _parent.has_obd_dt_j1979 ? (((engine_rpm >> 8) & 0xff) * 256 + (engine_rpm & 0xff)) / 4 : 0
      fuel_level_percent:
        value: _parent.has_obd_dt_j1979 ? (engine_rpm & 0xff) * 100 / 255 : 0
      fuel_rate_lph:
        value: _parent.has_obd_dt_j1979 ? (((engine_fuel_rate >> 8) & 0xff) * 256 + (engine_fuel_rate & 0xff)) * 0.05 : 0
      oil_temp_celsius:
        value: _parent.has_obd_dt_j1979 ? (engine_oil_temperature & 0xff) - 40 : 0
      coolant_temp_celsius:
        value: _parent.has_obd_dt_j1979 ? (engine_coolant_temperature & 0xff) - 40 : 0
      mil_status:
        value: _parent.has_obd_dt_j1979 ? (malfunction_indicator_lamp & 0x80) != 0 : false

enums:
  message_types:
    0x80: msg_identification
    0x85: msg_archive_inquiry
    0x86: msg_archive_data
    0x87: msg_remove_archive_inquiry

  general_flags:
    0: ignition
    1: gsm_connection
    2: gps_valid
    3: roaming
    4: backup_power
    5: panic_button
    6: device_tamper
    7: discrete_output
    8: voice_call_button
    9: gps_jamming
    10: gsm_jamming
    11: battery_fault

  image_status_codes:
    0: image_ok
    1: image_error
    2: camera_busy
    3: camera_not_available
    4: storage_full
    5: format_error

  lls_status_codes:
    0: sensor_ok
    1: sensor_error
    2: sensor_not_connected
    3: sensor_calibrating
    4: sensor_out_of_range

  j1939_spn_codes:
    70: parking_brake_status
    91: accelerator_pedal_position
    96: fuel_level_1
    100: engine_oil_pressure
    110: engine_coolant_temperature
    174: fuel_temperature
    175: engine_oil_temperature
    182: trip_fuel_consumption
    184: instantaneous_fuel_economy
    190: engine_speed
    244: trip_distance
    245: total_vehicle_distance
    247: total_engine_hours
    250: total_fuel_used
    521: service_brake_pedal_position
    522: clutch_pedal_position
    527: cruise_control_status
    597: brake_pedal_switch
    598: clutch_pedal_switch
    914: distance_to_service
    916: time_to_service
    1624: wheel_based_vehicle_speed
    1821: door_control_status
    1856: seat_belt_status

  j1979_pid_codes:
    0x0d: vehicle_speed
    0x31: distance_since_dtc_cleared
    0x4e: engine_run_time_since_dtc_cleared
    0x42: control_module_voltage
    0x0c: engine_rpm
    0x2f: fuel_level_input
    0x5e: engine_fuel_rate
    0x5c: engine_oil_temperature
    0x05: engine_coolant_temperature
    0x01: monitor_status_since_dtc_cleared

  cruise_control_states:
    0: off_disabled
    1: hold
    2: accelerate
    3: decelerate
    4: resume
    5: set
    6: accelerator_override
    7: not_available

  door_status_states:
    0: at_least_one_door_open
    1: closing_last_door
    2: all_doors_closed
    14: error
    15: not_available

  seatbelt_status_states:
    0: not_buckled
    1: buckled
    2: error
    3: not_available