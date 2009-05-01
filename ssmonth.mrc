on $*:TEXT:/^[@!.](ssm|ssmo|ssmonth|ssmonthly) */Si:#: {
%class = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
if ($scores($right($2,-1)) != nomatch && $2) {
%skill = $scores($right($2,-1))
%nick = $caps($regsubex($rsn($nick),/\W+/g,_))
}
else if ($scores($right($2,-1)) == nomatch && $2) {
if ($chr(64) isin $2-) {
%nick = $caps($regsubex($rsn($replace($left($gettok($2-,1,64),-1),$chr(32),_,-,_)),/\W+/g,_))
%skill = $scores($gettok($2-,2,64))
}
else {
%nick = $caps($regsubex($rsn($replace($2-,$chr(32),_,-,_)),/\W+/g,_))
%skill = all
}
}
if (!$2) {
%nick = $caps($regsubex($rsn($nick),/\W+/g,_))
%skill = all
}
hadd -m $+(a,%class) out $iif($left($1,1) == @,.msg $chan,.notice $nick)
hadd -m $+(a,%class) nick %nick
hadd -m $+(a,%class) skill %skill
sockopen $+(ssmonth.a,%class) ss.x10hosting.com 80
}
on *:sockopen:ssmonth.*: {
.sockwrite -n $sockname GET /leader.php HTTP/1.1
.sockwrite -n $sockname Host: ss.x10hosting.com $+ $crlf $+ $crlf
}
on *:sockread:ssmonth.*: {
if (%row == $null) { set %row 1 }
if ($sockerr) {
$right($hget($gettok($sockname,2,46),out),-1) [Socket Error] $sockname $time $script
halt
}
.sockread %stats
if (%row < 1000) {
if (<!-- skill1 isin %stats) { set %skill1 $regsubex(%stats,/^<!-- Skill1=(.+?) Skill2=(.+?) -->$/i,\1) | set %skill2 $regsubex(%stats,/^<!-- Skill1=(.+?) Skill2=(.+?) -->$/i,\2) }
if (($hget($gettok($sockname,2,46),skill) == Overall || $hget($gettok($sockname,2,46),skill) == all) || (%skill1 != $hget($gettok($sockname,2,46),skill) && %skill2 != $hget($gettok($sockname,2,46),skill))) {
if (*<!-- oa --><tr><td align="center">1</td><td>* iswm %stats) { set %oa1 $regsubex(%stats,/^<!-- oa --><tr><td align=\"center\">1<\/td><td>(\w+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><\/tr>$/,\1 [+ $+ \2 $+ ]07 \3;) }
if (*<!-- oa --><tr><td align="center">2</td><td>* iswm %stats) { set %oa2 $regsubex(%stats,/^<!-- oa --><tr><td align=\"center\">2<\/td><td>(\w+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><\/tr>$/,\1 [+ $+ \2 $+ ]07 \3;) }
if (*<!-- oa --><tr><td align="center">3</td><td>* iswm %stats) { set %oa3 $regsubex(%stats,/^<!-- oa --><tr><td align=\"center\">3<\/td><td>(\w+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><\/tr>$/,\1 [+ $+ \2 $+ ]07 \3;) }
if (*<!-- oa --><tr><td align="center">4</td><td>* iswm %stats) { set %oa4 $regsubex(%stats,/^<!-- oa --><tr><td align=\"center\">4<\/td><td>(\w+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><\/tr>$/,\1 [+ $+ \2 $+ ]07 \3;) }
if (*<!-- oa --><tr><td align="center">5</td><td>* iswm %stats) { set %oa5 $regsubex(%stats,/^<!-- oa --><tr><td align=\"center\">5<\/td><td>(\w+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><\/tr>$/,\1 [+ $+ \2 $+ ]07 \3;) }
if (<!-- oa --> isin %stats && $hget($gettok($sockname,2,46),nick) isin %stats) { %useroa = $regsubex(%stats,/^<!-- oa --><tr><td align=\"center\">(\d+)<\/td><td>(\w+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><\/tr>$/,$iif(\1 > 5,# $+ \1 \2 [+ $+ \3 $+ ]07 \4;)) }
if (*</html>* iswm %stats) {
$hget($gettok($sockname,2,46),out) SS Monthly Lead Overall: $replace(#1 %oa1 #2 %oa2 #3 %oa3 #4 %oa4 #5 %oa5,$hget($gettok($sockname,2,46),nick), $+ $hget($gettok($sockname,2,46),nick) $+ ) %useroa
}
}
;
if ($hget($gettok($sockname,2,46),skill) == %skill1 || $hget($gettok($sockname,2,46),skill) == all) {
if (*<!-- s1 --><tr><td align="center">1</td><td>* iswm %stats) { set %s11 $regsubex(%stats,/^<!-- s1 --><tr><td align=\"center\">1<\/td><td>(\w+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><\/tr>$/,\107 \2) }
if (*<!-- s1 --><tr><td align="center">2</td><td>* iswm %stats) { set %s12 $regsubex(%stats,/^<!-- s1 --><tr><td align=\"center\">2<\/td><td>(\w+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><\/tr>$/,\107 \2) }
if (*<!-- s1 --><tr><td align="center">3</td><td>* iswm %stats) { set %s13 $regsubex(%stats,/^<!-- s1 --><tr><td align=\"center\">3<\/td><td>(\w+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><\/tr>$/,\107 \2) }
if (*<!-- s1 --><tr><td align="center">4</td><td>* iswm %stats) { set %s14 $regsubex(%stats,/^<!-- s1 --><tr><td align=\"center\">4<\/td><td>(\w+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><\/tr>$/,\107 \2) }
if (*<!-- s1 --><tr><td align="center">5</td><td>* iswm %stats) { set %s15 $regsubex(%stats,/^<!-- s1 --><tr><td align=\"center\">5<\/td><td>(\w+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><\/tr>$/,\107 \2) }
if (<!-- s1 --> isin %stats && $hget($gettok($sockname,2,46),nick) isin %stats) { set %users1 $regsubex(%stats,/^<!-- s1 --><tr><td align=\"center\">(\d+)<\/td><td>(\w+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><\/tr>$/,$iif(\1 > 5,# $+ \1 \207 \3)) }
if (*</html>* iswm %stats) {
$hget($gettok($sockname,2,46),out) SS Monthly Lead %skill1 $+ : $replace(#1 %s11 #2 %s12 #3 %s13 #4 %s14 #5 %s15,$hget($gettok($sockname,2,46),nick), $+ $hget($gettok($sockname,2,46),nick) $+ ) %users1
}
}
;
if ($hget($gettok($sockname,2,46),skill) == %skill2 || $hget($gettok($sockname,2,46),skill) == all) {
if (*<!-- s2 --><tr><td align="center">1</td><td>* iswm %stats) { set %s21 $regsubex(%stats,/^<!-- s2 --><tr><td align=\"center\">1<\/td><td>(\w+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><\/tr>$/,\107 \2) }
if (*<!-- s2 --><tr><td align="center">2</td><td>* iswm %stats) { set %s22 $regsubex(%stats,/^<!-- s2 --><tr><td align=\"center\">2<\/td><td>(\w+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><\/tr>$/,\107 \2) }
if (*<!-- s2 --><tr><td align="center">3</td><td>* iswm %stats) { set %s23 $regsubex(%stats,/^<!-- s2 --><tr><td align=\"center\">3<\/td><td>(\w+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><\/tr>$/,\107 \2) }
if (*<!-- s2 --><tr><td align="center">4</td><td>* iswm %stats) { set %s24 $regsubex(%stats,/^<!-- s2 --><tr><td align=\"center\">4<\/td><td>(\w+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><\/tr>$/,\107 \2) }
if (*<!-- s2 --><tr><td align="center">5</td><td>* iswm %stats) { set %s25 $regsubex(%stats,/^<!-- s2 --><tr><td align=\"center\">5<\/td><td>(\w+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><\/tr>$/,\107 \2) }
if (<!-- s2 --> isin %stats && $hget($gettok($sockname,2,46),nick) isin %stats) { set %users2 $regsubex(%stats,/^<!-- s2 --><tr><td align=\"center\">(\d+)<\/td><td>(\w+)<\/td><td align=\"right\">\+([0-9\x2C]+)<\/td><\/tr>$/,$iif(\1 > 5,# $+ \1 \207 \3)) }
if (*</html>* iswm %stats) {
$hget($gettok($sockname,2,46),out) SS Monthly Lead %skill2 $+ : $replace(#1 %s21 #2 %s22 #3 %s23 #4 %s24 #5 %s25,$hget($gettok($sockname,2,46),nick), $+ $hget($gettok($sockname,2,46),nick) $+ ) %users2
}
}
}
inc %row 1
}
on *:sockclose:ssmonth.*: {
unset %*
}
;######################
;######-SSRecord-######
;######################
on $*:TEXT:/^[!@.]ssr(ecord)? */Si:#: {
var %class = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
if !$readini(chan.ini,$chan,public) { hadd -m $+(a,%class) out $iif($left($1,1) == @,.msg $chan,.notice $nick) }
if $readini(chan.ini,$chan,public) == on hadd -m $+(a,%class) out $iif($left($1,1) == @,.msg $chan,.notice $nick)
if $readini(chan.ini,$chan,public) == off hadd -m $+(a,%class) out .notice $nick
if $readini(chan.ini,$chan,public) == voice hadd -m $+(a,%class) out $iif($nick isvoice $chan || $nick ishop $chan || $nick isop $chan,$iif($left($1,1) == @,.msg $chan,.notice $nick),.notice $nick)
if $readini(chan.ini,$chan,public) == half hadd -m $+(a,%class) out $iif($nick ishop $chan || $nick isop $chan,$iif($left($1,1) == @,.msg $chan,.notice $nick),.notice $nick)
if $2 { hadd -m $+(a,%class) record $lookups($2) }
else hadd -m $+(a,%class) record Overall
sockopen $+(ssr.a,%class) ss.x10hosting.com 80
}
on *:sockopen:ssr.*: {
.sockwrite -n $sockname GET /record.php HTTP/1.1
.sockwrite -n $sockname Host: ss.x10hosting.com $+ $crlf $+ $crlf
}
on *:sockread:ssr.*: {
if (!%row) { set %row 1 }
if ($sockerr) {
$right($hget($gettok($sockname,2,46),out),-1) [Socket Error] $sockname $time $script
halt
}
.sockread %stats
if (%row < 1000) {
var %regex = /<tr><td>( $+ $hget($gettok($sockname,2,46),record) $+ )<\/td><td>(\w+)<\/td><td align="right">(\d+(\x2c\d+)*)<\/td><\/tr>$/i
if $regex(%stats,%regex) {
$hget($gettok($sockname,2,46),out) [SS] $regml(2) 07 $+ $regml(1) | Record exp gain in one log out:07 $regml(3) 12http://www.ss.x10hosting.com/record.php
unset %*
sockclose $sockname
}
inc %row
}
}
:END
