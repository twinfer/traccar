meta:
  id: meiligao
  title: Meiligao GPS Tracker Protocol
  file-extension: meiligao
  endian: be
  encoding: ASCII

seq:
  - id: message
    type: meiligao_frame

types:
  meiligao_frame:
    seq:
      - id: header
        contents: [0x24, 0x24]  # "$$"
      - id: length
        type: u2
      - id: device_id
        type: bcd_device_id
      - id: command_type
        type: u2
      - id: data
        size: data_length
        type:
          switch-on: command_type
          cases:
            0x0001: heartbeat_data
            0x0002: server_request_data
            0x5000: login_request_data
            0x9955: position_report_data
            0x9016: logged_position_data
            0x9999: alarm_data
            0x9966: rfid_data
            0x6688: retransmission_data
            0x9901: obd_realtime_data
            0x9902: obd_additional_data
            0x9903: dtc_data
            0x0800: photo_upload_request
            0x9988: photo_data_packet
            0x9977: position_with_image
            0x0f80: upload_complete
            0x4000: login_response
            0x4101: track_on_demand
            0x4102: track_by_interval
            0x4106: movement_alarm_setup
            0x4114: output_control_1
            0x4115: output_control_2
            0x4132: set_timezone
            0x4151: take_photo
            0x8801: photo_upload_response
            0x4902: reboot_device
            _: raw_data
      - id: crc16
        type: u2
      - id: cr
        contents: [0x0D]
      - id: lf
        contents: [0x0A]
        
    instances:
      data_length:
        value: 'length - 16'  # Total length minus fixed fields (header + length + device_id + command + crc + terminators)
        
  bcd_device_id:
    seq:
      - id: id_bytes
        size: 7
    instances:
      imei_string:
        value: 'decode_bcd_imei(id_bytes)'
        
  heartbeat_data:
    seq: []
    
  server_request_data:
    seq: []
    
  login_request_data:
    seq:
      - id: login_info
        type: str
        size-eos: true
        
  position_report_data:
    seq:
      - id: position_string
        type: str
        size-eos: true
    instances:
      parsed_position:
        type: position_fields
        io: '_io_from_string(position_string)'
        
  logged_position_data:
    seq:
      - id: count
        type: u1
      - id: positions
        type: logged_position_entry
        repeat: expr
        repeat-expr: count
        
  logged_position_entry:
    seq:
      - id: position_string
        type: str
        terminator: 0x5C  # backslash separator
        include: false
    instances:
      parsed_position:
        type: position_fields
        io: '_io_from_string(position_string)'
        
  alarm_data:
    seq:
      - id: alarm_type
        type: u1
      - id: position_string
        type: str
        size-eos: true
    instances:
      parsed_position:
        type: position_fields
        io: '_io_from_string(position_string)'
        
  rfid_data:
    seq:
      - id: rfid_tag
        size: 8
      - id: position_string
        type: str
        size-eos: true
    instances:
      parsed_position:
        type: position_fields
        io: '_io_from_string(position_string)'
        
  retransmission_data:
    seq:
      - id: count
        type: u1
      - id: positions
        type: retrans_position_entry
        repeat: expr
        repeat-expr: count
        
  retrans_position_entry:
    seq:
      - id: position_string
        type: str
        terminator: 0x5C  # backslash separator
        include: false
    instances:
      parsed_position:
        type: position_fields
        io: '_io_from_string(position_string)'
        
  obd_realtime_data:
    seq:
      - id: obd_string
        type: str
        size-eos: true
    instances:
      parsed_obd:
        type: obd_fields
        io: '_io_from_string(obd_string)'
        
  obd_additional_data:
    seq:
      - id: obd_string
        type: str
        size-eos: true
        
  dtc_data:
    seq:
      - id: dtc_count
        type: u1
      - id: dtc_codes
        type: str
        size-eos: true
        
  photo_upload_request:
    seq:
      - id: photo_index
        type: u2
        
  photo_data_packet:
    seq:
      - id: photo_index
        type: u2
      - id: packet_index
        type: u2
      - id: jpeg_data
        size-eos: true
        
  position_with_image:
    seq:
      - id: position_string
        type: str
        terminator: 0x2C  # comma before image data
      - id: image_data
        size-eos: true
    instances:
      parsed_position:
        type: position_fields
        io: '_io_from_string(position_string)'
        
  upload_complete:
    seq:
      - id: upload_type
        type: u1
        
  login_response:
    seq:
      - id: result
        type: u1
        
  track_on_demand:
    seq: []
    
  track_by_interval:
    seq:
      - id: interval_seconds
        type: u4
        
  movement_alarm_setup:
    seq:
      - id: enable
        type: u1
      - id: sensitivity
        type: u1
        
  output_control_1:
    seq:
      - id: output_number
        type: u1
      - id: state
        type: u1
        
  output_control_2:
    seq:
      - id: output_mask
        type: u2
        
  set_timezone:
    seq:
      - id: timezone_offset
        type: s2
        
  take_photo:
    seq:
      - id: photo_index
        type: u2
        
  photo_upload_response:
    seq:
      - id: photo_index
        type: u2
      - id: packet_index
        type: u2
      - id: result
        type: u1
        
  reboot_device:
    seq: []
    
  raw_data:
    seq:
      - id: data_bytes
        size-eos: true
        
  position_fields:
    seq:
      - id: time
        type: str
        terminator: 0x2C  # ','
      - id: validity
        type: str
        terminator: 0x2C
      - id: latitude
        type: str
        terminator: 0x2C
      - id: lat_hemisphere
        type: str
        terminator: 0x2C
      - id: longitude
        type: str
        terminator: 0x2C
      - id: lon_hemisphere
        type: str
        terminator: 0x2C
      - id: speed
        type: str
        terminator: 0x2C
      - id: course
        type: str
        terminator: 0x2C
      - id: date
        type: str
        terminator: 0x7C  # '|'
      - id: extended_data
        type: extended_position_fields
        if: has_extended_data
        
    instances:
      has_extended_data:
        value: '_io.pos < _io.size'
        
  extended_position_fields:
    seq:
      - id: hdop
        type: str
        terminator: 0x7C  # '|'
        if: has_hdop
      - id: altitude
        type: str
        terminator: 0x7C
        if: has_altitude
      - id: status
        type: str
        terminator: 0x7C
        if: has_status
      - id: adc_values
        type: str
        terminator: 0x7C
        if: has_adc
      - id: cell_data
        type: str
        terminator: 0x7C
        if: has_cell
      - id: rssi
        type: str
        terminator: 0x7C
        if: has_rssi
      - id: odometer
        type: str
        terminator: 0x7C
        if: has_odometer
      - id: satellites
        type: str
        terminator: 0x7C
        if: has_satellites
      - id: driver_id
        type: str
        size-eos: true
        if: has_driver
        
    instances:
      has_hdop:
        value: '_io.pos < _io.size'
      has_altitude:
        value: '_io.pos < _io.size'
      has_status:
        value: '_io.pos < _io.size'
      has_adc:
        value: '_io.pos < _io.size'
      has_cell:
        value: '_io.pos < _io.size'
      has_rssi:
        value: '_io.pos < _io.size'
      has_odometer:
        value: '_io.pos < _io.size'
      has_satellites:
        value: '_io.pos < _io.size'
      has_driver:
        value: '_io.pos < _io.size'
        
  obd_fields:
    seq:
      - id: timestamp
        type: str
        terminator: 0x2C
      - id: obd_data
        type: str
        size-eos: true

