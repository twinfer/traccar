meta:
  id: navtelecom
  title: Navtelecom GPS Tracker Protocol
  license: MIT
  ks-version: 0.11
  endian: le

doc: |
  Navtelecom protocol supporting flexible field configuration with bit-mask based
  data transmission. Features control messages, position reporting, bidirectional
  commands, and CRC8_EGTS checksum validation. Supports up to 255 configurable
  data fields including GPS, sensors, OBD, fuel, and custom user data.

seq:
  - id: message
    type: navtelecom_packet

types:
  navtelecom_packet:
    seq:
      - id: message_start
        type: u1
      - id: message_body
        type:
          switch-on: message_start
          cases:
            0x40: control_message    # '@' - Control messages
            0x7E: position_message   # '~' - Position data
            0x7F: heartbeat_message  # Keepalive

  control_message:
    seq:
      - id: preamble_suffix
        contents: "NTC"
      - id: receiver_id
        type: u4
      - id: sender_id
        type: u4
      - id: data_length
        type: u2
      - id: data_checksum
        type: u1
      - id: header_checksum
        type: u1
      - id: payload
        size: data_length
        type:
          switch-on: payload_type
          cases:
            '"*>S"': device_info_message
            '"*>F"': flex_config_message  # *>FLEX
            '"*<F"': flex_config_message  # *<FLEX
            '"*@C"': command_result_message
    instances:
      payload_type:
        pos: _io.pos
        size: 3
        type: str
        encoding: ASCII

  device_info_message:
    seq:
      - id: data
        size-eos: true
        type: str
        encoding: ASCII

  flex_config_message:
    seq:
      - id: header_suffix
        contents: "LEX"
      - id: protocol_version
        type: u1
      - id: structure_version
        type: u1
      - id: bit_count
        type: u1
      - id: bit_mask
        size: (bit_count + 7) / 8
    instances:
      field_enabled:
        value: |
          _index < bit_count ? 
          (bit_mask[_index / 8] & (1 << (_index % 8))) != 0 : 
          false

  command_result_message:
    seq:
      - id: result
        size-eos: true

  position_message:
    seq:
      - id: message_type
        type: u1
        doc: Should be 'A' (0x41)
      - id: record_count
        type: u1
      - id: records
        type: position_record
        repeat: expr
        repeat-expr: record_count
      - id: checksum
        type: u1

  heartbeat_message:
    doc: Empty heartbeat/keepalive message

  position_record:
    seq:
      - id: fields
        type: field_data
        repeat: eos

  field_data:
    seq:
      - id: field_id
        type: u1
        enum: field_ids
      - id: field_value
        size: field_length
        type:
          switch-on: field_id
          cases:
            field_ids::index: u4
            field_ids::event: u2
            field_ids::time: u4
            field_ids::latitude: coordinate
            field_ids::longitude: coordinate
            field_ids::speed: u2
            field_ids::course: u2
            field_ids::altitude: s2
            field_ids::satellites: u1
            field_ids::hdop: u1
            field_ids::valid: u1
            field_ids::inputs: u2
            field_ids::outputs: u2
            field_ids::adc1: u2
            field_ids::adc2: u2
            field_ids::adc3: u2
            field_ids::adc4: u2
            field_ids::adc5: u2
            field_ids::adc6: u2
            field_ids::counter1: u4
            field_ids::counter2: u4
            field_ids::external_power: u2
            field_ids::battery_voltage: u2
            field_ids::fuel1: u2
            field_ids::fuel2: u2
            field_ids::fuel3: u2
            field_ids::fuel4: u2
            field_ids::fuel5: u2
            field_ids::fuel6: u2
            field_ids::fuel7: u2
            field_ids::temperature1: s1
            field_ids::temperature2: s1
            field_ids::temperature3: s1
            field_ids::temperature4: s1
            field_ids::temperature5: s1
            field_ids::temperature6: s1
            field_ids::temperature7: s1
            field_ids::temperature8: s1
            field_ids::fuel_consumption: u4
            field_ids::rpm: u2
            field_ids::coolant_temp: s1
            field_ids::obd_odometer: u4
            field_ids::obd_speed: u1
            field_ids::obd_fuel_level: u1
            field_ids::driver_id: u8
            field_ids::custom_u1: u1
            field_ids::custom_u2: u2
            field_ids::custom_u4: u4
            field_ids::custom_u8: u8
            _: raw_data
    instances:
      field_length:
        value: |
          field_id == field_ids::index ? 4 :
          field_id == field_ids::event ? 2 :
          field_id == field_ids::time ? 4 :
          field_id == field_ids::satellites or field_id == field_ids::hdop or field_id == field_ids::valid ? 1 :
          field_id == field_ids::latitude or field_id == field_ids::longitude ? 4 :
          field_id == field_ids::speed or field_id == field_ids::course or field_id == field_ids::altitude ? 2 :
          field_id == field_ids::inputs or field_id == field_ids::outputs ? 2 :
          field_id >= field_ids::adc1 and field_id <= field_ids::adc6 ? 2 :
          field_id == field_ids::counter1 or field_id == field_ids::counter2 ? 4 :
          field_id == field_ids::external_power or field_id == field_ids::battery_voltage ? 2 :
          field_id >= field_ids::fuel1 and field_id <= field_ids::fuel7 ? 2 :
          field_id >= field_ids::temperature1 and field_id <= field_ids::temperature8 ? 1 :
          field_id == field_ids::fuel_consumption ? 4 :
          field_id == field_ids::rpm ? 2 :
          field_id == field_ids::coolant_temp ? 1 :
          field_id == field_ids::obd_odometer ? 4 :
          field_id == field_ids::obd_speed or field_id == field_ids::obd_fuel_level ? 1 :
          field_id == field_ids::driver_id ? 8 :
          field_id == 73 ? 16 :
          field_id == 77 ? 37 :
          field_id == 94 or field_id == 107 or field_id == 109 or field_id == 197 ? 6 :
          field_id == 95 ? 12 :
          field_id == 96 ? 24 :
          field_id == 97 ? 48 :
          field_id == 204 ? 5 :
          field_id >= 84 and field_id <= 93 ? 3 :
          field_id == 142 or field_id == 146 or field_id == 198 ? 3 :
          field_id >= 253 and field_id <= 255 ? 8 :
          1  # Default for unknown fields

  coordinate:
    seq:
      - id: value
        type: s4
    instances:
      degrees:
        value: value * 0.0001 / 60.0

  raw_data:
    seq:
      - id: data
        size-eos: true

