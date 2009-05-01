on $*:TEXT:/^[!@.](table|top) */Si:*: {
var %thread = $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
hadd -m %thread out $saystyle($left($1,1),$nick,$chan)
if (!$2) { hadd -m %thread skill overall }
if ($2 && $scores($2) == nomatch) { hadd -m %thread skill overall }
if ($scores($2) != nomatch) {
if ($left($3,1) == $chr(35) || $litecalc($3) isnum) { hadd -m %thread rank $litecalc($remove($3,$chr(35))) }
else { hadd -m %thread nick $rsn($regsubex($3-,/\W/g,_)) }
hadd -m %thread skill $scores($2)
}
sockopen $+(top.,%thread) hiscore.runescape.com 80
}
on *:sockopen:top.*: {
sockwrite -n $sockname GET /overall.ws?category_type= $+ $catno($hget($gettok($sockname,2,46),skill)) $+ &table= $+ $smartno($hget($gettok($sockname,2,46),skill)) $+ &user= $+ $hget($gettok($sockname,2,46),nick) $+ &rank= $+ $hget($gettok($sockname,2,46),rank)
sockwrite -n $sockname Host: hiscore.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:top.*: {
var %thread = $gettok($sockname,2,46)
if (!%row) { %row = 1 }
if ($sockerr) {
write ErrorLog.txt $timestamp SocketError[sockread]: $nopath($script) $socket $([,) $+ $hget(%thread,out) $hget(%thread,nick) $+ $(],)
echo -at Socket Error: $nopath($script)
$hget(%thread,out) Connection Error: Please try again in a few moments.
hfree %thread
sockclose $sockname
halt
}
.sockread %top
if (%row < 350) {
if ($nohtml(%top)) {
set % [ $+ [ $calc(%row) ] ] $replace($nohtml(%top),$chr(32),_)
inc %row 1
}
}
if (</html> isin %top) { topout }
}
alias topout {
var %thread = $gettok($sockname,2,46)
if ($minigames($hget(%thread,skill)) == nomatch) {
var %out = $hget(%thread,out)  $+ $hget(%thread,skill) $+  Ranks
if ($hget(%thread,nick)) { var %y = 117 }
else { var %y = 118 }
%out = %out 07# $+ $(% $+ %y,2) $+  $(% $+ $calc(%y + 1),2) $+(07,$(% $+ $calc(%y + 2),2)) ( $+ $(% $+ $calc(%y + 3),2) $+ )
inc %y 4
var %x = 1
while (%x <= 9) {
var %true = $iif($(% $+ $calc(%y + 1),2) == $hget(%thread,nick) || $(% $+ %y,2) == $hget(%thread,rank),$true,$false)
%out = %out $iif(%true,) $+ 07# $+ $(% $+ %y,2) $+  $(% $+ $calc(%y + 1),2) $+(07,$(% $+ $calc(%y + 2),2)) ( $+ $(% $+ $calc(%y + 3),2) $+ ) $+ $iif(%true,)
inc %y 4
inc %x
}
%out
}
else {
var %out = $hget(%thread,out)  $+ $hget(%thread,skill) $+  Ranks
if ($hget(%thread,nick)) { var %y = 98 }
else { var %y = 96 }
%out = %out 07# $+ $(% $+ %y,2) $+  $(% $+ $calc(%y + 1),2) ( $+ $(% $+ $calc(%y + 2),2) $+ )
inc %y 3
var %x = 1
while (%x <= 9) {
var %true = $iif($(% $+ $calc(%y + 1),2) == $hget(%thread,nick) || $(% $+ %y,2) == $hget(%thread,rank),$true,$false)
%out = %out $iif(%true,) $+ 07# $+ $(% $+ %y,2) $+  $(% $+ $calc(%y + 1),2) ( $+ $(% $+ $calc(%y + 2),2) $+ ) $+ $iif(%true,)
inc %y 3
inc %x
}
%out
}
unset %*
hfree %thread
}
