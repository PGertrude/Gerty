on *:TEXT:*:#: {
if (!$regex($1,/^[!@.](g(reat|rand)?e(xchange)?|price)$/Si)) { halt }
var %class = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
hadd -m $+(a,%class) out $saystyle($left($1,1),$nick,$chan)
if ($calculate($2)) {
hadd -m $+(a,%class) amount $calculate($2)
hadd -m $+(a,%class) search " $+ $replace($3-,$chr(32),+) $+ "
}
else {
hadd -m $+(a,%class) search " $+ $replace($2-,$chr(32),+) $+ "
}
sockopen $+(gelink.a,%class) itemdb-rs.runescape.com 80
}
on *:sockopen:gelink.*:{
sockwrite -n $sockname GET /results.ws?query= $+ $hget($gettok($sockname,2,46),search) $+ &price=all&members= HTTP/1.1
sockwrite -n $sockname Host: itemdb-rs.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:gelink.*: {
var %bleh = $gettok($sockname,2,46)
if ($sockerr) {
$hget($gettok($sockname,2,46),out) [Socket Error] $sockname $time $script
halt
}
else {
while ($sock($sockname).rq) {
sockread &gelink
bwrite %bleh -1 -1 &gelink
}
bread %bleh 0 $file(%bleh).size &gelink2
if ($bfind(&gelink2,0,</HTML>)) {
var %amount = $hget($gettok($sockname,2,46),amount)
var %number = $calc($bfind(&gelink2,0,results_text">)+15), %end = $bfind(&gelink2,%number,item)
var %start = $bfind(&gelink2,0,Change Today (gp)</td>), %limit = 8
while ($bfind(&gelink2,%start,ws?obj) && %limit) {
var %a = $bfind(&gelink2,%start,ws?obj), %b = $calc($bfind(&gelink2,%a,>)+2), %c = $bfind(&gelink2,%b,<)
var %d = $calc($bfind(&gelink2,%c,<td>)+4), %e = $bfind(&gelink2,%d,<)
var %f = $calc($bfind(&gelink2,%e,">)+2), %g = $bfind(&gelink2,%f,<)
var %h = $calc($bfind(&gelink2,%g,img src=")+10), %i = $bfind(&gelink2,%h,/serverlist/), %k = $bfind(&gelink2,%i,.png)
var %j = $iif(*member* iswm $bvar(&gelink2,%i,$calc(%k - %i)).text,$+($chr(32),,$chr(40),07M,$chr(41)))
var %price = $calculate($bvar(&gelink2,%d,$calc(%e - %d)).text)
var %z = $iif($len(%z) > 5,%z) | $+ %j $bvar(&gelink2,%b,$calc(%c - %b)).text $+ :07 $iif(%amount,$format_number($calc(%amount * %price)),$format_number(%price)) $+  $updo($bvar(&gelink2,%f,$calc(%g - %f)).text)
var %start = %c
dec %limit 1
}
if (*your search* iswm $bvar(&gelink2,%number,$calc(%end - %number)).text) {
var %z = No match found for $replace($hget($gettok($sockname,2,46),search),+,$chr(32))
}
if (*your search* !iswm $bvar(&gelink2,%number,$calc(%end - %number)).text) {
var %out = $bvar(&gelink2,%number,$calc(%end - %number)).text
}
$hget($gettok($sockname,2,46),out) Results: $+ $iif(%amount, $+($chr(32),(Price x $+ $format_number(%amount) $+ ))) $+ 07 %out %z
.remove %bleh
.hfree $gettok($sockname,2,46)
unset %*
sockclose $sockname
}
}
}
alias updo {
var %price = $calculate($1)
if (%price > 0) { return 03[ $+ $trim($1) $+ 03] }
if (%price < 0) { return 04[ $+ $trim($1) $+ 04] }
}
on *:TEXT:*:?: {
if (!$regex($1,/^[!@.](g(reat|rand)?e(xchange)?|price)$/Si)) { halt }
var %class = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
hadd -m $+(a,%class) out .msg $nick
if ($calculate($2)) {
hadd -m $+(a,%class) amount $calculate($2)
hadd -m $+(a,%class) search " $+ $replace($3-,$chr(32),+) $+ "
}
else {
hadd -m $+(a,%class) search " $+ $replace($2-,$chr(32),+) $+ "
}
sockopen $+(gelink.a,%class) itemdb-rs.runescape.com 80
}
:END
