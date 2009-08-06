>start<|rank.mrc|typo fixed|1.2|rs
on $*:NOTICE:/^[@!.]Rank */Si:*: {
  var %class = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  hadd -m $+(e,%class) out .notice $nick
  if (!$3) { $hget($+(e,%class),out) Invalid Command. !rank <number> <skill> | halt }
  if (($scores($3) != nomatch) && ($litecalc($remove($2,$#)) >= 1) && ($litecalc($remove($2,$#)) <= 2000000)) {
    hadd -m $+(e,%class) skill $scores($3)
    hadd -m $+(e,%class) rank $litecalc($remove($2,$#))
    sockopen $+(rank.e,%class) hiscore.runescape.com 80
  }
  if (($scores($2) != nomatch) && ($litecalc($remove($3,$#)) >= 1) && ($litecalc($remove($3,$#)) <= 2000000)) {
    hadd -m $+(e,%class) skill $scores($2)
    hadd -m $+(e,%class) rank $litecalc($remove($3,$#))
    sockopen $+(rank.e,%class) hiscore.runescape.com 80
  }
}
on $*:TEXT:/^[@!.]Rank\b/Si:*: {
  _CheckMain
  var %class = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  hadd -m $+(e,%class) out $saystyle($left($1,1),$nick,$chan)
  if (!$3) { $hget($+(e,%class),out) Invalid Command. !rank <number> <skill> | halt }
  if (($scores($3) != nomatch) && ($litecalc($remove($2,$#)) >= 1) && ($litecalc($remove($2,$#)) <= 2000000)) {
    hadd -m $+(e,%class) skill $scores($3)
    hadd -m $+(e,%class) rank $litecalc($remove($2,$#))
    sockopen $+(rank.e,%class) hiscore.runescape.com 80
  }
  if (($scores($2) != nomatch) && ($litecalc($remove($3,$#)) >= 1) && ($litecalc($remove($3,$#)) <= 2000000)) {
    hadd -m $+(e,%class) skill $scores($2)
    hadd -m $+(e,%class) rank $litecalc($remove($3,$#))
    sockopen $+(rank.e,%class) hiscore.runescape.com 80
  }
}
on *:sockopen:rank.*: {
  sockwrite -n $sockname GET /overall.ws?category_type= $+ $catno($hget($gettok($sockname,2,46),skill)) $+ &table= $+ $smartno($hget($gettok($sockname,2,46),skill)) $+ &rank= $+ $hget($gettok($sockname,2,46),rank)
  sockwrite -n $sockname Host: hiscore.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:rank.*: {
  if ($sockerr) {
    $hget($gettok($sockname,2,46),out) There was a socket error.
    halt
  }
  .sockread %read
  if (*#F3C334* iswm %read) {
    var %nick $nohtml(%read)
    .sockread %read
    var %level $nohtml(%read)
    .sockread %read
    var %exp $remove($nohtml(%read),$chr(44))
    var %skill = $hget($gettok($sockname,2,46),skill)
    var %rank = $hget($gettok($sockname,2,46),rank)
    if ($minigames(%skill) == NoMatch) {
      $hget($gettok($sockname,2,46),out)  $+ %nick 07 $+ %skill | Rank:07 $bytes(%rank,db) | Lvl:07 %level $iif(%skill != overall,(07 $+ $virtual(%exp) $+ )) | Exp:07 $bytes(%exp,db) $&
        $iif(%skill != overall,(07 $+ $round($calc(100 * %exp / 13034431 ),1) $+ 07% of 99) | Exp till $calc($virtual(%exp) +1) $+ :07 $bytes($calc($lvltoxp($calc($virtual(%exp) +1)) - %exp),db)))
      rscript.singleskill $sockname $replace(%nick,$chr(32),_) %skill $hget($gettok($sockname,2,46),out)
    }
    if ($minigames(%skill) != NoMatch) {
      $hget($gettok($sockname,2,46),out)  $+ %nick $+ 07 %skill | Rank:07 $bytes(%rank,db) | Score:07 %level
      rscript.singleminigame $sockname $replace(%nick,$chr(32),_) $replace(%skill,$chr(32),_) $hget($gettok($sockname,2,46),out)
    }
    :unset
    .hfree $gettok($sockname,2,46)
    .sockclose $sockname
  }
  if (</tbody> isin %read) {
    $hget($gettok($sockname,2,46),out) Hiscores does not contain an entry for rank $format_number($hget($gettok($sockname,2,46),rank)) $hget($gettok($sockname,2,46),skill) $+ .
    .hfree $gettok($sockname,2,46)
    .sockclose $sockname
    unset %*
    halt
  }
}
