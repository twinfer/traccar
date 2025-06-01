meta:
  id: gl200
  title: Queclink GL200 GPS Tracker Protocol
  endian: be
  file-extension: gl200
  
doc: |
  Queclink GL200 protocol parser for GPS tracking devices.
  This protocol is primarily text-based with comma-separated values.
  Messages start with +RESP:, +BUFF:, or +ACK: and may end with $.

seq:
  - id: message
    type: text_message
    
types:
  text_message:
    seq:
      - id: prefix
        type: str
        encoding: ASCII
        terminator: 0x3A  # ':'
        doc: Message prefix (+RESP, +BUFF, or +ACK)
        
      - id: message_type
        type: str
        size: 3
        encoding: ASCII
        doc: Three-letter message type code
        
      - id: comma1
        contents: ","
        
      - id: content
        type:
          switch-on: message_type
          cases:
            '"FRI"': fri_message
            '"ERI"': eri_message
            '"IGN"': event_message
            '"IGF"': event_message
            '"STT"': event_message
            '"STP"': event_message
            '"SOS"': event_message
            '"SPD"': event_message
            '"TOW"': event_message
            '"HBM"': hbm_message
            '"GEO"': geo_message
            '"OBD"': obd_message
            '"CAN"': can_message
            '"INF"': inf_message
            '"GSM"': gsm_message
            '"WIF"': wif_message
            '"BAA"': baa_message
            '"BID"': bid_message
            '"LSA"': lsa_message
            '"TMP"': tmp_message
            '"TEM"': tem_message
            '"DAR"': dar_message
            '"DTT"': dtt_message
            '"ACK"': ack_message
            _: generic_message
            
  # Fixed Report Information (regular position reports)
  fri_message:
    seq:
      - id: protocol_version
        type: str
        encoding: ASCII
        terminator: 0x2C  # ','
        
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: device_name
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: report_id
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: number
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: positions
        type: position_record
        repeat: expr
        repeat-expr: _root.parse_int(number)
        
      - id: odometer
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: hour_meter
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: adc_data
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: cell_info
        type: cell_tower
        
      - id: battery
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: report_time
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: count_number
        type: str
        encoding: ASCII
        terminator: 0x24  # '$' or next ','
        
  # Extended Report Information (with optional fields based on mask)
  eri_message:
    seq:
      - id: protocol_version
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: device_name
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: report_mask
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Hex value indicating which optional fields are present
        
      - id: report_id
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: number
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      # Optional fields based on report mask would follow
      # This is simplified - actual implementation would parse mask
      - id: remaining_data
        type: str
        encoding: ASCII
        terminator: 0x24
        
  # Event messages (ignition, motion, etc.)
  event_message:
    seq:
      - id: protocol_version
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: device_name
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: report_id
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: state
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: hours
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: position
        type: position_record
        
      - id: odometer
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: hour_meter
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: remaining_data
        type: str
        encoding: ASCII
        terminator: 0x24
        
  # OBD (On-Board Diagnostics) data
  obd_message:
    seq:
      - id: protocol_version
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: device_name
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: report_mask
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: vin
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Vehicle Identification Number
        
      - id: obd_connect
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: obd_voltage
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: engine_rpm
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: speed
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: coolant_temp
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: fuel_consumption
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: dtc_cleared_distance
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: remaining_data
        type: str
        encoding: ASCII
        terminator: 0x24
        
  # CAN bus data
  can_message:
    seq:
      - id: protocol_version
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: device_name
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: report_mask
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: vin
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: can_bus_state
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: fuel_consumed
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: fuel_level
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: engine_rpm
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: speed
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: remaining_data
        type: str
        encoding: ASCII
        terminator: 0x24
        
  # Harsh Behavior Message
  hbm_message:
    seq:
      - id: protocol_version
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: device_name
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: report_id
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: behavior_type
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: 1=acceleration, 2=braking, 3=cornering
        
      - id: severity
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: position
        type: position_record
        
      - id: remaining_data
        type: str
        encoding: ASCII
        terminator: 0x24
        
  # Geofence alert
  geo_message:
    seq:
      - id: protocol_version
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: device_name
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: report_id
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: fence_id
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: fence_action
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: 0=enter, 1=exit
        
      - id: position
        type: position_record
        
      - id: remaining_data
        type: str
        encoding: ASCII
        terminator: 0x24
        
  # Device information
  inf_message:
    seq:
      - id: protocol_version
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: device_name
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: state
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: iccid
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: csq_rssi
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: csq_ber
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: remaining_data
        type: str
        encoding: ASCII
        terminator: 0x24
        
  # GSM cell information
  gsm_message:
    seq:
      - id: protocol_version
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: device_name
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: cell_count
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: cells
        type: cell_info
        repeat: expr
        repeat-expr: _root.parse_int(cell_count)
        
      - id: remaining_data
        type: str
        encoding: ASCII
        terminator: 0x24
        
  # WiFi information
  wif_message:
    seq:
      - id: protocol_version
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: device_name
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: wifi_count
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: access_points
        type: wifi_ap
        repeat: expr
        repeat-expr: _root.parse_int(wifi_count)
        
      - id: remaining_data
        type: str
        encoding: ASCII
        terminator: 0x24
        
  # Bluetooth accessory data
  baa_message:
    seq:
      - id: protocol_version
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: device_name
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: beacon_count
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: beacons
        type: bluetooth_beacon
        repeat: expr
        repeat-expr: _root.parse_int(beacon_count)
        
      - id: remaining_data
        type: str
        encoding: ASCII
        terminator: 0x24
        
  # Bluetooth ID
  bid_message:
    seq:
      - id: protocol_version
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: device_name
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: beacon_count
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: remaining_data
        type: str
        encoding: ASCII
        terminator: 0x24
        
  # Light sensor alert
  lsa_message:
    seq:
      - id: protocol_version
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: device_name
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: report_id
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: light_status
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: position
        type: position_record
        
      - id: remaining_data
        type: str
        encoding: ASCII
        terminator: 0x24
        
  # Temperature alert
  tmp_message:
    seq:
      - id: protocol_version
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: device_name
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: report_id
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: sensor_count
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: sensors
        type: temp_sensor
        repeat: expr
        repeat-expr: _root.parse_int(sensor_count)
        
      - id: position
        type: position_record
        
      - id: remaining_data
        type: str
        encoding: ASCII
        terminator: 0x24
        
  # Temperature event (simplified version)
  tem_message:
    seq:
      - id: protocol_version
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: device_name
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: temperature
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: position
        type: position_record
        
      - id: remaining_data
        type: str
        encoding: ASCII
        terminator: 0x24
        
  # Driver Alert Report
  dar_message:
    seq:
      - id: protocol_version
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: device_name
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: report_id
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: alert_type
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Fatigue driving detection type
        
      - id: alert_degree
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: position
        type: position_record
        
      - id: remaining_data
        type: str
        encoding: ASCII
        terminator: 0x24
        
  # Data Transmission (custom payload)
  dtt_message:
    seq:
      - id: protocol_version
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: device_name
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: data_type
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: data_length
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: data
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: position
        type: position_record
        
      - id: remaining_data
        type: str
        encoding: ASCII
        terminator: 0x24
        
  # Acknowledgment message
  ack_message:
    seq:
      - id: protocol_version
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: imei
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: device_name
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: message_id
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: event_code
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: checksum
        type: str
        encoding: ASCII
        terminator: 0x24
        
  # Generic message for unhandled types
  generic_message:
    seq:
      - id: data
        type: str
        encoding: ASCII
        terminator: 0x24
        
  # Position record structure
  position_record:
    seq:
      - id: hdop
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: speed
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Speed in km/h
        
      - id: course
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Course in degrees (0-360)
        
      - id: altitude
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Altitude in meters
        
      - id: longitude
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Longitude in decimal degrees
        
      - id: latitude
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Latitude in decimal degrees
        
      - id: timestamp
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: UTC timestamp in yyyyMMddHHmmss format
        
  # Cell tower information
  cell_tower:
    seq:
      - id: mcc
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Mobile Country Code
        
      - id: mnc
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Mobile Network Code
        
      - id: lac
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Location Area Code
        
      - id: cell_id
        type: str
        encoding: ASCII
        terminator: 0x2C
        doc: Cell ID
        
  # Cell information for GSM message
  cell_info:
    seq:
      - id: mcc
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: mnc
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: lac
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: cell_id
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: signal
        type: str
        encoding: ASCII
        terminator: 0x2C
        
  # WiFi access point
  wifi_ap:
    seq:
      - id: mac_address
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: signal_strength
        type: str
        encoding: ASCII
        terminator: 0x2C
        
  # Bluetooth beacon
  bluetooth_beacon:
    seq:
      - id: mac_address
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: rssi
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: battery
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: temperature
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: humidity
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: alert
        type: str
        encoding: ASCII
        terminator: 0x2C
        
  # Temperature sensor
  temp_sensor:
    seq:
      - id: sensor_id
        type: str
        encoding: ASCII
        terminator: 0x2C
        
      - id: temperature
        type: str
        encoding: ASCII
        terminator: 0x2C
        
instances:
  # Helper function to parse integer from string
  parse_int:
    params:
      - id: str_value
        type: str
    value: str_value.to_i