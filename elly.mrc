>start<|elly.mrc|elly still here...|3.0|rs
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
