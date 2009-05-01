on $*:TEXT:/^[!@.]qfc/Si:*:{
var %saystyle = $saystyle($left($1,1),$nick,$chan)
if ($regex($2-,/^(\d{1,3}\W\d{1,3}\W\d+\W\d+)/Si)) {
var %qfc = $regsubex($regml(1),/\W/Sg,-)
var %ticks = %ticks
hadd -m a $+ %ticks out %saystyle
hadd -m a $+ %ticks qfc %qfc
hadd -m a $+ %ticks link yes
sockopen qfc.a $+ %ticks forum.runescape.com 80
}
else { %saystyle Invalid qfc code. }
}
on $*:text:/forum\.runescape\.com\/forums\.ws\?(\d{1,3}\W\d{1,3}\W\d+\W\d+)/Si:#:{
if (Runescript isin $nick || Vectra isin $nick || $chanset($chan,qfc) == off) { halt }
var %qfc = $regml(1)
var %ticks = %ticks
hadd -m a $+ %ticks out msg $chan
hadd -m a $+ %ticks qfc $replace(%qfc,$chr(44),-)
sockopen qfc.a $+ %ticks forum.runescape.com 80
}
on *:sockopen:qfc.*: {
hadd -m $gettok($sockname,2,46) count 1
sockwrite -nt $sockname GET /forums.ws? $+ $replace($hget($gettok($sockname,2,46),qfc),-,$chr(44)) HTTP/1.1
sockwrite -nt $sockname Host: forum.runescape.com $+ $crlf $+ $crlf
}
on *:sockread:qfc.*:{
if ($sockerr) { echo -st Error in socket: $sockname }
sockread %qfc
if ($hget($gettok($sockname,2,46),count) == 115) { hadd -m $gettok($sockname,2,46) section $nohtml(%qfc) }
if ($hget($gettok($sockname,2,46),count) == 116) { hadd -m $gettok($sockname,2,46) title $nohtml(%qfc) }
if ($hget($gettok($sockname,2,46),count) == 297) { hadd -m $gettok($sockname,2,46) creator $nohtml(%qfc) }
if ($hget($gettok($sockname,2,46),count) == 281) { hadd -m $gettok($sockname,2,46) pages $gettok($nohtml(%qfc),3,32) }
if ($hget($gettok($sockname,2,46),count) == 298) {
if ($hget($gettok($sockname,2,46),creator)) {
$hget($gettok($sockname,2,46),out) QFC code07 $hget($gettok($sockname,2,46),qfc) $+ : Title:07 $hget($gettok($sockname,2,46),title) | Creator:07 $hget($gettok($sockname,2,46),creator) | Section:07 $hget($gettok($sockname,2,46),section) | Pages:07 $hget($gettok($sockname,2,46),pages) $iif($hget($gettok($sockname,2,46),link),| Link:12 http://forum.runescape.com/forums.ws? $+ $replace($hget($gettok($sockname,2,46),qfc),-,$chr(44)))
unset %*
hfree $gettok($sockname,2,46)
sockclose $sockname
halt
}
}
if (*Thread was not found; the thread does not exist* iswm %qfc) {
$hget($gettok($sockname,2,46),out) Thread with QFC code07 $hget($gettok($sockname,2,46),qfc) was not found.12 http://forum.runescape.com/forums.ws? $+ $replace($hget($gettok($sockname,2,46),qfc),-,$chr(44))
unset %*
hfree $gettok($sockname,2,46)
sockclose $sockname
halt
}
hinc $gettok($sockname,2,46) count
}
