meta:
  id: suntech_extended
  title: Suntech Extended GPS Tracker Protocol
  license: MIT
  ks-version: 0.11
  endian: be

doc: |
  Extended Suntech GPS tracker protocol supporting advanced device series
  including ST4000, ST6000 series, marine trackers, and specialized models
  with enhanced features, maritime applications, and IoT sensor integration.

seq:
  - id: message
    type: suntech_extended_message

types:
  suntech_extended_message:
    seq:
      - id: message_format
        type: u1
        doc: Message format indicator
      - id: message_content
        type:
          switch-on: message_format
          cases:
            0x02: compressed_message
            0x03: encrypted_message
            0x04: maritime_message
            0x05: industrial_message
            _: enhanced_text_message

  enhanced_text_message:
    seq:
      - id: message_body
        type: str
        encoding: ASCII
        terminator: 0x0D
        doc: Enhanced text message content
    instances:
      parsed_fields:
        value: message_body.split(";")
      protocol_header:
        value: parsed_fields[0]
      device_id:
        value: parsed_fields[1] 
      message_type:
        value: parsed_fields[2]
      timestamp:
        value: parsed_fields[3]
      enhanced_data:
        value: parse_enhanced_fields(parsed_fields)

  compressed_message:
    doc: Compressed binary format for bandwidth efficiency
    seq:
      - id: compression_type
        type: u1
        enum: compression_types
      - id: data_length
        type: u2
      - id: device_id
        size: 5
        doc: Device identifier
      - id: compressed_payload
        size: data_length - 5
        type:
          switch-on: compression_type
          cases:
            compression_types::zip_basic: zip_compressed_data
            compression_types::zip_enhanced: enhanced_zip_data
            compression_types::lz4: lz4_compressed_data
            _: raw_compressed_data

  encrypted_message:
    doc: Encrypted message format for secure applications
    seq:
      - id: encryption_type
        type: u1
        enum: encryption_types
      - id: key_id
        type: u2
        doc: Encryption key identifier
      - id: iv
        size: 16
        doc: Initialization vector
      - id: encrypted_length
        type: u2
      - id: encrypted_payload
        size: encrypted_length
        doc: Encrypted message data
      - id: auth_tag
        size: 16
        doc: Authentication tag

  maritime_message:
    doc: Maritime-specific tracking for marine applications
    seq:
      - id: vessel_data
        type: vessel_information
      - id: navigation_data
        type: navigation_information
      - id: ais_data
        type: ais_integration
        if: has_ais_data
      - id: weather_data
        type: weather_information
        if: has_weather_data
    instances:
      has_ais_data:
        value: false  # Determined by message parsing
      has_weather_data:
        value: false  # Determined by device capabilities

  industrial_message:
    doc: Industrial IoT applications with specialized sensors
    seq:
      - id: industrial_sensors
        type: industrial_sensor_array
      - id: process_data
        type: process_monitoring
      - id: environmental_conditions
        type: environmental_monitoring
      - id: safety_systems
        type: safety_monitoring

  enhanced_zip_data:
    doc: Enhanced compressed data with additional telemetry
    seq:
      - id: timestamp
        type: u4
        doc: Unix timestamp
      - id: position_data
        type: enhanced_position
      - id: sensor_data
        type: enhanced_sensors
      - id: vehicle_data
        type: enhanced_vehicle
        if: has_vehicle_data
      - id: custom_data
        type: custom_telemetry
        if: has_custom_data
    instances:
      has_vehicle_data:
        value: false
      has_custom_data:
        value: false

  enhanced_position:
    seq:
      - id: latitude_raw
        type: s4
        doc: Latitude × 1000000
      - id: longitude_raw
        type: s4
        doc: Longitude × 1000000
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
        doc: Number of satellites
      - id: gps_status
        type: u1
        doc: GPS status and flags
    instances:
      latitude:
        value: latitude_raw / 1000000.0
      longitude:
        value: longitude_raw / 1000000.0
      speed_kmh:
        value: speed / 10.0
      heading:
        value: course / 10.0
      valid_fix:
        value: (gps_status & 0x01) != 0

  enhanced_sensors:
    seq:
      - id: accelerometer
        type: accelerometer_data
      - id: gyroscope
        type: gyroscope_data
      - id: magnetometer
        type: magnetometer_data
      - id: environmental
        type: environmental_sensors
      - id: proximity
        type: proximity_sensors

  accelerometer_data:
    seq:
      - id: x_axis
        type: s2
        doc: X-axis acceleration (mg)
      - id: y_axis
        type: s2
        doc: Y-axis acceleration (mg)
      - id: z_axis
        type: s2
        doc: Z-axis acceleration (mg)
    instances:
      acceleration_magnitude:
        value: sqrt(x_axis^2 + y_axis^2 + z_axis^2)

  gyroscope_data:
    seq:
      - id: x_rotation
        type: s2
        doc: X-axis rotation (°/s × 10)
      - id: y_rotation
        type: s2
        doc: Y-axis rotation (°/s × 10)
      - id: z_rotation
        type: s2
        doc: Z-axis rotation (°/s × 10)

  magnetometer_data:
    seq:
      - id: x_magnetic
        type: s2
        doc: X-axis magnetic field (µT)
      - id: y_magnetic
        type: s2
        doc: Y-axis magnetic field (µT)
      - id: z_magnetic
        type: s2
        doc: Z-axis magnetic field (µT)

  environmental_sensors:
    seq:
      - id: temperature
        type: s2
        doc: Temperature × 100 (°C)
      - id: humidity
        type: u2
        doc: Humidity × 100 (%)
      - id: pressure
        type: u4
        doc: Atmospheric pressure (Pa)
      - id: light_level
        type: u2
        doc: Ambient light (lux)
    instances:
      temperature_celsius:
        value: temperature / 100.0
      humidity_percent:
        value: humidity / 100.0

  proximity_sensors:
    seq:
      - id: ultrasonic_distance
        type: u2
        doc: Ultrasonic distance (cm)
      - id: infrared_presence
        type: u1
        doc: IR presence detection
      - id: rfid_tags
        type: rfid_tag
        repeat: expr
        repeat-expr: rfid_count
    instances:
      rfid_count:
        value: 4  # Maximum RFID tags

  rfid_tag:
    seq:
      - id: tag_id
        size: 8
        doc: RFID tag identifier
      - id: read_strength
        type: u1
        doc: Signal strength

  enhanced_vehicle:
    seq:
      - id: can_bus_data
        type: enhanced_can_data
      - id: obd_diagnostics
        type: enhanced_obd_data
      - id: fuel_monitoring
        type: enhanced_fuel_data
      - id: driver_behavior
        type: driver_behavior_data

  enhanced_can_data:
    seq:
      - id: engine_rpm
        type: u2
        doc: Engine RPM
      - id: vehicle_speed
        type: u1
        doc: Vehicle speed (km/h)
      - id: throttle_position
        type: u1
        doc: Throttle position (%)
      - id: brake_pressure
        type: u2
        doc: Brake pressure (kPa)
      - id: steering_angle
        type: s2
        doc: Steering wheel angle (degrees)
      - id: gear_position
        type: u1
        doc: Current gear position
      - id: clutch_position
        type: u1
        doc: Clutch pedal position (%)

  enhanced_obd_data:
    seq:
      - id: diagnostic_codes
        type: diagnostic_code
        repeat: expr
        repeat-expr: dtc_count
      - id: fuel_consumption
        type: u2
        doc: Fuel consumption (L/100km × 10)
      - id: engine_load
        type: u1
        doc: Engine load (%)
      - id: coolant_temperature
        type: s1
        doc: Coolant temperature (°C)
      - id: oil_pressure
        type: u2
        doc: Oil pressure (kPa)
    instances:
      dtc_count:
        value: 5  # Maximum DTCs

  diagnostic_code:
    seq:
      - id: code
        type: u2
        doc: DTC code
      - id: status
        type: u1
        doc: Code status

  enhanced_fuel_data:
    seq:
      - id: fuel_level_1
        type: u2
        doc: Primary fuel tank level (%)
      - id: fuel_level_2
        type: u2
        doc: Secondary fuel tank level (%)
      - id: fuel_temperature
        type: s1
        doc: Fuel temperature (°C)
      - id: consumption_rate
        type: u2
        doc: Current consumption rate (L/h × 10)
      - id: total_consumed
        type: u4
        doc: Total fuel consumed (mL)

  driver_behavior_data:
    seq:
      - id: harsh_acceleration_count
        type: u1
        doc: Harsh acceleration events
      - id: harsh_braking_count
        type: u1
        doc: Harsh braking events
      - id: sharp_turn_count
        type: u1
        doc: Sharp turn events
      - id: overspeed_duration
        type: u2
        doc: Overspeed duration (seconds)
      - id: idle_time
        type: u2
        doc: Engine idle time (minutes)
      - id: driving_score
        type: u1
        doc: Overall driving score (0-100)

  vessel_information:
    doc: Maritime vessel-specific data
    seq:
      - id: vessel_type
        type: u1
        enum: vessel_types
      - id: mmsi
        type: u4
        doc: Maritime Mobile Service Identity
      - id: imo_number
        type: u4
        doc: International Maritime Organization number
      - id: call_sign
        size: 8
        type: str
        encoding: ASCII
        doc: Vessel call sign
      - id: vessel_name
        size: 20
        type: str
        encoding: ASCII
        doc: Vessel name

  navigation_information:
    seq:
      - id: navigation_status
        type: u1
        enum: navigation_status_types
      - id: rate_of_turn
        type: s2
        doc: Rate of turn (degrees/minute × 10)
      - id: speed_over_ground
        type: u2
        doc: Speed over ground (knots × 10)
      - id: course_over_ground
        type: u2
        doc: Course over ground (degrees × 10)
      - id: true_heading
        type: u2
        doc: True heading (degrees × 10)
      - id: water_depth
        type: u2
        doc: Water depth (meters)
      - id: wind_speed
        type: u1
        doc: Wind speed (knots)
      - id: wind_direction
        type: u2
        doc: Wind direction (degrees)

  ais_integration:
    seq:
      - id: ais_enabled
        type: u1
        doc: AIS transceiver status
      - id: nearby_vessels
        type: nearby_vessel
        repeat: expr
        repeat-expr: vessel_count
    instances:
      vessel_count:
        value: 10  # Maximum nearby vessels

  nearby_vessel:
    seq:
      - id: mmsi
        type: u4
        doc: Vessel MMSI
      - id: distance
        type: u2
        doc: Distance (meters)
      - id: bearing
        type: u2
        doc: Bearing (degrees)
      - id: vessel_type
        type: u1
        enum: vessel_types

  weather_information:
    seq:
      - id: air_temperature
        type: s2
        doc: Air temperature × 10 (°C)
      - id: water_temperature
        type: s2
        doc: Water temperature × 10 (°C)
      - id: barometric_pressure
        type: u4
        doc: Barometric pressure (Pa)
      - id: visibility
        type: u2
        doc: Visibility (meters)
      - id: wave_height
        type: u1
        doc: Wave height (decimeters)
      - id: sea_state
        type: u1
        enum: sea_states

  industrial_sensor_array:
    seq:
      - id: process_sensors
        type: process_sensor
        repeat: expr
        repeat-expr: sensor_count
    instances:
      sensor_count:
        value: 16  # Industrial sensor count

  process_sensor:
    seq:
      - id: sensor_id
        type: u2
        doc: Sensor identifier
      - id: sensor_type
        type: u1
        enum: industrial_sensor_types
      - id: value_raw
        type: u4
        doc: Raw sensor value
      - id: unit_type
        type: u1
        enum: measurement_units
      - id: calibration_offset
        type: s2
        doc: Calibration offset
      - id: calibration_scale
        type: u2
        doc: Calibration scale factor

  process_monitoring:
    seq:
      - id: process_state
        type: u1
        enum: process_states
      - id: production_rate
        type: u4
        doc: Production rate (units/hour)
      - id: efficiency_rating
        type: u1
        doc: Process efficiency (%)
      - id: quality_metrics
        type: quality_metric
        repeat: expr
        repeat-expr: 5

  quality_metric:
    seq:
      - id: metric_type
        type: u1
        doc: Quality metric type
      - id: metric_value
        type: u2
        doc: Quality value

  environmental_monitoring:
    seq:
      - id: air_quality_index
        type: u1
        doc: Air quality index (0-500)
      - id: noise_level
        type: u1
        doc: Ambient noise level (dB)
      - id: radiation_level
        type: u2
        doc: Radiation level (µSv/h)
      - id: chemical_sensors
        type: chemical_sensor
        repeat: expr
        repeat-expr: 8

  chemical_sensor:
    seq:
      - id: chemical_type
        type: u1
        enum: chemical_types
      - id: concentration
        type: u4
        doc: Concentration (ppb)

  safety_monitoring:
    seq:
      - id: safety_status
        type: u1
        doc: Overall safety status
      - id: emergency_systems
        type: emergency_system
        repeat: expr
        repeat-expr: 4
      - id: personnel_count
        type: u1
        doc: Personnel present
      - id: evacuation_status
        type: u1
        doc: Evacuation system status

  emergency_system:
    seq:
      - id: system_type
        type: u1
        enum: emergency_system_types
      - id: system_status
        type: u1
        doc: System operational status
      - id: last_test_time
        type: u4
        doc: Last system test timestamp

  custom_telemetry:
    seq:
      - id: custom_fields
        type: custom_field
        repeat: expr
        repeat-expr: field_count
    instances:
      field_count:
        value: 8  # Configurable custom fields

  custom_field:
    seq:
      - id: field_id
        type: u1
        doc: Custom field identifier
      - id: data_type
        type: u1
        enum: data_types
      - id: field_data
        size: 4
        doc: Field data (format depends on type)

  zip_compressed_data:
    seq:
      - id: compressed_data
        size-eos: true

  lz4_compressed_data:
    seq:
      - id: compressed_data
        size-eos: true

  raw_compressed_data:
    seq:
      - id: raw_data
        size-eos: true