enums:
  command_type_enum:
    0x0001: heartbeat
    0x0002: server_request
    0x5000: login_request
    0x9955: position_report
    0x9016: logged_position
    0x9999: alarm
    0x9966: rfid_data
    0x6688: retransmission
    0x9901: obd_realtime
    0x9902: obd_additional
    0x9903: dtc_codes
    0x0800: photo_upload_request
    0x9988: photo_data_packet
    0x9977: position_with_image
    0x0f80: upload_complete
    0x4000: login_response
    0x4101: track_on_demand
    0x4102: track_by_interval
    0x4106: movement_alarm_setup
    0x4114: output_control_1
    0x4115: output_control_2
    0x4132: set_timezone
    0x4151: take_photo
    0x8801: photo_upload_response
    0x4902: reboot_device
    
  alarm_type_enum:
    0x01: sos
    0x10: low_battery
    0x11: overspeed
    0x12: movement
    0x13: geofence
    0x14: accident
    0x50: power_off
    0x53: gps_antenna_cut
    0x72: hard_braking
    0x73: hard_acceleration
    
  validity_status:
    0: valid_gps      # 'A'
    1: invalid_gps    # 'V'
    
  hemisphere:
    0: north_east     # 'N', 'E'
    1: south_west     # 'S', 'W'