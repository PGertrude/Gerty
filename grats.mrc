>start<|grats.mrc|Grats Script|1.11|rs
on $*:TEXT:/^[!@.](g|gratz|grats|lvl|level)\b/Si:#: {
  _CheckMain
  var %grat.out = $iif($left($1,1) == @,.msg $chan,.notice $nick)
  if (!$3) { halt }
  if ($right($1,-1) == google) { halt }
  if ($4 && *xp* !iswm $2-) { var %nick = $replace($4-,$chr(32),_,-,_) }
  if (!$4 && *xp* !iswm $2-) { var %nick = $nick }
  if ($5 && *xp* iswm $2-) { var %nick = $replace($5-,$chr(32),_,-,_) }
  if (!$5 && *xp* iswm $2-) { var %nick = $iif($4 == xp || $4 == exp || $4 == experience,$nick,$replace($4-,$chr(32),_,-,_)) }
  if ($3 && *xp* !iswm $2-) {
    if ($lookups($3) != overall && $lookups($3) != nomatch) {
      if ($lookups($3) == Combat) {
        if (($calculate($2) >= 1) && ($calculate($2) <= 138)) { .msg $chan :D\-< 4¤11.12¡9*4°9*12¡11.4¤ Gratz on lvl $2 $+(,$lookups($3),) $rsn(%nick) 4¤11.12¡9*4°9*12¡11.4¤ :D/-< }
        if ($calculate($2) == 138) { .msg $chan :D\-< 4¤11.12¡9*4°9*12¡11.4¤ And gratz on maxing out! 4¤11.12¡9*4°9*12¡11.4¤ :D/-< }
      }
      else {
        if (($calculate($2) <= 126) && ($calculate($2) >= 1)) { .msg $chan :D\-< 4¤11.12¡9*4°9*12¡11.4¤ Gratz on lvl $2 $+(,$lookups($3),) $rsn(%nick) 4¤11.12¡9*4°9*12¡11.4¤ :D/-< }
        if ($calculate($2) == 99) { .msg $chan :D\-< 4¤11.12¡9*4°9*12¡11.4¤ And gratz on maxing out! 4¤11.12¡9*4°9*12¡11.4¤ :D/-< }
      }
    }
    if ($lookups($2) != overall && $lookups($2) != nomatch) {
      if ($lookups($2) == Combat) {
        if (($calculate($3) >= 1) && ($calculate($3) <= 138)) { .msg $chan :D\-< 4¤11.12¡9*4°9*12¡11.4¤ Gratz on lvl $3 $+(,$lookups($2),) $rsn(%nick) 4¤11.12¡9*4°9*12¡11.4¤ :D/-< }
        if ($calculate($3) == 138) { .msg $chan :D\-< 4¤11.12¡9*4°9*12¡11.4¤ And gratz on maxing out! 4¤11.12¡9*4°9*12¡11.4¤ :D/-< }
      }
      else {
        if (($calculate($3) <= 126) && ($calculate($3) >= 1)) { .msg $chan :D\-< 4¤11.12¡9*4°9*12¡11.4¤ Gratz on lvl $3 $+(,$lookups($2),) $rsn(%nick) 4¤11.12¡9*4°9*12¡11.4¤ :D/-< }
        if ($calculate($3) == 99) { .msg $chan :D\-< 4¤11.12¡9*4°9*12¡11.4¤ And gratz on maxing out! 4¤11.12¡9*4°9*12¡11.4¤ :D/-< }
      }
    }
    if ($lookups($3) == Overall || $lookups($2) == overall) {
      if ((($calculate($2) >= 1) && ($calculate($2) <= 2376)) || (($calculate($3) >= 1) && ($calculate($3) <= 2376))) {
        if ($calculate($2) isnum) { var %2we = $2 }
        if ($calculate($3) isnum) { var %2we = $3 }
        .msg $chan :D\-< 4¤11.12¡9*4°9*12¡11.4¤ Gratz on lvl %2we $+(,Overall,) %nick 4¤11.12¡9*4°9*12¡11.4¤ :D/-<
      }
      if ($calculate($2) == 2376 || $calculate($2) == 2376) { .msg $chan :D\-< 4¤11.12¡9*4°9*12¡11.4¤ And gratz on maxing out! 4¤11.12¡9*4°9*12¡11.4¤ :D/-< }
    }
    if ($lookups($3) == nomatch && $lookups($2) == nomatch) { msg $chan Congratulations, you have just reached level 99 Idiocy! | msg $chan Please visit Martin on Mars to obtain your cape. You can get there by walking into a wall 7 times. }
  }
  if ($3 && *xp* iswm $2-) {
    if ($lookups($3) != overall && $lookups($3) != nomatch) {
      if ($lookups($3) == Combat) {
        if (($calculate($2) >= 1) && ($calculate($2) <= 1600000000)) { .msg $chan :D\-< 4¤11.12¡9*4°9*12¡11.4¤ Gratz on $2 $+(,$lookups($3),) Exp $rsn(%nick) 4¤11.12¡9*4°9*12¡11.4¤ :D/-< }
      }
      else {
        if (($calculate($2) <= 200000000) && ($calculate($2) >= 1)) { .msg $chan :D\-< 4¤11.12¡9*4°9*12¡11.4¤ Gratz on $2 $+(,$lookups($3),) Exp $rsn(%nick) 4¤11.12¡9*4°9*12¡11.4¤ :D/-< }
      }
    }
    if ($lookups($2) != overall && $lookups($2) != nomatch) {
      if ($lookups($2) == Combat) {
        if (($calculate($3) >= 1) && ($calculate($3) <= 1600000000)) { .msg $chan :D\-< 4¤11.12¡9*4°9*12¡11.4¤ Gratz on $3 $+(,$lookups($2),) Exp $rsn(%nick) 4¤11.12¡9*4°9*12¡11.4¤ :D/-< }
      }
      else {
        if (($calculate($3) <= 200000000) && ($calculate($3) >= 1)) { .msg $chan :D\-< 4¤11.12¡9*4°9*12¡11.4¤ Gratz on $3 $+(,$lookups($2),) Exp $rsn(%nick) 4¤11.12¡9*4°9*12¡11.4¤ :D/-< }
      }
    }
    if ($lookups($3) == Overall || $lookups($2) == overall) {
      if ((($calculate($2) >= 1) && ($calculate($2) <= 4800000000)) || (($calculate($3) >= 1) && ($calculate($3) <= 4800000000))) {
        if ($calculate($2) > 0) { var %2we = $2 }
        if ($calculate($3) > 0) { var %2we = $3 }
        .msg $chan :D\-< 4¤11.12¡9*4°9*12¡11.4¤ Gratz on %2we $+(,Overall,) Exp %nick 4¤11.12¡9*4°9*12¡11.4¤ :D/-<
      }
    }
  }
}
