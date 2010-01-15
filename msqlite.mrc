alias SQLITE_OK                   return 0
alias SQLITE_ERROR                return 1
alias SQLITE_INTERNAL             return 2
alias SQLITE_PERM                 return 3
alias SQLITE_ABORT                return 4
alias SQLITE_BUSY                 return 5
alias SQLITE_LOCKED               return 6
alias SQLITE_NOMEM                return 7
alias SQLITE_READONLY             return 8
alias SQLITE_INTERRUPT            return 9
alias SQLITE_IOERR                return 10
alias SQLITE_CORRUPT              return 11
alias SQLITE_NOTFOUND             return 12
alias SQLITE_FULL                 return 13
alias SQLITE_CANTOPEN             return 14
alias SQLITE_PROTOCOL             return 15
alias SQLITE_EMPTY                return 16
alias SQLITE_SCHEMA               return 17
alias SQLITE_TOOBIG               return 18
alias SQLITE_CONSTRAINT           return 19
alias SQLITE_MISMATCH             return 20
alias SQLITE_MISUSE               return 21
alias SQLITE_NOLFS                return 22
alias SQLITE_AUTH                 return 23
alias SQLITE_FORMAT               return 24
alias SQLITE_RANGE                return 25
alias SQLITE_NOTADB               return 26
alias SQLITE_INVALIDARG           return 200
alias SQLITE_NOMOREROWS           return 201
alias SQLITE_NOTMEMORYDB          return 202

alias SQLITE_BEG                  return 1
alias SQLITE_CUR                  return 2
alias SQLITE_END                  return 3

alias SQLITE_BOTH                 return 1
alias SQLITE_NUM                  return 2
alias SQLITE_ASSOC                return 3

alias SQLITE_ALL                  return 1
alias SQLITE_BOUND                return 2

alias SQLITE_INTEGER              return 1
alias SQLITE_FLOAT                return 2
alias SQLITE_TEXT                 return 3
alias SQLITE_BLOB                 return 4
alias SQLITE_NULL                 return 5

alias SQLITE_DENY                 return 1
alias SQLITE_IGNORE               return 2

alias SQLITE_CREATE_INDEX         return 1
alias SQLITE_CREATE_TABLE         return 2
alias SQLITE_CREATE_TEMP_INDEX    return 3
alias SQLITE_CREATE_TEMP_TABLE    return 4
alias SQLITE_CREATE_TEMP_TRIGGER  return 5
alias SQLITE_CREATE_TEMP_VIEW     return 6
alias SQLITE_CREATE_TRIGGER       return 7
alias SQLITE_CREATE_VIEW          return 8
alias SQLITE_DELETE               return 9
alias SQLITE_DROP_INDEX           return 10
alias SQLITE_DROP_TABLE           return 11
alias SQLITE_DROP_TEMP_INDEX      return 12
alias SQLITE_DROP_TEMP_TABLE      return 13
alias SQLITE_DROP_TEMP_TRIGGER    return 14
alias SQLITE_DROP_TEMP_VIEW       return 15
alias SQLITE_DROP_TRIGGER         return 16
alias SQLITE_DROP_VIEW            return 17
alias SQLITE_INSERT               return 18
alias SQLITE_PRAGMA               return 19
alias SQLITE_READ                 return 20
alias SQLITE_SELECT               return 21
alias SQLITE_TRANSACTION          return 22
alias SQLITE_UPDATE               return 23
alias SQLITE_ATTACH               return 24
alias SQLITE_DETACH               return 25
alias SQLITE_ALTER_TABLE          return 26
alias SQLITE_REINDEX              return 27
alias SQLITE_ANALYZE              return 28
alias SQLITE_CREATE_VTABLE        return 29
alias SQLITE_DROP_VTABLE          return 30
alias SQLITE_FUNCTION             return 31

