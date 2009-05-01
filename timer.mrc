on $*:TEXT:/^[!@.](start|check|end|stop)\b/Si:*: {
var %thread = $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9)), %command
if ($regml(1) == start) { %command = start }
else if ($regml(1) == check) { %command = check }
else { %command = end }
var %saystyle = $saystyle($left($1,1),$nick,$chan), %nick, %skill
var %x = 2, %input
while (%x < $0) {
%input = %input $($ $+ %x,2)
inc %x
}
if ($skills($2) != nomatch && $skills($2) && $3) { %skill = $skills($2) | %nick = $regsubex($3-,/\W/g,_) }
else if ($skills($($ $+ $0,2)) && $skills($($ $+ $0,2)) != nomatch && $3) { %skill = $skills($($ $+ $0,2)) | %nick = $regsubex(%input,/\W/g,_) }
else if ($2 && (!$skills($($ $+ $0,2)) || $skills($($ $+ $0,2)) == nomatch)) { %nick = $regsubex($2-,/\W/g,_) | %skill = Overall }
else if ($2) { %nick = $regsubex($nick,/\W/g,_) | %skill = $skills($2) }
else { %nick = $regsubex($nick,/\W/g,_) | %skill = Overall }
%nick = $rsn(%nick)
%skill = $skills(%skill)
if (%command == start) {
if (($readini(timer.ini,%nick,start) && $readini(timer.ini,%nick,start) != 0)) {
%saystyle You must end your current timer (07 $+ $readini(timer.ini,%nick,skill) $+ ) before starting a new one.
halt
}
writeini timer.ini %nick owner $rsn($nick)
}
else if (%command == check) {
if (!$readini(timer.ini,%nick,start)) {
%saystyle You have to start a timer before you can check your progress!07 !start <skill> <nick> to start one.
halt
}
}
else {
if (!$readini(timer.ini,%nick,start)) {
%saystyle You do not have a timer started!07 !start <skill> <nick> to start one.
halt
}
if ($readini(timer.ini,%nick,owner) != $rsn($regsubex($nick,/\W/g,_))) {
%saystyle This is not your timer to end!
halt
}
}
var %skillid = $statnum(%skill)
var %socket = %thread
var %url = http://hiscore.runescape.com/index_lite.ws?player= $+ %nick
noop $download.break(timer. $+ %command %saystyle %skill %skillid %nick,%socket,%url)
}
alias timer.start {
var %saystyle = $1 $2, %skill = $3, %skillid = $4, %nick = $caps($5)
.tokenize 10 $distribute($6)
if ($1 == unranked) { goto unranked }
else if (!$1) { %saystyle Connection Error: Please try again in a few moments. | goto unset }
.tokenize 44 $($ $+ %skillid,2)
; save start
writeini timer.ini %nick skill %skill
writeini timer.ini %nick start $3
writeini timer.ini %nick starttime $ctime($date $time)
; output
%saystyle  $+ %nick $+ 's starting experience of07 $bytes($3,db) in  $+ %skill $+  has been saved.
goto unset
:unranked
%saystyle  $+ %nick $+  does not feature Hiscores.
:unset
}
alias timer.check {
var %saystyle = $1 $2, %nick = $5
var %skill = $readini(timer.ini,%nick,skill), %skillid = $statnum(%skill)
.tokenize 10 $distribute($6)
if ($1 == unranked) { goto unranked }
else if (!$1) { %saystyle Connection Error: Please try again in a few moments. | goto unset }
.tokenize 44 $($ $+ %skillid,2)
; changes
var %expchange = $calc($3 - $readini(timer.ini,%nick,start))
var %timechange = $calc($ctime($date $time) - $readini(timer.ini,%nick,starttime))
var %exp.hour = $calc( 3600 * %expchange / %timechange )
var %exp.second = $calc( %expchange / %timechange )
var %target = $lvlceil($3), %goal = $lvltoxp(%target)
; check for goal in skill
if ($userset(%nick,%skillid $+ goal)) {
%goal = $v1
%target = $userset(%nick,%skillid $+ target)
}
; output
%saystyle  $+ %nick $+  gained07 $bytes(%expchange,db)  $+ %skill $+  experience in07 $duration(%timechange) $+ . That's07 $bytes($round(%exp.hour,0),db) exp/hour so far. $&
Estimated time till %target $+ :07 $iif(%exp.hour == 0,Infinite,$duration($calc( (%goal - $3) / %exp.second )))
:unset
}
alias timer.end {
var %saystyle = $1 $2, %nick = $5
var %skill = $readini(timer.ini,%nick,skill), %skillid = $statnum(%skill)
.tokenize 10 $distribute($6)
if ($1 == unranked) { goto unranked }
else if (!$1) { %saystyle Connection Error: Please try again in a few moments. | goto unset }
.tokenize 44 $($ $+ %skillid,2)
; changes
var %expchange = $calc($3 - $readini(timer.ini,%nick,start))
var %timechange = $calc($ctime($date $time) - $readini(timer.ini,%nick,starttime))
var %exp.hour = $calc( 3600 * %expchange / %timechange )
var %exp.second = $calc( %expchange / %timechange )
var %target = $lvlceil($3), %goal = $lvltoxp(%target)
; check for goal in skill
if ($userset(%nick,%skillid $+ goal)) {
%goal = $v1
%target = $userset(%nick,%skillid $+ target)
}
; output
%saystyle  $+ %nick $+  gained07 $bytes(%expchange,db)  $+ %skill $+  experience in07 $duration(%timechange) $+ . That's07 $bytes($round(%exp.hour,0),db) exp/hour. $&
Estimated time till %target $+ :07 $iif(%exp.hour == 0,Infinite,$duration($calc( (%goal - $3) / %exp.second )))
remini timer.ini %nick
:unset
}
