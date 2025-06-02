meta:
  id: meitrack_extended
  title: Meitrack Extended GPS Tracking Protocol  
  license: MIT
  ks-version: 0.11
  endian: le

doc: |
  Extended Meitrack GPS tracking protocol supporting advanced device series
  including MVT series, T series professional trackers, and specialized models
  with enhanced telemetry, CAN bus integration, and IoT sensor capabilities.

seq:
  - id: message
    type: meitrack_extended_message

types:
  meitrack_extended_message:
    seq:
      - id: format_indicator
        type: u2
        doc: Message format (0x2424 for text, binary otherwise)
      - id: message_content
        type:
          switch-on: format_indicator
          cases:
            0x2424: advanced_text_message
            _: enhanced_binary_message

  advanced_text_message:
    seq:
      - id: message_body
        type: str
        encoding: ASCII
        terminator: 0x0D
        doc: Message content until carriage return
      - id: line_feed
        type: u1
        doc: Line feed character (0x0A)
    instances:
      parsed_fields:
        value: message_body.split(",")
      message_flag:
        value: parsed_fields[0].substring(0, 1)
      data_length:
        value: parsed_fields[0].substring(1).to_i
      device_imei:
        value: parsed_fields[1]
      command_word:
        value: parsed_fields[2]
      event_code:
        value: parsed_fields[3]

  enhanced_binary_message:
    seq:
      - id: header_flag
        type: u2
        doc: Binary message header
      - id: data_length
        type: u2
        doc: Message payload length
      - id: imei
        size: 8
        doc: Device IMEI (BCD encoded)
      - id: command_word
        type: u2
        doc: Command identifier
      - id: payload
        size: data_length - 12
        type:
          switch-on: command_word
          cases:
            0x9955: mvt_position_data
            0x9966: can_bus_data
            0x9977: sensor_data_extended
            0x9988: camera_data
            0x9999: maintenance_data
            _: generic_binary_payload
      - id: checksum
        type: u2
        doc: Message checksum

  mvt_position_data:
    doc: Enhanced position data for MVT professional series
    seq:
      - id: gps_data
        type: enhanced_gps_info
      - id: gsm_data
        type: enhanced_gsm_info
      - id: status_data
        type: enhanced_status_info
      - id: vehicle_data
        type: enhanced_vehicle_info
      - id: sensor_readings
        type: advanced_sensor_array
        if: has_sensor_data
    instances:
      has_sensor_data:
        value: _io.eof == false

  enhanced_gps_info:
    seq:
      - id: timestamp
        type: u4
        doc: Unix timestamp
      - id: latitude_raw
        type: s4
        doc: Latitude × 600000
      - id: longitude_raw
        type: s4
        doc: Longitude × 600000
      - id: altitude
        type: s2
        doc: Altitude in meters
      - id: speed
        type: u2
        doc: Speed in km/h × 10
      - id: course
        type: u2
        doc: Course in degrees × 10
      - id: hdop
        type: u1
        doc: Horizontal dilution of precision
      - id: satellite_count
        type: u1
        doc: Number of satellites used
      - id: gps_status
        type: u1
        doc: GPS fix status flags
    instances:
      latitude:
        value: latitude_raw / 600000.0
      longitude:
        value: longitude_raw / 600000.0
      speed_kmh:
        value: speed / 10.0
      heading:
        value: course / 10.0
      valid_fix:
        value: (gps_status & 0x01) != 0

  enhanced_gsm_info:
    seq:
      - id: mcc
        type: u2
        doc: Mobile Country Code
      - id: mnc
        type: u2
        doc: Mobile Network Code
      - id: lac
        type: u4
        doc: Location Area Code
      - id: cell_id
        type: u4
        doc: Cell tower ID
      - id: signal_strength
        type: u1
        doc: Signal strength (0-31)
      - id: network_type
        type: u1
        enum: network_types
      - id: neighbor_cells
        type: neighbor_cell
        repeat: expr
        repeat-expr: neighbor_count
    instances:
      neighbor_count:
        value: 3  # Typical neighbor cell count

  enhanced_status_info:
    seq:
      - id: power_voltage
        type: u2
        doc: Main power voltage (mV)
      - id: battery_voltage
        type: u2
        doc: Backup battery voltage (mV)
      - id: battery_level
        type: u1
        doc: Battery charge percentage
      - id: device_temperature
        type: s1
        doc: Internal temperature (°C)
      - id: digital_inputs
        type: u2
        doc: Digital input states (16 bits)
      - id: digital_outputs
        type: u2
        doc: Digital output states (16 bits)
      - id: analog_inputs
        type: u2
        repeat: expr
        repeat-expr: 4
        doc: Analog input readings (mV)
    instances:
      ignition_on:
        value: (digital_inputs & 0x0001) != 0
      door_open:
        value: (digital_inputs & 0x0002) != 0
      alarm_triggered:
        value: (digital_inputs & 0x0004) != 0
      panic_button:
        value: (digital_inputs & 0x0008) != 0

  enhanced_vehicle_info:
    seq:
      - id: odometer
        type: u4
        doc: Vehicle odometer (meters)
      - id: engine_hours
        type: u4
        doc: Engine runtime (seconds)
      - id: fuel_level
        type: u2
        doc: Fuel level (0.1% resolution)
      - id: engine_rpm
        type: u2
        doc: Engine RPM
      - id: vehicle_speed
        type: u1
        doc: Vehicle speed from OBD (km/h)
      - id: coolant_temperature
        type: s1
        doc: Engine coolant temperature (°C)
      - id: engine_load
        type: u1
        doc: Engine load percentage
      - id: throttle_position
        type: u1
        doc: Throttle position percentage
    instances:
      odometer_km:
        value: odometer / 1000.0
      engine_hours_display:
        value: engine_hours / 3600.0
      fuel_percentage:
        value: fuel_level / 10.0

  advanced_sensor_array:
    seq:
      - id: sensor_count
        type: u1
        doc: Number of connected sensors
      - id: sensors
        type: advanced_sensor
        repeat: expr
        repeat-expr: sensor_count

  advanced_sensor:
    seq:
      - id: sensor_id
        type: u2
        doc: Sensor identifier
      - id: sensor_type
        type: u1
        enum: sensor_types
      - id: sensor_data
        type:
          switch-on: sensor_type
          cases:
            sensor_types::temperature: temperature_sensor
            sensor_types::humidity: humidity_sensor
            sensor_types::pressure: pressure_sensor
            sensor_types::fuel: fuel_sensor
            sensor_types::weight: weight_sensor
            sensor_types::rfid: rfid_sensor
            sensor_types::camera: camera_sensor
            _: generic_sensor

  temperature_sensor:
    seq:
      - id: temperature_raw
        type: s2
        doc: Temperature × 100 (°C)
      - id: sensor_status
        type: u1
        doc: Sensor status flags
    instances:
      temperature_celsius:
        value: temperature_raw / 100.0
      sensor_active:
        value: (sensor_status & 0x01) != 0

  humidity_sensor:
    seq:
      - id: humidity_raw
        type: u2
        doc: Humidity × 100 (%)
      - id: sensor_status
        type: u1
    instances:
      humidity_percent:
        value: humidity_raw / 100.0

  pressure_sensor:
    seq:
      - id: pressure_raw
        type: u4
        doc: Pressure in Pa
      - id: sensor_status
        type: u1
    instances:
      pressure_kpa:
        value: pressure_raw / 1000.0

  fuel_sensor:
    seq:
      - id: fuel_volume
        type: u2
        doc: Fuel volume in liters × 10
      - id: fuel_percentage
        type: u1
        doc: Fuel level percentage
    instances:
      fuel_liters:
        value: fuel_volume / 10.0

  weight_sensor:
    seq:
      - id: weight_raw
        type: u4
        doc: Weight in grams
      - id: tare_weight
        type: u4
        doc: Tare weight in grams
    instances:
      weight_kg:
        value: weight_raw / 1000.0
      net_weight_kg:
        value: (weight_raw - tare_weight) / 1000.0

  rfid_sensor:
    seq:
      - id: card_id
        size: 8
        doc: RFID card identifier
      - id: read_timestamp
        type: u4
        doc: Card read timestamp
    instances:
      card_hex:
        value: card_id.to_hex

  camera_sensor:
    seq:
      - id: camera_id
        type: u1
        doc: Camera identifier
      - id: photo_id
        type: u4
        doc: Photo sequence number
      - id: photo_size
        type: u4
        doc: Photo file size
      - id: resolution
        type: u2
        doc: Photo resolution code

  generic_sensor:
    seq:
      - id: data
        size-eos: true

  can_bus_data:
    doc: CAN bus diagnostic data for professional vehicle tracking
    seq:
      - id: can_protocol
        type: u1
        enum: can_protocols
      - id: message_count
        type: u1
        doc: Number of CAN messages
      - id: can_messages
        type: can_message
        repeat: expr
        repeat-expr: message_count

  can_message:
    seq:
      - id: can_id
        type: u4
        doc: CAN message identifier
      - id: data_length
        type: u1
        doc: CAN data length (0-8)
      - id: can_data
        size: data_length
        doc: CAN message data
      - id: timestamp
        type: u4
        doc: Message timestamp

  sensor_data_extended:
    doc: Extended sensor data for specialized applications
    seq:
      - id: environmental_data
        type: environmental_sensors
      - id: security_data
        type: security_sensors
      - id: maintenance_data
        type: maintenance_sensors

  environmental_sensors:
    seq:
      - id: ambient_temperature
        type: s2
        doc: Ambient temperature × 100
      - id: ambient_humidity
        type: u2
        doc: Ambient humidity × 100
      - id: atmospheric_pressure
        type: u4
        doc: Atmospheric pressure (Pa)
      - id: light_level
        type: u2
        doc: Ambient light level (lux)
    instances:
      temperature_c:
        value: ambient_temperature / 100.0
      humidity_pct:
        value: ambient_humidity / 100.0

  security_sensors:
    seq:
      - id: motion_detection
        type: u1
        doc: Motion sensor status
      - id: tamper_detection
        type: u1
        doc: Tamper sensor status
      - id: glass_break
        type: u1
        doc: Glass break sensor
      - id: door_sensors
        type: u1
        doc: Door sensor states
    instances:
      motion_detected:
        value: motion_detection > 0
      device_tampered:
        value: tamper_detection > 0

  maintenance_sensors:
    seq:
      - id: vibration_level
        type: u2
        doc: Vibration intensity
      - id: operating_hours
        type: u4
        doc: Equipment operating hours
      - id: cycle_count
        type: u4
        doc: Operation cycle count
      - id: maintenance_due
        type: u1
        doc: Maintenance due flag

  camera_data:
    doc: Camera integration and photo management
    seq:
      - id: camera_count
        type: u1
        doc: Number of cameras
      - id: cameras
        type: camera_info
        repeat: expr
        repeat-expr: camera_count

  camera_info:
    seq:
      - id: camera_id
        type: u1
        doc: Camera identifier
      - id: photo_count
        type: u2
        doc: Number of photos
      - id: video_duration
        type: u2
        doc: Video length (seconds)
      - id: storage_used
        type: u4
        doc: Storage used (bytes)
      - id: last_photo_timestamp
        type: u4
        doc: Last photo timestamp

  maintenance_data:
    doc: Vehicle maintenance and diagnostic information
    seq:
      - id: diagnostic_codes
        type: diagnostic_code
        repeat: expr
        repeat-expr: code_count
      - id: maintenance_alerts
        type: maintenance_alert
        repeat: expr
        repeat-expr: alert_count
    instances:
      code_count:
        value: 5  # Typical DTC count
      alert_count:
        value: 3  # Typical alert count

  diagnostic_code:
    seq:
      - id: dtc_code
        type: u2
        doc: Diagnostic trouble code
      - id: dtc_status
        type: u1
        doc: Code status (active/pending/stored)
      - id: occurrence_count
        type: u1
        doc: Number of occurrences

  maintenance_alert:
    seq:
      - id: alert_type
        type: u1
        enum: maintenance_types
      - id: severity
        type: u1
        doc: Alert severity level
      - id: remaining_distance
        type: u4
        doc: Distance until maintenance (km)
      - id: remaining_time
        type: u4
        doc: Time until maintenance (hours)

  neighbor_cell:
    seq:
      - id: cell_id
        type: u2
      - id: signal_strength
        type: u1

  generic_binary_payload:
    seq:
      - id: data
        size-eos: true

