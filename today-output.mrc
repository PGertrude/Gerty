on *:TEXT:*:?: {
if ($tracks($right($1,-1)) == NoMatch) { halt }
var %class = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
if ($2) {
var %nick = $rsn($replace($gettok($2-,1,64),$chr(32),_,-,_))
}
if (!$2) {
var %nick = $rsn($nick)
}
hadd -m $+(a,%class) out .msg $nick
hadd -m $+(a,%class) command $tracks($right($1,-1))
hadd -m $+(a,%class) nick $caps(%nick)
if ($tracked(%nick) == tracked) { sockopen $+(today2.a,%class) hiscore.runescape.com 80 }
if ($tracked(%nick) != tracked) {
if ($duration($time) >= 25200) {
%today = $duration($time) - 25200
}
if ($duration($time) < 25200) {
%today = $duration($time) + 61200
}
if ($duration($time) < 25200 && $date(ddd) == sun) {
%week = 579600 + %today
}
else {
%week = $calc($replace($day,Sunday,0,Monday,1,Tuesday,2,Wednesday,3,Thursday,4,Friday,5,Saturday,6) * 86400 + %today )
}
if ($duration($time) < 25200 && $date(dd) == 01) {
%month = $replace($date(mmm),Jan,2394000,Feb,2653200,Mar,2566800,Apr,2653200,May,2566800,Jun,2653200,Jul,2653200,Aug,2566800,Sep,2653200,Oct,2566800,Nov,2653200,Dec,2653200) + %today
}
else {
%month = $calc(($gettok($date,1,47) - 1) * 86400 + %today )
}
set %year $calc($ctime($date $time) - $ctime(January 1 $date(yyyy) 07:00:00))
hadd -m $+(a,%class) nick $caps(%nick)
hadd -m $+(a,%class) time % [ $+ [ $tracks($right($1,-1)) ] ]
hadd -m $+(a,%class) skill $skills($2)
sockopen $+(trackyes.a,%class) www.rscript.org 80
}
}
on $*:TEXT:/^[!@.] */Si:#: {
if ($chan == #gerty && $me != Gerty && Gerty isin #gerty) { halt }
if ($tracks($right($1,-1)) == NoMatch) { halt }
var %class = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
if ($2) {
var %nick = $rsn($replace($gettok($2-,1,64),$chr(32),_,-,_))
}
if (!$2) {
var %nick = $rsn($nick)
}
hadd -m $+(a,%class) out $saystyle($left($1,1),$nick,$chan)
hadd -m $+(a,%class) command $tracks($right($1,-1))
hadd -m $+(a,%class) nick $caps(%nick)
if ($tracked(%nick) == tracked) { sockopen $+(today2.a,%class) hiscore.runescape.com 80 }
if ($tracked(%nick) != tracked) {
if ($duration($time) >= 25200) {
%today = $duration($time) - 25200
}
if ($duration($time) < 25200) {
%today = $duration($time) + 61200
}
if ($duration($time) < 25200 && $date(ddd) == sun) {
%week = 579600 + %today
}
else {
%week = $calc($replace($day,Sunday,0,Monday,1,Tuesday,2,Wednesday,3,Thursday,4,Friday,5,Saturday,6) * 86400 + %today )
}
if ($duration($time) < 25200 && $date(dd) == 01) {
%month = $replace($date(mmm),Jan,2394000,Feb,2653200,Mar,2566800,Apr,2653200,May,2566800,Jun,2653200,Jul,2653200,Aug,2566800,Sep,2653200,Oct,2566800,Nov,2653200,Dec,2653200) + %today
}
else {
%month = $calc(($gettok($date,1,47) - 1) * 86400 + %today )
}
set %year $calc($ctime($date $time) - $ctime(January 1 $date(yyyy) 07:00:00))
hadd -m $+(a,%class) nick $caps(%nick)
hadd -m $+(a,%class) time % [ $+ [ $tracks($right($1,-1)) ] ]
hadd -m $+(a,%class) skill $skills($2)
sockopen $+(trackyes.a,%class) www.rscript.org 80
}
}
on *:sockopen:today2.*: {
.sockwrite -n $sockname GET /index_lite.ws?player= $+ $hget($gettok($sockname,2,46),nick) HTTP/1.1
.sockwrite -n $sockname Host: hiscore.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:today2.*: {
if (%row == $null) { set %row 1 }
if ($sockerr) {
$right($hget($gettok($sockname,2,46),out),-1) [Socket Error] $sockname $time $script
halt
}
.sockread %stats
if (%row < 100 && $regex(%stats,/^-*\d+\x2C-*\d+(\x2C-*\d+)*$/)) {
set % [ $+ [ %row ] ] %stats
set %e [ $+ [ %row ] ] $gettok(%stats,3,44)
set %r [ $+ [ %row ] ] $gettok(%stats,1,44)
if ($gettok(%stats,2,44) == -1 && %row < 26 && %row > 1) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
if ($gettok(%stats,2,44) != -1 && %row < 26 && %row > 1) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
inc %row 1
if (%row == 30) { closetoday }
}
}
alias closetoday {
if ($gettok(%1,2,44) > 100) {
var %x = 1,%y = 1
hadd -m $gettok($sockname,2,46) rankeds 0
while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
inc %x 1
}
set %unranked $round($calc(($gettok(%11,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ ~ $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
inc %y 1
}
}
if ($gettok(%1,2,44) < 100) {
var %v = 24
var %w = 0
while (%v > 0) {
var %w = %w + $remove($gettok(% [ $+ [ $calc(%v +1) ] ],2,44),-)
if ($gettok(% [ $+ [ $calc(%v +1) ] ],2,44) == -1 && %v != 4) { set % [ $+ [ $calc(%v +1) ] ] Unranked,~1,0 }
if ($gettok(% [ $+ [ $calc(%v +1) ] ],2,44) == -1 && %v == 4) { set %15 Unranked,10,1154 | var %w = %w + 9 }
dec %v 1
}
var %x = 24
var %y = 0
while (%x > 0) {
var %y = %y + $replace($gettok(% [ $+ [ $calc(%x +1) ] ],3,44),-1,0)
dec %x 1
}
set %1 Unranked,~ $+ $calc(%w) $+ , $+ $calc(%y)
}
var %x = 25
while (%x) {
set %g [ $+ [ %x ] ] $calc(%e [ $+ [ %x ] ] - $gettok($readini($hget($gettok($sockname,2,46),command) $+ .ini,$hget($gettok($sockname,2,46),nick),$statnum(%x)),3,44))
dec %x
}
var %x = 25
while (%x) {
set %rg [ $+ [ %x ] ] $calc($gettok($readini($hget($gettok($sockname,2,46),command) $+ .ini,$hget($gettok($sockname,2,46),nick),$statnum(%x)),1,44) - %r [ $+ [ %x ] ] )
dec %x
}
var %x = 25
var %cmb = $sorttoday(Attack %e2 %g2 %rg2 Defence %e3 %g3 %rg3 Strength %e4 %g4 %rg4 Hitpoints %e5 %g5 %rg5 Range %e6 %g6 %rg6 Pray %e7 %g7 %rg7 Mage %e8 %g8 %rg8 Summon %e25 %g25 %rg25)
if (%cmb) { var %out1 = $hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),nick) Combat  $+ $hget($gettok($sockname,2,46),command) $+ : %cmb }
var %others = $sorttoday(Cook %e9 %g9 %rg9 Woodcut %e10 %g10 %rg10 Fletching %e11 %g11 %rg11 Fishing %e12 %g12 %rg12 Firemake %e13 %g13 %rg13 Crafting %e14 %g14 %rg14 Smithing %e15 %g15 %rg15 Mine %e16 %g16 %rg16 Herblore %e17 %g17 %rg17 Agility %e18 %g18 %rg18 Thieve %e19 %g19 %rg19 Slayer %e20 %g20 %rg20 Farming %e21 %g21 %rg21 Runecraft %e22 %g22 %rg22 Hunter %e23 %g23 %rg23 Construct %e24 %g24 %rg24)
if (%others) { var %out2 = $hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),nick) Others  $+ $hget($gettok($sockname,2,46),command) $+ : %others }
if (%rg1 != 0) { var %rank = $iif(%rg1 > 0,03 [+ $+ $overk(%rg1) $+ ],04 [ $+ $overk(%rg1) $+ ]) ranks }
$hget($gettok($sockname,2,46),out)  $+ $hget($gettok($sockname,2,46),nick) Skills  $+ $hget($gettok($sockname,2,46),command) $+ : 07Overall $gettok(%1,2,44) $iif(%total > 0,[+ $+ %total $+ ]) 03+ $+ $iif(%g1 > 1000,$bytes($round($calc($v1 /1000),0),db) $+ k,$bytes($v1,db)) exp $+ %rank $+ ;
%out1
%out2
:unset
unset %*
}
alias sorttoday {
var %string = $1-
%exps = $sorttok($regsubex(%string,/((\w+) (\d+) (\d+) (\d+))/g,\4),32,nr)
var %x = $numtok(%exps,32)
var %y = 1
var %z = 1
while (%z <= %x) {
var %p = 1
while (%p <= $numtok(%string,32)) {
if ($gettok(%string,$calc(%p +2),32) == $gettok(%exps,%y,32) && $gettok(%string,$calc(%p +2),32) > 0 && $gettok(%string,%p,32) !isin %done) {
var %levels = $virt($gettok(%string,$calc(%p +1),32)) - $virt($calc($gettok(%string,$calc(%p +1),32) - $gettok(%string,$calc(%p +2),32)))
%total = $calc(%total + %levels)
}
if ($gettok(%string,$calc(%p +2),32) == $gettok(%exps,%y,32) && $gettok(%string,$calc(%p +2),32) > 0 && $gettok(%string,%p,32) !isin %done && $numtok(%done,124) <= 7) {
if ($gettok(%string,$calc(%p +3),32) != 0) { var %rank = $iif($gettok(%string,$calc(%p +3),32) > 0,03 [+ $+ $overk($gettok(%string,$calc(%p +3),32)) $+ ],04 [ $+ $overk($gettok(%string,$calc(%p +3),32)) $+ ]) }
var %out = %out 07 $+ $gettok(%string,%p,32) $+  $virt($gettok(%string,$calc(%p +1),32)) $iif(%levels > 0,[+ $+ %levels $+ ]) 03+ $+ $overk($gettok(%string,$calc(%p +2),32)) $+ %rank $+ ;
var %done = %done $+ | $+ $gettok(%string,%p,32)
unset %rank
}
inc %p 4
}
inc %y
inc %z
}
return %out
}
alias overk {
return $iif($1 > 999 || $1 < -999,$bytes($round($calc($1 /1000),0),db) $+ k,$bytes($1,db))
}
on *:NOTICE:*:*: {
if ($left($1,1) != . && $left($1,1) != ! && $left($1,1) != @) { halt }
if ($tracks($right($1,-1)) == NoMatch) { halt }
var %class33 = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
if ($2) {
if ($readini(rsn.ini,$address($replace($2-,$chr(32),_),3),rsn)) { var %nick = $readini(rsn.ini,$address($replace($2-,$chr(32),_),3),rsn) }
if (!$readini(rsn.ini,$address($replace($2-,$chr(32),_),3),rsn)) { var %nick = $capwords($replace($2-,$chr(32),_,-,_)) }
}
if (!$2) {
if ($readini(rsn.ini,$address($nick,3),rsn)) { var %nick = $readini(rsn.ini,$address($nick,3),rsn) }
if (!$readini(rsn.ini,$address($nick,3),rsn)) { var %nick = $capwords($nick) }
}
hadd -m $+(n,%class33) out .notice $nick
hadd -m $+(n,%class33) command $tracks($right($1,-1))
hadd -m $+(n,%class33) nick %nick
sockopen $+(today2.,$+(n,%class33)) hiscore.runescape.com 80
}
:END
