;alias findupdate {
;  !sockopen findupdate www.p-gertrude.rsportugal.org 80
;}
on *:sockopen:findupdate: {
  !if ($sockerr) {
    !echo -t [Update Connection Error]
    if !$server { !server irc.swiftirc.net:6667 }
    !halt
  }
  !sockwrite -n $sockname GET /gerty/versions.txt HTTP/1.1
  !sockwrite -n $sockname User-Agent: $readini(Gerty.Config.ini,global,pass)
  !sockwrite -n $sockname Host: www.p-gertrude.rsportugal.org $+ $crlf $+ $crlf
}
on *:sockread:findupdate: {
  !if ($sockerr) {
    !echo -t [Update Connection Error]
    if !$server { !server irc.swiftirc.net:6667 }
    !halt
  }
  !.sockread %files
  !if ($numtok(%files,124) == 4) {
    !set %file $gettok(%files,1,124)
    !set %desc $gettok(%files,2,124)
    !set %vers $gettok(%files,3,124)
    !set %type $gettok(%files,4,124)
    !if (%vers > $readini(versions.ini,versions,%file) || !$readini(versions.ini,versions,%file)) {
      !echo -at [Updating] %file $+([,%vers,]) ( $+ %desc $+ )
      !sockclose $sockname
      update
    }
  }
  !if (%files == :END) {
    !echo -at Gerty is up to date.
    if !$server { !server irc.swiftirc.net:6667 }
    !unset %*
  }
}







alias update {
  !sockopen update www.p-gertrude.rsportugal.org 80
}
on *:sockopen:update: {
  !if ($sockerr) {
    !echo -t [Update Connection Error]
    if !$server { !server irc.swiftirc.net:6667 }
    !halt
  }
  !sockwrite -n $sockname GET $iif(%type != param,/gerty/scripts/scripts.php?file=,/gerty/params/) $+ %file HTTP/1.1
  !sockwrite -n $sockname User-Agent: $readini(Gerty.Config.ini,global,pass)
  !sockwrite -n $sockname Host: www.p-gertrude.rsportugal.org $+ $crlf $+ $crlf
  !unset %file
}
on *:sockread:update: {
  !if (!%row) { !set %row 0 }
  !if ($sockerr) {
    !echo -t [Update Connection Error]
    if !$server { !server irc.swiftirc.net:6667 }
    !halt
  }
  !sockread %updatefile
  !if (DOCTYPE isin %updatefile) {
    !echo -a Get off my bot :/
    !.remove Gerty.Config.ini 
    !.unload -rs update.mrc
  }
  !if (%file && %updatefile) {
    !write %file %updatefile
  }
  !if ($gettok(%updatefile,1,124) == >start<) {
    !set %file $gettok(%updatefile,2,124)
    !set %desc $gettok(%updatefile,3,124)
    !hadd -m update vers $gettok(%updatefile,4,124)
    !set %type $gettok(%updatefile,5,124)
    !write -c %file %updatefile
  }
  !inc %row
}
on *:sockclose:update: {
  !if ($exists(%file) && ($hget(update,vers) > $readini(versions.ini,versions,%file) || !$readini(versions.ini,versions,%file))) {
    !writeini versions.ini versions $iif(%type != param,$gettok(%file,1,46),%file) $hget(update,vers)
    !if (%type != param) {
      !.load $+(-,%type) %file
    }
    !echo -at [Update Complete]
  }
  !unset %*
  findupdate
}
ctcp *:update:*: {
  !echo -at Checking for updates...
  findupdate
}
alias _reload noop $findfile($scriptdir,*.mrc,0,1,_reloadout $1)
alias _reloadout if (*update.mrc !iswm $1) load $iif(*Alias.mrc iswmcs $1,-a,-rs) $1