enums:
  network_types:
    0: gsm_2g
    1: umts_3g
    2: lte_4g
    3: nb_iot
    4: cat_m1

  sensor_types:
    0x01: temperature
    0x02: humidity
    0x03: pressure
    0x04: fuel
    0x05: weight
    0x06: rfid
    0x07: camera
    0x08: motion
    0x09: door
    0x0A: vibration

  can_protocols:
    0x01: j1939
    0x02: obd2
    0x03: j1708
    0x04: iso15765
    0x05: kwp2000

  maintenance_types:
    0x01: oil_change
    0x02: tire_rotation
    0x03: brake_inspection
    0x04: filter_replacement
    0x05: battery_check
    0x06: scheduled_service

  message_flags:
    A: position_report
    B: heartbeat
    C: alarm_report
    D: answer_phone
    E: status_report
    F: configuration
    G: information_report

  event_codes:
    0x01: sos_alarm
    0x02: power_cut_alarm
    0x03: vibration_alarm
    0x04: fence_in_alarm
    0x05: fence_out_alarm
    0x06: overspeed_alarm
    0x07: movement_alarm
    0x08: gps_blind_area
    0x09: power_low_alarm
    0x0A: power_off_alarm
    0x0B: gps_antenna_cut
    0x0C: gps_antenna_short
    0x0D: power_low_protect
    0x0E: power_off_protect
    0x0F: auto_defense
    0x10: auto_undefense
    0x11: sim_door_open

  device_series:
    mvt380: mvt_380_professional
    mvt600: mvt_600_advanced
    mvt800: mvt_800_enterprise
    t333: t_333_basic
    t366: t_366_enhanced
    t399: t_399_premium
    tc68s: tc_68s_personal
    tc68sg: tc_68sg_senior
    mt90g: mt_90g_standard