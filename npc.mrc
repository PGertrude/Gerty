on $*:TEXT:/^[!@.](npc|monster|mdb) */Si:#: {
if (%gerty == disabled) { .notice $nick This command has been Disabled temporarily. Speak to an admin to have it enabled. | halt }
var %class7 = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
if ($2 && *@* !iswm $2-) {
hadd -m $+(g,%class7) npc $replace($2-,$chr(32),+)
if (!$readini(chan.ini,$chan,public)) { hadd -m $+(g,%class7) out $iif($left($1,1) == @,.msg $chan,.notice $nick) }
if ($readini(chan.ini,$chan,public) == on) { hadd -m $+(g,%class7) out $iif($left($1,1) == @,.msg $chan,.notice $nick) }
if ($readini(chan.ini,$chan,public) == off) { hadd -m $+(g,%class7) out .notice $nick }
if ($readini(chan.ini,$chan,public) == voice) { hadd -m $+(g,%class7) out $iif($nick isvoice $chan || $nick ishop $chan || $nick isop $chan,$iif($left($1,1) == @,.msg $chan,.notice $nick),.notice $nick) }
if ($readini(chan.ini,$chan,public) == half) { hadd -m $+(g,%class7) out $iif($nick ishop $chan || $nick isop $chan,$iif($left($1,1) == @,.msg $chan,.notice $nick),.notice $nick) }
if ($2- == kree'arra) { hadd -m $+(g,%class7) id 996 | .sockopen $+(npc2.,$+(g,%class7)) www.tip.it 80 }
sockopen $+(npc.,$+(g,%class7)) www.tip.it 80
}
if ($2 && *@* iswm $2-) {
hadd -m $+(g,%class7) npc $remplus($gettok($replace($2-,$chr(32),+),1,64))
if (!$readini(chan.ini,$chan,public)) { hadd -m $+(g,%class7) out $iif($left($1,1) == @,.msg $chan,.notice $nick) }
if ($readini(chan.ini,$chan,public) == on) { hadd -m $+(g,%class7) out $iif($left($1,1) == @,.msg $chan,.notice $nick) }
if ($readini(chan.ini,$chan,public) == off) { hadd -m $+(g,%class7) out .notice $nick }
if ($readini(chan.ini,$chan,public) == voice) { hadd -m $+(g,%class7) out $iif($nick isvoice $chan || $nick ishop $chan || $nick isop $chan,$iif($left($1,1) == @,.msg $chan,.notice $nick),.notice $nick) }
if ($readini(chan.ini,$chan,public) == half) { hadd -m $+(g,%class7) out $iif($nick ishop $chan || $nick isop $chan,$iif($left($1,1) == @,.msg $chan,.notice $nick),.notice $nick) }
sockopen $+(npc3.,$+(g,%class7)) www.tip.it 80
}
}
on $*:TEXT:/^[!@.](npc|monster|mdb) */Si:?: {
if (%gerty == disabled) { .notice $nick This command has been Disabled temporarily. Speak to an admin to have it enabled. | halt }
var %class7 = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
if ($2 && *@* !iswm $2-) {
hadd -m $+(g,%class7) npc $replace($2-,$chr(32),+)
hadd -m $+(g,%class7) out .msg $nick
if ($2- == kree'arra) { hadd -m $+(g,%class7) id 996 | .sockopen $+(npc2.,$+(g,%class7)) www.tip.it 80 }
sockopen $+(npc.,$+(g,%class7)) www.tip.it 80
}
if ($2 && *@* iswm $2-) {
hadd -m $+(g,%class7) npc $remplus($gettok($replace($2-,$chr(32),+),1,64))
hadd -m $+(g,%class7) out .msg $nick
sockopen $+(npc3.,$+(g,%class7)) www.tip.it 80
}
}
on *:sockopen:npc.*: {
.sockwrite -n $sockname Get /runescape/index.php?rs2monster=&orderby=0&levels=All&race=0&keywords= $+ $hget($gettok($sockname,2,46),npc) HTTP/1.1
.sockwrite -n $sockname host: www.tip.it $+ $crlf $+ $crlf
}
on *:sockread:npc.*: {
if ($sockerr) {
$hget($gettok($sockname,2,46),out) There was a socket error.
halt
}
.sockread %npc
if (*> $+ $replace($hget($gettok($sockname,2,46),npc),+,$chr(32)) $+ </a* iswm %npc) { hadd -m $gettok($sockname,2,46) id $gettok($gettok(%npc,2,34),2,61) | .sockopen $+(npc2.,$gettok($sockname,2,46)) www.tip.it 80 | hadd -m $gettok($sockname,2,46) nout yes | goto skip }
if (!$hget($gettok($sockname,2,46),nout)) {
if (*rs2monster_id* iswm %npc && $numtok($hget($gettok($sockname,2,46),monsterlist),59) < 20) {
hadd -m $gettok($sockname,2,46) monsterlist $hget($gettok($sockname,2,46),monsterlist) $+ ; $nohtml(%npc)
hadd -m $gettok($sockname,2,46) match yes
}
}
:skip
}
on *:sockclose:npc.*: {
if (!$hget($gettok($sockname,2,46),id) && !$hget($gettok($sockname,2,46),match)) {
$hget($gettok($sockname,2,46),out) 12www.tip.it doesn't have any record for " $+ $replace($hget($gettok($sockname,2,46),npc),+,$chr(32)) $+ ".
}
if (!$hget($gettok($sockname,2,46),nout) && $hget($gettok($sockname,2,46),match)) {
$hget($gettok($sockname,2,46),out) More than 1 match found07 $+ $replace($hget($gettok($sockname,2,46),monsterlist),;,$+(,;,07)) 12[Tip.it]
}
unset %out
unset %npc
}
on *:sockopen:npc2.*: {
.sockwrite -n $sockname Get /runescape/index.php?rs2monster_id= $+ $hget($gettok($sockname,2,46),id) HTTP/1.1
.sockwrite -n $sockname host: www.tip.it $+ $crlf $+ $crlf
}
on *:sockread:npc2.*: {
if ($sockerr) {
$hget($gettok($sockname,2,46),out) There was a socket error.
halt
}
.sockread %npc2
if (*>aggressive* iswm %npc2) { hadd -m $gettok($sockname,2,46) aggressive $nohtml($gettok(%npc2,2,63)) }
if (*>retreats* iswm %npc2) { hadd -m $gettok($sockname,2,46) retreat $nohtml($gettok(%npc2,2,63)) }
if (*<b>Quest* iswm %npc2) { hadd -m $gettok($sockname,2,46) quest $nohtml($gettok(%npc2,2,63)) }
if (*>members* iswm %npc2) { hadd -m $gettok($sockname,2,46) members $nohtml($gettok(%npc2,2,63)) }
if (*>pois* iswm %npc2) { hadd -m $gettok($sockname,2,46) poison $nohtml($gettok(%npc2,2,63)) }
if (*><ul><a href="?page=* iswm %npc2) { hadd -m $gettok($sockname,2,46) habitat $nohtml(%npc2) }
if (*width="20* iswm %npc2 && $hget($gettok($sockname,2,46),b) && !$hget($gettok($sockname,2,46),a)) { hadd -m $gettok($sockname,2,46) a %npc2 }
if (*width="20* iswm %npc2 && $hget($gettok($sockname,2,46),c) && !$hget($gettok($sockname,2,46),b)) { hadd -m $gettok($sockname,2,46) b %npc2 }
if (*width="20* iswm %npc2 && $hget($gettok($sockname,2,46),d) && !$hget($gettok($sockname,2,46),c)) { hadd -m $gettok($sockname,2,46) c %npc2 }
if (*width="20* iswm %npc2 && $hget($gettok($sockname,2,46),e) && !$hget($gettok($sockname,2,46),d)) { hadd -m $gettok($sockname,2,46) d %npc2 }
if (*width="20* iswm %npc2 && $hget($gettok($sockname,2,46),f) && !$hget($gettok($sockname,2,46),e)) { hadd -m $gettok($sockname,2,46) e %npc2 }
if (*width="20* iswm %npc2 && $hget($gettok($sockname,2,46),g) && !$hget($gettok($sockname,2,46),f)) { hadd -m $gettok($sockname,2,46) f %npc2 }
if (*width="20* iswm %npc2 && $hget($gettok($sockname,2,46),h) && !$hget($gettok($sockname,2,46),g)) { hadd -m $gettok($sockname,2,46) g %npc2 }
if (*width="20* iswm %npc2 && $hget($gettok($sockname,2,46),i) && !$hget($gettok($sockname,2,46),h)) { hadd -m $gettok($sockname,2,46) h $remove($nohtml(%npc2),$chr(9)) }
if (*width="20* iswm %npc2 && !$hget($gettok($sockname,2,46),i)) { hadd -m $gettok($sockname,2,46) i %npc2 }
}
on *:sockclose:npc2.*: {
if ($hget($gettok($sockname,2,46),habitat)) {
var %hab =  $+ $chr(124) Habitat:07 $nohtml($hget($gettok($sockname,2,46),habitat))
}
$hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),h) $+  Level:07 $nohtml($hget($gettok($sockname,2,46),d))  $+ $chr(124) Hitpoints:07 $nohtml($hget($gettok($sockname,2,46),b))  $+ $chr(124) Race:07 $nohtml($hget($gettok($sockname,2,46),f))  $+ $chr(124) 12HTTP://www.tip.it/runescape/index.php?rs2monster_id= $+ $hget($gettok($sockname,2,46),id)
$hget($gettok($sockname,2,46),out) Aggressive?07 $yescol($hget($gettok($sockname,2,46),aggressive))  $+ $chr(124) Retreat?07 $yescol($hget($gettok($sockname,2,46),retreat))  $+ $chr(124) Quest?07 $yescol($hget($gettok($sockname,2,46),quest))  $+ $chr(124) Members?07 $yescol($hget($gettok($sockname,2,46),members))  $+ $chr(124) Poisonous?07 $yescol($hget($gettok($sockname,2,46),poison)) %hab 12[Tip.it]
unset %npc*
}
on *:sockopen:npc3.*: {
.sockwrite -n $sockname Get /runescape/index.php?rs2monster=&orderby=0&levels=All&race=0&keywords= $+ $hget($gettok($sockname,2,46),npc) HTTP/1.1
.sockwrite -n $sockname host: www.tip.it $+ $crlf $+ $crlf
}
on *:sockread:npc3.*: {
if ($sockerr) {
$hget($gettok($sockname,2,46),out) There was a socket error.
halt
}
.sockread %npc
if (*rs2monster_id* iswm %npc) {
if ($numtok($hget($gettok($sockname,2,46),monsterlist),59) < 10) {
hadd -m $gettok($sockname,2,46) monsterlist $hget($gettok($sockname,2,46),monsterlist) $+ ; $nohtml(%npc)
}
}
:skip
}
on *:sockclose:npc3.*: {
if (!$hget($gettok($sockname,2,46),monsterlist)) {
$hget($gettok($sockname,2,46),out) 12www.tip.it doesn't have any record for " $+ $replace($hget($gettok($sockname,2,46),npc),+,$chr(32)) $+ ".
}
if ($hget($gettok($sockname,2,46),monsterlist)) {
$hget($gettok($sockname,2,46),out) More than 1 match found07 $+ $replace($hget($gettok($sockname,2,46),monsterlist),;,$+(,;,07)) 12[Tip.it]
}
unset %npc
}
alias remplus {
if ($right($gettok($1-,1,32),1) == +) { return $left($gettok($1-,1,32),-1) }
if ($right($gettok($1-,1,32),1) != +) { return $1- }
}
alias yescol {
if ($1 == No) { return $+(04,No,) }
if ($1 == Yes) { return $+(03,Yes,) }
}
:END
