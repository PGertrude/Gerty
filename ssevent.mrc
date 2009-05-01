on $*:TEXT:/^[!@.](ssevent) */Si:#: {
hadd -m out out $saystyle($left($1,1),$nick,$chan)
ssforum POST /Supreme_Skillers/index.php?act=Login&CODE=01 UserName=P_Gertrude&PassWord=penguin&CookieDate=1&submit=Log me in
}
alias ssforum {
var %method = $iif($1,$1,GET)
var %page = $iif($2,$2,/)
var %sock = ssforum. $+ $ticks
hadd -m %sock out $hget(out,out)
sockopen %sock z3.invisionfree.com 80
sockmark %sock %method %page $3
}
on *:SOCKOPEN:ssforum.*:{
var %a = sockwrite -n $sockname
var %string = $urlencode_string($getmark($sockname,3-))
%a $getmark($sockname,1-2) $+ $iif($getmark($sockname,1) == GET && %string,$+(?,%string)) HTTP/1.1
%a Host: z3.invisionfree.com
if ($exists(cookie.txt)) {
var %n = 1, %cookie
while ($read(cookie.txt,%n)) {
%cookie = $+(%cookie,$v1,;)
inc %n
}
%a Cookie: %cookie
}
if ($getmark($sockname,1) == POST) {
%a Content-Length: $len(%string)
%a Content-Type: application/x-www-form-urlencoded
}
%a Connection: close
%a Accept: */*
%a Accept-Charset: *
%a Accept-Encoding: *
%a Accept-Language: *
%a User-Agent: Mozilla/5.0
if ($getmark($sockname,1) == POST) {
%a $crlf %string
}
else {
%a $crlf
}
}
on *:SOCKREAD:ssforum.*:{
sockread %tmp
if ($regex(%tmp,/^Set-Cookie: (.+?)=(.+?);/i)) {
if ($read(cookie.txt, w, $regml(1) $+ =*)) {
write -l $+ $readn cookie.txt $+($regml(1),=,$regml(2))
}
else write cookie.txt $+($regml(1),=,$regml(2))
}
if ((!%tmp) && ($getmark($sockname,1) == POST)) {
sockclose $sockname
ssforum GET /Supreme_Skillers/index.php act=calendar
}
if ($regex(%tmp,/y=(\d{4})&m=(\d+)&d=(\d+)/)) hadd -m $+(a,$gettok($sockname,2,46)) date $regml(3) $+ / $+ $regml(2) $+ / $+ $regml(1)
if ($regex(%tmp,/eventid.+?>(.+?)</gi) && $len($hget(ssforum,out)) < 200 && $gettok($hget($+(a,$gettok($sockname,2,46)),date),1,47) >= $date(dd)) {
var %x = 1
while (%x <= 5) {
if (!$regml(%x)) break
hadd -m ssforum out $hget(ssforum,out) $hget($+(a,$gettok($sockname,2,46)),date) 07 $+ $regml(%x) $+ ;
inc %x
}
}
}
on *:sockclose:ssforum.*: {
if ($getmark($sockname,1) == GET) {
$hget($sockname,out) Supreme Skillers next events: $hget(ssforum,out)
.hfree ssforum
}
}
alias getmark {
return $gettok($sock($1).mark,$$2,32)
}
alias urlencode_string {
var %a = 1, %string = $1, %output
while ($gettok(%string,%a,38)) {
tokenize 61 $v1
if (%a != 1) %output = %output $+ &
%output = $+(%output,$1,=,$urlencode($2))
inc %a
}
return %output
}
alias urlencode {
var %a = $regsubex($$1,/([^\w\s])/Sg,$+(%,$base($asc(\t),10,16,2)))
return $replace(%a,$chr(32),$chr(43))
}
:END
