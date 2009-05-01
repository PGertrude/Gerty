on $*:TEXT:/^[!@.](item|alch|alk) */Si:#: {
var %class = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
hadd -m $+(a,%class) out $saystyle($left($1,1),$nick,$chan)
if (!$2) { $hget($+(a,%class),out) Syntax: !item <item> | halt }
if ($left($2,1) != $chr(35) && $calculate($2) !isnum) {
hadd -m $+(a,%class) search $replace($2-,$chr(32),+)
sockopen $+(zybez.a,%class) www.zybez.net 80
}
if ($left($2,1) == $chr(35) || $calculate($2) isnum) {
hadd -m $+(a,%class) id $calculate($remove($2,$chr(35)))
sockopen $+(zybez2.a,%class) www.zybez.net 80
}
}
on *:sockopen:zybez.*: {
.sockwrite -n $sockname GET /items.php?search_area=name&search_term= $+ $hget($gettok($sockname,2,46),search) HTTP/1.0
.sockwrite -n $sockname Host: www.zybez.net $+ $crlf $+ $crlf
}
on *:sockread:zybez.*: {
var %bleh = $gettok($sockname,2,46)
if ($sockerr) {
$hget($gettok($sockname,2,46),out) [Socket Error] $sockname $time $script
halt
}
else {
while ($sock($sockname).rq) {
sockread &item
bwrite %bleh -1 -1 &item
}
bread %bleh 0 $file(%bleh).size &item2
if ($bfind(&item2,0,</HTML>)) {
if ($bfind(&item2,0,location:) < 1) {
var %start = $bfind(&item2,0,>Submit Missing Item<)
if (%start < 1) { goto unset }
while ($bfind(&item2,%start,items.php?id=)) {
var %a = $calc($bfind(&item2,%start,items.php?id=)+13), %b = $bfind(&item2,%a,&amp;), %c = $calc($bfind(&item2,$calc(%b + 50),htm">)+5), %d = $bfind(&item2,%c,<)
var %e = %e | $bvar(&item2,%c,$calc(%d - %c)).text 07 $+ $chr(35) $+ $bvar(&item2,%a,$calc(%b - %a)).text
var %start = %d
}
var %e = $gettok(%e,1-8,124)
$hget($gettok($sockname,2,46),out) Matches found07 $count(%e,$chr(35)) %e
:unset
.remove %bleh
sockclose $sockname
halt
}
if ($bfind(&item2,0,location:) > 1) {
var %start = $calc($bfind(&item2,0,?id=)+4)
hadd -m $gettok($sockname,2,46) id $iif($bvar(&item2,%start,4).text isnum,$bvar(&item2,%start,4).text,$iif($bvar(&item2,%start,3).text isnum,$bvar(&item2,%start,3).text,$iif($bvar(&item2,%start,2).text isnum,$bvar(&item2,%start,2).text,$iif($bvar(&item2,%start,1).text isnum,$bvar(&item2,%start,1).text))))
sockopen $+(zybez2.,$gettok($sockname,2,46)) www.zybez.net 80
.remove %bleh
sockclose $sockname
}
}
}
}
on *:sockopen:zybez2.*: {
.sockwrite -n $sockname GET /items.php?id= $+ $hget($gettok($sockname,2,46),id) HTTP/1.0
.sockwrite -n $sockname Host: www.zybez.net $+ $crlf $+ $crlf
}
on *:sockread:zybez2.*: {
var %bleh = $gettok($sockname,2,46) $+ 2
if ($sockerr) {
$hget($gettok($sockname,2,46),out) [Socket Error] $sockname $time $script
halt
}
else {
while ($sock($sockname).rq) {
sockread &item3
bwrite %bleh -1 -1 &item3
}
bread %bleh 0 $file(%bleh).size &item4
if ($bfind(&item4,0,</HTML>)) {
var %start = $calc($bfind(&item4,0,"border-right:none">)+20), %a = $bfind(&item4,%start,<), %b = $calc($bfind(&item4,%a,members:)+17), %c = $bfind(&item4,%b,<), %d = $calc($bfind(&item4,%c,Tradable:)+18), %e = $bfind(&item4,%d,<)
if (%start < 21) { $hget($gettok($sockname,2,46),out) Item not found | goto unset }
var %f = $calc($bfind(&item4,%e,Equipable:)+19), %g = $bfind(&item4,%f,<), %h = $calc($bfind(&item4,%g,Stackable:)+19), %i = $bfind(&item4,%h,<), %j = $calc($bfind(&item4,%i,Weight:)+16), %k = $bfind(&item4,%j,<)
var %l = $calc($bfind(&item4,%k,Quest:)+15), %m = $bfind(&item4,$calc(%l +1),<), %n = $calc($bfind(&item4,%m,Examine:)+17), %o = $bfind(&item4,%n,<)
var %xx = $calc($bfind(&item4,%n,Price:)+15), %yy = $calc($bfind(&item4,%xx,>)+1), %zz = $bfind(&item4,%yy,<)
var %aa = $calc($bfind(&item4,%n,Price:)+12), %bb = $calc($bfind(&item4,%aa,>)+1), %cc = $bfind(&item4,%bb,<)
if ($bfind(&item4,%n,Price:) > 1) {
var %pp = $bfind(&item4,%n,Price:), %p = $bfind(&item4,%pp,<div), %q = $calc($bfind(&item4,%p,</div>)+6)
var %price = $nohtml($bvar(&item4,%p,$calc(%q - %p)).text)
}
if (!%price) { var %price = Not Applicable }
if ($yesno($bvar(&item4,%d,$calc(%e - %d)).text) == 03Yes) { var %price = Check Price Guide }
var %r = $calc($bfind(&item4,%n,alchemy:)+17), %s = $bfind(&item4,%r,<), %t = $calc($bfind(&item4,%s,alchemy:)+17), %u = $bfind(&item4,%t,<), %v = $calc($bfind(&item4,%n,from:)+14), %w = $bfind(&item4,%v,<)
var %halch = $iif( * $+ $chr(13) $+ * iswm $remove($bvar(&item4,%r,$calc(%s - %r)).text,gp),0,$remove($bvar(&item4,%r,$calc(%s - %r)).text,gp))
var %lalch = $iif( * $+ $chr(13) $+ * iswm $remove($bvar(&item4,%t,$calc(%u - %t)).text,gp),0,$remove($bvar(&item4,%t,$calc(%u - %t)).text,gp))
$hget($gettok($sockname,2,46),out)  $+ $bvar(&item4,%start,$calc(%a - %start)).text $+  Alch:07 %halch $+ / $+ %lalch gp | Market Price:07 $remove(%price,>) | Obtained From:07 $remove($bvar(&item4,%v,$calc(%w - %v)).text,>) | 12http://www.zybez.net/items.php?id= $+ $hget($gettok($sockname,2,46),id)
$hget($gettok($sockname,2,46),out) Members? $yesno($bvar(&item4,%b,$calc(%c - %b)).text) | Tradeable? $yesno($bvar(&item4,%d,$calc(%e - %d)).text) | Equipable: $yesno($bvar(&item4,%f,$calc(%g - %f)).text) | Stackable? $yesno($bvar(&item4,%h,$calc(%i - %h)).text) $&
| Weight:07 $regsubex($bvar(&item4,%j,$calc(%k - %j)).text,/^kg$/i,0Kg) | Quest?07 $yesno($nohtml($bvar(&item4,%l,$calc(%m - %l)).text)) | Examine:07 $nohtml($bvar(&item4,%n,$calc(%o - %n)).text)
:unset
.remove %bleh
sockclose $sockname
unset %*
halt
}
}
}
$+(item_,$hget($gettok($sockname,2,46),id),$chr(32),">)
alias yesno {
if $1 = yes return 03Yes
if $1 = no return 04No
else return $1
}
$remove($bvar(&item4,%r,$calc(%s - %r)).text,gp) $+ / $+ $remove($bvar(&item4,%t,$calc(%u - %t)).text,gp) gp
on $*:TEXT:/^[!@.]look */Si:#: {
var %class = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
if (!$readini(chan.ini,$chan,public)) { hadd -m $+(a,%class) out $iif($left($1,1) == @,.msg $chan,.notice $nick) }
if ($readini(chan.ini,$chan,public) == on) { hadd -m $+(a,%class) out $iif($left($1,1) == @,.msg $chan,.notice $nick) }
if ($readini(chan.ini,$chan,public) == off) { hadd -m $+(a,%class) out .notice $nick }
if ($readini(chan.ini,$chan,public) == voice) { hadd -m $+(a,%class) out $iif($nick isvoice $chan || $nick ishop $chan || $nick isop $chan,$iif($left($1,1) == @,.msg $chan,.notice $nick),.notice $nick) }
if ($readini(chan.ini,$chan,public) == half) { hadd -m $+(a,%class) out $iif($nick ishop $chan || $nick isop $chan,$iif($left($1,1) == @,.msg $chan,.notice $nick),.notice $nick) }
if (!$2) { $hget($+(a,%class),out) Syntax: !item <item> | halt }
if ($left($2,1) != $chr(35)) {
hadd -m $+(a,%class) search $replace($2-,$chr(32),+)
sockopen $+(zybez3.a,%class) www.zybez.net 80
}
}
on *:sockopen:zybez3.*: {
.sockwrite -n $sockname GET /items.php?search_area=name&search_term= $+ $hget($gettok($sockname,2,46),search) HTTP/1.0
.sockwrite -n $sockname Host: www.zybez.net $+ $crlf $+ $crlf
}
on *:sockread:zybez3.*: {
var %bleh = $gettok($sockname,2,46)
if (!%row) { set %row 1 }
if ($sockerr) {
$hget($gettok($sockname,2,46),out) [Socket Error] $sockname $time $script
halt
}
sockread %zybez
set %line [ $+ [ %row ] ] %zybez
inc %row
}
on $*:TEXT:/^[!@.]loook */Si:#: {
var %class = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
if (!$readini(chan.ini,$chan,public)) { hadd -m $+(a,%class) out $iif($left($1,1) == @,.msg $chan,.notice $nick) }
if ($readini(chan.ini,$chan,public) == on) { hadd -m $+(a,%class) out $iif($left($1,1) == @,.msg $chan,.notice $nick) }
if ($readini(chan.ini,$chan,public) == off) { hadd -m $+(a,%class) out .notice $nick }
if ($readini(chan.ini,$chan,public) == voice) { hadd -m $+(a,%class) out $iif($nick isvoice $chan || $nick ishop $chan || $nick isop $chan,$iif($left($1,1) == @,.msg $chan,.notice $nick),.notice $nick) }
if ($readini(chan.ini,$chan,public) == half) { hadd -m $+(a,%class) out $iif($nick ishop $chan || $nick isop $chan,$iif($left($1,1) == @,.msg $chan,.notice $nick),.notice $nick) }
if (!$2) { $hget($+(a,%class),out) Syntax: !item <item> | halt }
if ($left($2,1) != $chr(35)) {
hadd -m $+(a,%class) search $replace($2-,$chr(32),+)
sockopen $+(zybez4.a,%class) www.zybez.net 80
}
if ($left($2,1) == $chr(35)) {
hadd -m $+(a,%class) id $right($2,-1)
sockopen $+(zybez4.a,%class) www.zybez.net 80
}
}
on *:sockopen:zybez4.*: {
.sockwrite -n $sockname GET /items.php?id= $+ $hget($gettok($sockname,2,46),id) HTTP/1.0
.sockwrite -n $sockname Host: www.zybez.net $+ $crlf $+ $crlf
}
on *:sockread:zybez4.*: {
var %bleh = $gettok($sockname,2,46)
if (!%row) { set %row 1 }
if ($sockerr) {
$hget($gettok($sockname,2,46),out) [Socket Error] $sockname $time $script
halt
}
sockread %zybez
set %line [ $+ [ %row ] ] %zybez
inc %row
}
:END
