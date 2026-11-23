(module
  (memory 1024)
  (export "memory" (memory 0))

  ;; ---- globals ----
  (global $g_text_ptr (mut i32) (i32.const 0))
  (global $g_text_len (mut i32) (i32.const 0))
  (global $g_end (mut i32) (i32.const 0))
  (global $g_header (mut i32) (i32.const 0))
  (global $g_line (mut i32) (i32.const 0))
  (global $g_pos (mut i32) (i32.const 0))
  (global $g_rec_line (mut i32) (i32.const 0))
  (global $g_rec_row (mut i32) (i32.const 0))
  (global $g_width (mut i32) (i32.const 0))
  (global $g_have_cols (mut i32) (i32.const 0))
  (global $g_nrows (mut i32) (i32.const 0))
  (global $g_nerrs (mut i32) (i32.const 0))
  (global $g_nfields (mut i32) (i32.const 0))
  (global $g_last_quoted (mut i32) (i32.const 0))
  (global $g_rows_end (mut i32) (i32.const 0))
  (global $g_errs_end (mut i32) (i32.const 0))
  (global $g_cols_end (mut i32) (i32.const 0))
  (global $g_scan_ncr (mut i32) (i32.const 0))
  (global $g_scan_dirty (mut i32) (i32.const 0))
  (global $g_scan_ended (mut i32) (i32.const 0))
  (global $g_u_dlen (mut i32) (i32.const 0))
  (global $g_u_spos (mut i32) (i32.const 0))

  ;; ---- rodata ----
  (data (i32.const 0x2C10000) "\"text\":\"")
  (data (i32.const 0x2C10010) "\"header\":")
  (data (i32.const 0x2C10020) "{\"code\":\"")
  (data (i32.const 0x2C10030) ",\"line\":")
  (data (i32.const 0x2C10040) ",\"row\":")
  (data (i32.const 0x2C10050) ",\"fields\":")
  (data (i32.const 0x2C10060) ",\"extra\":[")
  (data (i32.const 0x2C10070) "null")
  (data (i32.const 0x2C10080) "{\"columns\":")
  (data (i32.const 0x2C10090) ",\"rows\":[")
  (data (i32.const 0x2C100A0) "],\"errors\":[")
  (data (i32.const 0x2C100B0) "]}")
  (data (i32.const 0x2C100C0) "\"stray_cr\"")
  (data (i32.const 0x2C100D0) "\"quote_junk\"")
  (data (i32.const 0x2C100E0) "\"short_row\"")
  (data (i32.const 0x2C100F0) "\"long_row\"")
  (data (i32.const 0x2C10100) "\"unterminated_quote\"")
  (data (i32.const 0x2C10200) "0123456789abcdef")

  ;; ---- helpers ----
  (func $st8 (param $p i32) (param $v i32) (result i32)
    local.get $p
    local.get $v
    i32.store8
    local.get $p
    i32.const 1
    i32.add)

  (func $cp (param $d i32) (param $s i32) (param $n i32) (result i32)
    local.get $d
    local.get $s
    local.get $n
    memory.copy
    local.get $d
    local.get $n
    i32.add)

  (func $hexval (param $h i32) (result i32)
    (local $x i32)
    local.get $h
    i32.const 48
    i32.sub
    local.set $x
    local.get $h
    i32.const 48
    i32.ge_u
    local.get $h
    i32.const 58
    i32.lt_u
    i32.and
    if
      local.get $x
      return
    end
    local.get $h
    i32.const 97
    i32.ge_u
    local.get $h
    i32.const 103
    i32.lt_u
    i32.and
    if
      local.get $h
      i32.const 97
      i32.sub
      i32.const 10
      i32.add
      return
    end
    local.get $h
    i32.const 65
    i32.ge_u
    local.get $h
    i32.const 71
    i32.lt_u
    i32.and
    if
      local.get $h
      i32.const 65
      i32.sub
      i32.const 10
      i32.add
      return
    end
    i32.const 0)

  (func $hex2 (param $d i32) (param $v i32) (result i32)
    local.get $d
    i32.const 0x2C10200
    local.get $v
    i32.const 4
    i32.shr_u
    i32.const 15
    i32.and
    i32.add
    i32.load8_u
    i32.store8
    local.get $d
    i32.const 1
    i32.add
    i32.const 0x2C10200
    local.get $v
    i32.const 15
    i32.and
    i32.add
    i32.load8_u
    i32.store8
    local.get $d
    i32.const 2
    i32.add)

  (func $u32 (param $p i32) (param $n i32) (result i32)
    (local $cnt i32)
    (local $v i32)
    local.get $n
    i32.eqz
    if
      local.get $p
      i32.const 48
      i32.store8
      local.get $p
      i32.const 1
      i32.add
      return
    end
    i32.const 0
    local.set $cnt
    local.get $n
    local.set $v
    block $bd
      loop $bl
        i32.const 0x2C00000
        local.get $cnt
        i32.add
        local.get $v
        i32.const 10
        i32.rem_u
        i32.const 48
        i32.add
        i32.store8
        local.get $cnt
        i32.const 1
        i32.add
        local.set $cnt
        local.get $v
        i32.const 10
        i32.div_u
        local.set $v
        local.get $v
        i32.eqz
        br_if $bd
        br $bl
      end
    end
    block $bd2
      loop $bl2
        local.get $cnt
        i32.eqz
        br_if $bd2
        local.get $cnt
        i32.const 1
        i32.sub
        local.set $cnt
        local.get $p
        i32.const 0x2C00000
        local.get $cnt
        i32.add
        i32.load8_u
        i32.store8
        local.get $p
        i32.const 1
        i32.add
        local.set $p
        br $bl2
      end
    end
    local.get $p)

  (func $utf8 (param $cp i32) (param $d i32) (result i32)
    local.get $cp
    i32.const 0x80
    i32.lt_u
    if
      local.get $d
      local.get $cp
      i32.store8
      local.get $d
      i32.const 1
      i32.add
      return
    end
    local.get $cp
    i32.const 0x800
    i32.lt_u
    if
      local.get $d
      i32.const 0xC0
      local.get $cp
      i32.const 6
      i32.shr_u
      i32.or
      i32.store8
      local.get $d
      i32.const 1
      i32.add
      i32.const 0x80
      local.get $cp
      i32.const 0x3F
      i32.and
      i32.or
      i32.store8
      local.get $d
      i32.const 2
      i32.add
      return
    end
    local.get $cp
    i32.const 0x10000
    i32.lt_u
    if
      local.get $d
      i32.const 0xE0
      local.get $cp
      i32.const 12
      i32.shr_u
      i32.or
      i32.store8
      local.get $d
      i32.const 1
      i32.add
      i32.const 0x80
      local.get $cp
      i32.const 6
      i32.shr_u
      i32.const 0x3F
      i32.and
      i32.or
      i32.store8
      local.get $d
      i32.const 2
      i32.add
      i32.const 0x80
      local.get $cp
      i32.const 0x3F
      i32.and
      i32.or
      i32.store8
      local.get $d
      i32.const 3
      i32.add
      return
    end
    local.get $d
    i32.const 0xF0
    local.get $cp
    i32.const 18
    i32.shr_u
    i32.or
    i32.store8
    local.get $d
    i32.const 1
    i32.add
    i32.const 0x80
    local.get $cp
    i32.const 12
    i32.shr_u
    i32.const 0x3F
    i32.and
    i32.or
    i32.store8
    local.get $d
    i32.const 2
    i32.add
    i32.const 0x80
    local.get $cp
    i32.const 6
    i32.shr_u
    i32.const 0x3F
    i32.and
    i32.or
    i32.store8
    local.get $d
    i32.const 3
    i32.add
    i32.const 0x80
    local.get $cp
    i32.const 0x3F
    i32.and
    i32.or
    i32.store8
    local.get $d
    i32.const 4
    i32.add)

  ;; ---- esc: escape bytes for JSON ----
  (func $esc (param $d i32) (param $s i32) (param $n i32) (param $mode i32) (result i32)
    (local $i i32) (local $e i32) (local $b i32)
    local.get $s
    local.set $i
    local.get $s
    local.get $n
    i32.add
    local.set $e
    block $done
      loop $l
        local.get $i
        local.get $e
        i32.ge_u
        br_if $done
        local.get $i
        i32.load8_u
        local.set $b
        local.get $mode
        i32.eqz
        if
          local.get $b
          i32.const 13
          i32.eq
          if
            local.get $i
            i32.const 1
            i32.add
            local.set $i
            br $l
          end
          local.get $b
          i32.const 34
          i32.eq
          if
            local.get $d
            i32.const 92
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $d
            i32.const 34
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $i
            i32.const 1
            i32.add
            local.set $i
            br $l
          end
          local.get $b
          i32.const 92
          i32.eq
          if
            local.get $d
            i32.const 92
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $d
            i32.const 92
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $i
            i32.const 1
            i32.add
            local.set $i
            br $l
          end
          local.get $b
          i32.const 10
          i32.eq
          if
            local.get $d
            i32.const 92
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $d
            i32.const 110
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $i
            i32.const 1
            i32.add
            local.set $i
            br $l
          end
          local.get $b
          i32.const 9
          i32.eq
          if
            local.get $d
            i32.const 92
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $d
            i32.const 116
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $i
            i32.const 1
            i32.add
            local.set $i
            br $l
          end
          local.get $b
          i32.const 32
          i32.lt_u
          if
            local.get $d
            i32.const 92
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $d
            i32.const 117
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $d
            i32.const 48
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $d
            i32.const 48
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $d
            local.get $b
            call $hex2
            local.set $d
            local.get $i
            i32.const 1
            i32.add
            local.set $i
            br $l
          end
          local.get $d
          local.get $b
          i32.store8
          local.get $d
          i32.const 1
          i32.add
          local.set $d
          local.get $i
          i32.const 1
          i32.add
          local.set $i
          br $l
        else
          local.get $b
          i32.const 34
          i32.eq
          if
            local.get $d
            i32.const 92
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $d
            i32.const 34
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $i
            i32.const 2
            i32.add
            local.set $i
            br $l
          end
          local.get $b
          i32.const 13
          i32.eq
          if
            local.get $d
            i32.const 92
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $d
            i32.const 110
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $i
            i32.const 1
            i32.add
            local.get $e
            i32.lt_u
            if
              local.get $i
              i32.const 1
              i32.add
              i32.load8_u
              i32.const 10
              i32.eq
              if
                local.get $i
                i32.const 2
                i32.add
                local.set $i
              else
                local.get $i
                i32.const 1
                i32.add
                local.set $i
              end
            else
              local.get $i
              i32.const 1
              i32.add
              local.set $i
            end
            br $l
          end
          local.get $b
          i32.const 10
          i32.eq
          if
            local.get $d
            i32.const 92
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $d
            i32.const 110
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $i
            i32.const 1
            i32.add
            local.set $i
            br $l
          end
          local.get $b
          i32.const 92
          i32.eq
          if
            local.get $d
            i32.const 92
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $d
            i32.const 92
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $i
            i32.const 1
            i32.add
            local.set $i
            br $l
          end
          local.get $b
          i32.const 32
          i32.lt_u
          if
            local.get $d
            i32.const 92
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $d
            i32.const 117
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $d
            i32.const 48
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $d
            i32.const 48
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $d
            local.get $b
            call $hex2
            local.set $d
            local.get $i
            i32.const 1
            i32.add
            local.set $i
            br $l
          end
          local.get $d
          local.get $b
          i32.store8
          local.get $d
          i32.const 1
          i32.add
          local.set $d
          local.get $i
          i32.const 1
          i32.add
          local.set $i
          br $l
        end
      end
    end
    local.get $d)

  ;; ---- scan_unquoted ----
  (func $scan_unquoted (param $from i32) (result i32)
    (local $p i32) (local $b i32) (local $end i32)
    i32.const 0
    global.set $g_scan_ncr
    i32.const 0
    global.set $g_scan_dirty
    local.get $from
    local.set $p
    block $done
      loop $l
        local.get $p
        global.get $g_end
        i32.ge_u
        if
          i32.const 2
          global.set $g_scan_ended
          local.get $p
          local.set $end
          br $done
        end
        local.get $p
        i32.load8_u
        local.set $b
        local.get $b
        i32.const 44
        i32.eq
        if
          i32.const 0
          global.set $g_scan_ended
          local.get $p
          local.set $end
          local.get $p
          i32.const 1
          i32.add
          local.set $p
          br $done
        end
        local.get $b
        i32.const 10
        i32.eq
        if
          i32.const 1
          global.set $g_scan_ended
          local.get $p
          local.set $end
          local.get $p
          i32.const 1
          i32.add
          local.set $p
          global.get $g_line
          i32.const 1
          i32.add
          global.set $g_line
          br $done
        end
        local.get $b
        i32.const 13
        i32.eq
        if
          local.get $p
          i32.const 1
          i32.add
          global.get $g_end
          i32.lt_u
          if
            local.get $p
            i32.const 1
            i32.add
            i32.load8_u
            i32.const 10
            i32.eq
            if
              i32.const 1
              global.set $g_scan_ended
              local.get $p
              local.set $end
              local.get $p
              i32.const 2
              i32.add
              local.set $p
              global.get $g_line
              i32.const 1
              i32.add
              global.set $g_line
              br $done
            end
          end
          global.get $g_rec_line
          global.get $g_rec_row
          call $estray
          global.get $g_scan_ncr
          i32.const 1
          i32.add
          global.set $g_scan_ncr
          i32.const 1
          global.set $g_scan_dirty
          local.get $p
          i32.const 1
          i32.add
          local.set $p
          br $l
        end
        local.get $b
        i32.const 34
        i32.eq
        if
          i32.const 1
          global.set $g_scan_dirty
          local.get $p
          i32.const 1
          i32.add
          local.set $p
          br $l
        end
        local.get $b
        i32.const 92
        i32.eq
        if
          i32.const 1
          global.set $g_scan_dirty
          local.get $p
          i32.const 1
          i32.add
          local.set $p
          br $l
        end
        local.get $b
        i32.const 32
        i32.lt_u
        if
          i32.const 1
          global.set $g_scan_dirty
          local.get $p
          i32.const 1
          i32.add
          local.set $p
          br $l
        end
        local.get $p
        i32.const 1
        i32.add
        local.set $p
        br $l
      end
    end
    local.get $p
    global.set $g_pos
    local.get $end)

  ;; ---- find_close ----
  (func $find_close (param $from i32) (result i32)
    (local $p i32)
    local.get $from
    local.set $p
    block $done (result i32)
      loop $l
        local.get $p
        global.get $g_end
        i32.ge_u
        if
          i32.const -1
          br $done
        end
        local.get $p
        i32.load8_u
        i32.const 34
        i32.eq
        if
          local.get $p
          i32.const 1
          i32.add
          global.get $g_end
          i32.lt_u
          if
            local.get $p
            i32.const 1
            i32.add
            i32.load8_u
            i32.const 34
            i32.eq
            if
              local.get $p
              i32.const 2
              i32.add
              local.set $p
              br $l
            end
          end
          local.get $p
          br $done
        end
        local.get $p
        i32.const 1
        i32.add
        local.set $p
        br $l
      end
      i32.const 0
    end)

  ;; ---- scan_quoted_raw: returns lineAdd, sets g_scan_dirty ----
  (func $scan_quoted_raw (param $from i32) (param $len i32) (result i32)
    (local $i i32) (local $e i32) (local $add i32) (local $b i32)
    i32.const 0
    global.set $g_scan_dirty
    i32.const 0
    local.set $add
    local.get $from
    local.set $i
    local.get $from
    local.get $len
    i32.add
    local.set $e
    block $done
      loop $l
        local.get $i
        local.get $e
        i32.ge_u
        br_if $done
        local.get $i
        i32.load8_u
        local.set $b
        local.get $b
        i32.const 34
        i32.eq
        local.get $b
        i32.const 92
        i32.eq
        i32.or
        local.get $b
        i32.const 32
        i32.lt_u
        i32.or
        if
          i32.const 1
          global.set $g_scan_dirty
        end
        local.get $b
        i32.const 13
        i32.eq
        if
          local.get $add
          i32.const 1
          i32.add
          local.set $add
        else
          local.get $b
          i32.const 10
          i32.eq
          if
            local.get $i
            global.get $g_text_ptr
            i32.gt_u
            if
              local.get $i
              i32.const 1
              i32.sub
              i32.load8_u
              i32.const 13
              i32.eq
              if
              else
                local.get $add
                i32.const 1
                i32.add
                local.set $add
              end
            else
              local.get $add
              i32.const 1
              i32.add
              local.set $add
            end
          end
        end
        local.get $i
        i32.const 1
        i32.add
        local.set $i
        br $l
      end
    end
    local.get $add)

  ;; ---- add_field(kind, sp, sl, dirty, ncr) ----
  (func $add_field (param $kind i32) (param $sp i32) (param $sl i32) (param $dirty i32) (param $ncr i32)
    (local $base i32)
    global.get $g_nfields
    i32.const 40
    i32.mul
    i32.const 0x2A00000
    i32.add
    local.set $base
    local.get $base
    local.get $sp
    i32.store
    local.get $base
    i32.const 4
    i32.add
    local.get $sl
    i32.store
    local.get $base
    i32.const 8
    i32.add
    local.get $kind
    i32.store
    local.get $base
    i32.const 12
    i32.add
    local.get $dirty
    i32.store
    local.get $base
    i32.const 16
    i32.add
    i32.const 0
    i32.store
    local.get $base
    i32.const 20
    i32.add
    i32.const 0
    i32.store
    local.get $base
    i32.const 24
    i32.add
    i32.const 0
    i32.store
    local.get $base
    i32.const 28
    i32.add
    local.get $ncr
    i32.store
    local.get $base
    i32.const 32
    i32.add
    i32.const 0
    i32.store
    global.get $g_nfields
    i32.const 1
    i32.add
    global.set $g_nfields)

  ;; ---- after_close: returns ended, handles junk ----
  (func $after_close (result i32)
    (local $b i32) (local $js i32) (local $je i32) (local $jv i32) (local $base i32)
    global.get $g_pos
    global.get $g_end
    i32.ge_u
    if
      i32.const 2
      return
    end
    global.get $g_pos
    i32.load8_u
    local.set $b
    local.get $b
    i32.const 44
    i32.eq
    if
      global.get $g_pos
      i32.const 1
      i32.add
      global.set $g_pos
      i32.const 0
      return
    end
    local.get $b
    i32.const 10
    i32.eq
    if
      global.get $g_pos
      i32.const 1
      i32.add
      global.set $g_pos
      global.get $g_line
      i32.const 1
      i32.add
      global.set $g_line
      i32.const 1
      return
    end
    local.get $b
    i32.const 13
    i32.eq
    if
      global.get $g_pos
      i32.const 1
      i32.add
      global.get $g_end
      i32.lt_u
      if
        global.get $g_pos
        i32.const 1
        i32.add
        i32.load8_u
        i32.const 10
        i32.eq
        if
          global.get $g_pos
          i32.const 2
          i32.add
          global.set $g_pos
          global.get $g_line
          i32.const 1
          i32.add
          global.set $g_line
          i32.const 1
          return
        end
      end
    end
    global.get $g_pos
    local.set $js
    local.get $js
    call $scan_unquoted
    local.set $je
    local.get $je
    local.get $js
    i32.sub
    global.get $g_scan_ncr
    i32.sub
    local.set $jv
    local.get $jv
    i32.const 0
    i32.gt_s
    if
      global.get $g_rec_line
      global.get $g_rec_row
      call $equotejunk
      global.get $g_nfields
      i32.const 1
      i32.sub
      i32.const 40
      i32.mul
      i32.const 0x2A00000
      i32.add
      local.set $base
      local.get $base
      i32.const 16
      i32.add
      local.get $js
      i32.store
      local.get $base
      i32.const 20
      i32.add
      local.get $je
      local.get $js
      i32.sub
      i32.store
      local.get $base
      i32.const 24
      i32.add
      global.get $g_scan_dirty
      i32.store
      local.get $base
      i32.const 32
      i32.add
      global.get $g_scan_ncr
      i32.store
    end
    global.get $g_scan_ended)

  ;; ---- emit_field(idx) -> dst ----
  (func $efield (param $d i32) (param $idx i32) (result i32)
    (local $base i32) (local $sp i32) (local $sl i32) (local $kind i32) (local $dirty i32)
    (local $jp i32) (local $jl i32) (local $jd i32)
    local.get $idx
    i32.const 40
    i32.mul
    i32.const 0x2A00000
    i32.add
    local.set $base
    local.get $base
    i32.load
    local.set $sp
    local.get $base
    i32.const 4
    i32.add
    i32.load
    local.set $sl
    local.get $base
    i32.const 8
    i32.add
    i32.load
    local.set $kind
    local.get $base
    i32.const 12
    i32.add
    i32.load
    local.set $dirty
    local.get $base
    i32.const 16
    i32.add
    i32.load
    local.set $jp
    local.get $base
    i32.const 20
    i32.add
    i32.load
    local.set $jl
    local.get $base
    i32.const 24
    i32.add
    i32.load
    local.set $jd
    local.get $d
    i32.const 34
    i32.store8
    local.get $d
    i32.const 1
    i32.add
    local.set $d
    local.get $kind
    i32.eqz
    if
      local.get $dirty
      if
        local.get $d
        local.get $sp
        local.get $sl
        i32.const 0
        call $esc
        local.set $d
      else
        local.get $d
        local.get $sp
        local.get $sl
        call $cp
        local.set $d
      end
    else
      local.get $kind
      i32.const 1
      i32.eq
      if
        local.get $dirty
        if
          local.get $d
          local.get $sp
          local.get $sl
          i32.const 1
          call $esc
          local.set $d
        else
          local.get $d
          local.get $sp
          local.get $sl
          call $cp
          local.set $d
        end
        local.get $jl
        if
          local.get $jd
          if
            local.get $d
            local.get $jp
            local.get $jl
            i32.const 0
            call $esc
            local.set $d
          else
            local.get $d
            local.get $jp
            local.get $jl
            call $cp
            local.set $d
          end
        end
      else
        local.get $d
        i32.const 92
        i32.store8
        local.get $d
        i32.const 1
        i32.add
        local.set $d
        local.get $d
        i32.const 34
        i32.store8
        local.get $d
        i32.const 1
        i32.add
        local.set $d
        local.get $d
        local.get $sp
        local.get $sl
        i32.const 0
        call $esc
        local.set $d
      end
    end
    local.get $d
    i32.const 34
    i32.store8
    local.get $d
    i32.const 1
    i32.add)

  ;; ---- error prefix helper ----
  (func $eb (param $d i32) (param $line i32) (param $row i32) (param $codep i32) (param $codelen i32) (result i32)
    global.get $g_nerrs
    if
      local.get $d
      i32.const 44
      i32.store8
      local.get $d
      i32.const 1
      i32.add
      local.set $d
    end
    local.get $d
    i32.const 0x2C10020
    i32.const 8
    call $cp
    local.set $d
    local.get $d
    local.get $codep
    local.get $codelen
    call $cp
    local.set $d
    local.get $d
    i32.const 0x2C10030
    i32.const 8
    call $cp
    local.set $d
    local.get $d
    local.get $line
    call $u32
    local.set $d
    local.get $d
    i32.const 0x2C10040
    i32.const 7
    call $cp
    local.set $d
    local.get $row
    i32.const -1
    i32.eq
    if
      local.get $d
      i32.const 0x2C10070
      i32.const 4
      call $cp
      local.set $d
    else
      local.get $d
      local.get $row
      call $u32
      local.set $d
    end
    global.get $g_nerrs
    i32.const 1
    i32.add
    global.set $g_nerrs
    local.get $d)

  (func $estray (param $line i32) (param $row i32)
    global.get $g_errs_end
    local.get $line
    local.get $row
    i32.const 0x2C100C0
    i32.const 10
    call $eb
    i32.const 125
    call $st8
    global.set $g_errs_end)

  (func $equotejunk (param $line i32) (param $row i32)
    global.get $g_errs_end
    local.get $line
    local.get $row
    i32.const 0x2C100D0
    i32.const 12
    call $eb
    i32.const 125
    call $st8
    global.set $g_errs_end)

  (func $eunterminated (param $line i32) (param $row i32)
    global.get $g_errs_end
    local.get $line
    local.get $row
    i32.const 0x2C10100
    i32.const 20
    call $eb
    i32.const 125
    call $st8
    global.set $g_errs_end)

  (func $eshort (param $line i32) (param $row i32) (param $nf i32)
    global.get $g_errs_end
    local.get $line
    local.get $row
    i32.const 0x2C100E0
    i32.const 11
    call $eb
    i32.const 0x2C10050
    i32.const 10
    call $cp
    local.get $nf
    call $u32
    i32.const 125
    call $st8
    global.set $g_errs_end)

  (func $elong (param $line i32) (param $row i32) (param $w i32)
    (local $d i32) (local $i i32) (local $nf i32)
    global.get $g_errs_end
    local.get $line
    local.get $row
    i32.const 0x2C100F0
    i32.const 10
    call $eb
    local.set $d
    local.get $d
    i32.const 0x2C10060
    i32.const 10
    call $cp
    local.set $d
    global.get $g_nfields
    local.set $nf
    local.get $w
    local.set $i
    block $done
      loop $l
        local.get $i
        local.get $nf
        i32.ge_u
        br_if $done
        local.get $i
        local.get $w
        i32.gt_u
        if
          local.get $d
          i32.const 44
          call $st8
          local.set $d
        end
        local.get $d
        local.get $i
        call $efield
        local.set $d
        local.get $i
        i32.const 1
        i32.add
        local.set $i
        br $l
      end
    end
    local.get $d
    i32.const 93
    call $st8
    i32.const 125
    call $st8
    global.set $g_errs_end)

  ;; ---- columns / rows ----
  (func $ecols (param $d i32) (result i32)
    (local $i i32) (local $nf i32)
    local.get $d
    i32.const 91
    call $st8
    local.set $d
    i32.const 0
    local.set $i
    global.get $g_nfields
    local.set $nf
    block $done
      loop $l
        local.get $i
        local.get $nf
        i32.ge_u
        br_if $done
        local.get $i
        i32.const 0
        i32.gt_u
        if
          local.get $d
          i32.const 44
          call $st8
          local.set $d
        end
        local.get $d
        local.get $i
        call $efield
        local.set $d
        local.get $i
        i32.const 1
        i32.add
        local.set $i
        br $l
      end
    end
    local.get $d
    i32.const 93
    call $st8)

  (func $erow (param $d i32) (result i32)
    (local $i i32) (local $nf i32)
    global.get $g_nrows
    i32.const 0
    i32.gt_u
    if
      local.get $d
      i32.const 44
      call $st8
      local.set $d
    end
    local.get $d
    i32.const 91
    call $st8
    local.set $d
    i32.const 0
    local.set $i
    global.get $g_nfields
    local.set $nf
    block $done
      loop $l
        local.get $i
        local.get $nf
        i32.ge_u
        br_if $done
        local.get $i
        i32.const 0
        i32.gt_u
        if
          local.get $d
          i32.const 44
          call $st8
          local.set $d
        end
        local.get $d
        local.get $i
        call $efield
        local.set $d
        local.get $i
        i32.const 1
        i32.add
        local.set $i
        br $l
      end
    end
    local.get $d
    i32.const 93
    call $st8)

  ;; ---- parse_case ----
  (func $parse_case (param $text_ptr i32) (param $text_len i32) (param $header i32) (param $out_ptr i32) (result i32)
    (local $b i32) (local $open i32) (local $openLine i32) (local $close i32)
    (local $raw i32) (local $rawlen i32) (local $end i32) (local $start i32)
    (local $ended i32) (local $d i32)
    local.get $text_len
    global.set $g_text_len
    local.get $text_ptr
    global.set $g_text_ptr
    local.get $text_ptr
    local.get $text_len
    i32.add
    global.set $g_end
    local.get $header
    global.set $g_header
    i32.const 1
    global.set $g_line
    local.get $text_ptr
    global.set $g_pos
    local.get $text_len
    i32.const 3
    i32.ge_u
    if
      local.get $text_ptr
      i32.load8_u
      i32.const 0xEF
      i32.eq
      local.get $text_ptr
      i32.const 1
      i32.add
      i32.load8_u
      i32.const 0xBB
      i32.eq
      i32.and
      local.get $text_ptr
      i32.const 2
      i32.add
      i32.load8_u
      i32.const 0xBF
      i32.eq
      i32.and
      if
        local.get $text_ptr
        i32.const 3
        i32.add
        global.set $g_pos
      end
    end
    i32.const 0x2400000
    global.set $g_rows_end
    i32.const 0x2800000
    global.set $g_errs_end
    i32.const 0x2900000
    global.set $g_cols_end
    i32.const -1
    global.set $g_width
    i32.const 0
    global.set $g_have_cols
    i32.const 0
    global.set $g_nrows
    i32.const 0
    global.set $g_nerrs
    i32.const 0
    global.set $g_nfields
    i32.const 0
    global.set $g_last_quoted
    block $od
      loop $ol
        block $bd
          loop $bl
            global.get $g_pos
            global.get $g_end
            i32.ge_u
            br_if $bd
            global.get $g_pos
            i32.load8_u
            local.set $b
            local.get $b
            i32.const 10
            i32.eq
            if
              global.get $g_pos
              i32.const 1
              i32.add
              global.set $g_pos
              global.get $g_line
              i32.const 1
              i32.add
              global.set $g_line
              br $bl
            end
            local.get $b
            i32.const 13
            i32.eq
            if
              global.get $g_pos
              i32.const 1
              i32.add
              global.get $g_end
              i32.lt_u
              if
                global.get $g_pos
                i32.const 1
                i32.add
                i32.load8_u
                i32.const 10
                i32.eq
                if
                  global.get $g_pos
                  i32.const 2
                  i32.add
                  global.set $g_pos
                  global.get $g_line
                  i32.const 1
                  i32.add
                  global.set $g_line
                  br $bl
                end
              end
            end
            br $bd
          end
        end
        global.get $g_pos
        global.get $g_end
        i32.ge_u
        br_if $od
        global.get $g_line
        global.set $g_rec_line
        global.get $g_header
        if
          global.get $g_have_cols
          i32.eqz
          if
            i32.const -1
            global.set $g_rec_row
          else
            global.get $g_nrows
            global.set $g_rec_row
          end
        else
          global.get $g_nrows
          global.set $g_rec_row
        end
        i32.const 0
        global.set $g_nfields
        i32.const 0
        global.set $g_last_quoted
        block $rd
          loop $fl
            i32.const 0
            local.set $ended
            global.get $g_pos
            global.get $g_end
            i32.lt_u
            if
              global.get $g_pos
              i32.load8_u
              i32.const 34
              i32.eq
              if
                i32.const 1
                global.set $g_last_quoted
                global.get $g_pos
                local.set $open
                global.get $g_line
                local.set $openLine
                global.get $g_pos
                i32.const 1
                i32.add
                global.set $g_pos
                global.get $g_pos
                call $find_close
                local.set $close
                local.get $close
                i32.const 0
                i32.lt_s
                if
                  local.get $open
                  i32.const 1
                  i32.add
                  global.set $g_pos
                  local.get $openLine
                  global.set $g_line
                  global.get $g_rec_line
                  global.get $g_rec_row
                  call $eunterminated
                  local.get $open
                  i32.const 1
                  i32.add
                  call $scan_unquoted
                  local.set $end
                  i32.const 2
                  local.get $open
                  i32.const 1
                  i32.add
                  local.get $end
                  local.get $open
                  i32.const 1
                  i32.add
                  i32.sub
                  i32.const 1
                  global.get $g_scan_ncr
                  call $add_field
                  global.get $g_scan_ended
                  local.set $ended
                else
                  local.get $close
                  global.get $g_pos
                  i32.sub
                  local.set $rawlen
                  global.get $g_pos
                  local.set $raw
                  local.get $close
                  i32.const 1
                  i32.add
                  global.set $g_pos
                  local.get $raw
                  local.get $rawlen
                  call $scan_quoted_raw
                  global.get $g_line
                  i32.add
                  global.set $g_line
                  i32.const 1
                  local.get $raw
                  local.get $rawlen
                  global.get $g_scan_dirty
                  i32.const 0
                  call $add_field
                  call $after_close
                  local.set $ended
                end
              else
                i32.const 0
                global.set $g_last_quoted
                global.get $g_pos
                local.set $start
                local.get $start
                call $scan_unquoted
                local.set $end
                i32.const 0
                local.get $start
                local.get $end
                local.get $start
                i32.sub
                global.get $g_scan_dirty
                global.get $g_scan_ncr
                call $add_field
                global.get $g_scan_ended
                local.set $ended
              end
            end
            local.get $ended
            i32.eqz
            if
              br $fl
            else
              br $rd
            end
          end
        end
        global.get $g_nfields
        i32.const 1
        i32.eq
        if
          global.get $g_last_quoted
          i32.eqz
          if
            i32.const 0x2A00000
            i32.const 8
            i32.add
            i32.load
            i32.eqz
            if
              i32.const 0x2A00000
              i32.const 4
              i32.add
              i32.load
              i32.const 0x2A00000
              i32.const 28
              i32.add
              i32.load
              i32.sub
              i32.eqz
              if
                br $ol
              end
            end
          end
        end
        global.get $g_width
        i32.const 0
        i32.lt_s
        if
          global.get $g_nfields
          global.set $g_width
        end
        global.get $g_header
        if
          global.get $g_have_cols
          i32.eqz
          if
            global.get $g_cols_end
            call $ecols
            global.set $g_cols_end
            i32.const 1
            global.set $g_have_cols
            br $ol
          end
        end
        global.get $g_nfields
        global.get $g_width
        i32.lt_s
        if
          global.get $g_rec_line
          global.get $g_rec_row
          global.get $g_nfields
          call $eshort
          block $pd
            loop $pl
              global.get $g_nfields
              global.get $g_width
              i32.ge_s
              br_if $pd
              i32.const 0
              i32.const 0
              i32.const 0
              i32.const 0
              i32.const 0
              call $add_field
              br $pl
            end
          end
        else
          global.get $g_nfields
          global.get $g_width
          i32.gt_s
          if
            global.get $g_rec_line
            global.get $g_rec_row
            global.get $g_width
            call $elong
            global.get $g_width
            global.set $g_nfields
          end
        end
        global.get $g_rows_end
        call $erow
        global.set $g_rows_end
        global.get $g_nrows
        i32.const 1
        i32.add
        global.set $g_nrows
        br $ol
      end
    end
    local.get $out_ptr
    local.set $d
    local.get $d
    i32.const 0x2C10080
    i32.const 11
    call $cp
    local.set $d
    global.get $g_header
    i32.eqz
    if
      local.get $d
      i32.const 0x2C10070
      i32.const 4
      call $cp
      local.set $d
    else
      global.get $g_have_cols
      if
        local.get $d
        i32.const 0x2900000
        global.get $g_cols_end
        i32.const 0x2900000
        i32.sub
        call $cp
        local.set $d
      else
        local.get $d
        i32.const 91
        call $st8
        local.set $d
        local.get $d
        i32.const 93
        call $st8
        local.set $d
      end
    end
    local.get $d
    i32.const 0x2C10090
    i32.const 9
    call $cp
    local.set $d
    local.get $d
    i32.const 0x2400000
    global.get $g_rows_end
    i32.const 0x2400000
    i32.sub
    call $cp
    local.set $d
    local.get $d
    i32.const 0x2C100A0
    i32.const 12
    call $cp
    local.set $d
    local.get $d
    i32.const 0x2800000
    global.get $g_errs_end
    i32.const 0x2800000
    i32.sub
    call $cp
    local.set $d
    local.get $d
    i32.const 0x2C100B0
    i32.const 2
    call $cp
    local.set $d
    local.get $d
    local.get $out_ptr
    i32.sub)

  ;; ---- find ----
  (func $find (param $s i32) (param $rem i32) (param $lit i32) (param $llen i32) (result i32)
    (local $i i32) (local $lim i32) (local $j i32)
    local.get $rem
    local.get $llen
    i32.sub
    local.set $lim
    local.get $lim
    i32.const 0
    i32.lt_s
    if
      i32.const -1
      return
    end
    i32.const 0
    local.set $i
    block $done
      loop $l
        local.get $i
        local.get $lim
        i32.gt_u
        br_if $done
        i32.const 0
        local.set $j
        block $ok
          loop $jl
            local.get $j
            local.get $llen
            i32.ge_u
            if
              local.get $s
              local.get $i
              i32.add
              return
            end
            local.get $s
            local.get $i
            i32.add
            local.get $j
            i32.add
            i32.load8_u
            local.get $lit
            local.get $j
            i32.add
            i32.load8_u
            i32.ne
            if
              br $ok
            end
            local.get $j
            i32.const 1
            i32.add
            local.set $j
            br $jl
          end
        end
        local.get $i
        i32.const 1
        i32.add
        local.set $i
        br $l
      end
    end
    i32.const -1)

  ;; ---- unescape ----
  (func $unescape (param $start i32) (param $end i32) (param $dst i32) (result i32)
    (local $p i32) (local $d i32) (local $b i32) (local $c i32) (local $cpv i32)
    (local $lo i32) (local $k i32)
    local.get $start
    local.set $p
    local.get $dst
    local.set $d
    block $done
      loop $l
        local.get $p
        local.get $end
        i32.ge_u
        if
          i32.const -1
          return
        end
        local.get $p
        i32.load8_u
        local.set $b
        local.get $b
        i32.const 34
        i32.eq
        if
          local.get $d
          local.get $dst
          i32.sub
          global.set $g_u_dlen
          local.get $p
          i32.const 1
          i32.add
          global.set $g_u_spos
          i32.const 0
          return
        end
        local.get $b
        i32.const 92
        i32.eq
        if
          local.get $p
          i32.const 1
          i32.add
          local.set $p
          local.get $p
          local.get $end
          i32.ge_u
          if
            i32.const -1
            return
          end
          local.get $p
          i32.load8_u
          local.set $c
          local.get $c
          i32.const 34
          i32.eq
          if
            local.get $d
            i32.const 34
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $p
            i32.const 1
            i32.add
            local.set $p
            br $l
          end
          local.get $c
          i32.const 92
          i32.eq
          if
            local.get $d
            i32.const 92
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $p
            i32.const 1
            i32.add
            local.set $p
            br $l
          end
          local.get $c
          i32.const 47
          i32.eq
          if
            local.get $d
            i32.const 47
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $p
            i32.const 1
            i32.add
            local.set $p
            br $l
          end
          local.get $c
          i32.const 98
          i32.eq
          if
            local.get $d
            i32.const 8
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $p
            i32.const 1
            i32.add
            local.set $p
            br $l
          end
          local.get $c
          i32.const 102
          i32.eq
          if
            local.get $d
            i32.const 12
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $p
            i32.const 1
            i32.add
            local.set $p
            br $l
          end
          local.get $c
          i32.const 110
          i32.eq
          if
            local.get $d
            i32.const 10
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $p
            i32.const 1
            i32.add
            local.set $p
            br $l
          end
          local.get $c
          i32.const 114
          i32.eq
          if
            local.get $d
            i32.const 13
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $p
            i32.const 1
            i32.add
            local.set $p
            br $l
          end
          local.get $c
          i32.const 116
          i32.eq
          if
            local.get $d
            i32.const 9
            i32.store8
            local.get $d
            i32.const 1
            i32.add
            local.set $d
            local.get $p
            i32.const 1
            i32.add
            local.set $p
            br $l
          end
          local.get $c
          i32.const 117
          i32.eq
          if
            local.get $p
            i32.const 1
            i32.add
            local.set $p
            i32.const 0
            local.set $cpv
            i32.const 0
            local.set $k
            block $hb
              loop $hl
                local.get $k
                i32.const 4
                i32.ge_u
                br_if $hb
                local.get $cpv
                i32.const 16
                i32.mul
                local.get $p
                local.get $k
                i32.add
                i32.load8_u
                call $hexval
                i32.add
                local.set $cpv
                local.get $k
                i32.const 1
                i32.add
                local.set $k
                br $hl
              end
            end
            local.get $p
            i32.const 4
            i32.add
            local.set $p
            local.get $cpv
            i32.const 0xD800
            i32.ge_u
            local.get $cpv
            i32.const 0xDBFF
            i32.le_u
            i32.and
            if
              local.get $p
              i32.const 6
              i32.add
              local.get $end
              i32.le_u
              if
                local.get $p
                i32.load8_u
                i32.const 92
                i32.eq
                local.get $p
                i32.const 1
                i32.add
                i32.load8_u
                i32.const 117
                i32.eq
                i32.and
                if
                  i32.const 0
                  local.set $lo
                  i32.const 0
                  local.set $k
                  block $lb
                    loop $ll
                      local.get $k
                      i32.const 4
                      i32.ge_u
                      br_if $lb
                      local.get $lo
                      i32.const 16
                      i32.mul
                      local.get $p
                      i32.const 2
                      i32.add
                      local.get $k
                      i32.add
                      i32.load8_u
                      call $hexval
                      i32.add
                      local.set $lo
                      local.get $k
                      i32.const 1
                      i32.add
                      local.set $k
                      br $ll
                    end
                  end
                  local.get $lo
                  i32.const 0xDC00
                  i32.ge_u
                  local.get $lo
                  i32.const 0xDFFF
                  i32.le_u
                  i32.and
                  if
                    local.get $cpv
                    i32.const 0xD800
                    i32.sub
                    i32.const 10
                    i32.shl
                    local.get $lo
                    i32.const 0xDC00
                    i32.sub
                    i32.add
                    i32.const 0x10000
                    i32.add
                    local.set $cpv
                    local.get $p
                    i32.const 6
                    i32.add
                    local.set $p
                  end
                end
              end
            end
            local.get $cpv
            local.get $d
            call $utf8
            local.set $d
            br $l
          end
          local.get $d
          local.get $c
          i32.store8
          local.get $d
          i32.const 1
          i32.add
          local.set $d
          local.get $p
          i32.const 1
          i32.add
          local.set $p
          br $l
        end
        local.get $d
        local.get $b
        i32.store8
        local.get $d
        i32.const 1
        i32.add
        local.set $d
        local.get $p
        i32.const 1
        i32.add
        local.set $p
        br $l
      end
    end
    i32.const 0)

  ;; ---- transduce_all ----
  (func $transduce_all (param $in i32) (param $inlen i32) (param $out i32) (result i32)
    (local $p i32) (local $sp i32) (local $end i32) (local $count i32)
    (local $idx i32) (local $hidx i32) (local $header i32)
    local.get $in
    local.get $inlen
    i32.add
    local.set $end
    local.get $out
    local.set $p
    local.get $p
    i32.const 91
    i32.store8
    local.get $p
    i32.const 1
    i32.add
    local.set $p
    local.get $in
    local.set $sp
    i32.const 0
    local.set $count
    block $done
      loop $l
        local.get $sp
        local.get $end
        local.get $sp
        i32.sub
        i32.const 0x2C10000
        i32.const 8
        call $find
        local.set $idx
        local.get $idx
        i32.const 0
        i32.lt_s
        if
          br $done
        end
        local.get $count
        if
          local.get $p
          i32.const 44
          i32.store8
          local.get $p
          i32.const 1
          i32.add
          local.set $p
        end
        local.get $idx
        i32.const 8
        i32.add
        local.get $end
        i32.const 0x1000000
        call $unescape
        if
          i32.const 0
          local.set $count
          br $done
        end
        global.get $g_u_spos
        local.get $end
        global.get $g_u_spos
        i32.sub
        i32.const 0x2C10010
        i32.const 9
        call $find
        local.set $hidx
        local.get $hidx
        i32.const 0
        i32.lt_s
        if
          i32.const 0
          local.set $count
          br $done
        end
        local.get $hidx
        i32.const 9
        i32.add
        i32.load8_u
        i32.const 116
        i32.eq
        local.set $header
        local.get $p
        i32.const 0x1000000
        global.get $g_u_dlen
        local.get $header
        local.get $p
        call $parse_case
        i32.add
        local.set $p
        local.get $hidx
        i32.const 9
        i32.add
        i32.const 5
        local.get $header
        i32.sub
        i32.add
        local.set $sp
        local.get $count
        i32.const 1
        i32.add
        local.set $count
        br $l
      end
    end
    local.get $count
    i32.eqz
    if
      i32.const -1
      return
    end
    local.get $p
    i32.const 93
    i32.store8
    local.get $p
    i32.const 1
    i32.add
    local.get $out
    i32.sub)

  (export "parse_case" (func $parse_case))
  (export "transduce_all" (func $transduce_all))
)
