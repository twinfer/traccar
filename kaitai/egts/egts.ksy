meta:
  id: egts
  title: EGTS (ERA-GLONASS Telematics Standard) Protocol
  license: MIT
  ks-version: 0.11
  endian: le

doc: |
  EGTS (ERA-GLONASS Telematics Standard) is the Russian Federation standard 
  for emergency response and telematics systems. This protocol supports 
  comprehensive vehicle monitoring, emergency response, fuel monitoring,
  and fleet management with government-mandated compliance features.

seq:
  - id: message
    type: egts_packet

types:
  egts_packet:
    seq:
      - id: protocol_version
        type: u1
      - id: security_key_id
        type: u1
      - id: flags
        type: u1
      - id: header_length
        type: u1
      - id: encoding
        type: u1
      - id: frame_data_length
        type: u2
      - id: packet_id
        type: u2
      - id: packet_type
        type: u1
        enum: packet_types
      - id: header_checksum
        type: u1
      - id: services_frame_data
        size: frame_data_length
        type: services_frame
        if: frame_data_length > 0
      - id: services_frame_checksum
        type: u2
        if: frame_data_length > 0
    instances:
      priority:
        value: (flags >> 0) & 0x03
      encryption_algorithm:
        value: (flags >> 2) & 0x03
      compression:
        value: (flags >> 4) & 0x01
      route:
        value: (flags >> 5) & 0x03

  services_frame:
    seq:
      - id: records
        type: service_data_record
        repeat: eos

  service_data_record:
    seq:
      - id: record_length
        type: u2
      - id: record_number
        type: u2
      - id: record_flags
        type: u1
      - id: object_id
        type: u4
        if: has_object_id
      - id: event_id
        type: u4
        if: has_event_id
      - id: event_time
        type: u4
        if: has_event_time
      - id: source_service_type
        type: u1
        enum: service_types
      - id: recipient_service_type
        type: u1
        enum: service_types
      - id: record_data
        size: data_length
        type: service_data_set
    instances:
      has_object_id:
        value: (record_flags >> 0) & 1 != 0
      has_event_id:
        value: (record_flags >> 1) & 1 != 0
      has_event_time:
        value: (record_flags >> 2) & 1 != 0
      object_identifier:
        value: has_object_id ? object_id : 0
      data_length:
        value: |(
          record_length - 
          (has_object_id ? 4 : 0) - 
          (has_event_id ? 4 : 0) - 
          (has_event_time ? 4 : 0) - 2
        )

  service_data_set:
    seq:
      - id: service_data_records
        type: service_data_item
        repeat: eos

  service_data_item:
    seq:
      - id: service_data_type
        type: u1
        enum: service_data_types
      - id: service_data_length
        type: u2
      - id: service_data_value
        size: service_data_length
        type:
          switch-on: service_data_type
          cases:
            service_data_types::sr_record_response: sr_record_response
            service_data_types::sr_term_identity: sr_term_identity
            service_data_types::sr_module_data: sr_module_data
            service_data_types::sr_vehicle_data: sr_vehicle_data
            service_data_types::sr_auth_params: sr_auth_params
            service_data_types::sr_auth_info: sr_auth_info
            service_data_types::sr_service_info: sr_service_info
            service_data_types::sr_result_code: sr_result_code
            service_data_types::sr_pos_data: sr_pos_data
            service_data_types::sr_ext_pos_data: sr_ext_pos_data
            service_data_types::sr_ad_sensors_data: sr_ad_sensors_data
            service_data_types::sr_counters_data: sr_counters_data
            service_data_types::sr_state_data: sr_state_data
            service_data_types::sr_loopin_data: sr_loopin_data
            service_data_types::sr_abs_dig_sens_data: sr_abs_dig_sens_data
            service_data_types::sr_abs_an_sens_data: sr_abs_an_sens_data
            service_data_types::sr_abs_cntr_data: sr_abs_cntr_data
            service_data_types::sr_abs_loopin_data: sr_abs_loopin_data
            service_data_types::sr_liquid_level_sensor: sr_liquid_level_sensor
            service_data_types::sr_passengers_counters: sr_passengers_counters

  sr_record_response:
    seq:
      - id: confirmed_record_number
        type: u2
      - id: record_status
        type: u1
    instances:
      success:
        value: record_status == 0

  sr_term_identity:
    seq:
      - id: terminal_id
        type: u4
      - id: terminal_flags
        type: u1
      - id: home_dispatcher_id
        type: u2
        if: has_home_dispatcher
      - id: imei
        size: 15
        type: str
        encoding: ascii
        if: has_imei
      - id: imsi
        size: 16
        type: str
        encoding: ascii
        if: has_imsi
      - id: language_identifier
        size: 3
        if: has_language
      - id: network_identifier
        size: 3
        if: has_network
      - id: buffer_size
        type: u2
        if: has_buffer_size
      - id: msisdn
        size: 15
        type: str
        encoding: ascii
        if: has_msisdn
    instances:
      has_home_dispatcher:
        value: (terminal_flags >> 0) & 1 != 0
      has_imei:
        value: (terminal_flags >> 1) & 1 != 0
      has_imsi:
        value: (terminal_flags >> 2) & 1 != 0
      has_language:
        value: (terminal_flags >> 3) & 1 != 0
      has_network:
        value: (terminal_flags >> 5) & 1 != 0
      has_buffer_size:
        value: (terminal_flags >> 6) & 1 != 0
      has_msisdn:
        value: (terminal_flags >> 7) & 1 != 0

  sr_module_data:
    seq:
      - id: module_type
        type: u1
      - id: vendor_identifier
        type: u4
      - id: firmware_version
        type: u2
      - id: software_version
        type: u2
      - id: modification
        type: u1
      - id: state
        type: u1
      - id: serial_number
        size: 16
        type: str
        encoding: ascii
      - id: description
        size-eos: true
        type: str
        encoding: ascii

  sr_vehicle_data:
    seq:
      - id: vehicle_identifier
        size: 17
        type: str
        encoding: ascii
      - id: vehicle_number
        size: 10
        type: str
        encoding: ascii
      - id: vehicle_description
        size-eos: true
        type: str
        encoding: ascii

  sr_auth_params:
    seq:
      - id: flags
        type: u1
      - id: key_length
        type: u1
      - id: key
        size: key_length
      - id: login_length
        type: u1
      - id: login
        size: login_length
        type: str
        encoding: ascii
      - id: password_length
        type: u1
      - id: password
        size: password_length
        type: str
        encoding: ascii
      - id: server_sequence_number
        size-eos: true

  sr_auth_info:
    seq:
      - id: user_name
        size: 16
        type: str
        encoding: ascii
      - id: user_password
        size: 16
        type: str
        encoding: ascii

  sr_service_info:
    seq:
      - id: service_type
        type: u1
      - id: service_state
        type: u1

  sr_result_code:
    seq:
      - id: result_code
        type: u1
        enum: result_codes

  sr_pos_data:
    seq:
      - id: navigation_time
        type: u4
      - id: latitude_raw
        type: u4
      - id: longitude_raw
        type: u4
      - id: flags
        type: u1
      - id: speed_course
        type: u2
      - id: course_high
        type: u1
      - id: odometer
        type: u3
      - id: digital_inputs
        type: u1
      - id: source
        type: u1
      - id: altitude
        type: s3
        if: has_altitude
    instances:
      timestamp:
        value: navigation_time + 1262304000
      latitude:
        value: |(
          (latitude_raw * 90.0 / 0xffffffff) * 
          (((flags >> 5) & 1) != 0 ? -1 : 1)
        )
      longitude:
        value: |(
          (longitude_raw * 180.0 / 0xffffffff) * 
          (((flags >> 6) & 1) != 0 ? -1 : 1)
        )
      valid:
        value: (flags >> 0) & 1 != 0
      has_altitude:
        value: (flags >> 7) & 1 != 0
      speed_kmh:
        value: (speed_course & 0x3fff) * 0.1
      speed_knots:
        value: speed_kmh * 0.539957
      course_degrees:
        value: course_high + (((speed_course >> 15) & 1) != 0 ? 256 : 0)
      odometer_meters:
        value: odometer * 100

  sr_ext_pos_data:
    seq:
      - id: ext_flags
        type: u1
      - id: vdop
        type: u2
        if: has_vdop
      - id: hdop
        type: u2
        if: has_hdop
      - id: pdop
        type: u2
        if: has_pdop
      - id: satellites
        type: u1
        if: has_satellites
    instances:
      has_vdop:
        value: (ext_flags >> 0) & 1 != 0
      has_hdop:
        value: (ext_flags >> 1) & 1 != 0
      has_pdop:
        value: (ext_flags >> 2) & 1 != 0
      has_satellites:
        value: (ext_flags >> 3) & 1 != 0

  sr_ad_sensors_data:
    seq:
      - id: digital_inputs_mask
        type: u1
      - id: digital_outputs
        type: u1
      - id: analog_sensors_mask
        type: u1
      - id: digital_input_data
        type: u1
        repeat: expr
        repeat-expr: digital_inputs_count
      - id: analog_sensor_data
        type: analog_sensor_value
        repeat: expr
        repeat-expr: analog_sensors_count
    instances:
      digital_inputs_count:
        value: |(
          ((digital_inputs_mask >> 0) & 1) +
          ((digital_inputs_mask >> 1) & 1) +
          ((digital_inputs_mask >> 2) & 1) +
          ((digital_inputs_mask >> 3) & 1) +
          ((digital_inputs_mask >> 4) & 1) +
          ((digital_inputs_mask >> 5) & 1) +
          ((digital_inputs_mask >> 6) & 1) +
          ((digital_inputs_mask >> 7) & 1)
        )
      analog_sensors_count:
        value: |(
          ((analog_sensors_mask >> 0) & 1) +
          ((analog_sensors_mask >> 1) & 1) +
          ((analog_sensors_mask >> 2) & 1) +
          ((analog_sensors_mask >> 3) & 1) +
          ((analog_sensors_mask >> 4) & 1) +
          ((analog_sensors_mask >> 5) & 1) +
          ((analog_sensors_mask >> 6) & 1) +
          ((analog_sensors_mask >> 7) & 1)
        )

  analog_sensor_value:
    seq:
      - id: sensor_value
        type: u3
    instances:
      voltage:
        value: sensor_value * 0.001

  sr_counters_data:
    seq:
      - id: counter_type
        type: u1
      - id: counter_value
        size-eos: true

  sr_state_data:
    seq:
      - id: state_fields
        type: u1
      - id: main_power_voltage
        type: u2
        if: has_main_power_voltage
      - id: backup_power_voltage
        type: u2
        if: has_backup_power_voltage
      - id: internal_battery_voltage
        type: u2
        if: has_internal_battery_voltage
      - id: temperature
        type: s1
        if: has_temperature
    instances:
      has_main_power_voltage:
        value: (state_fields >> 0) & 1 != 0
      has_backup_power_voltage:
        value: (state_fields >> 1) & 1 != 0
      has_internal_battery_voltage:
        value: (state_fields >> 2) & 1 != 0
      has_temperature:
        value: (state_fields >> 3) & 1 != 0

  sr_loopin_data:
    seq:
      - id: relative_time
        type: u2
      - id: latitude_raw
        type: u4
      - id: longitude_raw
        type: u4
      - id: flags_and_speed
        type: u2
      - id: course
        type: u1
    instances:
      latitude:
        value: latitude_raw * 90.0 / 0xffffffff
      longitude:
        value: longitude_raw * 180.0 / 0xffffffff
      speed_kmh:
        value: (flags_and_speed & 0x3fff) * 0.1
      valid:
        value: (flags_and_speed >> 15) & 1 != 0

  sr_abs_dig_sens_data:
    seq:
      - id: sensor_number
        type: u1
      - id: digital_sensor_data
        size-eos: true

  sr_abs_an_sens_data:
    seq:
      - id: sensor_number
        type: u1
      - id: analog_sensor_value
        type: u4

  sr_abs_cntr_data:
    seq:
      - id: counter_number
        type: u1
      - id: counter_value
        type: u4

  sr_abs_loopin_data:
    seq:
      - id: absolute_time
        type: u4
      - id: latitude_raw
        type: u4
      - id: longitude_raw
        type: u4
      - id: speed_and_flags
        type: u2
      - id: course
        type: u1
    instances:
      timestamp:
        value: absolute_time + 1262304000
      latitude:
        value: latitude_raw * 90.0 / 0xffffffff
      longitude:
        value: longitude_raw * 180.0 / 0xffffffff
      speed_kmh:
        value: (speed_and_flags & 0x3fff) * 0.1
      valid:
        value: (speed_and_flags >> 15) & 1 != 0

  sr_liquid_level_sensor:
    seq:
      - id: sensor_flags
        type: u1
      - id: sensor_address
        type: u2
      - id: raw_data
        size-eos: true
        if: has_raw_data
      - id: liquid_level
        type: u4
        if: not has_raw_data
    instances:
      has_raw_data:
        value: (sensor_flags >> 3) & 1 != 0

  sr_passengers_counters:
    seq:
      - id: route_number
        type: u2
      - id: passenger_count_in
        type: u2
      - id: passenger_count_out
        type: u2

