on $*:TEXT:/^[!@.]y(ou)?t(ube)?\b/Si:*: {
var %thread = $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9)), %saystyle = $saystyle($left($1,1),$nick,$chan)
hadd -m %thread out %saystyle
if ($2) {
hadd -m %thread page video
hadd -m %thread search $urlencode($2-)
sockopen $+(google.,%thread) ajax.googleapis.com 80
}
else {
%saystyle Syntax Error: !youtube <search term>
}
}
on $*:TEXT:/^[!@.]google\b/Si:*: {
var %thread = $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9)), %saystyle = $saystyle($left($1,1),$nick,$chan)
hadd -m %thread out %saystyle
if ($2 == -i) {
hadd -m %thread page images
hadd -m %thread search $urlencode($3-)
}
else if ($2 == -v) {
hadd -m %thread page video
hadd -m %thread search $urlencode($3-)
}
else {
if ($2) {
hadd -m %thread page web
hadd -m %thread search $urlencode($2-)
}
else {
%saystyle Syntax Error: !google [-vi] <search term> (-i image search, -v video search)
}
}
sockopen $+(google.,%thread) ajax.googleapis.com 80
}
on *:sockopen:google.*: {
sockwrite -n $sockname GET /ajax/services/search/ $+ $hget($gettok($sockname,2,46),page) $+ ?v=1.0&q= $+ $hget($gettok($sockname,2,46),search) HTTP/1.1
sockwrite -n $sockname Referer: http://www.gerty.x10hosting.com/index.php
sockwrite -n $sockname User-Agent: curl/7.18.2 (i486-pc-linux-gnu) libcurl/7.18.2 OpenSSL/0.9.8g zlibidn/1.8
sockwrite -n $sockname Host: ajax.googleapis.com
sockwrite -n $sockname Accept: */*
sockwrite -n $sockname $crlf
}
on *:sockread:google.*: {
var %thread = $gettok($sockname,2,46)
var %file = %thread $+ .txt
if ($sockerr) {
write ErrorLog.txt $timestamp SocketError[sockread]: $nopath($script) $socket $([,) $+ $hget(%thread,out) $hget(%thread,nick) $hget(%thread,search) $+ $(],)
$hget(%thread,out) Connection Error: please try again in a few moments.
.hfree %thread
.sockclose $sockname
halt
}
else {
while ($sock($sockname).rq) {
sockread &google
bwrite %file -1 -1 &google
}
bread %file 0 $file(%file).size &google2
if ($bfind(&google2,0,"responseStatus")) {
var %a = $bfind(&google2,0,$chr(123)), %b = $bfind(&google2,%a,"responseStatus")
var %string = $bvar(&google2,%a,4000).text
noop $regex(%string,/"url":"(.+?)"/)
var %url = $regml(1)
noop $regex(%string,/"titleNoFormatting":"(.+?)"/)
var %title = $regml(1)
noop $regex(%string,/"content":"(.+?)"/)
var %content = $regml(1)
var %content = $nohtml($regsubex(%content,/\\u(.{4})/g,$chr($base(\1,16,10))))
var %title = $nohtml($regsubex(%title,/\\u(.{4})/g,$chr($base(\1,16,10))))
var %url = $nohtml($regsubex(%url,/(?:\\u(.{4})|%(.{2}))/g,$chr($base(\1,16,10))))
if (%url) {
if ($hget(%thread,page) == video) { %url = $regsubex(%url,/^.+?q=(.+?)&(.+?)$/,\1) }
$hget(%thread,out) Google $caps($hget(%thread,page)) Search " $+ $replace($hget(%thread,search),+,$chr(32)) $+ ":07 %title url:12 %url content:07 %content
}
else { $hget(%thread,out) No search results for $+(",$replace($hget(%thread,search),+,$chr(32)),".) }
if ($hget(%thread,page) == video) {
var %id = $regex(%url,/\?v=(.+?)(&|$)/)
var %id = $regml(1)
if (%id) {
hadd -m %thread link %id
sockopen youtube. $+ %thread rscript.org 80
}
else {
.hfree %thread
}
}
else {
.hfree %thread
}
.remove %file
sockclose $sockname
unset %*
halt
}
}
}
