>start<|elly.mrc|elly still here...|3.0|rs
alias listchans {
  var %out = Chans:07 $chan(0) Nicks:07 $bot(users) Uptime:07 $swaptime($uptime(server,1)) Chan list: $bot(chanlist)
  if ($isid) {
    return %out
  }
  else {
    if ($chan) { msg $chan %out }
    else { msg $nick %out }
  }
}
alias botstats {
  var %x = 1,%lines = 0,%names,%size = 0,%long = 0,%big,%cur
  while ($script(%x)) {
    %cur = $v1
    inc %lines $lines(%cur)
    if ($lines(%cur) > $lines(%long)) %long = %cur
    inc %size $file(%cur).size
    if (!$exists(%big)) || ($file(%cur).size > $file(%big).size) %big = %cur
    %names = %names $nopath(%cur)
    inc %x
  }
  $iif(m isin $1,msg $active,echo -a) I have $+($chr(2),$script(0),$chr(2)) remote script files loaded $+ $iif(n isin $1,$+($chr(32),$chr(40),$chr(2),%names,$chr(2),$chr(41))) $+ , for a total of $+($chr(2),%lines,$chr(2)) lines and $+($chr(2),$round($calc(%size / 1024),2),$chr(2)) $+ KB.
  $iif(t isin $1,$iif(m isin $1,msg $active,echo -a),return) Longest file: $+($chr(2),$nopath(%long),$chr(2)) at $+($chr(2),$lines(%long),$chr(2)) lines. Largest file: $+($chr(2),$nopath(%big),$chr(2)) at $+($chr(2),$round($calc($file(%big).size / 1024),2),$chr(2)) $+ KB.
}
on $*:text:/^(Gerty? )?[!.@]m(ember)?l(ist)?/Si:*:{
  _CheckMain
  var %chan on
  if ($chan) %chan = $chanset($chan,ml)
  if ($iif($regex($1,/^Gerty?/Si),$3,$2) && %chan != off) {
    var %ticks $ticks
    sockopen ml.a $+ %ticks www6.runehead.com 80
    hadd -m a $+ %ticks out $saystyle($left($iif($regex($1,/^Gerty?/Si),$2,$1),1),$nick,$chan)
    hadd -m a $+ %ticks ml $caps($regsubex($iif($regex($1,/^Gerty?/Si),$3-,$2-),/(\W)/g,_))
  }
}
on $*:text:/^(Gerty?\x20)?[!.@](mag(e|ic))?spell? /Si:*:{
  _CheckMain
  if ($iif($regex($1,/^Gerty?/Si),$3,$2)) { spell $remove($iif($regex($1,/^Gerty?/Si),$3-,$2-),$chr(44),$chr(36)) $+ $chr(44) $+ $saystyle($left($iif($regex($1,/^Gerty?/Si),$2,$1),1),$nick,$chan) }
}
alias spell {
  if ($litecalc($1)) { var %num $litecalc($1) | var %spell $gettok($2-,1,44) }
  else { var %num 1 | var %spell $gettok($1-,1,44) }
  if ($chr(34) isin %spell) { var %spell $remove(%spell,$chr(34)) | var %exact yes }
  var %saystyle $gettok($1-,2,44)
  .fopen spells magic.txt
  var %x 1
  while (!$feof && %x <= 4) {
    var %spel = $fread(spells)
    if ($iif(%exact,$+(%spell,$chr(9),*),$+(*,%spell,*)) iswm %spel) {
      var %spellname $gettok(%spel,1,9)
      var %spellexp $calc(%num * $gettok(%spel,2,9))
      var %spelllvl $gettok(%spel,3,9)
      var %spellrunes $regsubex($gettok(%spel,4,9),/(\d+) (\w+)/ig,$calc(%num * \1) \2)
      var %spellprice $calc($replace($regsubex(%spellrunes,/(\d+) (\w+)/Sig,$calc( $+(\1,$chr(42),$hget(runeprice,\2 $+ _Rune)) )),$chr(32),$chr(43),$chr(44),$chr(32)))
      var %spellmax $gettok(%spel,5,9)
      var %spellbook $gettok(%spel,6,9)
      var %spellother $gettok(%spel,7,9)
      %saystyle Magic Params07 %spellname $+(,$iif(%num > 1,$+($chr(40),x,07,%num,,$chr(41),$chr(32))),$chr(124)) Exp:07 $bytes(%spellexp,bd)  $+ $chr(124) Level:07 %spelllvl  $+ $chr(124) Runes:07 $regsubex(%spellrunes,/(\d+) (\w+)(\x2c)?/ig,$bytes(\1,bd) \2 $+ $iif(\3,$+(,\3,07)))  $+ $chr(124) Price:07 $bytes(%spellprice,bd) $+ gp $chr(124) Max hit:07 %spellmax  $+ $chr(124) Spellbook:07 %spellbook  $+ $chr(124) Other info:07 %spellother $+ .
      hadd -m spelluse $replace(%spellname,$chr(32),$chr(95)) $calc($hget(spelluse,$replace(%spellname,$chr(32),$chr(95))) + 1)
      inc %x
    }
  }
  if (%x == 1) { %saystyle 07 $+ $iif(%exact,Exact match $+(07,",%spell,"),%spell) $+  spell not found. }
  .fclose *
}
alias runepriceupdater {
  sockopen runeprice.rune1 itemdb-rs.runescape.com 80
  sockopen runeprice.rune2 itemdb-rs.runescape.com 80
  if ($hget(potprice)) { hfree potprice }
}

