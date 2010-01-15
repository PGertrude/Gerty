; Connects to the database on startup
on *:START:{
  var %db $sqlite_open(gerty.db)
  if (!%db) {
    echo 4 -a Failed to connect to gerty.db
    return
  }
  echo 3 -a gerty.db Loaded
}

; 'PUBLIC' METHODS

;@SYNTAX dbSelect(string table, string[] fields, params string[] conditions)
;@SUMMARY returns an 'array' of the results for an msl SELECT query on the gerty database.
;@NOTE beware of entering conditions with spaces: use $dbSelectWhere
alias dbSelect {
  var %table = $1, %fields = $replace($2,;,$chr(44)), %conditions = $3-
  var %sql = SELECT %fields FROM %table

  ; CONDITIONS
  ; Check for null tokens
  var %x = 1
  while (%x <= $0) {
    if ($($ $+ %x,2) == $null) fatalError sqliteCommands > dbSelect > params > There is a null parameter @ $($ $+ %x $+ .,1)
    inc %x
  }
  .tokenize 32 %conditions
  ; Check conditions
  if ($calc($0 % 2) != 0) fatalError sqliteCommands > dbSelect > conditions > Mismatch in field/value assossiation.
  ; Form WHERE
  var %where, %x = 1
  while (%x <= $0) {
    %where = %where $($ $+ %x,2) = ' $+ $($ $+ $calc(%x + 1),2) $+ ' AND
    inc %x 2
  }
  if (%where) %sql = %sql WHERE $left(%where, -4)
  if ($prop == sql) return %sql
  ; Execute sql
  return $sql_query(%sql, %fields)

  :error
  reseterror
  warnError sqliteCommands > dbSelect > Unknown Error: sql at time of error: %sql
  return $false
}

;@SYNTAX dbSelectWhere(string table, string[] fields, string conditions)
;@SUMMARY returns an 'array' of the results for an msl SELECT query on the gerty database.
alias dbSelectWhere {
  var %table = $1, %fields = $replace($2,;,$chr(44)), %condition = $3
  var %sql = SELECT %fields FROM %table WHERE %condition

  ; Check for null tokens
  var %x = 1
  while (%x <= $0) {
    if ($($ $+ %x,2) == $null) fatalError sqliteCommands > dbSelectWhere > params > There is a null parameter @ $($ $+ %x $+ .,1)
    inc %x
  }
  if ($prop == sql) return %sql
  ; Execute sql
  return $sql_query(%sql, %fields)

  :error
  reseterror
  warnError sqliteCommands > dbSelectWhere > Unknown Error: sql at time of error: %sql
  return $false
}

;@SYNTAX dbUpdate(string table, string condition, params string[] fields)
;@SUMMARY updates an existing row in an sqlite database.
alias dbUpdate {
  var %table = $1, %condition = $2, %fields = $3-
  var %sql = UPDATE $+(`,%table,`) SET

  ; Check for null tokens
  var %x = 1
  while (%x <= $0) {
    if (!$($ $+ %x,2)) fatalError sqliteCommands > dbUpdate > params > There is a null parameter @ $($ $+ %x $+ .,1)
    inc %x
  }

  var %x = 3, %fields
  while (%x <= $0) {
    %fields = %fields $+(`,$($ $+ %x,2),`,=,',$($ $+ $calc(%x + 1),2),',$chr(44))
    inc %x 2
  }
  %fields = $left(%fields, -1)
  %sql = %sql %fields WHERE %condition $+ ;
  if ($prop == sql) return %sql
  ; Perform Query
  var %query $sqlite_query(1, %sql)
  return $true

  :error
  reseterror
  warnError sqliteCommands > dbUpdate > Unknown Error: sql at time of error: %sql
  return $false
}

;@SYNTAX getDefname(string ircNick), getDefname(string fingerPrint)
;@SUMMARY returns the rsn for a user, if found, returns $false if not. Accepts input as an irc nick, or as their hostmask(format 3).
alias getDefname {
  if ($0 != 1) fatalError sqliteCommands > getDefname > No overload for getDefname takes $0 arguments, best match takes 1 argument: getDefname(string ircNick)
  var %fingerPrint = $iif($left($1,1) == $chr(42), $right($1,-3), $1), %rsn = $false
  if (@ !isin $1) %fingerprint = $right($address($1,3),-3)
  if (%fingerPrint) %rsn = $dbSelect(users, rsn, fingerprint, %fingerprint)
  if (%rsn) return %rsn
  return $false
}

;@SYNTAX getChanSetting(string channel, string setting)
;@SUMMARY returns the value of a channel setting.
alias getChanSetting return $iif($dbSelect(channel, $2, channel, $1), $v1, $false)

;@SYNTAX getUserSetting(string fingerprint, string setting, bool rsn)
;@SUMMARY returns the value of a user setting. Often returned as an 'array'. If $3 is $true, searches by rsn, else fingerprint
alias getUserSetting return $iif($dbSelect(users, $2, $iif($3,rsn,fingerprint), $1), $v1, $false)

