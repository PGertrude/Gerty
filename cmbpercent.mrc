on $*:TEXT:/^([!@.](%|cmb%|combat%|p2p%|f2p%|sl%|slay%|slayer%|skill%|pc%|pest%|pestcontrol%|skiller%)|%)( |$)/Si:*: {
  var %thread = $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9)), %nick, %saystyle
  if ($2) %nick = $rsn($2-)
  if (!$2) %nick = $rsn($nick)
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
