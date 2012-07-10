alias versions.updater return 4.01

alias _findUpdate !sockopen findupdate sselessar.net 80
on *:sockopen:findupdate: {
  !if ($sockerr) {
    !echo -t [Update Connection Error]
    !halt
  }
  !sockwrite -n $sockname GET Gerty/Updater/versions.mrc HTTP/1.1
  !sockwrite -n $sockname Host: sselessar.net $+ $crlf $+ $crlf
}
on *:sockread:findupdate: {
  var %file temp $+ $r(0,99999) $+ .txt
  !if ($sockerr) {
    !echo -t [Update Connection Error]
    !halt
  }
  while ($sock($sockname).rq) {
    !sockread &versions
    !var %a $calc($bfind(&versions, 0, 13 10 13 10) + 1)
    !bwrite %file -1 -1 $bvar(&versions, %a, $bvar(&versions,0)).text
  }
  !.load -rs %file
  if ($isalias(checkVersions)) {
    checkVersions
  }
  elseif ($server) {
    _warning Update Failed
  }
  _queue !.unload -rs %file
  _queue !.remove %file
}
alias _update {
  var %sock update $+ $r(0,99999)
  if ($exists($2)) .remove $2
  !sockopen %sock sselessar.net 80
  !sockmark %sock $1-
}
on *:sockopen:update*: {
  !if ($sockerr) {
    !echo -t [Update Connection Error]
    !halt
  }
  !sockwrite -n $sockname GET /Gerty/Updater/ $+ $gettok($sock($sockname).mark, 2, 32) HTTP/1.1
  !sockwrite -n $sockname Host: sselessar.net $+ $crlf $+ $crlf
}
on *:sockread:update*: {
  !if ($sockerr) {
    !echo -t [Update Connection Error]
    !halt
  }
  while ($sock($sockname).rq) {
    !sockread &file
    !bwrite $gettok($sock($sockname).mark, 2, 32) -1 -1 &file
  }
}
on *:sockclose:update*: {
  if ($gettok($read($gettok($sock($sockname).mark, 2, 32), 1), 1, 46) != versions) {
    var %x 1
    while (%x <= 10) {
      write -dl1 $gettok($sock($sockname).mark, 2, 32)
      inc %x
    }
  }
  .load $sock($sockname).mark
  echo -s $gettok($sock($sockname).mark, 2, 32) updated.
}

alias _updateParam {
  var %sock paramUpdate $+ $r(0,99999)
  if ($exists($1)) .remove $1
  !sockopen %sock sselessar.net 80
  !sockmark %sock $1-
}
on *:sockopen:paramUpdate*: {
  !if ($sockerr) {
    !echo -t [Update Connection Error]
    !halt
  }
  !sockwrite -n $sockname GET /Gerty/Updater/params/ $+ $gettok($sock($sockname).mark, 1, 32) HTTP/1.1
  !sockwrite -n $sockname Host: sselessar.net $+ $crlf $+ $crlf
}
on *:sockread:paramUpdate*: {
  !if ($sockerr) {
    !echo -t [Update Connection Error]
    !halt
  }
  while ($sock($sockname).rq) {
    !sockread &file
    !bwrite $gettok($sock($sockname).mark, 1, 32) -1 -1 &file
  }
}
on *:sockclose:paramUpdate*: {
  var %x 1
  while (%x <= 10) {
    write -dl1 $gettok($sock($sockname).mark, 1, 32)
    inc %x
  }
  writeini Gerty.Config.ini versions $gettok($sock($sockname).mark, 1, 46) $gettok($sock($sockname).mark, 2, 32)
  echo -s $gettok($sock($sockname).mark, 1, 32) updated to $gettok($sock($sockname).mark, 2, 32) $+ .
}
