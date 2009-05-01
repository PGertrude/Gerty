on $*:text:/^[@!.](rcevent)$/Si:#: {
if ($rcadmin($nick) == admin) {
writeini rccomp.ini war start yes
set %rclead true
whois $me
join #0,0
var %saystyle = $iif($left($1,1) == @,.msg $chan,.notice $nick)
var %update = 1
while (%update <= $numtok($readini(rccomp.ini,member,nick),124)) {
.timer 1 $calc( %update * 2 ) sockopen $+(rcers.,$gettok($readini(rccomp.ini,member,nick),%update,124)) hiscore.runescape.com 80
inc %update 1
}
.timer 1 $calc( %update * 30 ) leadupdate
}
}
on *:sockopen:rcers.*: {
.sockwrite -n $sockname GET /index_lite.ws?player= $+ $gettok($sockname,2,46) HTTP/1.1
.sockwrite -n $sockname Host: hiscore.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:rcers.*: {
if (%row == $null) { set %row 1 }
if ($sockerr) {
$right($hget($gettok($sockname,2,46),out),-1) [Socket Error] $sockname $time $script
halt
}
.sockread %stats
if (%row < 100 && $regex(%stats,/^-*\d+\x2C-*\d+(\x2C-*\d+)*$/)) {
set % [ $+ [ %row ] ] %stats
if ($gettok(%stats,2,44) == -1 && %row < 26 && %row > 1) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
if ($gettok(%stats,2,44) != -1 && %row < 26 && %row > 1) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
inc %row 1
if (%row == 30) { rcers.out }
}
if (*Page not found* iswm %stats) { rcers.out }
}
alias rcers.out {
if ($gettok(%1,2,44) > 100) {
var %x = 1,%y = 1
hadd -m $gettok($sockname,2,46) rankeds 0
while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
inc %x 1
}
set %unranked $round($calc(($gettok(%1,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
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
if ($gettok(% [ $+ [ $calc(%v +1) ] ],2,44) == -1 && %v == 4) { set %5 Unranked,10,1154 | var %w = %w + 9 }
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
writeini rccomps.ini $gettok($sockname,2,46) runecraft $gettok(%22,3,44)
writeini rccomps.ini $gettok($sockname,2,46) runecraftlvl $gettok(%22,2,44)
writeini rccomps.ini $gettok($sockname,2,46) runecraftran $gettok(%22,1,44)
writeini rccomp.ini $gettok($sockname,2,46) runecraft $gettok(%22,3,44)
writeini rccomp.ini $gettok($sockname,2,46) runecraftlvl $gettok(%22,2,44)
writeini rccomp.ini $gettok($sockname,2,46) runecraftran $gettok(%22,1,44)
:unset
unset %*
}
on $*:text:/^[@!.](endevent)$/Si:#: {
if ($rcadmin($nick) == admin) {
var %saystyle = $iif($left($1,1) == @,.msg $chan,.notice $nick)
%saystyle Exp is being saved. this will take approximately 4 minutes
var %update = 1
while (%update <= $numtok($readini(rccomp.ini,member,nick),124)) {
.timer 1 $calc( %update * 2 ) sockopen $+(rcday.,$gettok($readini(rccomp.ini,member,nick),%update,124)) hiscore.runescape.com 80
inc %update 1
}
}
}
on *:sockopen:rcday.*: {
.sockwrite -n $sockname GET /index_lite.ws?player= $+ $gettok($sockname,2,46) HTTP/1.1
.sockwrite -n $sockname Host: hiscore.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:rcday.*: {
if (%row == $null) { set %row 1 }
if ($sockerr) {
$right($hget($gettok($sockname,2,46),out),-1) [Socket Error] $sockname $time $script
halt
}
.sockread %stats
if (%row < 100 && $regex(%stats,/^-*\d+\x2C-*\d+(\x2C-*\d+)*$/)) {
set % [ $+ [ %row ] ] %stats
if ($gettok(%stats,2,44) == -1 && %row < 26 && %row > 1) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
if ($gettok(%stats,2,44) != -1 && %row < 26 && %row > 1) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
inc %row 1
if (%row == 30) { rcday.out }
}
if (*Page not found* iswm %stats) { rcday.out }
}
alias rcday.out {
var %x = 1,%y = 1
hadd -m $gettok($sockname,2,46) rankeds 0
while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
inc %x 1
}
set %unranked $round($calc(($gettok(%12,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
inc %y 1
}
writeini rccomp.ini $gettok($sockname,2,46) runecraft $calc($gettok(%22,3,44) - $readini(rccomp.ini,$gettok($sockname,2,46),runecraft))
writeini rccomp.ini $gettok($sockname,2,46) runecraftlvl $calc($gettok(%22,2,44) - $readini(rccomp.ini,$gettok($sockname,2,46),runecraftlvl))
writeini rccomp.ini $gettok($sockname,2,46) runecraftran $gettok(%22,1,44) - $readini(rccomp.ini,$gettok($sockname,2,46),runecraftran))
:unset
unset %*
}
on $*:text:/^[@!.](newrcday)$/Si:#: {
if ($rcadmin($nick) == admin) {
set %rclead true
whois $me
join #0,0
var %saystyle = $iif($left($1,1) == @,.msg $chan,.notice $nick)
var %update = 1
while (%update <= $numtok($readini(rccomp.ini,member,nick),124)) {
.timer 1 $calc( %update * 2 ) sockopen $+(rcupdate.,$gettok($readini(rccomp.ini,member,nick),%update,124)) hiscore.runescape.com 80
inc %update 1
}
}
}
on *:sockopen:rcupdate.*: {
.sockwrite -n $sockname GET /index_lite.ws?player= $+ $gettok($sockname,2,46) HTTP/1.1
.sockwrite -n $sockname Host: hiscore.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:rcupdate.*: {
if (%row == $null) { set %row 1 }
if ($sockerr) {
$right($hget($gettok($sockname,2,46),out),-1) [Socket Error] $sockname $time $script
halt
}
.sockread %stats
if (%row < 100 && $regex(%stats,/^-*\d+\x2C-*\d+(\x2C-*\d+)*$/)) {
set % [ $+ [ %row ] ] %stats
if ($gettok(%stats,2,44) == -1 && %row < 26 && %row > 1) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
if ($gettok(%stats,2,44) != -1 && %row < 26 && %row > 1) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
inc %row 1
if (%row == 30) { rcupdate.out }
}
if (*Page not found* iswm %stats) { rcupdate.out }
}
alias rcupdate.out {
var %x = 1,%y = 1
hadd -m $gettok($sockname,2,46) rankeds 0
while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
inc %x 1
}
set %unranked $round($calc(($gettok(%12,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
inc %y 1
}
writeini rccomp.ini $gettok($sockname,2,46) runecraft $gettok(%22,3,44)
writeini rccomp.ini $gettok($sockname,2,46) runecraftlvl $gettok(%22,2,44)
writeini rccomp.ini $gettok($sockname,2,46) runecraftran $gettok(%22,1,44)
writeini rccomp.ini leaders $gettok($sockname,2,46) $calc( $gettok(%22,3,44) - $readini(rccomps.ini,$gettok($sockname,2,46),runecraft) )
writeini rccomp.ini leaders a $calc($readini(rccomp.ini,leaders,a)+1)
if ($readini(rccomp.ini,leaders,a) == $calc($numtok($readini(rccomp.ini,member,nick),124)+1)) { writeini rccomp.ini leaders a 1 }
:unset
unset %*
.hfree $gettok($sockname,2,46)
}
on *:TEXT:!test:#: {
var %update = 1
while (%update <= $numtok($readini(rccomp.ini,member,nick),124)) {
.timer 1 $calc( %update * 1 ) .notice P_Gertrude o $gettok($readini(rccomp.ini,member,nick),%update,124)
inc %update 1
}
}
alias leadupdate {
var %saystyle = $iif($left($1,1) == @,.msg $chan,.notice $nick)
var %update = 1
writeini rccomp.ini leaders a 1
while (%update <= $numtok($readini(rccomp.ini,member,nick),124)) {
timer 1 $calc( %update * 20 ) sockopen $+(rcupdate2.,$gettok($readini(rccomp.ini,member,nick),%update,124)) hiscore.runescape.com 80
inc %update 1
}
}
on $*:text:/^[@!.](leadupdate)$/Si:#: {
if ($rcadmin($nick) == admin) {
set %rclead true
whois $me
join #0,0
var %saystyle = $iif($left($1,1) == @,.msg $chan,.notice $nick)
var %update = 1
.timerrc* off
writeini rccomp.ini leaders a 1
while (%update <= $numtok($readini(rccomp.ini,member,nick),124)) {
.timer 1 $calc( %update * 2 ) sockopen $+(rcupdate2.,$gettok($readini(rccomp.ini,member,nick),%update,124)) hiscore.runescape.com 80
inc %update 1
}
}
}
on *:sockopen:rcupdate2.*: {
.sockwrite -n $sockname GET /index_lite.ws?player= $+ $gettok($sockname,2,46) HTTP/1.1
.sockwrite -n $sockname Host: hiscore.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:rcupdate2.*: {
if (%row == $null) { set %row 1 }
if ($sockerr) {
$right($hget($gettok($sockname,2,46),out),-1) [Socket Error] $sockname $time $script
halt
}
.sockread %stats
if (%row < 100 && $regex(%stats,/^-*\d+\x2C-*\d+(\x2C-*\d+)*$/)) {
set % [ $+ [ %row ] ] %stats
if ($gettok(%stats,2,44) == -1 && %row < 26 && %row > 1) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
if ($gettok(%stats,2,44) != -1 && %row < 26 && %row > 1) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
inc %row 1
if (%row == 30) { asdfghjkl }
}
if (*Page not found* iswm %stats) { asdfghjkl }
}
alias asdfghjkl {
if ($gettok(%1,2,44) > 100) {
var %x = 1,%y = 1
hadd -m $gettok($sockname,2,46) rankeds 0
while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
inc %x 1
}
set %unranked $round($calc(($gettok(%1,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
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
if ($gettok(% [ $+ [ $calc(%v +1) ] ],2,44) == -1 && %v == 4) { set %5 Unranked,10,1154 | var %w = %w + 9 }
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
writeini rccomp.ini leaders $iif(!$readini(rccomp.ini,leaders,a),1,$readini(rccomp.ini,leaders,a)) $calc( $gettok(%22,3,44) - $readini(rccomps.ini,$gettok($sockname,2,46),runecraft) ) $gettok($sockname,2,46)
writeini rccomp.ini leaders $gettok($sockname,2,46) $calc( $gettok(%22,3,44) - $readini(rccomps.ini,$gettok($sockname,2,46),runecraft) )
writeini rccomp.ini leaders a $calc($readini(rccomp.ini,leaders,a)+1)
:unset
unset %*
.hfree $gettok($sockname,2,46)
}
on $*:TEXT:/^[@.!](comp(ranks?|stats?)) */Si:#: {
if ($rcadmin($nick) != admin) { halt }
var %saystyle = .notice $nick
if ($2) { %nick = $caps($regsubex($rsn($replace($2-,$chr(32),_)),/\W/g,_)) }
if (!$2) { %nick = $caps($regsubex($rsn($nick),/\W/g,_)) }
var %x = $numtok($readini(rccomp.ini,member,nick),124)
while (%x) {
var %out = %out $readini(rccomp.ini,leaders,$gettok($readini(rccomp.ini,member,nick),%x,124)) $gettok($readini(rccomp.ini,member,nick),%x,124)
dec %x
}
var %reply = $sortcprc(%out)
unset %*
}
on $*:TEXT:/^[@.!](lb|leaderboard) */Si:#: {
if ($rcadmin($nick) != admin) { halt }
if ($2) { %nick = $caps($regsubex($rsn($replace($2-,$chr(32),_)),/\W/g,_)) }
if (!$2) { %nick = $caps($regsubex($rsn($nick),/\W/g,_)) }
var %saystyle = $iif($left($1,1) == @,.msg $chan,.notice $nick)
var %x = $numtok($readini(rccomp.ini,member,nick),124)
while (%x) {
var %out = %out $readini(rccomp.ini,leaders,$gettok($readini(rccomp.ini,member,nick),%x,124)) $gettok($readini(rccomp.ini,member,nick),%x,124)
dec %x
}
var %reply = $sortrc(%out)
%saystyle RC Leader Board: $replace(%reply,%nick, $+ %nick $+ ,$gettok(%reply,1-3,32), $+ $gettok(%reply,1-3,32) $+ ) $iif(%nick !isin %reply && %nick isin $readini(rccomp.ini,member,nick),$rankrc(%out))
unset %*
}
on $*:TEXT:/^[!@.](total|comp)xp */Si:#: {
var %saystyle = $iif($left($1,1) == @,.msg $chan,.notice $nick)
var %x = $numtok($readini(rccomp.ini,member,nick),124)
var %out = 0
while (%x) {
var %out = $calc(%out + $readini(rccomp.ini,leaders,$gettok($readini(rccomp.ini,member,nick),%x,124)))
dec %x
}
%saystyle Total Exp Gain:07 $bytes(%out,db)
unset %*
}
alias sortcprc {
var %string = $1-
%exps = $sorttok($regsubex(%string,/((\d+) (\w+))/g,\2),32,nr)
var %x = $numtok(%exps,32)
var %y = 1
var %z = 1
while (%z <= %x) {
var %p = 1
while (%p <= $numtok(%string,32)) {
if ($gettok(%string,$calc(%p),32) == $gettok(%exps,%y,32) && $gettok(%string,$calc(%p),32) > 0 && $gettok(%string,$calc(%p +1),32) !isin %done && $numtok(%done,124) <= 100 && $numtok(%out,32) < 30) {
var %out = %out 07 $+ $chr(35) $+ %y $+  $gettok(%string,$calc(%p +1),32) (07 $+ $bytes($gettok(%string,$calc(%p),32),db) $+ );
if ($numtok(%out,32) == 30) { .notice $nick $iif($gettok(%out,1,32) == 07#1,RC Leaderboard) $iif($gettok(%out,1,32) == 07#1,$replace(%out,%nick, $+ %nick $+ ,$gettok(%out,1-3,32), $+ $gettok(%out,1-3,32) $+ ),$replace(%out,%nick, $+ %nick $+ )) | unset %out }
var %done = %done $+ | $+ $gettok(%string,$calc(%p +1),32)
}
inc %p 2
}
inc %y
inc %z
}
.notice $nick $replace(%out,%nick, $+ %nick $+ )
}
alias sortrc {
var %string = $1-
%exps = $sorttok($regsubex(%string,/((\d+) (\w+))/g,\2),32,nr)
var %x = $numtok(%exps,32)
var %y = 1
var %z = 1
while (%z <= %x) {
var %p = 1
while (%p <= $numtok(%string,32)) {
if ($gettok(%string,$calc(%p),32) == $gettok(%exps,%y,32) && $gettok(%string,$calc(%p),32) > 0 && $gettok(%string,$calc(%p +1),32) !isin %done && $numtok(%done,124) <= 100 && $numtok(%out,32) < 30) {
var %out = %out 07 $+ $chr(35) $+ %y $+  $gettok(%string,$calc(%p +1),32) (07 $+ $bytes($gettok(%string,$calc(%p),32),db) $+ );
var %done = %done $+ | $+ $gettok(%string,$calc(%p +1),32)
}
inc %p 2
}
inc %y
inc %z
}
return %out
}
alias rankrc {
var %string = $1-
%exps = $sorttok($regsubex(%string,/((\d+) (\w+))/g,\2),32,nr)
var %x = $numtok(%exps,32)
var %y = 1
var %z = 1
while (%z <= %x) {
var %p = 1
while (%p <= $numtok(%string,32)) {
if ($gettok(%string,$calc(%p),32) == $gettok(%exps,%y,32) && $gettok(%string,$calc(%p),32) > 0 && $gettok(%string,$calc(%p +1),32) !isin %done && $numtok(%done,124) <= 100 && $numtok(%out,32) < 30) {
if (%nick == $gettok(%string,$calc(%p +1),32)) { var %out = %out 07 $+ $chr(35) $+ %y $+   $+ $gettok(%string,$calc(%p +1),32) $+  (07 $+ $bytes($gettok(%string,$calc(%p),32),db) $+ ); }
var %done = %done $+ | $+ $gettok(%string,$calc(%p +1),32)
}
inc %p 2
}
inc %y
inc %z
}
return %out
}
;on $*:text:/^[@!.]currentrc */Si:#: {
; set %nick $replace($2-,$chr(32),_)
; set %saystyle $iif($left($1,1) == @,.msg $chan,.notice $nick)
; sockopen currentrc.1 hiscore.runescape.com 80
;}
;on *:sockopen:currentrc.*: {
; .sockwrite -n $sockname GET /index_lite.ws?player= $+ %nick HTTP/1.1
; .sockwrite -n $sockname Host: hiscore.runescape.com $+ $crlf $+ $crlf
;}
;on *:sockread:currentrc.*: {
; if (%row == $null) { set %row 1 }
; if ($sockerr) {
; $hget($gettok($sockname,2,46),out) There was a socket error.
; halt
; }
; .sockread %stats
; if (%row < 100) {
; set % [ $+ [ %row ] ] %stats
; if ($gettok(%stats,2,44) == -1 && %row < 36 && %row > 11) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
; if ($gettok(%stats,2,44) != -1 && %row < 36 && %row > 11) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
; inc %row 1
; }
;}
;on *:sockclose:currentrc.*: {
; var %x = 1,%y = 1
; hadd -m $gettok($sockname,2,46) rankeds 0
; while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
; hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
; inc %x 1
; }
; set %unranked $round($calc(($gettok(%12,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
; while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
; set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
; inc %y 1
; }
; var %exp = $gettok(%22,3,44)
; var %lvl = $gettok(%22,2,44)
; %saystyle $capwords(%nick) 07RuneCraft | Rank:07 $bytes($gettok(%22,1,44),db) | Level: 04 $+ $gettok(%22,2,44) $+  (07 $+ $virtual($gettok(%22,3,44)) $+ ) | Exp:07 $bytes($gettok(%22,3,44),db) (07 $+ $round($calc(($gettok(%22,3,44)/13034431)*100),1) $+ % of 99)| Exp till $calc($gettok(%22,2,44)+1) $+ :07 84,130 (07 $+ $round($calc((%exp -$calc($readini(exp.ini,lvl,%lvl)))/($readini(exp.ini,lvl,$calc(%lvl + 1))-$readini(exp.ini,lvl,%lvl))*100),1) $+ % of $calc($gettok(%32,2,44)+1) $+ )
; %saystyle Competition Progress - Today: 03 $+ $bytes($calc( $gettok(%22,3,44) - $readini(rccomp.ini,%nick,runecraft) ),db) exp, 03 $+ $bytes($calc( $gettok(%22,2,44) - $readini(rccomp.ini,%nick,runecraftlvl) ),db) lvls, 03 $+ $bytes($calc( $readini(rccomp.ini,%nick,runecraftran) - $gettok(%22,1,44) ),db) ranks; Whole Competition: 03 $+ $bytes($calc( $gettok(%22,3,44) - $readini(rccomps.ini,%nick,runecraft) ),db) exp, 03 $+ $bytes($calc( $gettok(%22,2,44) - $readini(rccomps.ini,%nick,runecraftlvl) ),db) lvls, 03 $+ $bytes($calc( $readini(rccomps.ini,%nick,runecraftran) - $gettok(%22,1,44) ),db) ranks
; :unset
; unset %*
;}
;
alias rci {
return $gettok($readini(rccomp.ini,leaders,$1),2,32) $gettok($readini(rccomp.ini,leaders,$1),1,32)
}
alias rcadmin {
if ($regex($1,$+(/^,$chr(40),$readini(rccomp.ini,member,admin),$chr(41),/i))) { return admin }
}
;on $*:TEXT:/^[!@.]Addcomp */Si:#: {
; if ($rcadmin($nick) == admin) {
; var %saystyle = $iif($left($1,1) == @,.msg $chan,.notice $nick)
; writeini rccomp.ini member nick $readini(rccomp.ini,member,nick) $+ $chr(124) $+ $2
; %saystyle 07 $+ $capwords($2) Added to competition.
; }
;}
;on $*:TEXT:/^[!@.](comp)$/Si:#: {
; var %saystyle = $iif($left($1,1) == @,.msg $chan,.notice $nick)
; if ($calc($ctime(28/4/2008 00:00:00) - $ctime($date $time)) < 172800 && $calc($ctime(28/4/2008 00:00:00) - $ctime($date $time)) > 0) {
; %saystyle Time Left:07 $duration($calc($ctime(28/4/2008 00:00:00) - $ctime($date $time))) | Total Exp Gain:07 $bytes($calc($replace($readini(rccomp.ini,leaders,order),$chr(32),+)),db)
; }
; if ($calc($ctime(28/4/2008 00:00:00) - $ctime($date $time)) > 172800) {
; %saystyle Competition start in:07 $duration($calc($ctime(26/4/2008 00:00:00) - $ctime($date $time)))
; }
; if ($calc($ctime(28/4/2008 00:00:00) - $ctime($date $time)) < 0) {
; %saystyle Competition Finished. 7#1 Aasiwat07 (07775,749) 07#2 Xx_Kingio_Xx07 (07614,295) 07#3 Rinaldi1507 (07596,460) 07#4 Vexen56707 (07514,820) 07#5 Roger_Al07 (07414,208)
; }
;}
on $*:TEXT:/^[!@.]rccompadmin */Si:#: {
var %saystyle = $iif($left($1,1) == @,.msg $chan,.notice $nick)
%saystyle There are07 $numtok($readini(rccomp.ini,member,admin),124) RC Comp Admin:07 $replace($gettok($replace($readini(rccomp.ini,member,admin),$chr(124),$+($chr(44),$chr(32))),1-35,44),$chr(44),$+(,$chr(44),07))
if ($gettok($replace($readini(rccomp.ini,member,admin),$chr(124),$+($chr(44),$chr(32))),36,44)) { %saystyle $replace($gettok($replace($readini(rccomp.ini,member,admin),$chr(124),$+($chr(44),$chr(32))),36-70,44),$chr(44),$+(,$chr(44),07)) }
if ($gettok($replace($readini(rccomp.ini,member,admin),$chr(124),$+($chr(44),$chr(32))),71,44)) { %saystyle $replace($gettok($replace($readini(rccomp.ini,member,admin),$chr(124),$+($chr(44),$chr(32))),71-106,44),$chr(44),$+(,$chr(44),07)) }
if ($gettok($replace($readini(rccomp.ini,member,admin),$chr(124),$+($chr(44),$chr(32))),107,44)) { %saystyle $replace($gettok($replace($readini(rccomp.ini,member,admin),$chr(124),$+($chr(44),$chr(32))),107-142,44),$chr(44),$+(,$chr(44),07)) }
}
on $*:TEXT:/^[!@.]rccomp */Si:#: {
var %saystyle = $iif($left($1,1) == @,.msg $chan,.notice $nick)
%saystyle There are07 $numtok($readini(rccomp.ini,member,nick),124) Competitors:07 $replace($gettok($replace($readini(rccomp.ini,member,nick),$chr(124),$+($chr(44),$chr(32))),1-25,44),$chr(44),$+(,$chr(44),07))
if ($gettok($replace($readini(rccomp.ini,member,nick),$chr(124),$+($chr(44),$chr(32))),26,44)) { %saystyle 07 $+ $replace($gettok($replace($readini(rccomp.ini,member,nick),$chr(124),$+($chr(44),$chr(32))),26-70,44),$chr(44),$+(,$chr(44),07)) }
if ($gettok($replace($readini(rccomp.ini,member,nick),$chr(124),$+($chr(44),$chr(32))),71,44)) { %saystyle $replace($gettok($replace($readini(rccomp.ini,member,nick),$chr(124),$+($chr(44),$chr(32))),71-106,44),$chr(44),$+(,$chr(44),07)) }
if ($gettok($replace($readini(rccomp.ini,member,nick),$chr(124),$+($chr(44),$chr(32))),107,44)) { %saystyle $replace($gettok($replace($readini(rccomp.ini,member,nick),$chr(124),$+($chr(44),$chr(32))),107-142,44),$chr(44),$+(,$chr(44),07)) }
}
alias rccomp {
if ($regex($1,$+(/^,$chr(40),$readini(rccomp.ini,member,rccomp),$chr(41),/i))) { return tracked }
}
alias rcxpgain { return $bytes($readini(rccomp.ini,%nick,$1),db) }
;on *:Join:#kingio: {
; if ($nick == $me) {
; var %x = $numtok($readini(rccomp.ini,member,nick),124)
; while (%x) {
; var %out = %out $readini(rccomp.ini,leaders,%x)
; dec %x
; }
; var %reply = $sortrc(%out)
; .msg $chan RC Leader Board: $gettok(%reply,1-30,32)
; var %x = $numtok($readini(rccomp.ini,member,nick),124)
; var %out = 0
; while (%x) {
; var %out = $calc(%out + $gettok($readini(rccomp.ini,leaders,%x),1,32))
; dec %x
; }
; .msg $chan Total Exp Gain:07 $bytes(%out,db)
; unset %*
; }
; if ($nick != $me) {
; var %x = $numtok($readini(rccomp.ini,member,nick),124)
; while (%x) {
; var %out = %out $readini(rccomp.ini,leaders,%x)
; dec %x
; }
; var %reply = $sortrc(%out)
; .notice $nick RC Leader Board: $gettok(%reply,1-30,32)
; unset %*
; }
;}
:END