enums:
  compression_types:
    0x01: zip_basic
    0x02: zip_enhanced
    0x03: lz4
    0x04: gzip
    0x05: custom

  encryption_types:
    0x01: aes_128_gcm
    0x02: aes_256_gcm
    0x03: chacha20_poly1305
    0x04: custom_encryption

  vessel_types:
    0: not_available
    20: wing_in_ground
    30: fishing
    31: towing
    32: towing_large
    33: dredging
    34: diving_ops
    35: military_ops
    36: sailing
    37: pleasure_craft
    40: high_speed_craft
    50: pilot_vessel
    51: search_rescue
    52: tug
    53: port_tender
    54: anti_pollution
    55: law_enforcement
    56: spare_local_1
    57: spare_local_2
    58: medical_transport
    59: noncombatant
    60: passenger
    70: cargo
    80: tanker
    90: other

  navigation_status_types:
    0: under_way_using_engine
    1: at_anchor
    2: not_under_command
    3: restricted_manoeuvrability
    4: constrained_by_her_draught
    5: moored
    6: aground
    7: engaged_in_fishing
    8: under_way_sailing
    15: not_defined

  sea_states:
    0: calm_glassy
    1: calm_rippled
    2: smooth_wavelets
    3: slight
    4: moderate
    5: rough
    6: very_rough
    7: high
    8: very_high
    9: phenomenal

  industrial_sensor_types:
    0x01: pressure_sensor
    0x02: flow_sensor
    0x03: level_sensor
    0x04: temperature_sensor
    0x05: vibration_sensor
    0x06: current_sensor
    0x07: voltage_sensor
    0x08: ph_sensor
    0x09: conductivity_sensor
    0x0A: dissolved_oxygen

  measurement_units:
    0x01: celsius
    0x02: fahrenheit
    0x03: kelvin
    0x04: pascal
    0x05: bar
    0x06: psi
    0x07: meters_per_second
    0x08: liters_per_minute
    0x09: cubic_meters_per_hour
    0x0A: percent
    0x0B: ppm
    0x0C: ppb

  process_states:
    0x00: idle
    0x01: starting
    0x02: running
    0x03: stopping
    0x04: emergency_stop
    0x05: maintenance
    0x06: error

  chemical_types:
    0x01: carbon_monoxide
    0x02: carbon_dioxide
    0x03: methane
    0x04: hydrogen_sulfide
    0x05: ammonia
    0x06: chlorine
    0x07: ozone
    0x08: nitrogen_dioxide

  emergency_system_types:
    0x01: fire_detection
    0x02: gas_detection
    0x03: evacuation_alarm
    0x04: emergency_lighting

  data_types:
    0x01: unsigned_integer
    0x02: signed_integer
    0x03: float
    0x04: boolean
    0x05: string
    0x06: timestamp

  device_series:
    st4000: st_4000_advanced
    st4300: st_4300_professional
    st4500: st_4500_enterprise
    st6000: st_6000_maritime
    st6100: st_6100_vessel
    st6200: st_6200_commercial
    st8000: st_8000_industrial
    st8100: st_8100_process
    st8200: st_8200_safety