alias -l sqlite_dll return $qt($+($scriptdir,msqlite.dll))
alias sqlite_help run $+($scriptdir,msqlite.chm)
alias sqlite_libversion return $dll($sqlite_dll, msqlite_libversion, $null)
alias sqlite_dllversion return $dll($sqlite_dll, msqlite_dllversion, $null)
alias sqlite_error_string return $dll($sqlite_dll, msqlite_error_string, $1)
alias sqlite_open return $dll($sqlite_dll, msqlite_open, $qt($1) $iif($2, $qt($2)))
alias sqlite_open_memory return $sqlite_open(:memory:, $1)
alias sqlite_close return $dll($sqlite_dll, msqlite_close, $1)

alias sqlite_exec {
  var %id = $gettok($1, 1, 32), %file = 0
  if ($sqlite_is_valid_statement(%id)) {
    var %bind, %i = 2
    while (%i <= $0) {
      var %value = $ [ $+ [ %i ] ]
      %bind = %bind $+(",$replace(%value,\,\\,",\"),")
      inc %i
    }
    return $dll($sqlite_dll, msqlite_exec, %id %bind)
  }
  else if ($isid) {
    var %params = $calc($0 - 2)
    if ($prop == file) {
      %file = 1
    }
    if (%params > 0) {
      var %bind, %i = 3
      while (%i <= $0) {
        var %value = $ [ $+ [ %i ] ]
        %bind = %bind $+(",$replace(%value,\,\\,",\"),")
        inc %i
      }
      return $dll($sqlite_dll, msqlite_exec, %id %file %params %bind $2)
    }
  }
  return $dll($sqlite_dll, msqlite_exec, %id %file 0 $2-)
}

alias sqlite_exec_file {
  if (!$isid || $0 < 3) {
    return $sqlite_exec($1, $2).file
  }
  else {
    var %params, %i = 1
    while (%i <= $0) {
      %params = $+(%params,$iif(%params,$chr(44)),$ $+ %i)
      inc %i
    }
    var %cmd = $!sqlite_exec( $+ %params $+ ).file
    return [ [ %cmd ] ]
  }
}

alias sqlite_query {
  var %id = $gettok($1, 1, 32), %file = 0
  if ($sqlite_is_valid_statement(%id)) {
    var %bind, %i = 2
    while (%i <= $0) {
      var %value = $ [ $+ [ %i ] ]
      %bind = %bind $+(",$replace(%value,\,\\,",\"),")
      inc %i
    }
    return $dll($sqlite_dll, msqlite_query, %id %bind)
  }
  elseif ($isid) {
    var %params = $calc($0 - 2)
    if ($prop == file) {
      %file = 1
    }
    if (%params > 0) {
      var %bind, %i = 3
      while (%i <= $0) {
        var %value = $ [ $+ [ %i ] ]
        %bind = %bind $+(",$replace(%value,\,\\,",\"),")
        inc %i
      }
      return $dll($sqlite_dll, msqlite_query, %id %file %params %bind $2)
    }
  }
  return $dll($sqlite_dll, msqlite_query, %id %file 0 $2-)
}

alias sqlite_unbuffered_query {
  var %id = $gettok($1, 1, 32), %file = 0
  if ($sqlite_is_valid_statement(%id)) {
    var %bind, %i = 2
    while (%i <= $0) {
      var %value = $ [ $+ [ %i ] ]
      %bind = %bind $+(",$replace(%value,\,\\,",\"),")
      inc %i
    }
    return $dll($sqlite_dll, msqlite_unbuffered_query, %id %bind)
  }
  elseif ($isid) {
    var %params = $calc($0 - 2)
    if ($prop == file) {
      %file = 1
    }
    if (%params > 0) {
      var %bind, %i = 3
      while (%i <= $0) {
        var %value = $ [ $+ [ %i ] ]
        %bind = %bind $+(",$replace(%value,\,\\,",\"),")
        inc %i
      }
      return $dll($sqlite_dll, msqlite_unbuffered_query, %id %file %params %bind $2)
    }
  }
  return $dll($sqlite_dll, msqlite_unbuffered_query, %id %file 0 $2-)
}

