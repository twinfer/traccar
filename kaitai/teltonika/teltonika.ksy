meta:
  id: teltonika
  title: Teltonika GPS Tracker Protocol
  endian: be
  file-extension: teltonika
  
doc: |
  Teltonika protocol parser for European GPS tracking devices.
  Supports multiple codec types (8, 8E, 12, 13, 16) with AVL data,
  commands, and extended features like BLE beacons and photos.

seq:
  - id: frame
    type: teltonika_frame
    
types:
  teltonika_frame:
    seq:
      - id: preamble
        contents: [0x00, 0x00, 0x00, 0x00]
        doc: TCP mode preamble
        
      - id: data_length
        type: u4
        doc: Length of data field
        
      - id: codec_id
        type: u1
        enum: codec_type
        doc: Identifies message format
        
      - id: data
        size: data_length - 1
        type:
          switch-on: codec_id
          cases:
            'codec_type::codec_8': codec8_data
            'codec_type::codec_8e': codec8e_data
            'codec_type::codec_12': codec12_data
            'codec_type::codec_13': codec13_data
            'codec_type::codec_16': codec16_data
            'codec_type::codec_gh3000': codec_gh3000_data
            
      - id: crc
        type: u4
        doc: CRC16-IBM checksum
        
  # Codec 8 - Standard AVL data
  codec8_data:
    seq:
      - id: record_count1
        type: u1
        doc: Number of records in packet
        
      - id: records
        type: avl_record(codec_type::codec_8)
        repeat: expr
        repeat-expr: record_count1
        
      - id: record_count2
        type: u1
        doc: Should match record_count1
        
  # Codec 8 Extended - AVL data with variable IO
  codec8e_data:
    seq:
      - id: record_count1
        type: u1
        
      - id: records
        type: avl_record(codec_type::codec_8e)
        repeat: expr
        repeat-expr: record_count1
        
      - id: record_count2
        type: u1
        
  # Codec 16 - Enhanced AVL with generation type
  codec16_data:
    seq:
      - id: record_count1
        type: u1
        
      - id: records
        type: avl_record(codec_type::codec_16)
        repeat: expr
        repeat-expr: record_count1
        
      - id: record_count2
        type: u1
        
  # Codec 12 - Commands and serial data
  codec12_data:
    seq:
      - id: command_count1
        type: u1
        
      - id: command_type
        type: u1
        doc: Command type identifier
        
      - id: command_length
        type: u4
        
      - id: command_data
        size: command_length
        type:
          switch-on: command_type
          cases:
            0x00: photo_data
            _: command_text
            
      - id: command_count2
        type: u1
        
  # Codec 13 - GPRS command responses
  codec13_data:
    seq:
      - id: response_count1
        type: u1
        
      - id: response_type
        type: u1
        
      - id: response_length
        type: u4
        
      - id: response_data
        type: str
        size: response_length
        encoding: ASCII
        
      - id: response_count2
        type: u1
        
  # Codec GH3000 - Special format
  codec_gh3000_data:
    seq:
      - id: length
        type: u4
        
      - id: data
        size: length
        
  # AVL Record structure
  avl_record:
    params:
      - id: codec
        type: u4
        enum: codec_type
    seq:
      - id: timestamp
        type: u8
        doc: Unix timestamp in milliseconds
        
      - id: priority
        type: u1
        doc: Message priority (0=low, 1=high, 2=panic)
        
      - id: gps_element
        type: gps_data
        
      - id: io_element
        type:
          switch-on: codec
          cases:
            'codec_type::codec_8': io_element_8
            'codec_type::codec_8e': io_element_8e
            'codec_type::codec_16': io_element_16
            
  # GPS data structure
  gps_data:
    seq:
      - id: longitude
        type: s4
        doc: Longitude × 10,000,000
        
      - id: latitude
        type: s4
        doc: Latitude × 10,000,000
        
      - id: altitude
        type: u2
        doc: Altitude in meters
        
      - id: angle
        type: u2
        doc: Course/heading in degrees
        
      - id: satellites
        type: u1
        doc: Number of visible satellites
        
      - id: speed
        type: u2
        doc: Speed in km/h
        
    instances:
      longitude_deg:
        value: longitude / 10000000.0
        
      latitude_deg:
        value: latitude / 10000000.0
        
      is_valid:
        value: satellites > 0
        
  # IO Element for Codec 8
  io_element_8:
    seq:
      - id: event_id
        type: u1
        doc: Event that generated this record
        
      - id: total_count
        type: u1
        doc: Total number of IO properties
        
      - id: io1_count
        type: u1
        doc: Number of 1-byte IO elements
        
      - id: io1_elements
        type: io_property_1
        repeat: expr
        repeat-expr: io1_count
        
      - id: io2_count
        type: u1
        doc: Number of 2-byte IO elements
        
      - id: io2_elements
        type: io_property_2
        repeat: expr
        repeat-expr: io2_count
        
      - id: io4_count
        type: u1
        doc: Number of 4-byte IO elements
        
      - id: io4_elements
        type: io_property_4
        repeat: expr
        repeat-expr: io4_count
        
      - id: io8_count
        type: u1
        doc: Number of 8-byte IO elements
        
      - id: io8_elements
        type: io_property_8
        repeat: expr
        repeat-expr: io8_count
        
  # IO Element for Codec 8 Extended
  io_element_8e:
    seq:
      - id: event_id
        type: u2
        doc: Extended event ID (2 bytes)
        
      - id: total_count
        type: u2
        doc: Total number of IO properties
        
      - id: io1_count
        type: u2
        
      - id: io1_elements
        type: io_property_1_ext
        repeat: expr
        repeat-expr: io1_count
        
      - id: io2_count
        type: u2
        
      - id: io2_elements
        type: io_property_2_ext
        repeat: expr
        repeat-expr: io2_count
        
      - id: io4_count
        type: u2
        
      - id: io4_elements
        type: io_property_4_ext
        repeat: expr
        repeat-expr: io4_count
        
      - id: io8_count
        type: u2
        
      - id: io8_elements
        type: io_property_8_ext
        repeat: expr
        repeat-expr: io8_count
        
      - id: iox_count
        type: u2
        doc: Number of variable-length IO elements
        
      - id: iox_elements
        type: io_property_x
        repeat: expr
        repeat-expr: iox_count
        
  # IO Element for Codec 16
  io_element_16:
    seq:
      - id: generation_type
        type: u1
        doc: Generation type indicator
        
      - id: event_id
        type: u2
        
      - id: total_count
        type: u2
        
      # Similar structure to 8E but with 16-byte support
      - id: io_data
        size-eos: true
        doc: Simplified - actual implementation would parse all IO sizes
        
  # IO Property structures
  io_property_1:
    seq:
      - id: id
        type: u1
        
      - id: value
        type: u1
        
  io_property_2:
    seq:
      - id: id
        type: u1
        
      - id: value
        type: u2
        
  io_property_4:
    seq:
      - id: id
        type: u1
        
      - id: value
        type: u4
        
  io_property_8:
    seq:
      - id: id
        type: u1
        
      - id: value
        type: u8
        
  # Extended IO properties (2-byte IDs)
  io_property_1_ext:
    seq:
      - id: id
        type: u2
        
      - id: value
        type: u1
        
  io_property_2_ext:
    seq:
      - id: id
        type: u2
        
      - id: value
        type: u2
        
  io_property_4_ext:
    seq:
      - id: id
        type: u2
        
      - id: value
        type: u4
        
  io_property_8_ext:
    seq:
      - id: id
        type: u2
        
      - id: value
        type: u8
        
  # Variable length IO property
  io_property_x:
    seq:
      - id: id
        type: u2
        
      - id: length
        type: u2
        
      - id: value
        size: length
        doc: Variable length data (strings, BLE data, etc.)
        
  # Photo data structure
  photo_data:
    seq:
      - id: packet_type
        type: u1
        enum: photo_packet_type
        
      - id: content
        size-eos: true
        type:
          switch-on: packet_type
          cases:
            'photo_packet_type::start': photo_start
            'photo_packet_type::data': photo_chunk
            'photo_packet_type::done': photo_done
            
  photo_start:
    seq:
      - id: photo_id
        type: u4
        
      - id: size
        type: u4
        
      - id: timestamp
        type: u8
        
  photo_chunk:
    seq:
      - id: photo_id
        type: u4
        
      - id: offset
        type: u4
        
      - id: chunk_size
        type: u2
        
      - id: data
        size: chunk_size
        
  photo_done:
    seq:
      - id: photo_id
        type: u4
        
  # Command text
  command_text:
    seq:
      - id: command
        type: str
        size-eos: true
        encoding: ASCII
        
enums:
  codec_type:
    0x07: codec_gh3000
    0x08: codec_8
    0x8E: codec_8e
    0x0C: codec_12
    0x0D: codec_13
    0x10: codec_16
    
  photo_packet_type:
    0x00: start
    0x01: data
    0x02: done
    
  # Common IO element IDs
  io_element:
    1: digital_input_1
    2: digital_input_2
    3: digital_input_3
    4: digital_input_4
    9: analog_input_1
    10: analog_input_2
    11: iccid
    12: fuel_used
    13: fuel_rate
    16: odometer
    17: accel_x
    18: accel_y
    19: accel_z
    21: gsm_signal
    24: speed
    66: external_voltage
    67: battery_voltage
    78: driver_id
    179: digital_output_1
    180: digital_output_2
    181: pdop
    182: hdop
    239: ignition
    240: movement
    241: operator
    256: vin
    281: dtcs
    385: ble_beacons
    548: ble_tag_1
    636: cell_id_4g