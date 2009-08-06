>start<|qfc.mrc|RSOF QFC|2.1|rs
on $*:TEXT:/^[!@.]qfc/Si:*: {
  _CheckMain
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
on $*:text:/forum\.runescape\.com\/forums\.ws\?(\d{1,3}\W\d{1,3}\W\d+\W\d+)/Si:#: {
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
on *:sockread:qfc.*: {
  var %thread = $gettok($sockname,2,46)
  if ($sockerr) {
    write ErrorLog.txt $timestamp SocketError[sockread]: $nopath($script) $socket $([,) $+ $hget(%thread,out) $hget(%thread,nick) $+ $(],)
    echo -at Socket Error: $nopath($script)
    $hget(%thread,out) Connection Error: Please try again in a few moments.
    hfree %thread
    sockclose $sockname
    halt
  }
  while ($sock($sockname).rq) {
    sockread &qfc
    bwrite %thread -1 -1 &qfc
  }
  bread %thread 0 $file(%thread).size &qfc2
  if ($bfind(&qfc2,0,</body)) {
    var %start = $bfind(&qfc2,0,backtoforum.gif), %cutA = $bfind(&qfc2,%start,</li>)
    var %strForum = $bvar(&qfc2,%start,$calc(%cutA - %start)).text
    noop $regex(%strForum,/up to (.+?)</i)
    %strForum = $regml(1)
    if (!%strForum) { goto error }
    var %start = $bfind(&qfc2,0,class="title thrd"), %cutB = $bfind(&qfc2,%start,</div)
    var %strTitle = $bvar(&qfc2,%start,$calc(%cutB - %start)).text
    %strTitle = $remove($nohtml(%strTitle),$chr(10))
    var %start = $bfind(&qfc2,%cutB,class="msgcreator), %cutC = $bfind(&qfc2,%start,</div>)
    var %strPoster = $bvar(&qfc2,%start,$calc(%cutC - %start)).text
    %strPoster = $remove($nohtml(%strPoster),$chr(10))
    var %start = $bfind(&qfc2,%cutC,class="msgtime"), %cutD = $bfind(&qfc2,%start,</div>)
    var %strTime = $bvar(&qfc2,%start,$calc(%cutD - %start)).text
    %strTime = $remove($nohtml(%strTime),$chr(10))
    var %start = $bfind(&qfc2,%cutD,class="msgcontents"), %cutE = $bfind(&qfc2,%start,</div>)
    var %strContent = $bvar(&qfc2,%start,$calc(%cutE - %start)).text
    %strContent = $remove($nohtml(%strContent),$chr(10))
    $hget(%thread,out) $formatwith(\c12\uhttp://forum.runescape.com/forums.ws?{0}\o $| Forum:\c07 %strForum \o| By:\c07 %strPoster \o| Title:\c07 %strTitle \o| Posted at:\c07 %strTime, $replace($hget(%thread,qfc),-,$chr(44)))
    $hget(%thread,out) $formatwith(\uThread Content:\u) $mid(%strContent,1,150) $+ $iif($len(%strContent) > 150,...)
    goto unset
    :error
    $hget(%thread,out) An error occured while retrieving information for this qfc.
    :unset
    .sockclose $sockname
    .hfree %thread
    .remove %thread
    unset %*
    halt
  }
}