enums:
  field_ids:
    1: index
    2: event
    3: time
    4: satellites
    5: hdop
    6: valid
    7: reserved7
    8: reserved8
    9: latitude
    10: longitude
    11: speed
    12: course
    13: altitude
    14: reserved14
    15: reserved15
    16: reserved16
    17: reserved17
    18: reserved18
    19: external_power
    20: battery_voltage
    21: adc1
    22: adc2
    23: adc3
    24: adc4
    25: adc5
    26: adc6
    27: reserved27
    28: reserved28
    29: inputs
    30: reserved30
    31: outputs
    32: reserved32
    33: counter1
    34: counter2
    35: reserved35
    36: reserved36
    37: reserved37
    38: fuel1
    39: fuel2
    40: fuel3
    41: fuel4
    42: fuel5
    43: fuel6
    44: fuel7
    45: temperature1
    46: temperature2
    47: temperature3
    48: temperature4
    49: temperature5
    50: temperature6
    51: temperature7
    52: temperature8
    53: fuel_used
    54: fuel_consumption
    55: rpm
    56: coolant_temp
    57: reserved57
    58: reserved58
    59: reserved59
    60: reserved60
    61: reserved61
    62: reserved62
    63: throttle_position
    64: battery_percent
    65: obd_fuel_level
    66: reserved66
    67: obd_odometer
    68: obd_fuel_used
    69: obd_speed
    70: driver_id
    71: reserved71
    72: reserved72
    73: custom_16bytes
    74: reserved74
    75: reserved75
    76: reserved76
    77: custom_37bytes
    78: fuel1_temp
    79: fuel2_temp
    80: fuel3_temp
    81: fuel4_temp
    82: fuel5_temp
    83: fuel6_temp
    84: custom_3bytes_84
    85: custom_3bytes_85
    86: custom_3bytes_86
    87: custom_3bytes_87
    88: custom_3bytes_88
    89: custom_3bytes_89
    90: custom_3bytes_90
    91: custom_3bytes_91
    92: custom_3bytes_92
    93: custom_3bytes_93
    94: custom_6bytes_94
    95: custom_12bytes
    96: custom_24bytes
    97: custom_48bytes
    107: custom_6bytes_107
    109: custom_6bytes_109
    142: custom_3bytes_142
    146: custom_3bytes_146
    163: temperature9
    164: temperature10
    165: temperature11
    166: temperature12
    167: humidity1
    168: humidity2
    169: humidity3
    170: humidity4
    197: custom_6bytes_197
    198: custom_3bytes_198
    204: custom_5bytes
    207: custom_u1_207
    208: custom_u1_208
    209: custom_u1_209
    210: custom_u1_210
    211: custom_u1_211
    212: custom_u1_212
    213: custom_u1_213
    214: custom_u1_214
    215: custom_u1_215
    216: custom_u1_216
    217: custom_u1_217
    218: custom_u1_218
    219: custom_u1_219
    220: custom_u1_220
    221: custom_u1_221
    222: custom_u1_222
    223: custom_u2_223
    224: custom_u2_224
    225: custom_u2_225
    226: custom_u2_226
    227: custom_u2_227
    228: custom_u2_228
    229: custom_u2_229
    230: custom_u2_230
    231: custom_u4_231
    232: custom_u4_232
    233: custom_u4_233
    234: custom_u4_234
    235: custom_u4_235
    236: custom_u4_236
    237: custom_u4_237
    238: custom_u4_238
    239: custom_u4_239
    240: custom_u4_240
    241: custom_u4_241
    242: custom_u4_242
    243: custom_u4_243
    244: custom_u4_244
    245: custom_u4_245
    246: custom_u4_246
    247: custom_u4_247
    248: custom_u4_248
    249: custom_u4_249
    250: custom_u4_250
    251: custom_u4_251
    252: custom_u4_252
    253: custom_u8_253
    254: custom_u8_254
    255: custom_u8_255

  message_types:
    0x40: control_message    # '@'
    0x7E: position_message   # '~'
    0x7F: heartbeat         # Keepalive