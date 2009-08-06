>start<|iq.mrc|Fun Commands|2.0|rs
on $*:TEXT:/^[!@.](iq|life|e-?penis)/Si:*: {
  _CheckMain
  var %thread = $+(a,$ticks)
  var %nick, %saystyle, %command = $remove($right($1,-1),-)
  if (!$2) %nick = $rsn($nick)
  if ($2) %nick = $caps($rsn($regsubex($2-,/\W/g,_)))
  %saystyle = $saystyle($left(1,1),$nick,$chan)
  var %socket = stats. $+ %thread
  var %url = http://hiscore.runescape.com/index_lite.ws?player= $+ %nick
  noop $download.break(spam. $+ %command %saystyle %nick %socket,%socket,%url)
}
alias spam.iq {
  var %saystyle = $1 $2, %nick = $3, %socket = $4, %info
  .tokenize 10 $distribute($5)
  if ($1 == unranked) { %saystyle  $+ %nick $+ 's IQ level is:07 60 | halt }
  %info =  $+ %nick $+ 's IQ level is:07
  if ($gettok($1,2,44) > 1800) { %info = %info $floor($calc($v1 / 21 + $gettok($20,2,44))) }
  else if ($gettok($4,2,44) < 90) { %info = %info $floor($calc($gettok($1,2,44) / 21 + $gettok($21,2,44))) }
  else { %info = %info $floor($calc($gettok($1,2,44) / 21 - $gettok($4,2,44) + 50)) }
  %saystyle %info
}
alias spam.life {
  var %saystyle = $1 $2, %nick = $3, %socket = $4, %info, %lvl, %xp, %newlvl, %newxp
  .tokenize 10 $distribute($5)
  if ($1 == unranked) { %saystyle  $+ %nick $+  07life | Rank:07 424,597 | Level:07 45 (0745) $(|,) Exp:07 63,572 (070.49% of 99) $(|,) Exp till 46:07 4,411 (31.8%) | halt }
  .tokenize 44 $1
  %lvl = 126 - $xptolvl($calc($3 / 24))
  %xp = $calc( ( $floor($calc($3 / 24)) - $lvltoxp($xptolvl($calc($3 / 24))) ) / ( $lvltoxp($calc($xptolvl($calc($3 / 24)) +1)) - $lvltoxp($xptolvl($calc($3 / 24))) ) )
  %newxp = $floor( $calc( $lvltoxp(%lvl) + %xp * ( $lvltoxp($calc(%lvl +1)) - $lvltoxp(%lvl) ) ) )
  %newlvl = $calc( $lvltoxp($calc(%lvl +1)) - %newxp )
  %saystyle  $+ %nick $+  07life | Rank:07 $remove($bytes($floor($calc( (($3 / 24) / 200) * 4 ) ),db),-) | Level:07 %lvl | Exp:07 $bytes(%newxp,db) | Exp till $calc(%lvl +1) $+ :07 $bytes(%newlvl,db) (07 $+ $remove($round($calc( %xp * 100 ),1),-) $+ 07%)
}
alias spam.epenis {
  var %saystyle = $1 $2, %nick = $3, %socket = $4, %info
  .tokenize 10 $distribute($5)
  if ($1 == unranked) { %saystyle 07 $+ %nick $+ 's e-penis is07 6 Inches. | halt }
  %saystyle  $+ %nick $+ 's epenis is07 $round($calc( $gettok($1,2,44) / 200 + $gettok($21,3,44) / 1000000 ),1) Inches.
}