;@SYNTAX getPrice(string item), getPrice(int itemId)
;@SUMMARY returns an 'array' 0 = name, 1 = price {Token 59}. Can be requested by id, or by name.
;@NOTE return type $null = no entry for item, return type $false = price unknown.
alias getPrice {
  if ($0 != 1) fatalError sqliteCommands > getPrice > No overload for getPrice takes $0 arguments, best match takes 1 argument: getPrice(string item)
  var %price
  if ($1 isnum) {
    if ($prop == sql) return $dbSelect(prices, name;price;change, id, $1).sql
    %price = $dbSelect(prices, name;price;change, id, $1)
    if (%price == $null) return $null
    else if ($trim($gettok(%price,2,59)) == 0) return $false
    return %price
  }
  else {
    if ($prop == sql) return $dbSelectWhere(prices, name;price;change, name LIKE $+('%,$1,$%,') ORDER BY price DESC).sql
    %price = $dbSelectWhere(prices, name;price;change, name LIKE $+('%,$1,$%,') AND price>0 ORDER BY price DESC)
    if (%price == $null) return $null
    else if ($trim($gettok(%price,2,59)) == 0) return $false
    return %price
  }
}

;@SYNTAX getPriceId(string item)
;@SUMMARY returns the Id of an item.
;@NOTE return type $null = no entry for item.
alias getPriceId {
  if ($0 != 1) fatalError sqliteCommands > getPrice > No overload for getPrice takes $0 arguments, best match takes 1 argument: getPrice(string item)
  var %id
  %id = $dbSelectWhere(prices, id;name, name LIKE '% $+ $1 $+ $% $+ ')
  if (%id == $null) return $null
  return %id
}

;@SYNTAX setPrice(int itemId, int price[, int change])
;@SUMMARY updates the price of an already existing item.
alias setPrice {
  if ($0 != 2 && $0 != 3) fatalError sqliteCommands > setPrice > No overload for setPrice takes $0 arguments, best match takes 3 arguments: setPrice(int itemId, int price, int change)
  var %change $3
  var %update $dbUpdate(prices, $+(`id`=',$1,'), price, $2, change, $iif($3, $3, NULL))
  if (%update) return $true
  return $false
}

;@SYNTAX resetPrices
;@SUMMARY resets all ge prices to 0
;@NOTE only trigger after a ge update.
alias resetPrices noop $sqlite_query(1, UPDATE `prices` SET `price`=0,`change`='NULL';)

;@SYNTAX countResults(string sql)
;@SUMMARY returns the number of rows in a query result.
alias countResults {
  var %query $sqlite_query(1, $1)
  return $sqlite_num_rows(%query)
}

;@SYNTAX getStringParameter(string fingerprint, string skill, string field, bool rsn)
;@SUMMARY returns the item or goal saved to a user. saved form skill:goal;skill:goal;
alias getStringParameter {
  if (!$4) .tokenize 32 $1- $false
  var %fieldValue $userSet($1, $3, $4)
  var %regex / $+ $2 $+ :([^;]+);/i
  noop $regex(%fieldValue, %regex)
  if ($regml(1)) return $v1
  return $false
}

;@SYNTAX setStringParameter(string fingerprint, string skill, string field, string value, bool rsn)
;@SUMMARY inserts a parameter into a field on the `users` table, saves as skill:value;skill:value
alias setStringParameter {
  if (!$5) .tokenize 32 $1 $replace($2,$chr(32),_) $3 $replace($4,$chr(32),_) $false
  var %fieldValue $userSet($1, $3, $5)
  var %regex /( $+ $2 $+ :[^;]+;)/i
  var %replace $replace($2,_,$chr(32)) $+ : $+ $replace($4,_,$chr(32)) $+ ;
  var %newField $regsubex(%fieldValue, %regex, %replace)
  if ($2 !isin %newField) %newField = %newField $+ %replace
  noop $dbUpdate(users,` $+ $iif($5,rsn,fingerprint) $+ `=' $+ $1 $+ ', $3, %newField)
}

;@SYNTAX rowExists(string table, string field, string value)
alias rowExists {
  var %query $sqlite_query(1, SELECT * FROM ` $+ $1 $+ ` WHERE ` $+ $2 $+ `=' $+ $3 $+ ';)
  if ($sqlite_num_rows(%query) > 0) return $true
  return $false
}



; 'PRIVATE' METHODS

;@SYNTAX sql_query(string sqlQuery)
;@SUMMARY Performs the sqlQuery on the gerty database. Will return an array if necessary, respective of the fields input.
;@NOTE return type $null = no results, return type $false = error occured
alias -l sql_query {
  var %sql = $1
  ; Perform Query
  var %query $sqlite_query(1, %sql)
  if ($sqlite_num_rows(%query) == 0) { return $null }
  ; Parse results
  ; get required response fields.
  .tokenize 44 $2
  var %x = 1, %fields
  while (%x <= $0) {
    %fields = %fields ; $!hget(row, $($ $+ %x,2) )
    inc %x
  }
  %fields = $right(%fields, -2)
  var %result_string
  while ($sqlite_fetch_row(%query, row, $SQLITE_ASSOC)) {
    %result_string = %result_string $+ $(%fields,2) $+ ,
  }
  hfree row
  return $left(%result_string,-1)

  ; catch an error in variable size
  :error
  reseterror
  warnError sqliteCommands > sql_query > Too many results returned by the command $+(",%sql,")
  return $false
}

; Throw a fatal error.
; echos hopefully useful information about where and why the error has occured.
alias -l fatalError {
  linesep
  echo $color(info) * $1-
  linesep
  halt
}
; Throw a non-fatal error
alias -l warnError {
  linesep
  echo $color(info) * $1-
  linesep
}