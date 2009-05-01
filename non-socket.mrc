on *:TEXT:*:*: {
if ($1 == raw) {
if (!$admin($nick)) { halt }
[ [ $2- ] ]
goto clean
}
if (!$regex($left($1,1),/[.!@]/)) { halt }
var %saystyle = $saystyle($left($1,1),$nick,$chan)
var %thread = $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
if ($regex($1,/^[!@.](def|set)(name|rsn)$/Si)) {
if ($regsubex($2-,/\W/,_) isin $readini(tracked.ini,tracked,admin)) { %saystyle This RSN is protected, please Contact an Admin if this is your RSN. | halt }
if ($2) {
var %nick = $caps($regsubex($left($2-,12),/\W/g,_))
writeini -n rsn.ini $address($nick,3) rsn %nick
writeini -n rsn.ini $regsubex($nick,/\W/g,_) rsn %nick
%saystyle Your default RuneScape name is now %nick $+ . This RSN is associated with the address $address($nick,3) $+ , and the User $nick $+ .
}
if (!$2) {
writeini -n rsn.ini $address($nick,3) rsn $caps($nick)
writeini -n rsn.ini $regsubex($nick,/\W/g,_) rsn $caps($regsubex($nick,/\W/g,_))
%saystyle Your default RuneScape name is now $caps($regsubex($nick,/\W/g,_)) $+ . This RSN is associated with the address $address($nick,3) $+ , and the User $nick $+ .
}
}
else if ($regex($1,/^[!@.](name|rsn|whois)$/Si)) {
var %nick = $regsubex($iif($right($2-,1) == &,$left($2-,-1),$2-),/\W/,_)
if ($2) {
if ($readini(rsn.ini,$address(%nick,3),rsn)) %saystyle 7 $+ $caps(%nick) $+ 's rsn is7 $rsn(%nick)
else {
if ($readini(rsn.ini,%nick,rsn)) %saystyle 7 $+ $caps(%nick) $+ 's rsn is7 $rsn(%nick)
else %saystyle No RSN for $2-
}
}
if (!$2) {
if ($readini(rsn.ini,$address($nick,3),rsn)) %saystyle 7 $+ $caps($nick) $+ 's rsn is7 $rsn($nick)
else {
if ($readini(rsn.ini,$nick,rsn)) %saystyle 7 $+ $caps($nick) $+ 's rsn is7 $rsn($nick)
else %saystyle No RSN for $nick
}
}
}
else if ($regex($1,/^[!@.]graph$/Si)) {
var %skill, %nick
if ($3) { %nick = $rsn($replace($3-,$chr(32),_)) }
else { %nick = $rsn($nick) }
if ($2) { %skill = $statnum($2) }
else { %skill = overall }
%saystyle $formatwith({0} 07{1} graph | 12http://t.rscript.org/graph-{0}.{2}.lvl.png | exp: 12http://t.rscript.org/graph-{0}.{2}.png | rank: 12http://t.rscript.org/graph-{0}.{2}.rank.png, %nick, %skill, $calc($statnum(%skill) -1))
goto clean
}
else if ($regex($1,/^[!@.]cmb-?est(imate)?$/Si)) {
%saystyle estimated combat level:07 $floor($calccombat($2,$3,$4,$5,$6,$7,$8,$9).p2p) (07 $+ $floor($calccombat($2,$3,$4,$5,$6,$7,$8,$9).f2p) $+ ) | class:07 $calccombat($2,$3,$4,$5,$6,$7,$8,$9).class | 04AD04SH03RP12MS: 04 $+ $2  $+ $3 04 $+ $4  $+ $5 03 $+ $6  $+ $7 12 $+ $8  $+ $9
goto clean
}
else if ($regex($1,/^[!@.]old(farmer|payment)$/Si)) {
var %param = $2-
var %info = $read(farming.txt, w,* $+ %param $+ *)
if ($2) { %saystyle Farming params07 $gettok(%info,1,9) | level Required:07 $gettok($gettok(%info,3,9),2,32) | experience:07 $gettok(%info,2,9) | payment:07 $gettok(%info,4,9) }
goto clean
}
else if ($regex($1,/^[!@.]f(uck)?my?l(ife)?$/Si)) {
if (!$2) { var %page = /random }
else { var %page = / $+ $remove($2,$chr(35)) }
hadd -m %thread page %page
hadd -m %thread out %saystyle
sockopen $+(fml.,%thread) www.fmylife.com 80
}
else if ($regex($1,/^[!@.]admindefname$/Si)) {
if (!$admin($nick)) { halt }
writeini -n rsn.ini $regsubex($2,/\W/g,_) rsn $caps($replace($3-,$chr(32),_,-,_))
writeini -n rsn.ini $address($2,3) rsn $caps($replace($3-,$chr(32),_,-,_))
%saystyle The default runescape name for $2 is now $caps($replace($3-,$chr(32),_,-,_)) $+ . This RSN is associated with the address $address($2,3) $+ , and the User $2 $+ .
goto clean
}
else if ($regex($1,/^[!@.]commands?$/Si)) {
%saystyle Commands Listing:07 http://www.gerty.x10hosting.com/commands.txt
goto clean
}
else if ($chan && $regex($1,/^[!@.]part$/Si)) {
if (($admin($nick) || $nick isop $chan || $nick ishop $chan) && ($2 == $me)) { part $chan Parted from07 $chan by07 $nick }
goto clean
}
else if ($chan && $regex($1,/^[!@.]public$/Si)) {
if ($nick !isop $chan && $nick !ishop $chan && $admin($nick) != admin) { halt }
if ($2 == on) {
writeini chan.ini $chan public on
%saystyle Channel commands set to07 On for07 All Users.
}
if ($2 == off) {
writeini chan.ini $chan public off
%saystyle Channel commands set to07 Off for07 All Users.
}
if ($2 == voice) {
writeini chan.ini $chan public voice
%saystyle Channel commands set to07 On for07 Voice+, and 07Off for 07Unvoiced Users.
}
if ($2 == half) {
writeini chan.ini $chan public half
%saystyle Channel commands set to07 On for07 HalfOp+, and 07Off for 07Voiced and Unvoiced Users.
}
goto clean
}
else if ($regex($1,/^[!@.]uptime$/Si)) {
%saystyle Connected:07 $uptime(server,1) System uptime:07 $uptime(system,1)
goto clean
}
else if ($regex($1,/^[!@.](fairy|fairyring|fr)$/Si)) {
if ($2) {
var %param = $replace($2-,_,$chr(32),-,$chr(32))
var %info = $read(fairy.txt,nw,* $+ $2- $+ *)
if (!%info && $len(%param) == 3) { %saystyle Fairy Code07 $upper($2-) not found | halt }
if (!%info && $len(%param) != 3) { %saystyle Location07 $2- not found | halt }
%saystyle Code:07 $upper($gettok(%info,1,124)) | Location:07 $gettok(%info,2,124) | Features:07 $gettok(%info,3,124)
}
if (!$2) {
%saystyle All Valid Fairy Codes: 07AJQ | 07AKQ | 07AJS | 07CIP | 07DKS | 07AJR | 07CJR | 07DJR | 07ALS | 07BLR | 07BIS | 07DJP | 07CIQ | 07CLS | 07BKP | 07AKS | 07ALR | 07DKR | 07DIS | 07DIR | 07BKQ | 07CKP | 07AIQ | 07BJR | 07BLP | 07DKP | 07CKR | 07DLS | 07CKS | 07BKR | 07BIQ | 07DLQ | 07AIR | 07BIP | 07CLP | 07DLR
}
goto clean
}
else if ($regex($1,/^[!@.]oldpo(uch)?$/Si)) {
var %info = $read(summoning.txt, nw, * $+ $2- $+ *)
if (!%info) { %saystyle No match found for07 $2- $+ . | halt }
%saystyle Summoning Params07 $gettok(%info,1,9) | Level Required:07 $gettok(%info,3,9) | Exp:07 $gettok(%info,2,9) | Charm:07 $gettok(%info,4,9) | Shards:07 $gettok(%info,5,9) | Second:07 $gettok(%info,7,9) | Time (mins):07 $gettok(%info,6,9) | High Alch:07 $gettok(%info,8,9) | Skill Focus:07 $gettok(%info,9,9) | Other:07 $gettok(%info,10,9)
goto clean
}
else if ($regex($1,/^[!@.]l(oot)?s(hare)?$/Si)) {
%saystyle 07P2P Lootshare Worlds: 9 12 22 28 39 44 46 48 51 54 56 59 64 76 84 88 91 92 97 98 112 114 117 131 145 151 157 158
%saystyle 07F2P Lootshare Worlds: 7 10 11 14 29 30 33 34 35 37 40 41 43 47 75 85 93 94 95 106 108 113 118 120 126 127 134 142 153 154 155 169
goto clean
}
else if ($regex($1,/^[!@.]l(oot)?s(hare)?$/Si)) {
%saystyle PVP worlds: 07F2P: 21 32 55 62 63 72 74 80 101 109 122 123 125 136 | 07P2P: 23 65 89 111 124 137 150 159 164 167
goto clean
}
else if ($regex($1,/^[!@.]activity$/Si)) {
if ($2 == ls || $2 == lootshare) {
%saystyle 07P2P Lootshare Worlds: 9 22 23 26 28 39 46 48 54 56 59 64 65 69 76 84 88 89 91 92 97 98 111 112 114 120 124 131 137 139 140 145 151 157 158 159
%saystyle 07F2P Lootshare Worlds: 7 10 11 14 29 30 34 37 40 43 47 51 52 85 94 95 106 108 113 117 118 126 127 134 142 153 154 155
}
if ($2 == pvp) {
%saystyle PVP worlds: 07F2P: 21 32 55 62 63 72 74 80 101 109 122 123 125 136 | 07P2P: 23 65 89 111 124 137 150 159 164 167
}
goto clean
}
else if ($regex($1,/^[!@.]set(tings?)?$/Si)) {
var %command $2
var %mode $iif($3 == on,on,off)
if ($chan && $nick isop $chan || $nick ishop $chan || $admin($nick) == admin) {
if (%command == youtube) {
writeini -n chan.ini $chan youtube %mode
%saystyle $chan Settings: Youtube link information messages are now %mode $+ .
}
if ($chan && %command == ge || %command == geupdate) {
writeini -n chan.ini $chan geupdate %mode
%saystyle $chan Settings: Ge Update messages are now %mode $+ .
}
if ($chan && %command == qfc) {
writeini -n chan.ini $chan qfc %mode
%saystyle $chan Settings: QFC link information messages are now %mode $+ .
}
if (%command == goal) {
if (!$4 && $litecalc($3) > 0) { %saystyle Sytax Error: !set goal <skill> <goal> | goto clean }
if (!$4 && $lookups($3) != nomatch) {
remini user.ini $rsn($nick) $statnum($3) $+ goal
%saystyle Your07 $lookups($3) goal has been removed.
goto clean
}
if ($lookups($4) != nomatch) { tokenize 32 $4 $3 }
else { tokenize 32 $3 $4 }
writeini -n user.ini $rsn($nick) $statnum($1) $+ goal $iif($litecalc($2) < 127,$lvltoxp($v1),$v1)
writeini -n user.ini $rsn($nick) $statnum($1) $+ target $litecalc($2)
%saystyle Your07 $lookups($1) goal has been set to07 $format_number($userset($rsn($nick),$statnum($1) $+ goal)) experience.
}
if (%command == item) {
if ($lookups($3) == nomatch) { %saystyle Sytax Error: !set item <skill> <item> | goto clean }
elseif (!$4) {
remini user.ini $rsn($nick) $statnum($3) $+ param
%saystyle Your07 $lookups($3) item has been removed.
goto clean
}
var %x = 3
while (%x < $0) {
var %input = %input $($ $+ %x,2)
inc %x
}
if ($lookups($($ $+ $0,2)) != nomatch) { var %skill = $lookups($($ $+ $0,2)), %itemin = %input }
else if ($lookups($3) != nomatch) { var %skill = $3, %itemin = $4- }
else { %saystyle Sytax Error: !set item <skill> <item> | goto clean }
var %socket = $+(a,$ticks)
var %file = $lookups(%skill) $+ .txt
.fopen %socket %file
if ($ferr) { goto clean }
while (!$feof) {
var %line = $fread(%socket)
if (%itemin isin %line) {
var %item = $gettok(%line,1,9)
break
}
}
if (!%item) {
%saystyle Your item07 %itemin could not be found in our07 $lookups(%skill) params.
%saystyle Here is a list of valid params for use with Gerty:12 http://hng.av.it.pt/~jdias/gerty/param.html
}
else {
writeini -n user.ini $rsn($nick) $statnum(%skill) $+ param %item
%saystyle Your07 $lookups(%skill) item has been set to07 $userset($rsn($nick),$statnum(%skill) $+ param) $+ .
}
.fclose %socket
}
if (%command == site) {
if ($nick isop $chan || $nick ishop $chan || $admin($nick) == admin) {
writeini -n chan.ini $chan site $ascii-hex($urlencode($3-))
%saystyle The website for07 $chan has been set to:07 $regsubex($hex-ascii($readini(chan.ini,$chan,site)),/%(.{2})/g,$chr($base(\1,16,10)))
}
}
}
}
else if ($chan && $regex($1,/^[!@.]setsite$/Si)) {
if ($nick isop $chan || $nick ishop $chan || $admin($nick) == admin) {
writeini -n chan.ini $chan site $ascii-hex($urlencode($2-))
%saystyle The website for07 $chan has been set to:07 $regsubex($hex-ascii($readini(chan.ini,$chan,site)),/%(.{2})/g,$chr($base(\1,16,10)))
}
}
else if ($chan && $regex($1,/^[!@.]site$/Si)) {
%saystyle The website for07 $chan is:07 $regsubex($hex-ascii($readini(chan.ini,$chan,site)),/%(.{2})/g,$chr($base(\1,16,10)))
}
else if ($chan && $regex($1,/^[!@.]setevent$/Si)) {
if ($nick isop $chan || $nick ishop $chan || $admin($nick) == admin) {
writeini -n chan.ini $chan event $ascii-hex($urlencode($2-)) $+ $(|,) $+ $nick $+ $(|,) $+ $date
%saystyle The event for07 $chan has been set to:07 $replace($regsubex($hex-ascii($gettok($readini(chan.ini,$chan,event),1,124)),/%(.{2})/g,$chr($base(\1,16,10))),+,$chr(32))
}
}
else if ($chan && $regex($1,/^[!@.]event$/Si)) {
if ($2 == clear) {
writeini -n chan.ini $chan event none
%saystyle The event for07 $chan has been cleared.
goto clean
}
else if ($2 == set) {
if ($nick isop $chan || $nick ishop $chan || $admin($nick) == admin) {
writeini -n chan.ini $chan event $ascii-hex($urlencode($3-)) $+ $(|,) $+ $nick $+ $(|,) $+ $date
%saystyle The event for07 $chan has been set to:07 $replace($regsubex($hex-ascii($gettok($readini(chan.ini,$chan,event),1,124)),/%(.{2})/g,$chr($base(\1,16,10))),+,$chr(32))
}
goto clean
}
else if ($2 == access) {
goto clean
}
var %event = $readini(chan.ini,$chan,event)
if ($gettok(%event,1,124) == none) {
%saystyle No event has been set for07 $chan $+ .
goto clean
}
%saystyle The event for07 $chan is:07 $replace($regsubex($hex-ascii($gettok(%event,1,124)),/%(.{2})/g,$chr($base(\1,16,10))),+,$chr(32)) $+ . Set by07 $gettok(%event,2,124) on07 $gettok(%event,3,124) $+ .
}
else if ($regex($1,/^[!@.]admin$/Si)) {
var %admin = $readini(tracked.ini,tracked,admin)
%saystyle 07 $+ $numtok(%admin,124) 'Gerty' Bot Administrators;07 $regsubex(%admin,/\|/gi, $+ $chr(44) 07)
goto clean
}
else if ($regex($1,/^[!@.]addadmin$/Si)) {
if ($admin($nick) != admin) { halt }
var %nick = $rsn($regsubex($2-,/\W/g,_))
var %admin = $readini(tracked.ini,tracked,admin)
var %regex = /(^|\|) $+ %nick $+ (\||$)/i
if ($regex(%admin,%regex)) { %saystyle %nick is already an admin | goto clean }
writeini tracked.ini tracked admin $readini(tracked.ini,tracked,admin) $+ $chr(124) $+ $rsn($replace($2-,$chr(32),_))
%saystyle 07 $+ $rsn($replace($2-,$chr(32),_)) added as07 $me Admin.
goto clean
}
else if ($regex($1,/^[!@.]removeadmin$/Si)) {
if ($admin($nick) != admin) { halt }
var %nick = $rsn($regsubex($2-,/\W/g,_))
var %admin = $readini(tracked.ini,tracked,admin)
var %regex = /((\| $+ %nick $+ )|( $+ %nick $+ \|))/i
writeini tracked.ini tracked admin $regsubex(%admin,%regex,$null)
%saystyle 07 $+ %nick Removed from07 $me Admin.
goto clean
}
else if ($regex($1,/^[!@.]coin$/Si)) {
var %coin = $r(1,2)
%saystyle 07 $+ $nick flipped a coin and the result was 07 $+ $iif(%coin == 1,heads,tails) $+ .
goto clean
}
else if ($regex($1,/^[!@.]dice$/Si)) {
%saystyle 07 $+ $nick rolled a dice and the result was 07 $+ $r(1,6) $+ .
goto clean
}
else if ($chan && $regex($1,/^[!@.]poll$/Si)) {
if ($nick !isop $chan && $nick !ishop $chan && $admin($nick) != admin) { .notice $nick You must be a (half)op to use the command | goto clean }
if (!$2) { .notice $nick You must specify a Question | goto clean }
if ($hget($chan,poll)) { .notice $nick A poll is already in progress. | goto clean }
if (!$hget($chan,poll)) {
hadd -m $chan poll $capwords($2-)
hadd -m $chan yes 0
hadd -m $chan no 0
.msg $chan Poll Started in $chan $+ :07 $capwords($2-)
.timer 1 120 .msg $chan Results for $!hget( $chan ,poll) $+ : Yes:07 $!hget( $chan ,yes) No:07 $!hget( $chan ,no) That's07 $!calc( 100 * $!hget( $chan ,yes) / ( $!hget( $chan ,yes) + $!hget( $chan ,no))) $!+ % Yes. $(|,) hfree $chan
}
goto clean
}
else if ($chan && $regex($1,/^[!@.]yes$/Si)) {
if (!$hget($chan,poll)) { goto clean }
if ($nick isin $hget($chan,nick)) {
.notice $nick You cannot vote twice.
goto clean
}
hadd -m $chan yes $calc($hget($chan,yes) +1)
hadd -m $chan nick $hget($chan,nick) $+ @ $+ $nick
.notice $nick You have voted07 Yes in the current poll
goto clean
}
else if ($chan && $regex($1,/^[!@.]no$/Si)) {
if (!$hget($chan,poll)) { goto clean }
if ($nick isin $hget($chan,nick)) {
.notice $nick You cannot vote twice.
goto clean
}
hadd -m $chan no $calc($hget($chan,yes) +1)
hadd -m $chan nick $hget($chan,nick) $+ @ $+ $nick
.notice $nick You have voted07 No in the current poll
goto clean
}
else if ($regex($1,/^[!@.]pi$/Si)) {
%saystyle 07Pi =07 3.141592653589793238462643383279502884197169399375105820974944592307816406286208998628034825342117067982148086513282306647093844609550582231725359408128481117450284102701938521105559644622948954930381964428810975665933446128475648233786783165271201909145648566923460
goto clean
}
:clean
unset %*
}
alias slines {
var %a = 1
while ($script(%a)) {
var %b = %b + $lines($v1)
inc %a
}
say 7Scripts:  $+ $script(0) $+  $chr(124) 7Lines $calc(%b)
}
alias timecount {
if ($read(timer.txt,nw,$ctime($asctime($gmt)) $+ *)) { $gettok($read(timer.txt,nw,$ctime($asctime($gmt)) $+ *),2,124) }
}