enums:
  packet_types:
    0: pt_response
    1: pt_appdata
    2: pt_signed_appdata

  service_types:
    1: service_auth
    2: service_teledata
    4: service_commands
    9: service_firmware
    10: service_ecall

  service_data_types:
    0: sr_record_response
    1: sr_term_identity
    2: sr_module_data
    3: sr_vehicle_data
    4: sr_auth_params
    5: sr_auth_info
    6: sr_service_info
    7: sr_result_code
    16: sr_pos_data
    17: sr_ext_pos_data
    18: sr_ad_sensors_data
    19: sr_counters_data
    20: sr_state_data
    22: sr_loopin_data
    23: sr_abs_dig_sens_data
    24: sr_abs_an_sens_data
    25: sr_abs_cntr_data
    26: sr_abs_loopin_data
    27: sr_liquid_level_sensor
    28: sr_passengers_counters

  result_codes:
    0: egts_pc_ok
    1: egts_pc_in_progress
    128: egts_pc_unk_type
    129: egts_pc_inv_format
    130: egts_pc_inv_id
    131: egts_pc_unsup_type
    132: egts_pc_no_auth
    133: egts_pc_obje_nfnd
    134: egts_pc_evnt_nfnd
    135: egts_pc_srvc_nfnd
    136: egts_pc_srvc_dnd
    137: egts_pc_ttlexp
    138: egts_pc_no_conf
    139: egts_pc_module_fault
    140: egts_pc_module_pwr_off
    141: egts_pc_module_no_pwr
    142: egts_pc_conn_lost
    143: egts_pc_timeout
    144: egts_pc_headcrc_err
    145: egts_pc_datacrc_err
    146: egts_pc_inc_datetime
    147: egts_pc_no_io_dev
    148: egts_pc_no_cmd_supp
    149: egts_pc_ill_op

  record_flags:
    0: ssod_flag
    1: rsod_flag  
    2: group_flag
    3: rp_flag
    4: tmfe_flag
    5: evfe_flag
    6: obfe_flag

  module_types:
    0: mt_hardware
    1: mt_software
    2: mt_firmware

  digital_input_types:
    0: input_1
    1: input_2
    2: input_3
    3: input_4
    4: input_5
    5: input_6
    6: input_7
    7: input_8

  analog_sensor_types:
    0: adc_1
    1: adc_2
    2: adc_3
    3: adc_4
    4: adc_5
    5: adc_6
    6: adc_7
    7: adc_8