raw 334567897654323456719:*: {
set %channels $replace($remove($3-,+,%,@),$chr(32),$chr(44))
if (!%rclead) {
.timer 1 $calc((4* $numtok($readini(tracked.ini,tracked,nick),124) +1)) join %channels
.timer 1 $calc((4* $numtok($readini(tracked.ini,tracked,nick),124) +2)) unset %channels
}
if (%rclead) {
.timer 1 $calc((2* $numtok($readini(rccomp.ini,member,nick),124) +1)) join %channels
.timer 1 $calc((2* $numtok($readini(rccomp.ini,member,nick),124) +2)) unset %channels
}
unset %rclead
}
on $*:TEXT:/^[!@.]addtracker */Si:#: {
set %saystyle $iif($left($1,1) == @,.msg $chan,.notice $nick)
set %nick $replace($2-,$chr(32),_)
sockopen addtrack hiscore.runescape.com 80
}
on *:sockopen:addtrack: {
.sockwrite -n $sockname GET /index_lite.ws?player= $+ %nick HTTP/1.1
.sockwrite -n $sockname Host: hiscore.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:addtrack: {
if (%row == $null) { set %row 1 }
if ($sockerr) {
%saystyle [Socket Error] $sockname $time $script
halt
}
.sockread %stats
if (%row < 100) {
set % [ $+ [ %row ] ] %stats
inc %row 1
}
}
on *:sockclose:addtrack: {
if (* $+ %nick $+ * !iswm $readini(tracked.ini,tracked,nick)) {
if (%19) {
writeini tracked.ini tracked nick $+($readini(tracked.ini,tracked,nick),$chr(124),%nick)
sockopen $+(today.,%nick) hiscore.runescape.com 80
.timer 1 3 sockopen $+(week.,%nick) hiscore.runescape.com 80
.timer 1 6 sockopen $+(month.,%nick) hiscore.runescape.com 80
.timer 1 9 sockopen $+(year.,%nick) hiscore.runescape.com 80
.timer 1 12 %saystyle %nick added to tracker.
}
else { %saystyle 07 $+ %nick isn't a valid RSN }
}
else { %saystyle 07 $+ %nick already added to tracker }
unset %*
}
alias newday {
whois $me
amsg Update in progress. Back in Approx. $duration($calc($numtok($readini(tracked.ini,tracked,nick),124) * 4 +1))
join #0,0
var %update = 1
while (%update <= $numtok($readini(tracked.ini,tracked,nick),124)) {
.timer 1 $calc( %update * 4 ) sockopen $+(today.,$gettok($readini(tracked.ini,tracked,nick),%update,124)) hiscore.runescape.com 80
inc %update 1
}
}
on $*:TEXT:/^[!@.]topupdate */Si:#: {
if ($admin($nick) != admin) { Halt }
if ($2) {
if ($readini(rsn.ini,$address($replace($2-,$chr(32),_),3),rsn)) { set %nick $readini(rsn.ini,$address($replace($2-,$chr(32),_),3),rsn) }
if (!$readini(rsn.ini,$address($replace($2-,$chr(32),_),3),rsn)) { set %nick $capwords($replace($2-,$chr(32),_,-,_)) }
}
set %saystyle $iif($left($1,1) == @,msg $chan,notice $nick)
sockopen $+(today.,%nick) hiscore.runescape.com 80
}
on *:sockopen:today.*: {
if ($sockerr) {
%saystyle There was a socket error.
halt
}
.sockwrite -n $sockname GET /index_lite.ws?player= $+ $gettok($sockname,2,46) HTTP/1.1
.sockwrite -n $sockname Host: hiscore.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:today.*: {
if (%row == $null) { set %row 1 }
if ($sockerr) {
%saystyle [Socket Error] $sockname $time $script
halt
}
.sockread %today
if (%row < 100) {
set % [ $+ [ %row ] ] %today
if ($gettok(%today,2,44) == -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
if ($gettok(%today,2,44) != -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
inc %row 1
}
if (%row == 40) { updatetoday }
}
alias updatetoday {
if ($sockerr) {
%saystyle There was a socket error.
halt
}
var %x = 1,%y = 1
hadd -m $gettok($sockname,2,46) rankeds 0
while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
inc %x 1
}
set %unranked $round($calc(($gettok(%11,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
inc %y 1
}
if (!%11) { echo -t error for $gettok($sockname,2,46) }
writeini Yesterday.ini $gettok($sockname,2,46) Overall $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Overall),1,44) - $gettok(%11,1,44)) $+ , $+ $calc($gettok(%11,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Overall),2,44)) $+ , $+ $calc($gettok(%11,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Overall),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Attack $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Attack),1,44) - $gettok(%12,1,44)) $+ , $+ $calc($gettok(%12,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Attack),2,44)) $+ , $+ $calc($gettok(%12,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Attack),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Defence $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Defence),1,44) - $gettok(%13,1,44)) $+ , $+ $calc($gettok(%13,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Defence),2,44)) $+ , $+ $calc($gettok(%13,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Defence),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Strength $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Strength),1,44) - $gettok(%14,1,44)) $+ , $+ $calc($gettok(%14,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Strength),2,44)) $+ , $+ $calc($gettok(%14,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Strength),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Hitpoints $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Hitpoints),1,44) - $gettok(%15,1,44)) $+ , $+ $calc($gettok(%15,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Hitpoints),2,44)) $+ , $+ $calc($gettok(%15,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Hitpoints),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Ranged $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Ranged),1,44) - $gettok(%16,1,44)) $+ , $+ $calc($gettok(%16,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Ranged),2,44)) $+ , $+ $calc($gettok(%16,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Ranged),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Prayer $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Prayer),1,44) - $gettok(%17,1,44)) $+ , $+ $calc($gettok(%17,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Prayer),2,44)) $+ , $+ $calc($gettok(%17,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Prayer),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Magic $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Magic),1,44) - $gettok(%18,1,44)) $+ , $+ $calc($gettok(%18,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Magic),2,44)) $+ , $+ $calc($gettok(%18,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Magic),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Cooking $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Cooking),1,44) - $gettok(%19,1,44)) $+ , $+ $calc($gettok(%19,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Cooking),2,44)) $+ , $+ $calc($gettok(%19,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Cooking),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Woodcutting $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Woodcutting),1,44) - $gettok(%20,1,44)) $+ , $+ $calc($gettok(%20,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Woodcutting),2,44)) $+ , $+ $calc($gettok(%20,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Woodcutting),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Fletching $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Fletching),1,44) - $gettok(%21,1,44)) $+ , $+ $calc($gettok(%21,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Fletching),2,44)) $+ , $+ $calc($gettok(%21,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Fletching),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Fishing $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Fishing),1,44) - $gettok(%22,1,44)) $+ , $+ $calc($gettok(%22,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Fishing),2,44)) $+ , $+ $calc($gettok(%22,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Fishing),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Firemaking $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Firemaking),1,44) - $gettok(%23,1,44)) $+ , $+ $calc($gettok(%23,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Firemaking),2,44)) $+ , $+ $calc($gettok(%23,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Firemaking),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Crafting $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Crafting),1,44) - $gettok(%24,1,44)) $+ , $+ $calc($gettok(%24,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Crafting),2,44)) $+ , $+ $calc($gettok(%24,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Crafting),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Smithing $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Smithing),1,44) - $gettok(%25,1,44)) $+ , $+ $calc($gettok(%25,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Smithing),2,44)) $+ , $+ $calc($gettok(%25,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Smithing),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Mining $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Mining),1,44) - $gettok(%26,1,44)) $+ , $+ $calc($gettok(%26,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Mining),2,44)) $+ , $+ $calc($gettok(%26,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Mining),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Herblore $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Herblore),1,44) - $gettok(%27,1,44)) $+ , $+ $calc($gettok(%27,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Herblore),2,44)) $+ , $+ $calc($gettok(%27,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Herblore),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Agility $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Agility),1,44) - $gettok(%28,1,44)) $+ , $+ $calc($gettok(%28,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Agility),2,44)) $+ , $+ $calc($gettok(%28,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Agility),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Thieving $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Thieving),1,44) - $gettok(%29,1,44)) $+ , $+ $calc($gettok(%29,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Thieving),2,44)) $+ , $+ $calc($gettok(%29,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Thieving),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Slayer $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Slayer),1,44) - $gettok(%30,1,44)) $+ , $+ $calc($gettok(%30,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Slayer),2,44)) $+ , $+ $calc($gettok(%30,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Slayer),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Farming $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Farming),1,44) - $gettok(%31,1,44)) $+ , $+ $calc($gettok(%31,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Farming),2,44)) $+ , $+ $calc($gettok(%31,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Farming),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Runecraft $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Runecraft),1,44) - $gettok(%32,1,44)) $+ , $+ $calc($gettok(%32,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Runecraft),2,44)) $+ , $+ $calc($gettok(%32,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Runecraft),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Hunter $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Hunter),1,44) - $gettok(%33,1,44)) $+ , $+ $calc($gettok(%33,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Hunter),2,44)) $+ , $+ $calc($gettok(%33,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Hunter),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Construction $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Construction),1,44) - $gettok(%34,1,44)) $+ , $+ $calc($gettok(%34,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Construction),2,44)) $+ , $+ $calc($gettok(%34,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Construction),3,44))
writeini Yesterday.ini $gettok($sockname,2,46) Summoning $calc($gettok($readini(Today.ini,$gettok($sockname,2,46),Summoning),1,44) - $gettok(%35,1,44)) $+ , $+ $calc($gettok(%35,2,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Summoning),2,44)) $+ , $+ $calc($gettok(%35,3,44) - $gettok($readini(Today.ini,$gettok($sockname,2,46),Summoning),3,44))
;
writeini Today.ini $gettok($sockname,2,46) Overall %11
writeini Today.ini $gettok($sockname,2,46) Attack %12
writeini Today.ini $gettok($sockname,2,46) Defence %13
writeini Today.ini $gettok($sockname,2,46) Strength %14
writeini Today.ini $gettok($sockname,2,46) Hitpoints %15
writeini Today.ini $gettok($sockname,2,46) Ranged %16
writeini Today.ini $gettok($sockname,2,46) Prayer %17
writeini Today.ini $gettok($sockname,2,46) Magic %18
writeini Today.ini $gettok($sockname,2,46) Cooking %19
writeini Today.ini $gettok($sockname,2,46) Woodcutting %20
writeini Today.ini $gettok($sockname,2,46) Fletching %21
writeini Today.ini $gettok($sockname,2,46) Fishing %22
writeini Today.ini $gettok($sockname,2,46) Firemaking %23
writeini Today.ini $gettok($sockname,2,46) Crafting %24
writeini Today.ini $gettok($sockname,2,46) Smithing %25
writeini Today.ini $gettok($sockname,2,46) Mining %26
writeini Today.ini $gettok($sockname,2,46) Herblore %27
writeini Today.ini $gettok($sockname,2,46) Agility %28
writeini Today.ini $gettok($sockname,2,46) Thieving %29
writeini Today.ini $gettok($sockname,2,46) Slayer %30
writeini Today.ini $gettok($sockname,2,46) Farming %31
writeini Today.ini $gettok($sockname,2,46) Runecraft %32
writeini Today.ini $gettok($sockname,2,46) Hunter %33
writeini Today.ini $gettok($sockname,2,46) Construction %34
writeini Today.ini $gettok($sockname,2,46) Summoning %35
hfree $gettok($sockname,2,46)
unset %*
}
alias newweek {
set %trackerout $iif($left($1,1) == @,.msg $chan,.notice $nick)
whois $me
amsg Update in progress. Back in Approx. $duration($calc($numtok($readini(tracked.ini,tracked,nick),124) * 4 +1))
join #0,0
var %update = 1
while (%update <= $numtok($readini(tracked.ini,tracked,nick),124)) {
.timer 1 $calc( %update * 4 ) sockopen $+(week.,$gettok($readini(tracked.ini,tracked,nick),%update,124)) hiscore.runescape.com 80
inc %update 1
}
}
on $*:TEXT:/^[!@.]updateweek */Si:#: {
if ($admin($nick) != admin) { Halt }
if ($2) {
if ($readini(rsn.ini,$address($replace($2-,$chr(32),_),3),rsn)) { set %nick $readini(rsn.ini,$address($replace($2-,$chr(32),_),3),rsn) }
if (!$readini(rsn.ini,$address($replace($2-,$chr(32),_),3),rsn)) { set %nick $capwords($replace($2-,$chr(32),_,-,_)) }
}
set %saystyle = $iif($left($1,1) == @,msg $chan,notice $nick)
sockopen $+(week.,%nick) hiscore.runescape.com 80
}
on *:sockopen:week.*: {
.sockwrite -n $sockname GET /index_lite.ws?player= $+ $gettok($sockname,2,46) HTTP/1.1
.sockwrite -n $sockname Host: hiscore.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:week.*: {
if (%row == $null) { set %row 1 }
if ($sockerr) {
%saystyle [Socket Error] $sockname $time $script
halt
}
.sockread %week
if (%row < 100) {
set % [ $+ [ %row ] ] %week
if ($gettok(%week,2,44) == -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
if ($gettok(%week,2,44) != -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
inc %row 1
}
if (%row == 40) { updateweek }
}
alias updateweek {
var %x = 1,%y = 1
hadd -m $gettok($sockname,2,46) rankeds 0
while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
inc %x 1
}
var %unranked = $round($calc(($gettok(%11,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
inc %y 1
}
if (!%11) { echo -t error for $gettok($sockname,2,46) }
writeini lastweek.ini $gettok($sockname,2,46) Overall $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),1,44) - $gettok(%11,1,44)) $+ , $+ $calc($gettok(%11,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),2,44)) $+ , $+ $calc($gettok(%11,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),3,44))
writeini lastweek.ini $gettok($sockname,2,46) Attack $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),1,44) - $gettok(%12,1,44)) $+ , $+ $calc($gettok(%12,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),2,44)) $+ , $+ $calc($gettok(%12,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),3,44))
writeini lastweek.ini[ $+ [ %row ] ] %week
if ($gettok(%week,2,44) == -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
if ($gettok(%week,2,44) != -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
inc %row 1
}
if (%row == 40) { updateweek }
}
alias updateweek {
var %x = 1,%y = 1
hadd -m $gettok($sockname,2,46) rankeds 0
while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
inc %x 1
}
var %unranked = $round($calc(($gettok(%11,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
inc %y 1
}
if (!%11) { echo -t error for $gettok($sockname,2,46) }
writeini lastweek.ini $gettok($sockname,2,46) Overall $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),1,44) - $gettok(%11,1,44)) $+ , $+ $calc($gettok(%11,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),2,44)) $+ , $+ $calc($gettok(%11,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),3,44))
writeini lastweek.ini $gettok($sockname,2,46) Attack $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),1,44) - $gettok(%12,1,44)) $+ , $+ $calc($gettok(%12,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),2,44)) $+ , $+ $calc($gettok(%12,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),3,44))
writeini lastweek.ini[ $+ [ %row ] ] %week
if ($gettok(%week,2,44) == -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
if ($gettok(%week,2,44) != -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
inc %row 1
}
if (%row == 40) { updateweek }
}
alias updateweek {
var %x = 1,%y = 1
hadd -m $gettok($sockname,2,46) rankeds 0
while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
inc %x 1
}
var %unranked = $round($calc(($gettok(%11,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
inc %y 1
}
if (!%11) { echo -t error for $gettok($sockname,2,46) }
writeini lastweek.ini $gettok($sockname,2,46) Overall $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),1,44) - $gettok(%11,1,44)) $+ , $+ $calc($gettok(%11,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),2,44)) $+ , $+ $calc($gettok(%11,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),3,44))
writeini lastweek.ini $gettok($sockname,2,46) Attack $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),1,44) - $gettok(%12,1,44)) $+ , $+ $calc($gettok(%12,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),2,44)) $+ , $+ $calc($gettok(%12,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),3,44))
writeini lastweek.ini[ $+ [ %row ] ] %week
if ($gettok(%week,2,44) == -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
if ($gettok(%week,2,44) != -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
inc %row 1
}
if (%row == 40) { updateweek }
}
alias updateweek {
var %x = 1,%y = 1
hadd -m $gettok($sockname,2,46) rankeds 0
while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
inc %x 1
}
var %unranked = $round($calc(($gettok(%11,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
inc %y 1
}
if (!%11) { echo -t error for $gettok($sockname,2,46) }
writeini lastweek.ini $gettok($sockname,2,46) Overall $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),1,44) - $gettok(%11,1,44)) $+ , $+ $calc($gettok(%11,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),2,44)) $+ , $+ $calc($gettok(%11,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),3,44))
writeini lastweek.ini $gettok($sockname,2,46) Attack $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),1,44) - $gettok(%12,1,44)) $+ , $+ $calc($gettok(%12,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),2,44)) $+ , $+ $calc($gettok(%12,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),3,44))
writeini lastweek.ini[ $+ [ %row ] ] %week
if ($gettok(%week,2,44) == -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
if ($gettok(%week,2,44) != -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
inc %row 1
}
if (%row == 40) { updateweek }
}
alias updateweek {
var %x = 1,%y = 1
hadd -m $gettok($sockname,2,46) rankeds 0
while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
inc %x 1
}
var %unranked = $round($calc(($gettok(%11,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
inc %y 1
}
if (!%11) { echo -t error for $gettok($sockname,2,46) }
writeini lastweek.ini $gettok($sockname,2,46) Overall $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),1,44) - $gettok(%11,1,44)) $+ , $+ $calc($gettok(%11,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),2,44)) $+ , $+ $calc($gettok(%11,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),3,44))
writeini lastweek.ini $gettok($sockname,2,46) Attack $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),1,44) - $gettok(%12,1,44)) $+ , $+ $calc($gettok(%12,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),2,44)) $+ , $+ $calc($gettok(%12,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),3,44))
writeini lastweek.ini[ $+ [ %row ] ] %week
if ($gettok(%week,2,44) == -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
if ($gettok(%week,2,44) != -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
inc %row 1
}
if (%row == 40) { updateweek }
}
alias updateweek {
var %x = 1,%y = 1
hadd -m $gettok($sockname,2,46) rankeds 0
while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
inc %x 1
}
var %unranked = $round($calc(($gettok(%11,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
inc %y 1
}
if (!%11) { echo -t error for $gettok($sockname,2,46) }
writeini lastweek.ini $gettok($sockname,2,46) Overall $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),1,44) - $gettok(%11,1,44)) $+ , $+ $calc($gettok(%11,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),2,44)) $+ , $+ $calc($gettok(%11,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),3,44))
writeini lastweek.ini $gettok($sockname,2,46) Attack $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),1,44) - $gettok(%12,1,44)) $+ , $+ $calc($gettok(%12,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),2,44)) $+ , $+ $calc($gettok(%12,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),3,44))
writeini lastweek.ini[ $+ [ %row ] ] %week
if ($gettok(%week,2,44) == -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
if ($gettok(%week,2,44) != -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
inc %row 1
}
if (%row == 40) { updateweek }
}
alias updateweek {
var %x = 1,%y = 1
hadd -m $gettok($sockname,2,46) rankeds 0
while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
inc %x 1
}
var %unranked = $round($calc(($gettok(%11,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
inc %y 1
}
if (!%11) { echo -t error for $gettok($sockname,2,46) }
writeini lastweek.ini $gettok($sockname,2,46) Overall $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),1,44) - $gettok(%11,1,44)) $+ , $+ $calc($gettok(%11,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),2,44)) $+ , $+ $calc($gettok(%11,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),3,44))
writeini lastweek.ini $gettok($sockname,2,46) Attack $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),1,44) - $gettok(%12,1,44)) $+ , $+ $calc($gettok(%12,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),2,44)) $+ , $+ $calc($gettok(%12,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),3,44))
writeini lastweek.ini[ $+ [ %row ] ] %week
if ($gettok(%week,2,44) == -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
if ($gettok(%week,2,44) != -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
inc %row 1
}
if (%row == 40) { updateweek }
}
alias updateweek {
var %x = 1,%y = 1
hadd -m $gettok($sockname,2,46) rankeds 0
while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
inc %x 1
}
var %unranked = $round($calc(($gettok(%11,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
inc %y 1
}
if (!%11) { echo -t error for $gettok($sockname,2,46) }
writeini lastweek.ini $gettok($sockname,2,46) Overall $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),1,44) - $gettok(%11,1,44)) $+ , $+ $calc($gettok(%11,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),2,44)) $+ , $+ $calc($gettok(%11,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),3,44))
writeini lastweek.ini $gettok($sockname,2,46) Attack $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),1,44) - $gettok(%12,1,44)) $+ , $+ $calc($gettok(%12,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),2,44)) $+ , $+ $calc($gettok(%12,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),3,44))
writeini lastweek.ini[ $+ [ %row ] ] %week
if ($gettok(%week,2,44) == -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
if ($gettok(%week,2,44) != -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
inc %row 1
}
if (%row == 40) { updateweek }
}
alias updateweek {
var %x = 1,%y = 1
hadd -m $gettok($sockname,2,46) rankeds 0
while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
inc %x 1
}
var %unranked = $round($calc(($gettok(%11,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
inc %y 1
}
if (!%11) { echo -t error for $gettok($sockname,2,46) }
writeini lastweek.ini $gettok($sockname,2,46) Overall $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),1,44) - $gettok(%11,1,44)) $+ , $+ $calc($gettok(%11,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),2,44)) $+ , $+ $calc($gettok(%11,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),3,44))
writeini lastweek.ini $gettok($sockname,2,46) Attack $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),1,44) - $gettok(%12,1,44)) $+ , $+ $calc($gettok(%12,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),2,44)) $+ , $+ $calc($gettok(%12,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),3,44))
writeini lastweek.ini[ $+ [ %row ] ] %week
if ($gettok(%week,2,44) == -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
if ($gettok(%week,2,44) != -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
inc %row 1
}
if (%row == 40) { updateweek }
}
alias updateweek {
var %x = 1,%y = 1
hadd -m $gettok($sockname,2,46) rankeds 0
while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
inc %x 1
}
var %unranked = $round($calc(($gettok(%11,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
inc %y 1
}
if (!%11) { echo -t error for $gettok($sockname,2,46) }
writeini lastweek.ini $gettok($sockname,2,46) Overall $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),1,44) - $gettok(%11,1,44)) $+ , $+ $calc($gettok(%11,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),2,44)) $+ , $+ $calc($gettok(%11,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),3,44))
writeini lastweek.ini $gettok($sockname,2,46) Attack $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),1,44) - $gettok(%12,1,44)) $+ , $+ $calc($gettok(%12,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),2,44)) $+ , $+ $calc($gettok(%12,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),3,44))
writeini lastweek.ini[ $+ [ %row ] ] %week
if ($gettok(%week,2,44) == -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
if ($gettok(%week,2,44) != -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
inc %row 1
}
if (%row == 40) { updateweek }
}
alias updateweek {
var %x = 1,%y = 1
hadd -m $gettok($sockname,2,46) rankeds 0
while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
inc %x 1
}
var %unranked = $round($calc(($gettok(%11,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
inc %y 1
}
if (!%11) { echo -t error for $gettok($sockname,2,46) }
writeini lastweek.ini $gettok($sockname,2,46) Overall $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),1,44) - $gettok(%11,1,44)) $+ , $+ $calc($gettok(%11,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),2,44)) $+ , $+ $calc($gettok(%11,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),3,44))
writeini lastweek.ini $gettok($sockname,2,46) Attack $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),1,44) - $gettok(%12,1,44)) $+ , $+ $calc($gettok(%12,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),2,44)) $+ , $+ $calc($gettok(%12,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),3,44))
writeini lastweek.ini[ $+ [ %row ] ] %week
if ($gettok(%week,2,44) == -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
if ($gettok(%week,2,44) != -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
inc %row 1
}
if (%row == 40) { updateweek }
}
alias updateweek {
var %x = 1,%y = 1
hadd -m $gettok($sockname,2,46) rankeds 0
while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
inc %x 1
}
var %unranked = $round($calc(($gettok(%11,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
inc %y 1
}
if (!%11) { echo -t error for $gettok($sockname,2,46) }
writeini lastweek.ini $gettok($sockname,2,46) Overall $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),1,44) - $gettok(%11,1,44)) $+ , $+ $calc($gettok(%11,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),2,44)) $+ , $+ $calc($gettok(%11,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),3,44))
writeini lastweek.ini $gettok($sockname,2,46) Attack $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),1,44) - $gettok(%12,1,44)) $+ , $+ $calc($gettok(%12,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),2,44)) $+ , $+ $calc($gettok(%12,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),3,44))
writeini lastweek.ini[ $+ [ %row ] ] %week
if ($gettok(%week,2,44) == -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
if ($gettok(%week,2,44) != -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
inc %row 1
}
if (%row == 40) { updateweek }
}
alias updateweek {
var %x = 1,%y = 1
hadd -m $gettok($sockname,2,46) rankeds 0
while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
inc %x 1
}
var %unranked = $round($calc(($gettok(%11,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
inc %y 1
}
if (!%11) { echo -t error for $gettok($sockname,2,46) }
writeini lastweek.ini $gettok($sockname,2,46) Overall $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),1,44) - $gettok(%11,1,44)) $+ , $+ $calc($gettok(%11,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),2,44)) $+ , $+ $calc($gettok(%11,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),3,44))
writeini lastweek.ini $gettok($sockname,2,46) Attack $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),1,44) - $gettok(%12,1,44)) $+ , $+ $calc($gettok(%12,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),2,44)) $+ , $+ $calc($gettok(%12,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),3,44))
writeini lastweek.ini[ $+ [ %row ] ] %week
if ($gettok(%week,2,44) == -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) unranked $hget($gettok($sockname,2,46),unranked) $+ $+(|,%row) }
if ($gettok(%week,2,44) != -1 && %row < 37 && %row > 12) { hadd -m $gettok($sockname,2,46) ranked $hget($gettok($sockname,2,46),ranked) $+ $+(|,%row) }
inc %row 1
}
if (%row == 40) { updateweek }
}
alias updateweek {
var %x = 1,%y = 1
hadd -m $gettok($sockname,2,46) rankeds 0
while (%x <= $numtok($hget($gettok($sockname,2,46),ranked),124)) {
hadd -m $gettok($sockname,2,46) rankeds $calc($hget($gettok($sockname,2,46),rankeds) + $gettok(% [ $+ [ $gettok($hget($gettok($sockname,2,46),ranked),%x,124) ] ],2,44))
inc %x 1
}
var %unranked = $round($calc(($gettok(%11,2,44) - $hget($gettok($sockname,2,46),rankeds))/$numtok($hget($gettok($sockname,2,46),unranked),124)),0)
while (%y <= $numtok($hget($gettok($sockname,2,46),unranked),124)) {
set % [ $+ [ $gettok($hget($gettok($sockname,2,46),unranked),%y,124) ] ] Unranked $+ , $+ %unranked $+ , $+ $readini(exp.ini,lvl,%unranked)
inc %y 1
}
if (!%11) { echo -t error for $gettok($sockname,2,46) }
writeini lastweek.ini $gettok($sockname,2,46) Overall $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),1,44) - $gettok(%11,1,44)) $+ , $+ $calc($gettok(%11,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),2,44)) $+ , $+ $calc($gettok(%11,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Overall),3,44))
writeini lastweek.ini $gettok($sockname,2,46) Attack $calc($gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),1,44) - $gettok(%12,1,44)) $+ , $+ $calc($gettok(%12,2,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),2,44)) $+ , $+ $calc($gettok(%12,3,44) - $gettok($readini(Week.ini,$gettok($sockname,2,46),Attack),3,44))
writeini lastweek.ini
