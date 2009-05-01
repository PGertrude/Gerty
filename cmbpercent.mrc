on $*:TEXT:/^([!@.](%|cmb%|combat%|p2p%|f2p%|sl%|slay%|slayer%|skill%|pc%|pest%|pestcontrol%|skiller%)|%)( |$)/Si:*: {
var %thread = $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9)), %nick, %saystyle
if ($2) %nick = $rsn($regsubex($2-,/\W/g,_))
if (!$2) %nick = $rsn($regsubex($nick,/\W/g,_))
%saystyle = $saystyle($left($1,1),$nick,$chan)
var %socket = spam. $+ %thread
var %url = http://hiscore.runescape.com/index_lite.ws?player= $+ %nick
noop $download.break(cmbpercent %saystyle %nick %socket, %socket, %url)
}
alias cmbpercent {
var %saystyle = $1 $2, %nick = $3, %socket = $4
.tokenize 10 $distribute($5)
if ($1 == unranked) { %saystyle  $+ %nick $+  does not feature Hiscores | halt }
; Standard
var %cmblvl = $calccombat($gettok($2,2,44),$gettok($3,2,44),$gettok($4,2,44),$gettok($5,2,44),$gettok($6,2,44),$gettok($7,2,44),$gettok($8,2,44),$gettok($25,2,44)).p2p
var %combatexp = 0
var %x = 2
while (%x <= 8) {
var %combatexp = $calc(%combatexp + $gettok($($ $+ %x,2),3,44))
inc %x
}
var %combatexp = $calc(%combatexp + $gettok($25,3,44))
set %cmb 0, $+ %cmblvl $+ , $+ %combatexp
var %avg = $iif(%state == 4,$round($calc($gettok($1,4,44) /24),1),$regsubex($gettok($1,2,44),/(\d+)/,$round($calc(\1 / 24),1))))
; F2P Exp
var %f2pxp = $calc( $gettok($2,3,44) + $gettok($3,3,44) + $gettok($4,3,44) + $gettok($5,3,44) + $gettok($6,3,44) + $gettok($7,3,44) + $gettok($8,3,44) + $gettok($9,3,44) + $gettok($10,3,44) + $gettok($12,3,44) + $gettok($13,3,44) + $gettok($14,3,44) + $gettok($15,3,44) + $gettok($16,3,44) + $gettok($22,3,44) )
; PC% calc
var %current = $calc($gettok($2,3,44) + $gettok($3,3,44) + $gettok($4,3,44) + $gettok($5,3,44) + $gettok($6,3,44))
var %expected = $calc($gettok($5,3,44) + $gettok($5,3,44) * 12 / 4 )
var %pc = $calc(%expected / %current * 100)
; Slayer% calc
var %slaybasedcmb = $calc( (($gettok($20,3,44) * 4 / 3)/ $gettok($5,3,44) )*100)
; Output
%saystyle Statistic Percentages for07 %nick | Total Exp:07 $bytes($gettok($1,3,44),db) | Combat Exp:07 $bytes(%combatexp,db) | F2P Exp:07 $bytes(%f2pxp,db) | Combat%07 $round($calc((%combatexp / $gettok($1,3,44))*100),1) $+ % | $&
F2P%07 $round($calc((%f2pxp / $gettok($1,3,44))*100),1) $+ % | Slay%07 $round(%slaybasedcmb,1) $+ % | PC%07 $round($calc(100-%pc),2) $+ %
}
; old stuff, incase I feel like remaking skiller%
on *:sockclose:skiller.*: {
var %skill99 = $calc($ni(%19) $ni(%20) $ni(%21) $ni(%22) $ni(%23) $ni(%24) $ni(%25) $ni(%26) $ni(%27) $ni(%28) $ni(%29) $ni(%30) $ni(%31) $ni(%32) $ni(%33) $ni(%34) 0)
var %cmb99 = $calc($ni(%12) $ni(%13) $ni(%14) $ni(%15) $ni(%16) $ni(%17) $ni(%18) $ni(%35))
var %ranksum = $calc($rank(%19) $rank(%20) $rank(%21) $rank(%22) $rank(%23) $rank(%24) $rank(%25) $rank(%26) $rank(%27) $rank(%28) $rank(%29) $rank(%30) $rank(%31) $rank(%32) $rank(%33) $rank(%34) $rank(%12) $rank(%13) $rank(%14) $rank(%15) $rank(%16) $rank(%17) $rank(%18) $rank(%35) 0)
if ($ssreq.skill1($cmbreq($gettok(%cmb,2,44))) == Yes) { inc %skills 25 }
if ($ssreq.skill2($cmbreq($gettok(%cmb,2,44))) == Yes) { inc %skills 25 }
if ($gettok(%11,3,44) > 100000000) { inc %skills 2 }
if ($gettok(%11,3,44) > 200000000) { inc %skills 5 }
if ($gettok(%11,2,44) > 2200) { inc %skills 10 }
if ($gettok(%11,2,44) > 2300) { inc %skills 5 }
if ($calc(%skill99 / %cmb99) >= 1) { inc %skills 5 }
if ($calc(%skill99 / %cmb99) >= 2) { inc %skills 5 }
if (%stand < 10) { inc %skills 3 }
if ($gettok(%32,2,44) > 90) { inc %skills 0.5 }
if ($gettok(%30,2,44) > 90) { inc %skills 0.5 }
if ($gettok(%26,2,44) > 90) { inc %skills 0.5 }
if ($gettok(%20,2,44) > 90) { inc %skills 0.5 }
if ($gettok(%22,2,44) > 90) { inc %skills 0.5 }
if ($gettok(%28,2,44) > 90) { inc %skills 0.5 }
if ($gettok(%31,2,44) > 90) { inc %skills 0.5 }
inc %skills $calc(%ranksum / 2.086957)
var %skillxp = $calc( $gettok(%19,3,44) + $gettok(%20,3,44) + $gettok(%21,3,44) + $gettok(%22,3,44) + $gettok(%23,3,44) + $gettok(%24,3,44) + $gettok(%25,3,44) + $gettok(%26,3,44) + $gettok(%27,3,44) + $gettok(%28,3,44) + $gettok(%29,3,44) + $gettok(%30,3,44) + $gettok(%31,3,44) + $gettok(%32,3,44) + $gettok(%33,3,44) + $gettok(%34,3,44) )
:unset
unset %*
.hfree $gettok($sockname,2,46)
}
alias ni {
if ($gettok($1,2,44) == 99) { return 1 + }
}
alias rank {
if ($gettok($1,1,44) < 3000) { return 1 + }
}
