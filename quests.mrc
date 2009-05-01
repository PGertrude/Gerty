on $*:TEXT:/^[!@.]quest */Si:#: {
var %class = $+($r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
var %saystyle = $saystyle($left($1,1),$nick,$chan)
if (!$2) { %saystyle Syntax Error: !quest #<id> or !quest [-t] <search> | halt }
hadd -m $+(a,%class) out %saystyle
if ($2 == -t) {
hadd -m $+(a,%class) search $replace($3-,$chr(32),+)
hadd -m $+(a,%class) switch yes
sockopen $+(rs2quest.a,%class) www.tip.it 80
}
elseif ($2 !isnum && $left($2,1) != $chr(35)) {
hadd -m $+(a,%class) search $2-
sockopen $+(rs2quest.a,%class) www.tip.it 80
}
else {
hadd -m $+(a,%class) id $remove($2,$chr(35))
sockopen $+(rs2questinfo.a,%class) www.tip.it 80
}
}
on *:sockopen:rs2quest.*: {
if ($sockerr) {
$right($hget($gettok($sockname,2,46),out),-1) [Socket Error] $sockname $time $script
halt
}
.sockwrite -n $sockname GET /runescape/index.php?rs2quest=&orderby=&keywords= $+ $iif($hget($gettok($sockname,2,46),switch),$hget($gettok($sockname,2,46),search)) $+ &difficulty=&members= HTTP/1.0
.sockwrite -n $sockname Host: www.tip.it $+ $crlf $+ $crlf
}
on *:sockread:rs2quest.*: {
if ($sockerr) {
$right($hget($gettok($sockname,2,46),out),-1) [Socket Error] $sockname $time $script
halt
}
.sockread %quest
if ($hget($gettok($sockname,2,46),switch)) {
if (rs2quest_id= isin %quest) {
var %regex = $regex(%quest,/rs2quest_id=(\d+)/)
%output = %output 07# $+ $regml(1) $+  $nohtml(%quest) $+ ;
}
}
else {
if ($regex(quest,%quest,/<.+?quest_id=(\d+)">(.+?)</i)) {
if ($+(*,$hget($gettok($sockname,2,46),search),*) iswm $regml(quest,2)) {
set %output %output $+(07,$chr(35),$regml(quest,1), $regml(quest,2),;)
}
}
}
if (Save Done isin %quest) {
if ($count(%output,$chr(35)) < 1) {
$hget($gettok($sockname,2,46),out) No results for "07 $+ $replace($hget($gettok($sockname,2,46),search),+,$chr(32)) $+ ". Visit12 http://www.tip.it/runescape/?rs2quest
.hfree $gettok($sockname,2,46)
}
else if ($count(%output,$chr(35)) == 1) {
hadd -m $gettok($sockname,2,46) id $regsubex(%output,/#(\d+)\D.+?$/S,\1)
sockopen $+(rs2questinfo.,$gettok($sockname,2,46)) www.tip.it 80
}
else {
$hget($gettok($sockname,2,46),out) Quests found for "07 $+ $replace($hget($gettok($sockname,2,46),search),+,$chr(32)) $+ ": %output
.hfree $gettok($sockname,2,46)
}
unset %*
sockclose $sockname
halt
}
}
;######################
;##### quest info #####
;######################
on *:sockopen:rs2questinfo.*: {
if ($sockerr) {
$right($hget($gettok($sockname,2,46),out),-1) [Socket Error] $sockname $time $script
halt
}
.sockwrite -n $sockname GET /runescape/index.php?rs2quest_id= $+ $hget($gettok($sockname,2,46),id) HTTP/1.0
.sockwrite -n $sockname Host: www.tip.it $+ $crlf $+ $crlf
}
on *:sockread:rs2questinfo.*: {
if ($sockerr) {
$right($hget($gettok($sockname,2,46),out),-1) [Socket Error] $sockname $time $script
halt
}
.sockread %quest
if ($regex(%quest,/\s*<td colspan="\d+" class="databasebig">(.+?)<\/td>/)) {
%title = $regml(1)
}
if (<b>Reward:</b> isin %quest) {
%store = 1
}
if (%store == 1) {
%reward = %reward $nohtml(%quest) $+ $iif(%reward,;)
if (Quest points gained on completion isin %quest) {
%store = 0
$hget($gettok($sockname,2,46),out) %title 12http://tip.it/runescape/index.php?rs2quest_id= $+ $hget($gettok($sockname,2,46),id)
$hget($gettok($sockname,2,46),out) $regsubex(%reward,/(Reward:) (.+?) Quest points gained on completion: (\d+)(.+?)$/i,\1 \2 QP: $+(07,\3,))
sockclose $sockname
unset %*
halt
}
}
}
:END