;##POTION##
on $*:text:/^(Gerty?\x20)?[!.@]oldpot(ion)?s? ./Si:*:{
  _CheckMain
  if ($calculate($iif($regex($1,/^Gerty?/Si),$3,$2)) isnum) { var %num $calculate($iif($regex($1,/^Gerty?/Si),$3,$2)) | var %potion $iif($regex($1,/^Gerty?/Si),$4-,$3-) }
  elseif ($calculate($iif($regex($1,/^Gerty?/Si),$3,$2)) !isnum) { var %num 1 | var %potion $iif($regex($1,/^Gerty?/Si),$3-,$2-) }
  var %ticks $ticks
  .fopen potion $+ %ticks potion.txt
  var %x 1
  while (!$feof && %x <= 2) {
    var %pot = $fread(potion $+ %ticks)
    if ($+(*,%potion,*) iswm $gettok(%pot,4,9)) {
      if (!$hget(potprice,p $+ $gettok(%pot,5,9))) {
        hadd -m $+(a,%ticks,.,$gettok(%pot,5,9)) out $saystyle($left($iif($regex($1,/^Gerty?/Si),$2,$1),1),$nick,$chan) $+ $chr(44) $+ %num $+ $chr(44) $+ $replace(%pot,$chr(9),$chr(44))
        sockopen $+(potion.a,%ticks,.,$gettok(%pot,5,9)) itemdb-rs.runescape.com 80
      }
      var %y 1
      while ($gettok($gettok(%pot,7,9),%y,43) && %y <= 5) {
        if (!$hget(potprice,p $+ $gettok($gettok(%pot,7,9),%y,43))) {
          hadd -m $+(a,%ticks,.,$gettok($gettok(%pot,7,9),%y,43)) out $saystyle($left($iif($regex($1,/^Gerty?/Si),$2,$1),1),$nick,$chan) $+ $chr(44) $+ %num $+ $chr(44) $+ $replace(%pot,$chr(9),$chr(44))
          sockopen $+(potion.a,%ticks,.,$gettok($gettok(%pot,7,9),%y,43)) itemdb-rs.runescape.com 80
        }
        inc %y
      }
      potsay $saystyle($left($iif($regex($1,/^Gerty?/Si),$2,$1),1),$nick,$chan) $+ $chr(44) $+ %num $+ $chr(44) $+ $replace(%pot,$chr(9),$chr(44))
      inc %x
    }
  }
  if %x = 1 $saystyle($left($iif($regex($1,/^Gerty?/Si),$2,$1),1),$nick,$chan) 07 $+ %potion potion not found.
  .fclose *
}