alias sqlite_free return $dll($sqlite_dll, msqlite_free, $1)
alias sqlite_finalize return $sqlite_free($1)
alias sqlite_escape_string return $replace($1-, ', '')
alias sqlite_num_rows return $dll($sqlite_dll, msqlite_num_rows, $1)
alias sqlite_num_fields return $dll($sqlite_dll, msqlite_num_fields, $1)
alias sqlite_changes return $dll($sqlite_dll, msqlite_changes, $1)
alias sqlite_last_insert_rowid return $dll($sqlite_dll, msqlite_last_insert_rowid, $1)
alias sqlite_field_name return $dll($sqlite_dll, msqlite_field_name, $gettok($1, 1, 32) $2)
alias sqlite_field_type return $dll($sqlite_dll, msqlite_field_type, $gettok($1, 1, 32) $2)
alias sqlite_fetch_row return $dll($sqlite_dll, msqlite_fetch_row, $gettok($1, 1, 32) $gettok($2, 1, 32) $3)

alias sqlite_fetch_bound {
  tokenize 32 $dll($sqlite_dll, msqlite_fetch_bound, $gettok($1, 1, 32) $2)
  if ($0 == 3) {
    var %file = $1, %i = 1, %total = $numtok($2, 124), %offset = 0
    while (%i <= %total) {
      var %size = $gettok($2, %i, 124), %bvar = $gettok($3, %i, 124)
      bread %file %offset %size %bvar
      inc %offset %size
      inc %i
    }
  }
  return 1
}

alias sqlite_fetch_single {
  if ($0 < 2) {
    return $dll($sqlite_dll, msqlite_fetch_single, $1)
  }
  else {
    tokenize 32 $dll($sqlite_dll, msqlite_fetch_single, $gettok($1, 1, 32) $2)
    if ($0 == 3) {
      bread $1 0 $2 $3
      return $bvar($3, 0)
    }
    return $null
  }
}

alias sqlite_fetch_field {
  if ($0 < 3) {
    return $dll($sqlite_dll, msqlite_fetch_field, $1 $iif($2 !isnum || $prop == name, 1, 0) $2 1)
  }
  else {
    tokenize 32 $dll($sqlite_dll, msqlite_fetch_field, $1 $iif($2 !isnum || $prop == name, 1, 0) $2 1 $3)
    if ($0 == 3) {
      bread $1 0 $2 $3
      return $bvar($3, 0)
    }
    return $null
  }
}

alias sqlite_has_more return $dll($sqlite_dll, msqlite_has_more, $1)
alias sqlite_has_prev return $dll($sqlite_dll, msqlite_has_prev, $1)
alias sqlite_next return $dll($sqlite_dll, msqlite_next, $1)
alias sqlite_prev return $dll($sqlite_dll, msqlite_prev, $1)
alias sqlite_seek return $dll($sqlite_dll, msqlite_seek, $gettok($1, 1, 32) $2)
alias sqlite_rewind return $sqlite_seek($1, 1, $SQLITE_BEG)
alias sqlite_key return $dll($sqlite_dll, msqlite_key, $1)
alias sqlite_current return $dll($sqlite_dll, msqlite_current, $gettok($1, 1, 32) $gettok($2, 1, 32) $3)
alias sqlite_current_bound return $dll($sqlite_dll, msqlite_current_bound, $gettok($1, 1, 32) $gettok($2, 1, 32) $3)

alias sqlite_result {
  if ($0 < 3) {
    return $dll($sqlite_dll, msqlite_fetch_field, $1 $iif($2 !isnum || $prop == name, 1, 0) $2 0)
  }
  else {
    tokenize 32 $dll($sqlite_dll, msqlite_fetch_field, $1 $iif($2 !isnum || $prop == name, 1, 0) $2 0 $3)
    if ($0 == 3) {
      bread $1 0 $2 $3
      return $bvar($3, 0)
    }
    return $null
  }
}

alias sqlite_busy_timeout return $dll($sqlite_dll, msqlite_busy_timeout, $gettok($1, 1, 32) $2)
alias sqlite_create_function return $dll($sqlite_dll, msqlite_create_function, $gettok($1, 1, 32) $gettok($2, 1, 32) $gettok($3, 1, 32) $gettok($4, 1, 32) $5)
alias sqlite_create_aggregate return $dll($sqlite_dll, msqlite_create_aggregate, $gettok($1, 1, 32) $gettok($2, 1, 32) $gettok($3, 1, 32) $gettok($4, 1, 32) $gettok($5, 1, 32) $gettok($6, 1, 32) $7)
alias sqlite_signal_error return $dll($sqlite_dll, msqlite_signal_error, $1-)
alias sqlite_qt return $+(',$1-,')
alias sqlite_field_metadata return $dll($sqlite_dll, msqlite_field_metadata, $1-)
alias sqlite_load_extension return $dll($sqlite_dll, msqlite_load_extension, $gettok($1, 1, 32) $gettok($2, 1, 32) $3)
alias sqlite_is_valid_conn return $dll($sqlite_dll, msqlite_is_valid_conn, $1)
alias sqlite_is_valid_result return $dll($sqlite_dll, msqlite_is_valid_result, $1)
alias sqlite_is_valid_statement return $dll($sqlite_dll, msqlite_is_valid_statement, $1)
alias sqlite_is_memory return $dll($sqlite_dll, msqlite_is_memory, $1)
alias sqlite_write_to_file return $dll($sqlite_dll, msqlite_write_to_file, $gettok($1, 1, 32) $qt($2-))
alias sqlite_reload noop $dll($sqlite_dll, msqlite_reload, $null)

alias sqlite_set_authorizer {
  if ($2 != $null) {
    return $dll($sqlite_dll, msqlite_set_authorizer, $gettok($1, 1, 32) $gettok($2, 1, 32) $3)
  }
  else {
    return $dll($sqlite_dll, msqlite_set_authorizer, $1)
  }
}

alias sqlite_prepare {
  var %id = $gettok($1, 1, 32), %file = 0
  if ($isid && $prop == file) {
    %file = 1
  }
  return $dll($sqlite_dll, msqlite_prepare, %id %file $2-)
}


alias sqlite_bind_field return $dll($sqlite_dll, msqlite_bind_field, $gettok($1, 1, 32) $iif($2 !isnum || $prop == name, 1, 0) $gettok($2, 1, 32) $gettok($3, 1, 32))
alias sqlite_bind_column return $sqlite_bind_field($1, $2, $3)
alias sqlite_bind_param return $dll($sqlite_dll, msqlite_bind_param, $gettok($1, 1, 32) $gettok($2, 1, 32) $gettok($3, 1, 32) $4)

alias sqlite_bind_value {
  if ($0 < 3) {
    return $dll($sqlite_dll, msqlite_bind_value, $gettok($1, 1, 32) $2)
  }
  else {
    return $dll($sqlite_dll, msqlite_bind_value, $gettok($1, 1, 32) $gettok($2, 1, 32) $iif($0 < 4, -1, $gettok($4, 1, 32)) $3)
  }
}

alias sqlite_clear_bindings return $dll($sqlite_dll, msqlite_clear_bindings, $1)
alias sqlite_begin return $sqlite_exec($1, BEGIN TRANSACTION)
alias sqlite_commit return $sqlite_exec($1, COMMIT TRANSACTION)
alias sqlite_rollback return $sqlite_exec($1, ROLLBACK TRANSACTION)
alias sqlite_autocommit return $dll($sqlite_dll, msqlite_autocommit, $gettok($1, 1, 32) $2)
