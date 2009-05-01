on *:TEXT:*:#: {
if (!$regex($1,/^[!@.](world|w|player)s*$/Si)) { halt }
var %class = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
if (!$readini(chan.ini,$chan,public)) { hadd -m $+(a,%class) out $iif($left($1,1) == @,.msg $chan,.notice $nick) }
if ($readini(chan.ini,$chan,public) == on) { hadd -m $+(a,%class) out $iif($left($1,1) == @,.msg $chan,.notice $nick) }
if ($readini(chan.ini,$chan,public) == off) { hadd -m $+(a,%class) out .notice $nick }
if ($readini(chan.ini,$chan,public) == voice) { hadd -m $+(a,%class) out $iif($nick isvoice $chan || $nick ishop $chan || $nick isop $chan,$iif($left($1,1) == @,.msg $chan,.notice $nick),.notice $nick) }
if ($readini(chan.ini,$chan,public) == half) { hadd -m $+(a,%class) out $iif($nick ishop $chan || $nick isop $chan,$iif($left($1,1) == @,.msg $chan,.notice $nick),.notice $nick) }
if ($2 !isnum && $2) { $hget($+(a,%class),out) Invalid World selection | halt }
if ($regex($2,/(122|139|140|146|147)/gi)) {
hadd -m $+(a,%class) lang /l=1
if ($2 isnum) { hadd -m $+(a,%class) world welt $2 }
}
if (!$regex($2,/(122|139|140|146|147)/gi)) {
if ($2 isnum) { hadd -m $+(a,%class) world world $2 }
}
if ($2) { sockopen $+(world.a,%class) www.runescape.com 80 }
if (!$2) { sockopen $+(world2.a,%class) www.runescape.com 80 }
}
on *:sockopen:world.*:{
sockwrite -n $sockname GET $hget($gettok($sockname,2,46),lang) $+ /slu.ws?lores.x=0&plugin=0&order=WMLPA
sockwrite -n $sockname Host: www.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:world.*: {
var %bleh = $gettok($sockname,2,46)
if ($sockerr) {
$hget($gettok($sockname,2,46),out) [Socket Error] $sockname $time $script
halt
}
else {
while ($sock($sockname).rq) {
sockread &world
bwrite %bleh -1 -1 &world
}
bread %bleh 0 $file(%bleh).size &world2
if ($bfind(&world2,0,</HTML>)) {
if ($gettok($hget($gettok($sockname,2,46),world),1,32) == world) {
var %start = $bfind(&world2,0,&nbsp;Type)
}
if ($gettok($hget($gettok($sockname,2,46),world),1,32) == welt) {
var %start = $bfind(&world2,0,&nbsp;art)
}
var %a = $calc($bfind(&world2,%start,$hget($gettok($sockname,2,46),world)) +4), %b = $calc($bfind(&world2,%a,<td>)+4), %c = $bfind(&world2,%b,</td>)
var %d = $calc($bfind(&world2,%c,class=") +7), %e = $bfind(&world2,%d,")
var %f = $calc($bfind(&world2,%e,<t) +4), %g = $bfind(&world2,%f,<)
var %h = $regsubex($remove($bvar(&world2,$calc(%g +5),600).text,$chr(10),$chr(13)),/^<[^>]+><[^>]+title="(\w)"><[^>]+>\n*\r*<[^>]+><[^>]+title="(\w)"><[^>]+>\n*\r*<[^>]+><[^>]+title="(\w)"><[^>]+><[^>]+>(\w+)<[^>]+>(.+?)$/,\1 \2 \3 \4)
.tokenize 32 %h
if (%a != 4) { $hget($gettok($sockname,2,46),out) World07 $gettok($hget($gettok($sockname,2,46),world),2,32) (07 $+ $remove($bvar(&world2,%d,$calc(%e - %d)).text,$crlf) $+ ) | Players:07 $remove($gettok($bvar(&world2,%b,$calc(%c - %b)).text,1,32),$crlf) | Type:07 $4 | Activity:07 $regsubex($remove($bvar(&world2,%f,$calc(%g - %f)).text,$crlf),/^([^>]>)*(.+?)$/,$iif(\2,\2,\1)) $iif($1 == N,04,03) Lootshare $iif($2 == N,04,03) Quickchat $iif($3 == N,04,03) PVP }
if (%a == 4) { $hget($gettok($sockname,2,46),out) World07 $gettok($hget($gettok($sockname,2,46),world),2,32) Not Found. }
.remove %bleh
sockclose $sockname
}
}
}
on *:sockopen:world2.*:{
sockwrite -n $sockname GET /title.ws
sockwrite -n $sockname Host: www.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:world2.*: {
var %bleh = $gettok($sockname,2,46)
if ($sockerr) {
$hget($gettok($sockname,2,46),out) [Socket Error] $sockname $time $script
halt
}
else {
while ($sock($sockname).rq) {
sockread &world
bwrite %bleh -1 -1 &world
}
bread %bleh 0 $file(%bleh).size &world2
if ($bfind(&world2,0,</HTML>)) {
var %a = $calc($bfind(&world2,0,There are currently)+20), %b = $calc($bfind(&world2,%a,playing)-8)
$hget($gettok($sockname,2,46),out) There are currently 07 $+ $bytes($bvar(&world2,%a,$calc(%b - %a)).text,db) People Playing across 169 servers. Runescape at07 $round($calc(100* $bvar(&world2,%a,$calc(%b - %a)).text / 338000),2) $+ 07% Capacity.
.remove %bleh
sockclose $sockname
}
}
}
:END
