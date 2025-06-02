meta:
  id: sigfox
  title: Sigfox IoT Network Protocol
  license: MIT
  ks-version: 0.11
  endian: be

doc: |
  Sigfox IoT network protocol supporting ultra-narrowband (UNB) communication with
  12-byte maximum payload. The protocol uses HTTP/JSON delivery with binary payloads
  for low-power wide-area IoT applications.

seq:
  - id: sigfox_message
    type: sigfox_http_message

types:
  sigfox_http_message:
    doc: |
      HTTP/JSON message from Sigfox backend containing device data, metadata,
      and binary payload from IoT sensors.
    seq:
      - id: device_id
        type: str
        encoding: UTF-8
        doc: Unique Sigfox device identifier (6-character hex)
      - id: time
        type: u4
        doc: Unix timestamp (seconds since epoch)
      - id: data
        type: str
        encoding: UTF-8
        doc: Hex-encoded binary payload (0-24 characters = 0-12 bytes)
        if: has_data_field
      - id: payload
        type: str
        encoding: UTF-8
        doc: Alternative hex-encoded payload field
        if: has_payload_field
      - id: seq_number
        type: u2
        doc: Message sequence number
      - id: snr
        type: f8
        doc: Signal-to-noise ratio in dB
        if: has_snr_field
      - id: rssi
        type: f8
        doc: Received signal strength indicator in dBm
        if: has_rssi_field
      - id: station
        type: str
        encoding: UTF-8
        doc: Receiving base station identifier
        if: has_station_field
      - id: duplicate
        type: u1
        doc: Duplicate message flag (boolean)
        if: has_duplicate_field
      - id: location
        type: location_data
        if: has_location_field
      - id: latitude
        type: f8
        doc: GPS latitude in decimal degrees
        if: has_direct_coordinates and not has_location_field
      - id: longitude
        type: f8
        doc: GPS longitude in decimal degrees
        if: has_direct_coordinates and not has_location_field
      - id: position_time
        type: u4
        doc: Position timestamp (Unix seconds)
        if: has_position_time_field
      - id: last_seen
        type: u4
        doc: Last communication timestamp
        if: has_last_seen_field
      - id: moving
        type: u1
        doc: Motion detection flag (boolean)
        if: has_moving_field
      - id: mag_status
        type: u1
        doc: Magnetic tamper status (boolean)
        if: has_mag_status_field
      - id: temperature
        type: f8
        doc: Device temperature in Celsius
        if: has_temperature_field
      - id: battery
        type: f8
        doc: Battery voltage
        if: has_battery_field
      - id: battery_percentage
        type: u1
        doc: Battery level percentage
        if: has_battery_percentage_field
    instances:
      has_data_field:
        value: true  # Simplified - actual implementation would check JSON
      has_payload_field:
        value: false # Alternative to data field
      has_snr_field:
        value: true
      has_rssi_field:
        value: true
      has_station_field:
        value: true
      has_duplicate_field:
        value: true
      has_location_field:
        value: false
      has_direct_coordinates:
        value: false
      has_position_time_field:
        value: false
      has_last_seen_field:
        value: false
      has_moving_field:
        value: false
      has_mag_status_field:
        value: false
      has_temperature_field:
        value: false
      has_battery_field:
        value: false
      has_battery_percentage_field:
        value: false
      binary_payload:
        value: data.length > 0 ? data : payload
      payload_bytes:
        value: binary_payload.length / 2
      device_identifier:
        value: device_id

  location_data:
    seq:
      - id: lat
        type: f8
        doc: Latitude in decimal degrees
      - id: lng
        type: f8
        doc: Longitude in decimal degrees
      - id: radius
        type: u2
        doc: Location accuracy radius in meters
      - id: source
        type: u1
        doc: Location source (1=GPS, 2=network)
      - id: status
        type: u1
        doc: Location status (1=valid)
    instances:
      is_gps_location:
        value: source == 1
      is_valid_location:
        value: status == 1

  sigfox_binary_payload:
    doc: |
      Binary payload parser for common Sigfox device formats.
      Supports multiple device types with different encoding schemes.
    seq:
      - id: payload_data
        size-eos: true
        type:
          switch-on: _parent.payload_bytes
          cases:
            1: payload_1_byte
            4: payload_4_bytes
            8: payload_8_bytes
            12: payload_12_bytes
    instances:
      is_position_payload:
        value: _parent.payload_bytes >= 8
      is_sensor_payload:
        value: _parent.payload_bytes <= 4

  payload_1_byte:
    seq:
      - id: event_code
        type: u1
        doc: Single-byte event or status code
    instances:
      is_sos_event:
        value: event_code == 0x22 or event_code == 0x62
      is_panic_button:
        value: event_code == 0x62

  payload_4_bytes:
    seq:
      - id: header
        type: u1
        doc: Message type header
      - id: data
        size: 3
        doc: 3 bytes of payload data
    instances:
      message_type:
        value: header

  payload_8_bytes:
    seq:
      - id: header
        type: u1
        doc: Message format identifier
      - id: payload_content
        size: 7
        type:
          switch-on: header
          cases:
            0x0f: position_payload_valid
            0x1f: position_payload_valid
            _: generic_8_byte_payload
    instances:
      has_valid_position:
        value: header == 0x0f or header == 0x1f
      position_valid:
        value: (header >> 4) > 0

  payload_12_bytes:
    seq:
      - id: header
        type: u1
        doc: Message format identifier
      - id: payload_content
        size: 11
        type:
          switch-on: header & 0xf0
          cases:
            0x00: position_12_byte_payload
            0x10: amber_device_payload
            _: generic_12_byte_payload
    instances:
      format_type:
        value: header >> 4
      sub_type:
        value: header & 0x0f

  position_payload_valid:
    seq:
      - id: latitude_raw
        type: s4
        doc: Signed magnitude latitude
      - id: longitude_raw
        type: s4
        doc: Signed magnitude longitude
      - id: battery_level
        type: u1
        doc: Battery level (0-255)
    instances:
      latitude:
        value: latitude_raw * 0.000001
      longitude:
        value: longitude_raw * 0.000001
      battery_voltage:
        value: battery_level

  position_12_byte_payload:
    seq:
      - id: flags
        type: u1
        doc: Status flags
      - id: latitude_raw
        type: s4le
        doc: Latitude in little-endian format
      - id: longitude_raw
        type: s4le
        doc: Longitude in little-endian format
      - id: course
        type: u1
        doc: Course/heading (×2 degrees)
      - id: speed
        type: u1
        doc: Speed in km/h
      - id: battery_raw
        type: u1
        doc: Battery voltage raw value
    instances:
      latitude:
        value: latitude_raw * 0.0000001
      longitude:
        value: longitude_raw * 0.0000001
      heading:
        value: course * 2
      speed_kph:
        value: speed
      battery_voltage:
        value: battery_raw * 0.025

  amber_device_payload:
    seq:
      - id: flags
        type: u1
        doc: Device status flags
      - id: battery_raw
        type: u1
        doc: Battery level (×0.02V)
      - id: temperature
        type: s1
        doc: Temperature in Celsius
      - id: latitude_raw
        type: s4
        doc: Latitude (÷60000)
      - id: longitude_raw
        type: s4
        doc: Longitude (÷60000)
    instances:
      motion_detected:
        value: (flags & 0x02) != 0
      battery_voltage:
        value: battery_raw * 0.02
      device_temperature:
        value: temperature
      latitude:
        value: latitude_raw / 60000.0
      longitude:
        value: longitude_raw / 60000.0

  generic_8_byte_payload:
    seq:
      - id: data
        size: 7
        doc: Generic 7-byte payload

  generic_12_byte_payload:
    seq:
      - id: data
        size: 11
        doc: Generic 11-byte payload

  structured_payload:
    doc: |
      Alternative payload format with structured type-length-value fields
      for custom device implementations.
    seq:
      - id: event_code
        type: u1
        doc: Event type identifier
      - id: fields
        type: payload_field
        repeat: until
        repeat-until: _io.eof
    instances:
      is_sos_alert:
        value: event_code == 0x22 or event_code == 0x62

  payload_field:
    seq:
      - id: field_type
        type: u1
        doc: Field type identifier
      - id: field_data
        type:
          switch-on: field_type
          cases:
            0x01: position_medium_precision
            0x02: position_float_precision
            0x03: temperature_field
            0x04: battery_voltage_field
            0x05: battery_percentage_field
            0x06: wifi_beacon_field
            0x07: wifi_extended_field
            0x08: accelerometer_field
            0x09: speed_field
            _: fence_number_field

  position_medium_precision:
    seq:
      - id: latitude_raw
        type: u3
        doc: 24-bit latitude
      - id: longitude_raw
        type: u3
        doc: 24-bit longitude
    instances:
      latitude:
        value: latitude_raw
      longitude:
        value: longitude_raw

  position_float_precision:
    seq:
      - id: latitude
        type: f4
        doc: 32-bit float latitude
      - id: longitude
        type: f4
        doc: 32-bit float longitude

  temperature_field:
    seq:
      - id: temperature_raw
        type: s1
        doc: Temperature in 0.5°C units
    instances:
      temperature_celsius:
        value: temperature_raw * 0.5

  battery_voltage_field:
    seq:
      - id: voltage_raw
        type: u1
        doc: Battery voltage in 0.1V units
    instances:
      voltage:
        value: voltage_raw * 0.1

  battery_percentage_field:
    seq:
      - id: percentage
        type: u1
        doc: Battery percentage (0-100)

  wifi_beacon_field:
    seq:
      - id: mac_address
        size: 6
        doc: WiFi MAC address
      - id: signal_strength
        type: u1
        doc: WiFi signal strength

  wifi_extended_field:
    seq:
      - id: extended_data
        size: 10
        doc: Extended WiFi data

  accelerometer_field:
    seq:
      - id: accel_data
        size: 6
        doc: 3-axis accelerometer data

  speed_field:
    seq:
      - id: speed_kph
        type: u1
        doc: Speed in km/h

  fence_number_field:
    seq:
      - id: fence_id
        type: u1
        doc: Geofence identifier

enums:
  message_types:
    0x0f: position_valid
    0x1f: position_valid_alt
    0x22: sos_event
    0x62: panic_button

  device_types:
    amber: amber_tracker
    generic: generic_iot
    structured: structured_payload

  location_sources:
    1: gps_location
    2: network_location
    3: hybrid_location

  payload_field_types:
    0x01: position_medium
    0x02: position_float
    0x03: temperature
    0x04: battery_voltage
    0x05: battery_percentage
    0x06: wifi_beacon
    0x07: wifi_extended
    0x08: accelerometer
    0x09: speed
    0x0a: fence_number

  event_codes:
    0x20: position_report
    0x22: sos_alarm
    0x62: panic_button
    0x40: sensor_data
    0x80: device_status

  sigfox_regions:
    1: europe
    2: usa_canada
    3: asia_pacific
    4: south_america