alias potsay {
  tokenize 44 $1-
  var %a %a $iif($hget(potprice,p $+ $7),y,n)
  var %b 1
  while ($gettok($9,%b,43) && %b <= 5) {
    var %a %a $iif($hget(potprice,p $+ $gettok($9,%b,43)),y,n)
    inc %b
  }
  if (n !isin %a) {
    var %potprice $calc($2 * $hget(potprice,p $+ $7))
    var %ingprice $calc($2 * ($regsubex($9,/(\d+)/g,$hget(potprice,p $+ \1))))
    $1 Herblore param $+(07,$iif($2 > 1,$bytes($2,bd) $6,$6), $chr(40),07,$bytes(%potprice,bd),gp,,$chr(41)) $chr(124) Exp: $+(07,$bytes($calc($2 * $5),bd),) $chr(124) Lvl: $+(07,$4,) $chr(124) Ingredients: $+(07,$regsubex($8,/;/g,$+(,$chr(44) 07)) ,$chr(40),07,$bytes(%ingprice,bd),gp,$chr(41)) Costs:07 $bytes($calc(%ingprice - %potprice),bd) $+(,$chr(40),07,$bytes($round($calc((%ingprice - %potprice) / ($2 * $5)),1),bd),gp/exp,$chr(41)) $chr(124) Other info: $+(07,$10-,.)
  }
}
on $*:text:/^(Gerty?\x20)?[!.@]newle?ve?l/Si:*:{
  _CheckMain
  var %saystyle $saystyle($left($iif($regex($1,/^Gerty?/Si),$2,$1),1),$nick,$chan)
  if ($calculate($iif($regex($1,/^Gerty?/Si),$3,$2)) isnum) { var %num $calculate($iif($regex($1,/^Gerty?/Si),$3,$2)) | var %skill $iif($regex($1,/^Gerty?/Si),$4,$3) }
  elseif ($calculate($iif($regex($1,/^Gerty?/Si),$3,$2)) !isnum) { var %num $iif($regex($1,/^Gerty?/Si),$4,$3) | var %skill $iif($regex($1,/^Gerty?/Si),$3,$2) }
  if (!$regex($1-,/\d/) || !%skill || !%num || %num > 99 || %num < 1) { %saystyle Syntax: !newlvl level skill | halt }
  var %skill $skills(%skill)
  var %ticks $ticks
  var %tok 3
  if (%skill = Slayer) { var %tok 4 }
  .fopen newlvl $+ %ticks %skill $+ .txt
  var %x 1
  while (!$feof && %x <= 8) {
    var %lvl = $fread(newlvl $+ %ticks)
    var %level $gettok(%lvl,%tok,124)
    if (%num = $regsubex(%level,/(?:\w+ )?(\d+)/Si,\1)) {
      var %newlvl %newlvl $iif(%newlvl,$chr(124)) 07 $+ $gettok(%lvl,1,124) $+(,$chr(40),07,$bytes($gettok(%lvl,2,124),bd),exp,$chr(41))
      inc %x
    }
  }
  .fclose *
  if (!%newlvl) { %saystyle No new objects available at level07 %num %skill $+ . | halt }
  %saystyle New objects available at level07 %num %skill $+ : %newlvl
}
alias draynor {
  if ($read(draynor.txt,w,$1)) sockopen draynor. $+ $1 www.draynor.net 80
}
alias EscapeURL return $regsubex($1-,/([\[\]@\+\x20<>&~#$%\^|=?}{\\/:`.])/g,$+(%,$base($asc(\1),10,16)))
alias pastebin {
  hadd -m $2- out $1
  sockopen pastebin. $+ $2- pastebin.com 80
}
