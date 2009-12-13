>start<|urban.mrc|Urban Dictionary command|1.1|rs
on $*:TEXT:/^[!@.]urban\b/Si:*: {
  _CheckMain
  var %thread = $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  _fillCommand %thread $left($1,1) $nick $iif($chan,$v1,PM) urban $replace($2-,$chr(32),+)
  var %url = http://www.rscript.org/lookup.php?type=urban&id=1&search= $+ $cmd(%thread,arg1)
  noop $download.break(urban %thread,urban. $+ %thread, %url)
}
alias urban {
  var %thread = $1, %urban = $2-
  .tokenize 10 %urban
  if (MATCHES: 0 isin $3) {
    $cmd(%thread,out) Urban Dictionary has no entry for ' $+ $cmd(%thread,arg1) $+ '.
    _clearCommand %thread
    halt
  }
  if (DEFINED: isin $4) {
    $cmd(%thread,out) Urban Dictionary: ' $+ $cmd(%thread,arg1) $+ ' $regsubex($gettok($4,2,58),/(^|\s)(\d+\.)\s/g,$+($chr(32),07\2,$chr(32)))
  }
  if (EXAMPLE: isin $5) {
    $cmd(%thread,out) Example: $regsubex($gettok($5,2,58),/(^|\s)(\d+\.)\s/g,$+($chr(32),07\2,$chr(32)))
  }
  _clearCommand %thread
}
