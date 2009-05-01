alias listchans {
var %x 1
while ($chan(%x)) {
var %a $calc(%a + $nick($chan(%x),0))
var %b %b $chan(%x) $+ $chr(91) $+ $nick($chan(%x),0) $+ $chr(93)
inc %x
}
return Chans:07 $chan(0) Nicks:07 %a Uptime:07 $swaptime($uptime(server,1)) Chan list: %b
}
on $*:TEXT:/^[!@.]status\b/Si:*: {
var %saystyle = $saystyle($left($1,1),$nick,$chan,no)
if ($admin($nick) != admin) { halt }
if ($2) {
if ($left($2,1) == $#) {
var %minusers = $chanset($2,users)
var %curusers = $nick($2,0)
var %blacklist = $chanset($2,blacklist)
var %youtube = $chanset($2,youtube)
var %site = $chanset($2,site)
var %event = $chanset($2,event)
var %public = $chanset($2,public)
if (%blacklist) { %blacklist = Blacklist:07 %blacklist }
if (%youtube) { %youtube = Youtube:07 $caps(%youtube) }
else { %youtube = Youtube:07 On }
if (%public) { %public = Public:07 %public }
else { %public = Public:07 On }
if (%site) { %site = Site:07 Yes }
else { %site = Site:07 No }
if (%event) { %event = Event:07 Yes }
else { %event = Event:07 No }
%saystyle Channel info:07 $2 $iif(%curusers,Users:07 %curusers $+ $chr(32)) $+ %public %blacklist %youtube %site %event
return
}
}
var %x 1
while ($chan(%x)) {
var %a $calc(%a + $nick($chan(%x),0))
inc %x
}
%saystyle Chans:07 $chan(0) Nicks:07 %a Uptime:07 $swaptime($uptime(server,1))
}
alias swaptime {
var %b = $regex(time,$1,/(\d+)/g)
var %x = 0
while (%x < $calc(5 - $regml(time,0))) { var %y = %y 00 | inc %x }
var %x = 1
while (%x <= 5) {
var %y = %y $iif($regml(time,%x) < 10,0) $+ $regml(time,%x)
inc %x
}
var %time = $replace(%y,$chr(32),:)
return $gettok(%time,1,58) $+ w $gettok(%time,2,58) $+ d $gettok(%time,3-5,58)
}
on $*:text:/^(Gerty [.!@]set(tings?)?|[.!@]set(tings?)?) (.+?) (on|off|private?)/Si:#howdy:{
var %set $regml(2)
var %mode $regml(3)
if ($nick isop $chan || %owner($nick) == owner) {
if (%set == youtube) {
writeini chan.ini $chan youtube %mode
.notice $nick Successfully set automatic 07Youtube link info to07 %mode $+ .
}
}
}
on $*:text:/youtube\.com\/watch\?v=([\w-]+)\W?/Si:*:{
if ($chanset($chan,youtube) != off) {
var %ticks $ticks
sockopen youtube.a $+ %ticks rscript.org 80
hadd -m a $+ %ticks out $saystyle(@,$nick,$chan)
hadd -m a $+ %ticks link $regml(1)
}
}
on $*:notice:/youtube\.com\/watch\?v=([\w-]+)\W?/Si:*:{
var %ticks $ticks
sockopen youtube.a $+ %ticks rscript.org 80
hadd -m a $+ %ticks out .notice $nick
hadd -m a $+ %ticks link $regml(1)
}
on $*:sockopen:youtube.*:{
sockwrite -nt $sockname GET /lookup.php?type=youtubeinfo&id= $+ $hget($gettok($sockname,2,46),link) HTTP/1.1
sockwrite -nt $sockname Host: rscript.org
sockwrite -nt $sockname $crlf
}
on $*:sockread:youtube.*:{
if ($sockerr) {
write ErrorLog.txt $timestamp SocketError[sockread]: $nopath($script) $socket $([,) $+ $hget($gettok($sockname,2,46),out) $hget($gettok($sockname,2,46),nick) $+ $(],)
echo -at Socket Error: $nopath($script)
$hget($sockname,out) The URL contained a malformed video ID.
halt
}
sockread %youtube
if ($regex(title,%youtube,/^TITLE: (.+?)$/i)) { hadd -m $gettok($sockname,2,46) title $regml(title,1) }
if ($regex(duration,%youtube,/^DURATION: (.+?)$/i)) { hadd -m $gettok($sockname,2,46) duration $regml(duration,1) }
if ($regex(views,%youtube,/^VIEWS: (.+?)$/i)) { hadd -m $gettok($sockname,2,46) views $regml(views,1) }
if ($regex(rating,%youtube,/^RATING: \d+ \d+ (\d+) (\d+(\.\d+)?)/i)) { hadd -m $gettok($sockname,2,46) rating $regml(rating,2) | hadd -m $gettok($sockname,2,46) ratings $regml(rating,1) }
if (%youtube == END) {
if (!$hget($gettok($sockname,2,46),title)) { $hget($gettok($sockname,2,46),out) The URL contained a malformed video ID. (ID: $hget($gettok($sockname,2,46),link) $+ ) | hfree $gettok($sockname,2,46) | sockclose $sockname | halt }
$hget($gettok($sockname,2,46),out) Youtube link code "07 $+ $hget($gettok($sockname,2,46),link) $+ " $chr(124) Title:7 $hget($gettok($sockname,2,46),title)  $+ $chr(124) Duration: $regsubex($duration($hget($gettok($sockname,2,46),duration),1),/(\d+)/g,07\1)  $+ $chr(124) Views:7 $bytes($hget($gettok($sockname,2,46),views),bd)  $+ $chr(124) Rating:7 $+($hget($gettok($sockname,2,46),rating),$chr(3),$chr(40),$chr(3),07,$bytes($hget($gettok($sockname,2,46),ratings),bd)) votes $+ $chr(41)
hfree $gettok($sockname,2,46)
sockclose $sockname
}
}
on $*:text:/^(Gerty? )?[!.@]m(ember)?l(ist)?/Si:*:{
if ($iif($regex($1,/^Gerty?/Si),$3,$2) && $readini(chan.ini,$chan,ml) != off) {
var %ticks $ticks
sockopen ml.a $+ %ticks runehead.com 80
hadd -m a $+ %ticks out $saystyle($left($iif($regex($1,/^Gerty?/Si),$2,$1),1),$nick,$chan)
hadd -m a $+ %ticks ml $caps($regsubex($iif($regex($1,/^Gerty?/Si),$3-,$2-),/(\W)/g,_))
}
}
on $*:notice:/^(Gerty? )?[!.@]m(ember)?l(ist)?/Si:*:{
if ($iif($regex($1,/^Gerty?/Si),$3,$2)) {
var %ticks $ticks
sockopen ml.a $+ %ticks runehead.com 80
hadd -m a $+ %ticks out .notice $nick
hadd -m a $+ %ticks ml $caps($regsubex($iif($regex($1,/^Gerty?/Si),$3-,$2-),/(\W)/g,_))
}
}
on *:sockopen:ml.*:{
sockwrite -nt $sockname GET /feeds/lowtech/searchclan.php?search= $+ $hget($gettok($sockname,2,46),ml) $+ &type=2
sockwrite -nt $sockname Host: runehead.com
sockwrite -nt $sockname $crlf
}
on *:sockread:ml.*:{
if ($sockerr) { echo -st Error in socket: $sockname }
sockread %ml
if (@@start !isin %ml) {
if (@@not isin %ml) {
$hget($gettok($sockname,2,46),out) $+(,$hget($gettok($sockname,2,46),ml),) clan not found. $+($chr(15),$chr(40),$chr(3),07,RuneHead.com,$chr(15),$chr(41))
hfree $gettok($sockname,2,46)
unset %*
sockclose $sockname
}
else {
tokenize 124 %ml
$hget($gettok($sockname,2,46),out) $+($chr(91),07,$5,,$chr(93),07) $1 $+(,$chr(40),07,$4,,$chr(41)) Link:12 $2  $+ $chr(124) Members: $+(07,$6,) $chr(124) Avg: P2P-Cmb: $+(07,$7,) F2P-Cmb: $+(07,$16,) Overall: $+(07,$bytes($9,bd),) $chr(124) Based: Region: $+(07,$13,) World: $+(07,$15,) Core: $+(07,$12,) Cape: $+(07,$14,) $chr(124) Runehead Link:12 $3
unset %*
hfree $gettok($sockname,2,46)
sockclose $sockname
}
}
}
on $*:text:/^(Gerty?\x20)?[!.@](mag(e|ic))?spell? /Si:*:{
if ($iif($regex($1,/^Gerty?/Si),$3,$2)) { spell $remove($iif($regex($1,/^Gerty?/Si),$3-,$2-),$chr(44),$chr(36)) $+ $chr(44) $+ $saystyle($left($iif($regex($1,/^Gerty?/Si),$2,$1),1),$nick,$chan) }
}
alias spell {
if ($calculate($1) isnum) { var %num $calculate($1) | var %spell $gettok($2-,1,44) }
elseif ($calculate($1) !isnum) { var %num 1 | var %spell $gettok($1-,1,44) }
if ($chr(34) isin %spell) { var %spell $remove(%spell,$chr(34)) | var %exact yes }
var %saystyle $gettok($1-,2,44)
.fopen spells magic.txt
var %x 1
while (!$feof && %x <= 4) {
var %spel = $fread(spells)
if ($iif(%exact,$+(%spell,$chr(9),*),$+(*,%spell,*)) iswm %spel) {
var %spellname $gettok(%spel,1,9)
var %spellexp $calc(%num * $gettok(%spel,2,9))
var %spelllvl $gettok(%spel,3,9)
var %spellrunes $regsubex($gettok(%spel,4,9),/(\d+) (\w+)/ig,$calc(%num * \1) \2)
var %spellprice $calc($replace($regsubex(%spellrunes,/(\d+) (\w+)/Sig,$calc( $+(\1,$chr(42),$hget(runeprice,\2 $+ _Rune)) )),$chr(32),$chr(43),$chr(44),$chr(32)))
var %spellmax $gettok(%spel,5,9)
var %spellbook $gettok(%spel,6,9)
var %spellother $gettok(%spel,7,9)
%saystyle Magic Params07 %spellname $+(,$iif(%num > 1,$+($chr(40),x,07,%num,,$chr(41),$chr(32))),$chr(124)) Exp:07 $bytes(%spellexp,bd)  $+ $chr(124) Level:07 %spelllvl  $+ $chr(124) Runes:07 $regsubex(%spellrunes,/(\d+) (\w+)(\x2c)?/ig,$bytes(\1,bd) \2 $+ $iif(\3,$+(,\3,07)))  $+ $chr(124) Price:07 $bytes(%spellprice,bd) $+ gp $chr(124) Max hit:07 %spellmax  $+ $chr(124) Spellbook:07 %spellbook  $+ $chr(124) Other info:07 %spellother $+ .
hadd -m spelluse $replace(%spellname,$chr(32),$chr(95)) $calc($hget(spelluse,$replace(%spellname,$chr(32),$chr(95))) + 1)
inc %x
}
}
if (%x == 1) { %saystyle 07 $+ $iif(%exact,Exact match $+(07,",%spell,"),%spell) $+  spell not found. }
.fclose *
}
on *:quit:{
hsave runeprice runeprice.txt
hsave spelluse spelluse.txt
}
on *:connect:{
if (!$hget(runeprice)) {
hmake runeprice
hload runeprice runeprice.txt
}
if (!$hget(spelluse)) {
hmake spelluse
hload spelluse spelluse.txt
}
}
alias runepriceupdater {
sockopen runeprice.rune1 itemdb-rs.runescape.com 80
sockopen runeprice.rune2 itemdb-rs.runescape.com 80
if ($hget(potprice)) { hfree potprice }
}
on *:sockopen:runeprice.rune1:{
sockwrite -nt $sockname GET /results.ws?query="+Rune"&price=0-500&members= HTTP/1.1
sockwrite -nt $sockname Host: itemdb-rs.runescape.com
sockwrite -nt $sockname $crlf
}
on *:sockopen:runeprice.rune2:{
sockwrite -nt $sockname GET /results.ws?query="%20rune"&sup=All&cat=All&sub=All&page=2&vis=1&order=1&sortby=name&price=0-500&members= HTTP/1.1
sockwrite -nt $sockname Host: itemdb-rs.runescape.com
sockwrite -nt $sockname $crlf
}
on *:sockread:runeprice.*:{
if ($sockerr) { echo -st Error in socket: $sockname }
sockread %rune
if ($regex(rune,%rune,/^<\w+><.+?> (\w+) rune<\/\w><\/\w+>$/i)) { hadd -m temp rune $regml(rune,1) }
if ($regex(price,%rune,/^<\w+>(\d+)<\/\w+>$/i) && $hget(temp,rune)) { hadd -m runeprice $hget(temp,rune) $+ _Rune $regml(price,1) | hfree temp }
}
;##POTION##
on $*:text:/^(Gerty?\x20)?[!.@]oldpot(ion)?s? ./Si:*:{
if ($calculate($iif($regex($1,/^Gerty?/Si),$3,$2)) isnum) { var %num $calculate($iif($regex($1,/^Gerty?/Si),$3,$2)) | var %potion $iif($regex($1,/^Gerty?/Si),$4-,$3-) }
elseif ($calculate($iif($regex($1,/^Gerty?/Si),$3,$2)) !isnum) { var %num 1 | var %potion $iif($regex($1,/^Gerty?/Si),$3-,$2-) }
var %ticks $ticks
.fopen potion $+ %ticks potion.txt
var %x 1
while (!$feof && %x <= 2) {
var %pot = $fread(potion $+ %ticks)
if ($+(*,%potion,*) iswm $gettok(%pot,4,9)) {
if (!$hget(potprice,p $+ $gettok(%pot,5,9))) {
hadd -m $+(a,%ticks,.,$gettok(%pot,5,9)) out $saystyle($left($iif($regex($1,/^Gerty?/Si),$2,$1),1),$nick,$chan) $+ $chr(44) $+ %num $+ $chr(44) $+ $replace(%pot,$chr(9),$chr(44))
sockopen $+(potion.a,%ticks,.,$gettok(%pot,5,9)) itemdb-rs.runescape.com 80
}
var %y 1
while ($gettok($gettok(%pot,7,9),%y,43) && %y <= 5) {
if (!$hget(potprice,p $+ $gettok($gettok(%pot,7,9),%y,43))) {
hadd -m $+(a,%ticks,.,$gettok($gettok(%pot,7,9),%y,43)) out $saystyle($left($iif($regex($1,/^Gerty?/Si),$2,$1),1),$nick,$chan) $+ $chr(44) $+ %num $+ $chr(44) $+ $replace(%pot,$chr(9),$chr(44))
sockopen $+(potion.a,%ticks,.,$gettok($gettok(%pot,7,9),%y,43)) itemdb-rs.runescape.com 80
}
inc %y
}
potsay $saystyle($left($iif($regex($1,/^Gerty?/Si),$2,$1),1),$nick,$chan) $+ $chr(44) $+ %num $+ $chr(44) $+ $replace(%pot,$chr(9),$chr(44))
inc %x
}
}
if %x = 1 $saystyle($left($iif($regex($1,/^Gerty?/Si),$2,$1),1),$nick,$chan) 07 $+ %potion potion not found.
.fclose *
}
on *:sockopen:potion.*:{
sockwrite -nt $sockname GET /viewitem.ws?obj= $+ $gettok($sockname,3,46) HTTP/1.1
sockwrite -nt $sockname Host: itemdb-rs.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:potion.*:{
if ($sockerr) { echo -st Error in socket: $sockname }
sockread %pots
if ($regex(pots,%pots,/^<\w>Market Price:<\/\w> ([\d\W]+)/Si)) {
hadd -m potprice p $+ $gettok($sockname,3,46) $remove($regml(pots,1),$chr(44))
potsay $hget($gettok($sockname,2-,46),out)
hfree $gettok($sockname,2-,46)
sockclose $sockname
}
}
alias potsay {
tokenize 44 $1-
var %a %a $iif($hget(potprice,p $+ $7),y,n)
var %b 1
while ($gettok($9,%b,43) && %b <= 5) {
var %a %a $iif($hget(potprice,p $+ $gettok($9,%b,43)),y,n)
inc %b
}
if (n !isin %a) {
var %potprice $calc($2 * $hget(potprice,p $+ $7))
var %ingprice $calc($2 * ($regsubex($9,/(\d+)/g,$hget(potprice,p $+ \1))))
$1 Herblore param $+(07,$iif($2 > 1,$bytes($2,bd) $6,$6), $chr(40),07,$bytes(%potprice,bd),gp,,$chr(41)) $chr(124) Exp: $+(07,$bytes($calc($2 * $5),bd),) $chr(124) Lvl: $+(07,$4,) $chr(124) Ingredients: $+(07,$regsubex($8,/;/g,$+(,$chr(44) 07)) ,$chr(40),07,$bytes(%ingprice,bd),gp,$chr(41)) Costs:07 $bytes($calc(%ingprice - %potprice),bd) $+(,$chr(40),07,$bytes($round($calc((%ingprice - %potprice) / ($2 * $5)),1),bd),gp/exp,$chr(41)) $chr(124) Other info: $+(07,$10-,.)
}
}
on $*:text:/^(Gerty?\x20)?[!.@]newle?ve?l/Si:*:{
var %saystyle $saystyle($left($iif($regex($1,/^Gerty?/Si),$2,$1),1),$nick,$chan)
if ($calculate($iif($regex($1,/^Gerty?/Si),$3,$2)) isnum) { var %num $calculate($iif($regex($1,/^Gerty?/Si),$3,$2)) | var %skill $iif($regex($1,/^Gerty?/Si),$4,$3) }
elseif ($calculate($iif($regex($1,/^Gerty?/Si),$3,$2)) !isnum) { var %num $iif($regex($1,/^Gerty?/Si),$4,$3) | var %skill $iif($regex($1,/^Gerty?/Si),$3,$2) }
if (!$regex($1-,/\d/) || !%skill || !%num || %num > 99 || %num < 1) { %saystyle Syntax: !newlvl level skill | halt }
var %skill $smart(%skill)
var %ticks $ticks
var %tok 3
if (%skill = Slayer) { var %tok 4 }
.fopen newlvl $+ %ticks %skill $+ .txt
var %x 1
while (!$feof && %x <= 8) {
var %lvl = $fread(newlvl $+ %ticks)
var %level $gettok(%lvl,%tok,124)
if (%num = $regsubex(%level,/(?:\w+ )?(\d+)/Si,\1)) {
var %newlvl %newlvl $iif(%newlvl,$chr(124)) 07 $+ $gettok(%lvl,1,124) $+(,$chr(40),07,$bytes($gettok(%lvl,2,124),bd),exp,$chr(41))
inc %x
}
}
.fclose *
if (!%newlvl) { %saystyle No new objects available at level07 %num %skill $+ . | halt }
%saystyle New objects available at level07 %num %skill $+ : %newlvl
}
alias draynor {
if ($read(draynor.txt,w,$1)) sockopen draynor. $+ $1 www.draynor.net 80
}
on *:sockopen:draynor.*:{
var %string = username= $+ $gettok($sockname,2,46) $+ &user_submit=Update%20Signatures!
sockwrite -n $sockname POST /signature_updater.php HTTP/1.1
sockwrite -n $sockname Host: www.draynor.net
sockwrite -n $sockname Content-Length: $len(%string)
sockwrite -n $sockname Content-Type: application/x-www-form-urlencoded
sockwrite -n $sockname $crlf %string
}
on *:sockread:draynor.*:{
if ($sockerr) { echo -st Error in socket: $sockname }
msg #howdy boo
sockclose $sockname
}
on $*:text:/^[!.@]draynor */Si:*:{
var %saystyle = $saystyle($left($1,1),$nick,$chan)
if ($regex($2,/^(del(ete)?|rem(ove)?)$/Si)) {
var %name = $regsubex($3-,/\W/g,_)
if ($read(draynor.txt,w,%name)) {
write -dl $+ $readn draynor.txt
%saystyle Removed 07 $+ %name $+ $chr(15) from automatic draynor sig update list.
}
else { %saystyle Couldn't find 07 $+ %name $+ $chr(15) on automatic draynor sig udpate list }
}
else {
var %name = $regsubex($2-,/\W/g,_)
if (!$read(draynor.txt,w,%name)) {
write draynor.txt %name
%saystyle Added 07 $+ %name $+ $chr(15) to automatic daynor sig update list.
draynor %name
}
else { %saystyle 07 $+ %name $+ $chr(15) is already on automatic draynor sig update list. !draynor REMOVE <name> to remove. }
}
}
