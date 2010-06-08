>start<|triggers.mrc|Entry point|3.6|rs
on *:TEXT:*:*: {
  if ($left($1,1) !isin !.@) {
    var %botCheck = $botid($1)
    if (%botCheck) {
      tokenize 32 $2-
      var %botid = $true
    }
    elseif (%botCheck == $false) goto clean
  }
  var %shuffleInput $nick > $iif($chan,$v1,PM) > $1-
  if ($1 == raw) {
    if (!$admin($nick)) { goto clean }
    [ [ $2- ] ]
    goto clean
  }
  if ($1- == ^) {
    var %save = $userSet($alfaddress($nick) ,save ,$false)
    if (%save) tokenize 32 %save
    else goto exit
  }
  tokenize 32 $strip($1-)
  var %thread $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9)), %saystyle
  if ($left($1,1) isin .!@) %saystyle = $saystyle($left($1,1),$nick,$chan)
  ; STATUS
  if ($regex($1,/^[!@.]status$/Si)) {
    if (!$admin($nick)) {
      var %output Channel Info for07 $chan $+ 
      var %x 1
      while (%x <= $hget($chan,0).item) {
        if ($hget($chan,%x).item != site && $v1 != event && $v1 != users && $hget($chan,$v1)) {
          %output = %output $hget($chan,%x).item $+ : $normaliseItem($hget($chan,$hget($chan,%x).item)) $+ ;
        }
        inc %x
      }
    }
    else {
      if ($2) {
        if ($left($2,1) == $#) {
          var %output Channel Info for07 $2 $+ 
          var %x 1
          while (%x <= $hget($2,0).item) {
            if ($hget($2,%x).item != site && $v1 != event && $v1 != users && $hget($2,$v1)) {
              %output = %output $hget($2,%x).item $+ : $normaliseItem($hget($2,$hget($2,%x).item)) $+ ;
            }
            inc %x
          }
          %saystyle %output $iif($gettok($chanset($2,blacklist),1,59) == yes,blacklist reason:07 $iif($gettok($chanset($2,blacklist),2,59),$v1,Unknown))
          goto clean
        }
      }
      hadd -m %thread out %saystyle
      hadd -m %thread ticks $ticks
      .raw status. $+ %thread
    }
    goto clean
  }
  if ($chr(36) isin $1-) { tokenize 32 $remove($1-,$chr(36)) }
  if (!%botid) _CheckMain
  ; Save
  if ($regex($1-,/^[!.@~].+@save$/Si)) {
    if (!$rowExists(users, rsn, $rsn($nick))) { noop $sqlite_query(1, INSERT INTO users (rsn, fingerprint) VALUES (' $+ $rsn($nick) $+ ',' $+ $aLfAddress($nick) $+ ');) }
    var %save = $remove($1-,@save)
    noop $_network(noop $!sqlite_query(1, update users set save=' $+ %save $+ ' WHERE fingerprint=' $+ $alfaddress($nick) $+ ';))
    $iif($chan,.notice,.msg) $nick Saved $qt(%save)
    tokenize 32 %save
  }
  ; RS forum link
  if ($regex(qfc,$1-,/forum\.runescape\.com\/forums\.ws\?(\d{1,3}\W\d{1,3}\W\d+\W\d+)/Si)) {
    if (Runescript isin $nick || Vectra isin $nick || $chanset($chan,qfc) == off) { goto clean }
    var %qfc = $regml(qfc,1), %ticks = %thread
    hadd -m %ticks out msg $iif($chan,$chan,$nick)
    hadd -m %ticks qfc $replace(%qfc,$chr(44),-)
    sockopen qfc. $+ %ticks forum.runescape.com 80
    goto clean
  }
  ; SPOTIFY link
  else if ($regex(spotify,$1-,/open\.spotify\.com\/track/(\w+)/Si)) {
    if ($chanset($chan,spotify) == off) goto clean
    _fillCommand %thread @ $nick $iif($chan,$v1,PM) Spotifylink
    var %url = http://sselessar.net/parser/spotify.php?id= $+ $regml(spotify,1)
    noop $download.break(spotify msg $iif($chan,$chan,$nick),%thread,%url)
    goto clean
  }
  ; YOUTUBE link
  else if ($regex(yt,$1-,/youtube\.com\/watch\?v=([\w-]+)\W?/Si)) {
    if ($chanset($chan,youtube) == off) goto clean
    _fillCommand %thread @ $nick $iif($chan,$v1,PM) Youtubelink
    var %url = http://rscript.org/lookup.php?type=youtubeinfo&id= $+ $regml(yt,1)
    noop $download.break(youtube %thread $regml(yt,1),%thread,%url)
  }
  ; DEFNAME
  else if ($regex($1,/^[!@.](def|set)(name|rsn)$/Si)) {
    if (!$2) { %saystyle Syntax Error: !defname <rsn> | goto clean }
    if ($regsubex($2-,/\W/,_) isin $readini(Gerty.Config.ini,admin,rsn) && !$admin($nick)) { %saystyle This RSN is protected, please Contact an Admin if this is your RSN. | goto clean }
    var %nick $regsubex($caps($left($2-,12)),/\W/g,_)
    if ($alfAddress($nick)) {
      noop $_network(noop $!setDefname( $v1 , %nick ))
      %saystyle Your default RuneScape name is now07 %nick $+ . This RSN is associated with the address07 $aLfAddress($nick,3) $+ .
    }
    else {
      %saystyle Error retrieving your address: please try the command again.
    }
    goto clean
  }
  ; RSN
  else if ($regex($1,/^[!@.](rsn|whois)$/Si)) {
    var %nick = $regsubex($iif($right($2-,1) == &,$left($2-,-1),$2-),/\W/,_)
    var %address = $aLfAddress(%nick)
    if ($3) .tokenize 32 $1 $replace($2-,$chr(32),_)
    if ($2) {
      if ($getDefname($2)) %saystyle 07 $+ $caps($2) $+ 's rsn is07 [ $v1 ]
      else %saystyle We have no rsn saved for07 $2
    }
    else {
      if ($getDefname($nick)) %saystyle 07 $+ $caps($nick) $+ 's rsn is07 [ $v1 ]
      else %saystyle We have no rsn saved for07 $nick
    }
    goto clean
  }
  ; NAME ; AVAILABLE
  else if ($regex($1,/^[!@.](name|available)$/Si)) {
    if (!$2) { %saystyle Syntax Error: !name <rsn> | goto clean }
    if ($len($2-) > 12) { %saystyle The max character limit for rsn's is 12 characters.07 $2- contains $len($2-) characters. | goto clean }
    var %rsn $replace($2-,$chr(32),_), %url https://secure.runescape.com/m=create/checkusername.ajax?username= $+ %rsn
    _fillCommand %thread $left($1,1) $nick $iif($chan,$v1,PM) name %rsn
    noop $download.break(name %thread, %thread, %url)
    goto clean
  }
  ; GRAPH
  else if ($regex($1,/^[!@.]graph$/Si)) {
    var %skill, %nick
    if ($3) { %nick = $rsn($replace($3-,$chr(32),_)) }
    else { %nick = $rsn($nick) }
    if ($2) { %skill = $scores($2) }
    else { %skill = overall }
    %saystyle $formatwith({0} 07{1} graph | 12http://t.rscript.org/graph-{0}.{2}.lvl.png | exp: 12http://t.rscript.org/graph-{0}.{2}.png | rank: 12http://t.rscript.org/graph-{0}.{2}.rank.png, %nick, %skill, $calc($statnum(%skill) -1))
    goto clean
  }
  ; GEUPDATE
  else if ($regex($1,/^[!@.]ge?u(pdate)?$/Si)) {
    var %output, %x = 2, %update
    %output = Recent Ge Updates (UK): $gettok($read(geupdate.txt,1),3,124) $+ 07 $gettok($read(geupdate.txt,1),1,124) $+  ( $+ $duration($calc($gmt - $gettok($read(geupdate.txt,1),2,124))) ago);
    while (%x <= 7) {
      if (!$read(geupdate.txt,%x)) { break }
      %update = $read(geupdate.txt,%x)
      %output = %output $gettok(%update,3,124) $+ 07 $gettok(%update,1,124) $+ ;
      inc %x
    }
    %saystyle %output
    goto clean
  }
  ; SETGEUPDATE
  else if ($regex($1,/^[!@.]setgeupdate$/Si)) {
    if ($nick isop $chan || $nick ishop $chan || $admin($nick)) {
      if $2 != on && $2 != off halt
      if $2 == on { noop $_network(noop $!dbUpdate(channel, `channel`=' $+ $chan $+ ', geupdate, on)) }
      if $2 == off { noop $_network( noop $!dbUpdate( channel , `channel`=' $+ $chan $+ ' , geupdate , off ) ) }
      %saystyle GE Update notification in $chan has been turned $2 $+ .
    }
    goto clean
  }
  ; CMBEST
  else if ($regex($1,/^[!@.]cmb-?est(imate)?$/Si)) {
    if (!$9) { %saystyle Syntax Error: !cmbest att def str hp range pray mage sum | goto clean }
    %saystyle estimated combat level:07 $floor($calccombat($2,$3,$4,$5,$6,$7,$8,$9).p2p) (07 $+ $floor($calccombat($2,$3,$4,$5,$6,$7,$8,$9).f2p) $+ ) | class:07 $calccombat($2,$3,$4,$5,$6,$7,$8,$9).class | 04AD04SH03RP12MS: 04 $+ $2  $+ $3 04 $+ $4  $+ $5 03 $+ $6  $+ $7 12 $+ $8  $+ $9
    goto clean
  }
  ; COORDS
  else if ($regex($1,/^[!@.](co-?ord|co-?ordinate)s?$/Si)) {
    var %regex = /(\d{2})\D*(\d{2})[^ns]*([ns])\D*(\d{2})\D*(\d{2})[^ew]*([ew])/i
    if (!$regex($2-,%regex)) { %saystyle Invalid coordinate search07 $remove($2-,$chr(32)) | halt }
    var %coord = $regml(1) $+ $regml(2) $+ $upper($regml(3)) $regml(4) $+ $regml(5) $+ $upper($regml(6))
    var %fname coord $+ $ran(0,999), %coordInfo
    .fopen %fname treasure.txt
    while (!$feof) {
      var %fileCoord = $fread(%fname)
      tokenize 9 %fileCoord
      if ($1 != COORD) { continue }
      if ($2 == %coord) {
        %coordInfo = $2-
        break
      }
    }
    .fclose %fname
    if ($numtok(%coordInfo,32) < 3) { %saystyle Could not locate07 $gettok(%coord,1,32) /07 $gettok(%coord,2,32) | goto clean }
    %saystyle Co-ordinates:07 $gettok(%coordInfo,1,32) /07 $gettok(%coordInfo,2,32) | Location:07 $gettok(%coordInfo,3-,32)
    goto clean
  }
  ; ANAGRAMS
  else if ($regex($1,/^[!@.](ana|anagrams?)$/Si)) {
    if (!$2) { %saystyle Syntax Error: !anagram <anagram> | goto clean }
    var %anagram = $read(anagram.txt,nw,* $+ $2- $+ *)
    if (!%anagram) { %saystyle Anagram "07 $+ $2- $+ " not found. | halt }
    %Saystyle Anagram:07 $gettok(%anagram,1,124) | NPC:07 $gettok(%anagram,2,124) | Location:07 $gettok(%anagram,3,124)
    goto clean
  }
  ; RIDDLES
  else if ($regex($1,/^[!@.]riddles?$/Si)) {
    if (!$2) { %saystyle Syntax Error: !riddle <riddle> | goto clean }
    var %riddle = $read(riddles.txt,nw,* $+ $2- $+ *)
    if (!%riddle) { %saystyle Riddle "07 $+ $2- $+ " not found. | halt }
    %Saystyle Riddle:07 $gettok(%riddle,1,124) | Location:07 $gettok(%riddle,2,124)
    goto clean
  }
  ; CHALLENGES
  else if ($regex($1,/^[!@.]challenges?$/Si)) {
    if (!$2) { %saystyle Syntax Error: !challenge <challenge question> | goto clean }
    var %challenge = $read(challenge.txt,nw,* $+ $2- $+ *)
    if (!%challenge) { %saystyle Challenge "07 $+ $2- $+ " not found. | halt }
    %Saystyle Challenge:07 $gettok(%challenge,1,124) | Answer:07 $gettok(%challenge,3,124) (07 $+ $gettok(%challenge,2,124) $+ )
    goto clean
  }
  ; URI
  else if ($regex($1,/^[!@.]uri$/Si)) {
    if (!$2) { %saystyle Syntax Error: !uri <uri clue> | goto clean }
    var %uri = $read(uri.txt,nw,* $+ $2- $+ *)
    if (!%uri) { %saystyle Uri clue "07 $+ $2- $+ " not found. | halt }
    %Saystyle Uri:07 $gettok(%uri,1,124) | Location:07 $gettok(%uri,3,124) | Gear:07 $+ $gettok(%uri,2,124)
    goto clean
  }
  ; CLAN
  else if ($regex($1,/^[!@.]clans?$/Si)) {
    var %user
    hmake %thread
    if ($2) { %user = $rsn($2-) }
    else { %user = $rsn($nick) }
    noop $download.break(getClans %user %saystyle clan %thread, a $+ $r(0,99999), http://runehead.com/feeds/lowtech/searchuser.php?user= $+ %user)
    noop $download.break(getClans %user %saystyle non-clan %thread, a $+ $r(0,99999), http://runehead.com/feeds/lowtech/searchuser.php?type=1&user= $+ %user)
    goto clean
  }
  ; STATISTICS ; % ; CMBPERCENT
  else if ($regex($1,/^([!@.](%|cmb%|combat%|p2p%|f2p%|sl%|slay%|slayer%|skill%|pc%|pest%|pestcontrol%|skiller%)|%)$/Si)) {
    var %nick
    if (!%saystyle) %saystyle = $iif($chan,.notice $nick,.msg $nick)
    if ($2) %nick = $rsn($2-)
    else %nick = $rsn($nick)
    var %socket = spam. $+ %thread
    var %url = http://hiscore.runescape.com/index_lite.ws?player= $+ %nick
    noop $download.break(cmbpercent %saystyle %nick %socket, %socket, %url)
    goto clean
  }
  ; RANK
  else if ($regex($1,/^[@!.]Rank$/Si)) {
    var %skill, %rank, %rawRank $litecalc($remove($2,$#)), %skill1 $scores($3), %skill2 $scores($2)
    if (%skill1 && %rawRank >= 1 && %rawRank <= 2000000) {
      %skill = %skill1
      %rank = %rawRank
    }
    var %rawRank = $litecalc($remove($3,$#))
    if (%skill2 && %rawRank >= 1 && %rawRank <= 2000000) {
      %skill = %skill2
      %rank = %rawRank
    }
    _fillCommand %thread $left($1,1) $nick $iif($chan, $v1, PM) rank %skill %rank
    if (!%rank || !%skill) {
      $cmd(%thread,out) Invalid Command. !rank <number> <skill>
      _clearCommand %thread
      halt
    }
    sockopen $+(rank.,%thread) hiscore.runescape.com 80
    goto clean
  }
  ; SHOP
  else if ($regex($1,/^[!@.](shop|store)$/Si)) {
    if (!$2) { %saystyle Syntax Error: !shop <item> }
    hadd -m %thread item $replace($2-,$chr(32),+)
    hadd -m %thread out %saystyle
    sockopen $+(shop.,%thread) www.tip.it 80
    goto clean
  }
  ; SKILLPLAN
  else if ($regex($1,/^[!@.]([a-z]+)-*plan$/i)) {
    var %skill = $skills($regml(1)), %amount, %item, %nick
    if (!%skill) halt
    if (!$3) { %saystyle Syntax Error: !<skill>plan [rsn] <amount> <item> | halt }
    if ($litecalc($2)) {
      %amount = $v1
      %item = $3-
      %nick = $rsn($nick)
    }
    else {
      %amount = $litecalc($3)
      %item = $4-
      %nick = $rsn($2)
    }
    hadd -m %thread out %saystyle
    hadd -m %thread nick %nick
    hadd -m %thread amount %amount
    hadd -m %thread item %item
    hadd -m %thread skill %skill
    _fillCommand %thread $left($1,1) $nick $iif($chan,$v,PM) skillplan %nick %amount %item %skill
    sockopen $+(skillplan.,%thread) hiscore.runescape.com 80
    goto clean
  }
  ; FML
  else if ($regex($1,/^[!@.]f(uck)?my?l(ife)?$/Si)) {
    if (!$2) { var %page = /random }
    else { var %page = / $+ $remove($2,$chr(35)) }
    hadd -m %thread page %page
    hadd -m %thread out %saystyle
    sockopen $+(fml.,%thread) www.fmylife.com 80
    goto clean
  }
  ; NEXT AND HILOW
  else if ($regex($1,/^[!@.](next(lvl)?|close(est)?|hi(gh)?(est|low?)?|low(est)?)$/Si)) {
    var %nick, %state, %string, %url, %command
    %string = $2-
    %state = 3
    if ($regex(%string,/@(\w+)( |$)/)) {
      %state = $state($regml(1))
      %string = $trim($regsubex(%string,/@(\w+)( |$)/,$null))
    }
    if (%state == 2) { %state = 3 }
    %nick = $nick
    if ($len(%string) > 0) {
      %nick = %string
    }
    %nick = $rsn(%nick)
    %command = $misc($right($1,-1))
    %url = http://hiscore.runescape.com/index_lite.ws?player= $+ %nick
    noop $download.break(stats. $+ %command %saystyle %nick %state,stats. $+ %thread,%url)
    goto clean
  }
  ; IQ AND LIFE AND EPENIS
  else if ($regex($1,/^[!@.](iq|life|e-?penis)$/Si)) {
    var %nick, %command = $remove($right($1,-1),-)
    if (!$2) %nick = $rsn($nick)
    if ($2) %nick = $rsn($2-)
    var %socket = stats. $+ %thread
    var %url = http://hiscore.runescape.com/index_lite.ws?player= $+ %nick
    noop $download.break(spam. $+ %command %saystyle %nick %socket,%socket,%url)
    goto clean
  }
  ; QFC
  else if ($regex($1,/^[!@.]qfc$/Si)) {
    if ($regex($2-,/^(\d{1,3}\W\d{1,3}\W\d+\W\d+)/Si)) {
      var %qfc = $regsubex($regml(1),/\W/Sg,-)
      hadd -m %thread out %saystyle
      hadd -m %thread qfc %qfc
      hadd -m %thread link yes
      sockopen qfc. $+ %thread forum.runescape.com 80
    }
    else { %saystyle Syntax Error: !qfc <rsof qfc> }
    goto clean
  }
  ; GELINK
  else if ($regex($1,/^[!@.](g(reat|rand)?e(xchange)?|price)$/Si)) {
    if (!$2) { %saystyle Syntax: !ge [number] <item> | halt }
    if ($chr(44) !isin $2-) {
      var %num = 1, %search = $2-
      if ($fixInt($2) >= 1) {
        %num = $v1
        %search = $3-
      }
      var %dbPrices $getPrice(%search)
      if (!%dbPrices) {
        _fillCommand %thread $left($1,1) $nick $iif($chan,$v1,PM) gelink %num $replace(%search, $chr(32), _)
        var %url http://gerty.rsportugal.org/parsers/ge.php?item= $+ $replace(%search,$chr(32),+)
        noop $download.break(downloadGe %thread,%thread,%url)
        halt
      }
      var %numberOfResults = $countResults($getPrice(%search).sql)
      .tokenize 44 %dbPrices
      var %x = 1, %results
      while (%x <= $0 && $len(%results) < 350) {
        var %name = $gettok($($ $+ %x,2),1,59), %price = $gettok($($ $+ %x,2),2,59), %change = $gettok($($ $+ %x,2),3,59)
        %results = %results | %name $+ 07 $format_number($calc(%price * %num)) $updo(%change)
        inc %x
      }
      %saystyle Results:07 %numberOfResults (07x $+ %num $+ ) %results
    }
    else {
      tokenize 44 $2-
      var %x 1, %output, %totalPrice
      while (%x <= $0) {
        var %num 1, %dirtyItem $($ $+ %x,2), %cleanItem $trim(%dirtyItem), %itemPrice
        if ($fixint($gettok(%dirtyItem,1,32)) > 0) {
          %num = $v1
          %cleanItem = $trim($gettok(%dirtyItem,2-,32))
        }
        %itemPrice = $exactPriceInfo(%cleanItem)
        if ($gettok(%itemPrice,2,59) == 0 || $gettok(%itemPrice,2,59) == null) {
          %saystyle item07 $gettok(%itemPrice,1,59) was not found on the grand exchange database. Make sure you use exact terms when looking up multiple items.
          inc %x
          continue
        }
        %output = %output $iif(%num > 1,%num) $gettok(%itemPrice,1,59) 07 $+ $format_number($calc(%num * $gettok(%itemPrice,2,59))) $updo($calc(%num * $gettok(%itemPrice,3,59))) $+ ;
        %totalPrice = $calc(%totalPrice + (%num * $gettok(%itemPrice,2,59)))
        inc %x
      }
      if ($len(%output) > 0) {
        %saystyle grand exchange results: %output
        %saystyle Total item values:07 $regsubex($format_number(%totalPrice),/(\d+)/,$bytes(\1,db)) gp.
      }
    }
    goto clean
  }
  ; GEINFO
  else if ($regex($1,/^[!@.]g(reat|rand)?e(xchange)?(info)$/Si)) {
    if (!$2) { %saystyle Syntax: !geinfo <item> | halt }
    var %id $fixInt($remove($2-,$chr(35)))
    if (%id > 0) {
      var %id = $regsubex($2-,/(\D+)/g,$null)
      _fillCommand %thread $left($1,1) $nick $iif($chan,$v1,PM) geinfo
      var %url http://gerty.rsportugal.org/parsers/geinfo.php?id= $+ %id
      noop $download.break(geInfo %thread,%thread,%url)
      goto clean
    }
    var %items $getPriceId($2-), %left $left($1,1)
    .tokenize 44 %items
    if ($0 == 1) {
      var %id = $gettok(%items,1,59)
      _fillCommand %thread %left $nick $iif($chan,$v1,PM) geinfo
      var %url http://gerty.rsportugal.org/parsers/geinfo.php?id= $+ %id
      noop $download.break(geInfo %thread,%thread,%url)
      goto clean
    }
    var %x 1, %itemList = |
    while (%x <= $0) {
      %itemList = %itemList $trim($gettok($($ $+ %x,2),2,59)) 07 $+ $# $+ $trim($gettok($($ $+ %x,2),1,59)) $+ ;
      if ($len(%itemList) > 400) break
      inc %x
    }
    %saystyle Results:07 $0 $iif($0 > 1,%itemList)
    goto clean
  }
  ; GOOGLE
  else if ($regex($1,/^[!@.]y(ou)?t(ube)?$/Si)) {
    hadd -m %thread out %saystyle
    if ($2) {
      hadd -m %thread page video
      hadd -m %thread search $urlencode($2-)
      sockopen $+(google.,%thread) ajax.googleapis.com 80
    }
    else {
      %saystyle Syntax Error: !youtube <search term>
    }
    goto clean
  }
  else if ($regex($1,/^[!@.]google$/Si)) {
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
        hadd -m %thread search $2-
      }
      else {
        %saystyle Syntax Error: !google [-vi] <search term> (-i image search, -v video search)
      }
    }
    sockopen $+(google.,%thread) ajax.googleapis.com 80
    goto clean
  }
  ; COINSHARE
  else if ($regex($1,/^[!@.]c(oin)?s(hare)?$/Si)) {
    var %people, %search = $remove($3-,$#)
    if ($2 isnum) %people = $2
    else goto csSyntax
    if (%search isnum) {
      _fillCommand %thread $left($1,1) $nick $iif($chan,$v1,PM) coinshare %people
      var %url http://gerty.rsportugal.org/parsers/geinfo.php?id= $+ %search
      noop $download.break(csOut %thread, %thread, %url)
      goto clean
    }
    var %sql $dbSelectWhere(prices, id;name, name LIKE "% $+ %search $+ $% $+ ").sql
    var %results $countResults(%sql)
    if (!%results) {
      %saystyle No results for07 %search found. If you think this is a valid item, please report it at #gerty
      goto clean
    }
    var %items $getPriceId(%search)
    if (%results == 1) {
      _fillCommand %thread $left($1,1) $nick $iif($chan,$v1,PM) coinshare %people
      var %url http://gerty.rsportugal.org/parsers/geinfo.php?id= $+ $gettok(%items, 1, 59)
      noop $download.break(csOut %thread, %thread, %url)
    }
    else {
      .tokenize 44 %items
      var %x 1, %itemList, %item
      while (%x <= %results && %x <= 10) {
        %item = $($ $+ %x,2)
        %itemList = %itemList $gettok(%item,2,59) 07 $+ $# $+ $trim($gettok(%item,1,59)) $+ ;
        inc %x
      }
      %saystyle Results:07 %results | %itemList
    }
    goto clean
    :csSyntax
    %saystyle Syntax Error: !coinshare <number of people> <item|#itemId>
    goto clean
  }
  ; QUEST
  else if ($regex($1,/^[!@.]quest$/Si)) {
    if (!$2) { %saystyle Syntax Error: !quest #<id> or !quest [-t] <search> | halt }
    hadd -m %thread out %saystyle
    if ($2 == -t) {
      hadd -m %thread search $replace($3-,$chr(32),+)
      hadd -m %thread switch yes
      hadd -m %thread command questSearch
      sockopen $+(rs2quest.,%thread) www.tip.it 80
    }
    elseif ($2 !isnum && $left($2,1) != $chr(35)) {
      hadd -m %thread search $2-
      hadd -m %thread command questSearch
      sockopen $+(rs2quest.,%thread) www.tip.it 80
    }
    else {
      hadd -m %thread id $remove($2,$chr(35))
      hadd -m %thread command questInfo
      sockopen $+(rs2questinfo.,%thread) www.tip.it 80
    }
    goto clean
  }
  ; TOP
  else if ($regex($1,/^[!@.](table|top|top10)$/Si)) {
    var %skill overall
    if ($scores($2)) {
      %skill = $v1
      .tokenize 32 $1 $3-
    }
    var %rank $false, %string $2-, %nick $false
    if ($regex($2-,/(?:#|^)(\d+[km]?)( |$)/S)) {
      %rank = $fixInt($regml(1))
      %string = $regsubex($2-,/(?:#|^)(\d+[km]?)( |$)/S,$null)
    }
    if ($trim(%string)) %nick = %string
    _fillcommand %thread $left($1,1) $nick $iif($chan,$v1,PM) top %skill %rank %nick
    var %url = http://gerty.rsportugal.org/parsers/hiscores.php?cat= $+ $catno(%skill) $+ &table= $+ $smartno(%skill) $+ &user= $+ $iif(%nick,$v1) $+ &rank= $+ $iif(%rank,$v1)
    noop $download.break(topOut %thread, %thread, %url)
    goto clean
  }
  ; CIRCUS
  else if ($regex($1,/^[!.@]circus$/Si)) {
    _fillCommand %thread $left($1,1) $nick $iif($chan,$v1,PM) circus
    sockopen circus. $+ %thread runescape.wikia.com 80
    goto clean
  }
  ; TASK
  else if ($regex($1,/^[!@.]Task$/Si)) {
    if (!$2) { %saystyle Invalid Syntax: !task <number> <monster> | halt }
    _fillCommand %thread $left($1,1) $nick $iif($chan,$v1,PM) task $rsn($nick) $litecalc($2) $replace($plural($3-),$chr(32),_)
    noop $download.break(taskOut %thread, %thread, http://hiscore.runescape.com/index_lite.ws?player= $+ $rsn($nick))
    goto clean
  }
  ; TIMER - REWRITE MAYBE
  else if ($regex($1,/^[!@.](start|check|end|stop)$/Si)) {
    var %command $regml(1)
    if (%command == stop) { %command = end }
    var %nick, %skill
    var %x = 2, %input
    while (%x < $0) {
      %input = %input $($ $+ %x,2)
      inc %x
    }
    if ($skills($2) && $3) { %skill = $skills($2) | %nick = $regsubex($3-,/\W/g,_) }
    else if ($skills($($ $+ $0,2)) && $skills($($ $+ $0,2)) && $3) { %skill = $skills($($ $+ $0,2)) | %nick = $regsubex(%input,/\W/g,_) }
    else if ($2 && (!$skills($($ $+ $0,2)))) { %nick = $regsubex($2-,/\W/g,_) | %skill = Overall }
    else if ($2) { %nick = $nick | %skill = $skills($2) }
    else { %nick = $nick | %skill = Overall }
    %nick = $rsn(%nick)
    %skill = $skills(%skill)
    if (%command == start) {
      if (($readini(timer.ini,%nick,start) && $readini(timer.ini,%nick,start) != 0)) {
        %saystyle You must end your current timer (07 $+ $readini(timer.ini,%nick,skill) $+ ) before starting a new one.
        halt
      }
      noop $_network(writeini -n timer.ini %nick owner $rsn($nick))
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
      if ($readini(timer.ini,%nick,owner) != $rsn($nick)) {
        %saystyle This is not your timer to end!
        halt
      }
    }
    var %skillid = $statnum(%skill)
    var %socket = %thread
    var %url = http://hiscore.runescape.com/index_lite.ws?player= $+ %nick
    noop $download.break(timer. $+ %command %saystyle %skill %skillid %nick,%socket,%url)
    goto clean
  }
  ;URBAN
  else if ($regex($1,/^[!@.](urban|ud)$/Si)) {
    _fillCommand %thread $left($1,1) $nick $iif($chan,$v1,PM) urban $replace($2-,$chr(32),+)
    var %url = http://www.rscript.org/lookup.php?type=urban&id=1&search= $+ $cmd(%thread,arg1)
    noop $download.break(urban %thread,urban. $+ %thread, %url)
  }
  ; ITEM
  else if ($regex($1,/^[!@.](hi(gh)?|low?)?(item|alch|alk)$/Si)) {
    if (!$2) %saystyle Syntax Error: !item <item|#item id>
    var %search $remove($2-,$#)
    var %url http://sselessar.net/Gerty/parser.php?type=items&item= $+ $urlencode(%search)
    _fillCommand %thread $left($1,1) $nick $iif($chan,$v1,PM) item %search
    noop $download.break(itemOut %thread, %thread, %url)
    goto clean
  }
  ; WORLD
  else if ($regex($1,/^[!@.](world|w|player)s?$/Si)) {
    if ($2 !isnum) { goto players }
    var %lang /l=0
    var %world = World
    if ($regex($2,/(122|139|140|146|147)/)) {
      var %lang /l=1
      var %world Welt
    }
    else if ($regex($2,/(128|150)/)) {
      var %lang /l=2
      var %world Serveur
    }
    else if ($regex($2,/(125|126|127)/)) {
      var %lang /l=3
      var %world Mundo
    }
    _fillCommand %thread $left($1,1) $nick $iif($chan,$v1,PM) World %lang %world $2
    sockopen $+(world.,%thread) www.runescape.com 80
    goto clean
    :players
    _fillcommand %thread $left($1,1) $nick $iif($chan,$v1,PM) Players
    sockopen $+(world2.,%thread) www.runescape.com 80
    goto clean
  }
  ; NPC DROPS - REWRITE {JSON PARSER}
  else if ($regex($1,/^[!@.](npc|monster|mdb(info)?|drops?|loot)$/Si)) {
    var %command
    if (!$2) { %saystyle you must specify a monster to look up. }
    if ($regex($right($1,-1),/(drops?|loot)/i)) %command = drop
    else %command = npc
    if ($left($2,1) != $chr(35) && $2 !isnum) {
      hadd -m %thread npc $replace($2-,$chr(32),+)
      hadd -m %thread out %saystyle
      hadd -m %thread command %command
      sockopen $+(drop.,%thread) www.zybez.net 80
    }
    if ($left($2,1) == $chr(35) || $2 isnum) {
      hadd -m %thread id $remove($2,$chr(35))
      hadd -m %thread out %saystyle
      hadd -m %thread command %command
      sockopen $+(drop2.,%thread) www.zybez.net 80
    }
    goto clean
  }
  ; ALOG
  else if ($regex($1,/^[!.@]a(chievements?)?log$/Si)) {
    if ($2 == -r) {
      _fillCommand %thread $left($1,1) $nick $iif($chan,$v1,PM) alog-r $rsn($iif($3,$regsubex($3-,/[\W_]/Sg,_),$nick))
      noop $download.break(alog-r %thread ,%thread,http://sselessar.net/parser/alog-rss.php?rsn= $+ $hget(%thread,arg1) )
    }
    else {
      _fillCommand %thread $left($1,1) $nick $iif($chan,$v1,PM) alog $rsn($iif($2,$regsubex($2-,/[\W_]/Sg,_),$nick))
      noop $download.break(alog %thread ,%thread,http://sselessar.net/parser/alog-rss.php?rsn= $+ $hget(%thread,arg1) )
    }
    goto clean
  }
  ; SPELL
  else if ($regex($1,/^[!.@](mag(e|ic))?spell?$/Si)) {
    .tokenize 32 $remove($2-,$chr(44),$chr(36))
    if ($litecalc($1)) { var %num $v1 | var %spell $2- }
    else { var %num 1 | var %spell $1- }
    if ($chr(34) isin %spell) { var %spell $remove(%spell,$chr(34)) | var %exact $true }
    var %fname $newThread
    .fopen %fname param.txt
    var %x 1, %y $lines(param.txt)
    while (!$feof && %x <= 4 && %y) {
      var %spel = $fread(%fname)
      tokenize 9 %spel
      if ($1 != MAGIC) { dec %y | continue }
      if ($iif(%exact,$+(%spell,$chr(9)),%spell) isin %spel) {
        var %spellname $4
        var %spellexp $calc(%num * $3)
        var %spelllvl $2
        var %spellrunes $regsubex($5,/(\d+) (\w+)/ig,$calc(%num * \1) \2)
        var %spellprice $calc($replace($regsubex(%spellrunes,/(\d+) (\w+)/Sig,$calc( $+(\1,$chr(42),$hget(runeprice,\2 $+ _Rune)) )),$chr(32),$chr(43),$chr(44),$chr(32)))
        var %spellmax $6
        var %spellbook $7
        var %spellother $8
        %saystyle Magic Params07 %spellname $+(,$iif(%num > 1,$+($chr(40),x,07,%num,,$chr(41),$chr(32))),$chr(124)) Exp:07 $bytes(%spellexp,bd)  $+ $chr(124) Level:07 %spelllvl  $+ $chr(124) Runes:07 $regsubex(%spellrunes,/(\d+) (\w+)(\x2c)?/ig,$bytes(\1,bd) \2 $+ $iif(\3,$+(,\3,07)))  $+ $chr(124) Price:07 $bytes(%spellprice,bd) $+ gp $chr(124) Max hit:07 %spellmax  $+ $chr(124) Spellbook:07 %spellbook  $+ $chr(124) Other info:07 %spellother $+ .
        inc %x
      }
      dec %y
    }
    if (%x == 1) { %saystyle 07 $+ $iif(%exact,Exact match $+(07,",%spell,"),%spell) $+  spell not found. }
    .fclose %fname
    goto clean
  }
  ; LASTNDAYS
  else if ($regex($1,/^[!@.](l|last)(\d+)([A-Za-z]+)$/Si)) {
    var %time = $regml(2) $+ $regml(3)
    %time = $duration(%time)
    if ($2) { var %nick = $rsn($2-) }
    if (!$2) { var %nick = $rsn($nick) }
    hadd -m %thread nick %nick
    hadd -m %thread time %time
    hadd -m %thread command Last $regsubex($duration(%time),/(\d+)([A-Za-z]+)/g,\1 \2)
    hadd -m %thread skill $skills($2)
    hadd -m %thread out %saystyle
    sockopen $+(trackyes.,%thread) www.rscript.org 80
    goto clean
  }
  ; NDAYSAGO
  else if ($regex($1,/^[!@.](\d+)([A-Za-z]+)ago$/Si)) {
    var %time $regml(1) $+ $regml(2)
    if ($2) { var %nick = $rsn($2-) }
    if (!$2) { var %nick = $rsn($nick) }
    var %input = $1-
    .tokenize 32 $timetoday
    var %today = $1, %week = $2, %month = $3, %year = $4
    .tokenize 32 %input
    %time = $calc($duration(%time) + %today)
    hadd -m %thread nick %nick
    hadd -m %thread time %time
    hadd -m %thread time2 $calc(%time - 86400)
    hadd -m %thread command $regsubex($duration($calc(%time - %today)),/(\d+)([A-Za-z]+)/g,\1 \2) ago
    hadd -m %thread skill $skills($2)
    hadd -m %thread out %saystyle
    sockopen $+(trackyes.,%thread) www.rscript.org 80
    goto clean
  }
  ; TODAY/WEEK/MONTH/YEAR
  else if ($regex($1,/^[!@.](today|week|month|year)$/Si)) {
    var %input = $1-
    .tokenize 32 $timetoday
    var %today = $1, %week = $2, %month = $3, %year = $4
    .tokenize 32 %input
    var %string = $2-
    var %command = $right($1,-1)
    var %time = % [ $+ [ %command ] ]
    var %nick = $nick
    if ($len($trim(%string)) > 0) {
      %nick = $trim(%string)
    }
    %nick = $rsn(%nick)
    var %url = http://www.rscript.org/lookup.php?type=track&user= $+ %nick $+ &skill=all&time= $+ %time
    noop $download.break(trackAll %saystyle %nick %time %command, %thread, %url)
    goto clean
  }
  ; LASTWEEK ; LASTMONTH ; LASTYEAR ; YESTERDAY
  else if ($regex($1,/^[!@.](?:y(?:ester)?(day)|l(?:ast)?(week|month|year))$/Si)) {
    var %timescale = $regml(1), %time, %time2, %command
    var %input = $1-
    .tokenize 32 $timetoday
    var %today = $1, %week = $2, %month = $3, %year = $4
    .tokenize 32 %input
    if ($2) { var %nick = $rsn($2-) }
    if (!$2) { var %nick = $rsn($nick) }
    if (%timescale == day) {
      ; start of yday
      %time = $calc(%today + 86400)
      ; start of today
      %time2 = %today
      %command = Yesterday
    }
    else if (%timescale == week) {
      %time = $calc(%week + 604800)
      %time2 = %week
      %command = Last Week
    }
    else if (%timescale == month) {
      var %lastmonth $replace($date(mmm),Jan,2419200,Feb,2678400,Mar,2592000,Apr,2678400,May,2592000,Jun,2678400,Jul,2678400,Aug,2592000,Sep,2678400,Oct,2592000,Nov,2678400,Dec,2678400)
      %time = $calc(%month + %lastmonth)
      %time2 = %month
      %command = Last Month
    }
    else {
      %time = $calc(%year + 31536000)
      %time2 = %year
      %command = %last Year
    }
    hadd -m %thread nick %nick
    hadd -m %thread time %time
    hadd -m %thread time2 %time2
    hadd -m %thread command %command
    hadd -m %thread out %saystyle
    sockopen $+(trackyes.,%thread) www.rscript.org 80
    goto clean
  }
  ; TRACK
  else if ($regex($1,/^[!@.]track$/Si)) {
    var %input = $1-
    .tokenize 32 $timetoday
    var %today = $1, %week = $2, %month = $3, %year $4
    .tokenize 32 %input
    ;skill specified
    if ($lookups($2)) {
      var %string = $3-
      var %time = null
      if ($regex(%string,/(?:^| )@(.+?)$/)) {
        %time = $regml(1)
        if (%time !isnum) { %time = $duration(%time) }
        var %string = $regsubex(%string,/(?:^| )@(.+?)$/,$null)
      }
      if ($len($trim(%string)) > 0) {
        var %nick = $rsn($trim(%string))
      }
      if (!%nick) { %nick = $rsn($nick) }
      var %skill = $scores($2)
      var %socket = stats. $+ %thread
      var %url = http://hiscore.runescape.com/index_lite.ws?player= $+ %nick
      noop $download.break(stats %saystyle $replace(%skill,$chr(32),_) $statnum(%skill) %nick null nl 1 200000001 %socket yes yes %time, %socket, %url)
    }
    ;skill not specified
    if (!$scores($2)) {
      var %string = $2-
      var %time = %today, %command = Today
      if ($regex(%string,/(?:^| ?)@(.+?)$/)) {
        %time = $regml(1)
        if (%time !isnum) { %time = $duration(%time) }
        %command = $duration(%time)
        var %string = $regsubex(%string,/(?:^| ?)@(.+?)$/,$null)
      }
      var %nick = $nick
      if ($len($trim(%string)) > 0) {
        %nick = $trim(%string)
      }
      %nick = $rsn(%nick)
      var %socket = %thread
      var %url = http://www.rscript.org/lookup.php?type=track&user= $+ %nick $+ &skill=all&time= $+ %time
      noop $download.break(trackAll %saystyle %nick %time $replace(%command, $chr(32), _), %socket, %url)
    }
    goto clean
  }
  ; COMPARE
  else if ($regex($left($1,1),/[!@.]/) && $misc($right($1,-1)) == compare) {
    if (!$2) { %saystyle Syntax Error: !compare [skill] <nick1> [nick2] [@time period] | goto clean }
    var %skill $compares($2), %left $left($1,1)
    if (!%skill) { %skill = overall | .tokenize 32 $2- }
    else .tokenize 32 $3-
    var %string $1-
    var %time Today
    if ($regex($1-,/@([^ ]+)\b/Si)) {
      var %time $regml(1)
      .tokenize 32 $regsubex(%string,/@([^ ]+)\b/Si,$null)
    }
    if ($0 == 0) { %saystyle Syntax Error: !compare [skill] 04<nick1> [nick2] [@(today|week|month|year)] | goto clean }
    var %nick1, %nick2
    if ($0 == 1) {
      %nick1 = $rsn($nick)
      %nick2 = $rsn($1)
    }
    else {
      %nick1 = $rsn($1)
      %nick2 = $rsn($2-)
    }
    var %thread2 $+(a,$r(0,99999))
    _fillCommand %thread %left $nick $iif($chan,$v1,PM) compare %thread2 $replace(%skill,$chr(32),_) %nick1 %time
    _fillCommand %thread2 %left $nick $iif($chan,$v1,PM) compare %thread $replace(%skill,$chr(32),_) %nick2 %time
    var %url http://hiscore.runescape.com/index_lite.ws?player=
    noop $download.break(compareOut %thread, %thread, %url $+ %nick1)
    noop $download.break(compareOut %thread2, %thread2, %url $+ %nick2)
    goto clean
  }
  ; STATS
  if ($left($1,1) isin .@! && $lookups($right($1,-1))) {
    var %string = $2-
    var %param = null, %presetparam = yes
    if ($regex(%string,/@([^@#]+)/)) {
      %param = $regml(1)
      %presetparam = no
      %string = $regsubex(%string,/@([^@#]+)/,$null)
    }
    var %goal = nl, %presetgoal = yes
    if ($regex(%string,/(?:#|goal=)([nl0-9]+[mkb]?)/)) {
      %goal = $regml(1)
      %presetgoal = no
      %string = $regsubex(%string,/(?:#|goal=)([nl0-9]+[mkb]?)/,$null)
    }
    var %lessthan = 200000001
    if ($regex(%string,/<([0-9]+[mkb]?)/)) {
      %lessthan = $fixInt($regml(1))
      %string = $regsubex(%string,/<([nlr0-9]+[mkb]?)/,$null)
    }
    var %morethan = 0
    if ($regex(%string,/>([0-9]+[mkb]?)/)) {
      %morethan = $fixInt($regml(1))
      %string = $regsubex(%string,/>([nlr0-9]+[mkb]?)/,$null)
    }
    if ($regex(eq,%string,/=([0-9]+[mkb]?)/)) {
      if ($fixInt($regml(eq,1)) < 127) {
        %morethan = $lvltoxp($v1)
        %lessthan = $calc($lvltoxp($fixInt($regml(eq,1) + 1)) + 1)
      }
      else {
        %morethan = $fixInt($regml(eq,1))
        %lessthan = $fixInt($regml(eq,1) + 1)
      }
      %string = $regsubex(%string,/=([nlr0-9]+[mkb]?)/,$null)
    }
    var %nick = $rsn($nick)
    if ($len($trim(%string)) > 0) {
      %nick = $trim(%string)
      %nick = $rsn(%nick)
    }
    %nick = $left($caps(%nick),12)
    if (%param == next) {
      var %command = next
      var %state = 3
      var %url = http://hiscore.runescape.com/index_lite.ws?player= $+ %nick
      noop $download.break(stats. $+ %command %saystyle %nick %state,stats. $+ %thread,%url)
      goto unset
    }
    %param = $replace(%param,$chr(32),~)
    var %skill = $lookups($right($1,-1))
    var %skillid = null
    if ($statnum(%skill)) { %skillid = $v1 }
    var %socket = stats. $+ %thread
    var %url = http://www.rscript.org/lookup.php?type=track&user= $+ %nick $+ &skill=all&time=10000
    noop $download.break(die,%socket $+ 1,%url)
    var %url = http://hiscore.runescape.com/index_lite.ws?player= $+ %nick
    noop $download.break(stats %saystyle $replace(%skill,$chr(32),_) %skillid %nick %param %goal %morethan %lessthan %socket %presetgoal %presetparam null,%socket,%url)
    :unset
    goto clean
  }
  ; LOGIN
  else if ($regex($1,/^[!@.]login$/Si)) {
    if ($2 == $readini(Gerty.Config.ini,admin,pass)) {
      var %rsn = Gerty
      if ($admin($3)) { %rsn = $3 }
      noop $_network(noop $!setDefname( $aLfAddress($nick) , %rsn ))
      %saystyle You are now logged in as Gerty admin.
    }
    goto clean
  }
  ; COMMANDS
  else if ($regex($1,/^[!@.]commands?$/Si)) {
    %saystyle Commands Listing:07 http://gerty.rsportugal.org/commands.html
    goto clean
  }
  ; PART
  else if ($chan && $regex($1,/^[!@.]part$/Si)) {
    if (($admin($nick) || $nick isop $chan || $nick ishop $chan) && ($2 == $me)) { part $chan Parted from07 $chan by07 $nick }
    goto clean
  }
  ; BHTIMER
  else if ($regex($1,/^[!@.]bhtimer$/Si)) {
    %saystyle Your Bounty Hunter death timer has been set.
    .timer 1 30 %saystyle Your Bounty Hunter timer has Expired.
    goto clean
  }
  ; TIMER
  else if ($regex($1,/^[!@.]timer$/Si)) {
    if ($2 isnum) {
      var %time = $calc($2 * 60 + $ctime($asctime($gmt)))
      write timer.txt %time $+ $chr(124) $+ %saystyle $nick $+ , your timer has expired.
      %saystyle Your timer will expire in $duration($calc($2 * 60)) $+ .
    }
    else { %saystyle You must specify a time(mins) for your timer to expire. }
    goto clean
  }
  ; SHARDS
  else if ($regex($1,/^[!@.](sh|shards?)$/Si)) {
    var %familiar = $read(summoning.txt,w,$gettok($2-,2,64) $+ *)
    var %expgain = $calculate($2)
    if (!$3 || !%familiar || %expgain !isnum) { %saystyle Syntax Error: !shards <exp gain> @<familiar> | goto clean }
    var %familiar.name = $gettok(%familiar,1,9)
    var %familiar.exp = $gettok(%familiar,2,9)
    var %familiar.shards = $gettok(%familiar,5,9)
    var %familiar.total = $ceil($calc( %expgain / %familiar.exp ))
    var %shard.total = $calc( %familiar.shards * %familiar.total )
    var %shard.left = $calc( %shard.total * 0.1 )
    if (%shard.left > 100000) { %shard.left = 100000 }
    if (%shard.left < $calc( 5 * 25 * %familiar.shards ) && %shard.total > $calc( 5 * 25 * %familiar.shards )) { %shard.left = $calc( 5 * 25 * %familiar.shards ) }
    var %y = $calc( (%expgain / %familiar.exp ) * 0.3 * %familiar.shards )
    %saystyle For07 $bytes(%expgain,db) experience making familiar %familiar.name $+ ,07 $bytes(%shard.total,db) shards, or07 $bytes($ceil(%y),db) minimum including trading in pouches
    goto clean
  }
  ; PUBLIC
  else if ($chan && $regex($1,/^[!@.]public$/Si)) {
    if ($nick !isop $chan && $nick !ishop $chan && !$admin($nick)) { halt }
    if ($2 == on) {
      noop $_network(noop $!dbUpdate(channel, `channel`=' $+ $chan $+ ', public, on))
      %saystyle Channel commands set to07 On for07 All Users.
    }
    if ($2 == off) {
      noop $_network(noop $!dbUpdate(channel, `channel`=' $+ $chan $+ ', public, off))
      %saystyle Channel commands set to07 Off for07 All Users.
    }
    if ($2 == voice) {
      noop $_network(noop $!dbUpdate(channel, `channel`=' $+ $chan $+ ', public, voice))
      %saystyle Channel commands set to07 On for07 Voice+, and 07Off for 07Unvoiced Users.
    }
    if ($2 == half) {
      noop $_network(noop $!dbUpdate(channel, `channel`=' $+ $chan $+ ', public, half))
      %saystyle Channel commands set to07 On for07 HalfOp+, and 07Off for 07Voiced and Unvoiced Users.
    }
    goto clean
  }
  ; FAIRY
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
  ; LOOTSHARE WORLDS [ACTIVITY]
  else if ($regex($1,/^[!@.]l(oot)?s(hare)?$/Si)) {
    %saystyle 07P2P Lootshare Worlds: 9 12 22 28 39 44 46 48 51 54 56 59 64 76 84 88 91 92 97 98 112 114 117 131 145 151 157 158
    %saystyle 07F2P Lootshare Worlds: 7 10 11 14 29 30 33 34 35 37 40 41 43 47 75 85 93 94 95 106 108 113 118 120 126 127 134 142 153 154 155 169
    goto clean
  }
  ; PVP WORLDS [ACTIVITY]
  else if ($regex($1,/^[!@.]pvp?$/Si)) {
    %saystyle PVP worlds: 07F2P: 21 32 55 62 63 72 74 80 101 109 122 123 125 136 | 07P2P: 23 65 89 111 124 137 150 159 164 167
    goto clean
  }
  ; ACTIVITY
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
  ; SET
  else if ($regex($1,/^[!@.]set(tings?)?$/Si)) {
    var %command $2
    var %mode $iif($3 == on,on,off)
    if ($chan && ($nick isop $chan || $nick ishop $chan || $admin($nick))) {
      if (%command == youtube) {
        noop $_network(noop $!setStringParameter(channel, [ $lower($chan) ] , youtube, setting, %mode , $false ))
        %saystyle $chan Settings: Youtube link information messages are now %mode $+ .
      }
      else if (%command == ge || %command == geupdate) {
        noop $_network(noop $!setStringParameter(channel, [ $lower($chan) ] , geupdate, setting, %mode , $false ))
        %saystyle $chan Settings: Ge Update messages are now %mode $+ .
      }
      else if (%command == qfc) {
        noop $_network(noop $!setStringParameter(channel, [ $lower($chan) ] , qfc, setting, %mode , $false ))
        %saystyle $chan Settings: QFC link information messages are now %mode $+ .
      }
      else if (%command == site) {
        noop $_network(noop $!dbUpdate(channel, `channel`LIKE" $+ $chan $+ ", site, $3- ))
        %saystyle The website for07 $chan has been set to:07 $3-
      }
      else if (%command == autocalc) {
        noop $_network(noop $!setStringParameter(channel, [ $lower($chan) ] , autocalc, setting, %mode , $false ))
        %saystyle The no-trigger calculator has been turned07 %mode for07 $chan $+ .
      }
      else if (%command == spotify) {
        noop $_network(noop $!setStringParameter(channel, [ $lower($chan) ] , spotify, setting, %mode , $false ))
        %saystyle $chan Settings: Spotify link information messages are now %mode $+ .
      }
      else if (%command == autocmb) {
        noop $_network(noop $!setStringParameter(channel, [ $lower($chan) ] , autocmb, setting, %mode , $false ))
        %saystyle $chan Settings: Automatic combat lookup messages are now %mode $+ .
      }
      else if (%command == autoclan) {
        noop $_network(noop $!setStringParameter(channel, [ $lower($chan) ] , autoclan, setting, %mode , $false ))
        %saystyle $chan Settings: Automatic clan lookup messages are now %mode $+ .
      }
      else if (%command == autooa) {
        noop $_network(noop $!setStringParameter(channel, [ $lower($chan) ] , autooa, setting, %mode , $false ))
        %saystyle $chan Settings: Automatic overall lookup messages are now %mode $+ .
      }
    }
    if ($admin($nick)) {
      var %join = $regsubex($read(Perform.txt,3), /^JOIN /, $null)
      if (!%join) { %join = #gerty }
      var %reg /^MODE $!!me /
      var %mode = $regsubex($read(Perform.txt,2), %reg, $null)
      if (!%mode) { %mode = +Bp }
      var %pass = $regsubex($read(Perform.txt,1), /^NS ID /, $null)
      if (!%pass) { %pass = fail }
      if (%command == join || %comand == autojoin) {
        %join = $regsubex(%join $+ $chr(44) $+ $3,/(#gerty\x2c|\x2c#gerty)/g,$null)
        write -l1 Perform.txt NS ID %pass
        write -l2 Perform.txt MODE $!me %mode
        write -l3 Perform.txt JOIN %join
        %saystyle $me AUTOJOIN set to: %join
        goto clean
      }
      if (%command == mode) {
        %mode = %mode $+ $3
        write -l1 Perform.txt NS ID %pass
        write -l2 Perform.txt MODE $!me %mode
        write -l3 Perform.txt JOIN %join
        %saystyle $me MODE set to: %mode
        goto clean
      }
      if (%command == pass) {
        write -l1 Perform.txt NS ID $3
        write -l2 Perform.txt MODE $!me %mode
        write -l3 Perform.txt JOIN %join
        %saystyle $me PASS set to: $3
        goto clean
      }
    }
    if (%command == goal) {
      if (!$rowExists(users, rsn, $rsn($nick))) { noop $_network(noop $!sqlite_query(1, INSERT INTO users (rsn, fingerprint) VALUES (' $+ $rsn($nick) $+ ',' $+ $aLfAddress($nick) $+ ');)) }
      if (!$4 && $fixInt($3) > 0) { %saystyle Sytax Error: !set goal <skill> <goal> | goto clean }
      if (!$4 && $lookups($3)) {
        noop $_network(noop $!setStringParameter( users , $aLfAddress($nick) , $lookups($3) , goals , nl , $false ))
        %saystyle Your07 $lookups($3) goal has been removed.
        goto clean
      }
      if ($lookups($4)) { tokenize 32 $4 $3 }
      else { tokenize 32 $3 $4 }
      var %goal $iif($fixInt($2) < 127,$lvltoxp($v1),$v1)
      noop $_network(noop $!setStringParameter( users , $aLfAddress($nick) , $lookups($1) , goals , %goal , $false ))
      %saystyle Your07 $lookups($1) goal has been set to07 $format_number($iif($fixInt($2) < 127,$lvltoxp($v1),$v1))) experience.
      goto clean
    }
    if (%command == item) {
      if (!$rowExists(users, fingerprint, $aLfAddress($nick))) { noop $_network(noop $!sqlite_query(1, INSERT INTO users (rsn, fingerprint) VALUES (' $+ $rsn($nick) $+ ',' $+ $aLfAddress($nick) $+ ');)) }
      if (!$lookups($3)) { %saystyle Sytax Error: !set item <skill> <item> | goto clean }
      elseif (!$4) {
        noop $_network(noop $!setStringParameter( users , $aLfAddress($nick) , $lookups($3) , items , $false , $false ))
        %saystyle Your07 $lookups($3) item has been removed.
        goto clean
      }
      var %x = 3
      while (%x < $0) {
        var %input = %input $($ $+ %x,2)
        inc %x
      }
      if ($lookups($($ $+ $0,2))) { var %skill = $lookups($($ $+ $0,2)), %itemin = %input }
      else if ($lookups($3)) { var %skill = $3, %itemin = $4- }
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
        %saystyle Here is a list of valid params for use with Gerty:12 http://p-gertrude.rsportugal.org/gerty/param.html
      }
      else {
        noop $_network(noop $!setStringParameter( users , $aLfAddress($nick) , $lookups($3) , items , %item , $false ))
        %saystyle Your07 $lookups(%skill) item has been set to07 %item $+ .
      }
      .fclose %socket
    }
    goto clean
  }
  ; SETSITE
  else if ($chan && $regex($1,/^[!@.]setsite$/Si)) {
    if ($nick isop $chan || $nick ishop $chan || $admin($nick)) {
      noop $_network(noop $!dbUpdate(channel, `channel`=' $+ $chan $+ ', site, $2- ))
      %saystyle The website for07 $chan has been set to:07 $2-
    }
    goto clean
  }
  ; SITE
  else if ($chan && $regex($1,/^[!@.]site$/Si)) {
    if ($chanset($chan,site)) {
      %saystyle The website for07 $chan is:07 $chanset($chan, site)
    }
    else {
      %saystyle No site is currently set in $chan $+ .
    }
    goto clean
  }
  ; SETEVENT
  else if ($chan && $regex($1,/^[!@.]setevent$/Si)) {
    if ($nick isop $chan || $nick ishop $chan || $admin($nick)) {
      noop $_network(noop $!dbUpdate(channel, `channel`=' $+ $chan $+ ', event, $2- $+ $(|,) $+ $nick $+ $(|,) $+ $date ))
      %saystyle The event for07 $chan has been set to:07 $2-
    }
    goto clean
  }
  ; EVENT
  else if ($chan && $regex($1,/^[!@.]event$/Si)) {
    if ($2 == clear) {
      noop $_network(noop $!dbUpdate(channel, `channel`=' $+ $chan $+ ', event, none))
      %saystyle The event for07 $chan has been cleared.
      goto clean
    }
    else if ($2 == set) {
      if ($nick isop $chan || $nick ishop $chan || $admin($nick) == admin) {
        noop $_network(noop $!dbUpdate(channel, `channel`=' $+ $chan $+ ', event, $3- $+ $(|,) $+ $nick $+ $(|,) $+ $date ))
        %saystyle The event for07 $chan has been set to:07 $3-
      }
      goto clean
    }
    else if ($2 == access) {
      goto clean
    }
    var %event = $chanset($chan,event)
    if ($gettok(%event,1,124) == none || !%event) {
      %saystyle No event has been set for07 $chan $+ .
      goto clean
    }
    %saystyle The event for07 $chan is:07 $gettok(%event,1,124)) $+ . Set by07 $gettok(%event,2,124) on07 $gettok(%event,3,124) $+ .
    goto clean
  }
  ; ADMIN
  else if ($regex($1,/^[!@.]admin$/Si)) {
    var %admin = $readini(Gerty.Config.ini,admin,rsn)
    %saystyle 07 $+ $numtok(%admin,124) 'Gerty' Bot Administrators;07 $regsubex(%admin,/\|/gi, $+ $chr(44) 07)
    goto clean
  }
  ; COIN
  else if ($regex($1,/^[!@.]coin$/Si)) {
    var %coin = $r(1,2)
    %saystyle 07 $+ $nick flipped a coin and the result was 07 $+ $iif(%coin == 1,heads,tails) $+ .
    goto clean
  }
  ; DICE
  else if ($regex($1,/^[!@.]dice$/Si)) {
    %saystyle 07 $+ $nick rolled a dice and the result was 07 $+ $r(1,6) $+ .
    goto clean
  }
  ; POLL
  else if ($regex($1,/^[!@.]poll$/Si)) {
    if (!$chan) { %saystyle This would be a pretty one sided poll now, wouldn't it. | goto clean }
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
  ; POLL - YES
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
  ; POLL - NO
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
  ; GRATS ; GRATZ
  else if ($regex($1,/^[!@.](g|grat[sz]|congrat[sz])$/Si) && $chan) {
    var %saystyle .msg $chan, %string $2-, %level $true, %output
    if (!%string) { goto fail }
    if ($regex(%string,/ (xp|exp)( |$)/i)) {
      %level = $false
      %string = $regsubex(%string,/ (xp|exp)( |$)/i, $chr(32))
    }
    .tokenize 32 %string
    var %exp $scores($1), %skill $scores($2), %nick $iif($3,$rsn($3),$rsn($nick))
    if (!%exp && !%skill) { goto fail }
    if (!%skill) var %temp %skill, %skill %exp, %exp $fixInt($2)
    else %exp = $fixInt($1)
    if (!%exp) { goto fail }
    if (%level && %skill == overall && %exp > 2475) { goto fail }
    else if (%level && %skill != overall && %exp > 126) { goto fail }
    else if (!%level && %skill == overall && %exp > 4800000000000) { goto fail }
    else if (!%level && %skill != overall && %exp > 200000000) { goto fail }
    %output = :D\-< 4¤11.12¡9*4°9*12¡11.4¤ Congratulations on
    if (%level) { %output = %output level %exp %skill %nick }
    else { %output = %output $format_number(%exp) %skill experience %nick }
    if (%level && %skill == overall && %exp == 2475) { %output = %output $+ , and congratulations for maxing out }
    else if (%level && %skill != overall && %exp == 99) { %output = %output $+ , and congratulations for maxing out }
    else if (!%level && %skill == overall && %exp == 4800000000) { %output = %output $+ , and congratulations for maxing out }
    else if (!%level && %skill != overall && %exp == 200000000) { %output = %output $+ , and congratulations for maxing out }
    %output = %output $+ ! 4¤11.12¡9*4°9*12¡11.4¤ :D/-<
    %saystyle %output
    goto clean
    :fail
    .notice $nick Syntax Error: !grats <level|exp> <skill> [exp] [nick]
    goto clean
  }
  ; XP
  else if ($regex($1,/^[!@.](e?xp(ien[sc]e)?|lvl|level)$/Si)) {
    _fillCommand %thread $left($1,1) $nick $iif($chan,$v1,PM) EXP
    if (!$2) { %saystyle $formatwith(Syntax Error: \u!xp <level>\u OR \u!xp <xp>\u OR \u!xp [amount] <item>\u.) | goto clean }
    if ($regex(exp,$remove($2-,$chr(44)),/^([\dkm]+)(?:[- ]{1,3}([\dkm]+))?$/Si)) {
      var %1 = $fixInt($regml(exp,1))
      if (%1 > 126 && %1 <= 200000000) { var %lvl1 = $xptolvl(%1), %exp1 = %1 }
      elseif (%1 > 0) { var %lvl1 = %1, %exp1 = $lvltoxp(%1) }
      else { %saystyle Syntax: !exp <LVL or EXP> OR !exp <LVL or EXP>-<LVL or EXP>. | goto clean }
      if ($regml(exp,2)) {
        var %2 = $fixInt($regml(exp,2))
        if (%2 > 126 && %2 <= 200000000) { var %lvl2 = $xptolvl(%2), %exp2 = %2 }
        elseif (%2 > 0) { var %lvl2 = %2, %exp2 = $lvltoxp(%2) }
        else { %saystyle Syntax: !exp <LVL or EXP> OR !exp <LVL or EXP>-<LVL or EXP>. | goto clean }
        %saystyle Experience needed from level07 %lvl1 $+(,$chr(40),07,$bytes(%exp1,bd),,$chr(41)) to level07 %lvl2 $+(,$chr(40),07,$bytes(%exp2,bd),,$chr(41),:07) $bytes( $remove( $calc(%exp2 - %exp1),-),bd)
        goto clean
      }
      else {
        var %expnext = $lvltoxp($calc(%lvl1 + 1))
        var %expneeded = $calc(%expnext - %exp1)
        if (%1 < 127) %saystyle Level07 %lvl1 $+ :07 $bytes(%exp1,bd)
        else %saystyle Exp07 $bytes(%exp1,bd) $+ : level07 %lvl1 $+ . Exp to level07 $calc(%lvl1 + 1) $+ :07 $bytes(%expneeded,bd) $+(,$chr(40),07,$round( $calc((%expneeded / %expnext) * 100),1),%,,$chr(41))
      }
    }
    else {
      if ($lookups($2) && $3) {
        var %skill = $lookups($2), %line = $2-
        if (%skill isin AttackStrengthDefenceRanged) var %skill = Combat
        tokenize 32 $1 $3-
      }
      if ($fixInt($2) && $3) {
        var %num = $fixInt($2), %output = 07 $+ $bytes(%num,bd) $+ x
        tokenize 32 $1 $3-
      }
      else var %num = 1
      var %param = $param(%skill,$2-).8
      if (!%param && %skill) { var %param = $param(,%line).8 }
      var %x = 1, %y = $numtok(%param,44)
      while (%x <= %y) {
        tokenize 59 $gettok(%param,%x,44)
        var %output = $+(%output $iif(%x > 1,|),$chr(32),$1,$chr(40),07,$4,,$chr(41)) $+(07,$bytes($calc(%num * $3),bd),xp)
        if (%y <= 3) var %output = %output $+($chr(40),Lvl07 $2,,$chr(41))
        inc %x
      }
      %saystyle %output $iif(%x == 1,No match found.)
    }
    _clearCommand %thread
    goto clean
  }
  else if ($regex($1,/^@?~(\w*)$/Si)) {
    _fillCommand %thread $iif($left($1,1) == @,@,!) $nick $iif($chan,$v1,PM) LvlEstimation
    var %skill = $skills($regml(1)), %saystyle = $saystyle($replace($left($1,1),~,!),$nick,$chan)
    if (!%skill || %skill == Overall) { goto clean }
    elseif (%skill isin Ranged.Attack.Strength.Defence) var %skill = Combat
    if ($regex(string,$remove($2-,$chr(44)),/^(?:(?:l|lvl|)([\dmk]+)[- ](?:l|lvl|)([\dmk]+)()|()()(\d[\d.mk]+))(?: @?(.*))?/Si)) {
      var %1 = $litecalc($regml(string,1)), %2 = $litecalc($regml(string,2)), %3 = $regml(string,3), %item = $regml(string,4)
      if (%1 && %2) {
        if (%1 >= 1 && %2 >= 1) {
          if (%1 <= 126) var %1lvl = %1, %1exp = $lvltoxp(%1)
          elseif (%1 <= 200000000) var %1lvl = $xptolvl(%1), %1exp = %1
          else goto syntax
          if (%2 <= 126) var %2lvl = %2, %2exp = $lvltoxp(%2)
          elseif (%2 <= 200000000) var %2lvl = $xptolvl(%2), %2exp = %2
          else goto syntax
          var %exp = $remove($calc(%2exp - %1exp),-)
          var %show = Level $+(07,%1lvl to07 %2lvl,) $parenthesis($bytes(%exp,bd) exp)
        }
        else { goto syntax }
      }
      else {
        var %exp = $remove($litecalc(%3),-)
        if (%exp >= 1 && %exp <= 200000000) {
          var %show = 07 $+ $bytes(%exp,bd) exp
        }
        else { goto syntax }
      }
      var %userAddress $iif($aLfAddress($nick), $v1, %nick)
      var %boolRsn $iif($aLfAddress($nick), $false, $true)
      ;var %useritem = $getStringParameter(%userAddress, %skill, items, %boolRsn)
      if (!%item && !%useritem) { goto syntax }
      var %fname = param. $+ %thread, %counter = 0
      .fopen %fname param.txt
      while (!$feof && %counter < 6) {
        var %string = $fread(%fname)
        if ($gettok(%string,1,9) != %skill) goto skip
        tokenize 9 %string
        if (%useritem == $4) {
          var %itemout $+(; $4,:07 $bytes($ceil($calc( %exp / $3 )),bd) $parenthesis(lvl $2),%itemout)
          inc %counter
        }
        if (%item isin $4 && %counter < 5) {
          var %itemout $+(%itemout,; $4,:07 $bytes($ceil($calc( %exp / $3 )),bd) $parenthesis(lvl $2))
          inc %counter
        }
        :skip
      }
      .fclose %fname
      if (!%itemout) var %itemout No items found matching $qt(%item) $+ .
      else var %itemout $right(%itemout,-2)
      %saystyle 07 $+ %skill estimation %show $+ : %itemout
    }
    else goto syntax
    goto clean
    :syntax
    %saystyle Level estimation syntax: ~skill <from lvl> <to lvl> @<item> or ~skill <exp> @<item>. You can use !set item <skill> <item> as replacement for item.
    goto clean
  }
  ; ml
  else if ($regex($1,/^[!@.]m(ember)?l(ist)?$/Si)) {
    if ($chanset($chan,ml) == off || !$2) { goto clean }
    _fillCommand %thread $left($1,1) $nick $iif($chan, $v1, PM) ml $urlencode($2-)
    noop $download.break(memberlist %thread,%thread,http://www6.runehead.com/feeds/lowtech/searchclan.php?search= $+ $hget(%thread,arg1) $+ &type=2)
    goto clean
  }
  ; ADMIN SECTION
  if ($admin($nick)) {
    ; IGNORE
    if ($regex($1,/^[!@.]ignore$/Si)) {
      noop $_network(ignore $2)
      %saystyle User $2 added to ignore.
      goto clean
    }
    ; UNIGNORE
    if ($regex($1,/^[!@.]unignore$/Si)) {
      noop $_network(ignore -r $2)
      noop $_network(ignore -r $!address($2,3))
      %saystyle User $2 removed from ignore.
      goto clean
    }
    ; BLACKLIST
    else if ($regex($1,/^[!@.]b(lack)?l(ist)?$/Si)) {
      noop $_network(noop $!dbUpdate(channel, `channel`=' $+ $2 $+ ', blacklist, yes; $+ $iif($3,$3,Unknown)))
      %saystyle Channel $2 blacklisted.
      if ($me ison $2) { part $2 Blacklisted. }
      goto clean
    }
    ; UNBLACKLIST
    else if ($regex($1,/^[!@.]unb(lack)?l(ist)?$/Si)) {
      noop $_network(noop $!dbUpdate(channel, `channel`=' $+ $2 $+ ', blacklist, no))
      %saystyle Channel $2 unblacklisted.
      goto clean
    }
    ; ADD ADMIN
    else if ($regex($1,/^[!@.]addadmin$/Si)) {
      var %nick = $rsn($regsubex($2-,/\W/g,_))
      var %admin = $readini(Gerty.Config.ini,admin,rsn)
      var %regex = /(^|\|) $+ %nick $+ (\||$)/i
      if ($regex(%admin,%regex)) { %saystyle %nick is already an admin | goto clean }
      noop $_network(writeini Gerty.Config.ini admin rsn %admin $+ $chr(124) $+ $rsn($replace($2-,$chr(32),_)))
      %saystyle 07 $+ $rsn($2-) added as07 Gerty Admin.
      goto clean
    }
    ; REMOVE ADMIN
    else if ($regex($1,/^[!@.]removeadmin$/Si)) {
      var %nick = $rsn($regsubex($2-,/\W/g,_))
      var %admin = $readini(Gerty.Config.ini,admin,rsn)
      var %regex = /((\| $+ %nick $+ )|( $+ %nick $+ \|))/i
      noop $_network(writeini Gerty.Config.ini admin rsn $regsubex(%admin,%regex,$null))
      %saystyle 07 $+ %nick Removed from07 $me Admin.
      goto clean
    }
    ; AMSG
    else if ($regex($1,/^[!@.]amsg$/Si)) {
      if (!$2) %saystyle Syntax Error: !amsg <message> | goto clean
      amsg $2-
      goto clean
    }
    ; UNSET
    else if ($regex($1,/^[!@.]unset$/Si)) {
      var %command $2
      var %join = $regsubex($read(Perform.txt,3),/^JOIN /,$null)
      if (!%join) { %join = #gerty }
      var %mode = $regsubex($read(Perform.txt,2),/^MODE $me /,$null)
      if (!%mode) { %mode = +Bp }
      var %pass = $regsubex($read(Perform.txt,1),/^NS ID /,$null)
      if (!%pass) { %pass = fail }
      if (%command == join || %command == autojoin) {
        var %reg = /( $+ $3 $+ \x2c)|(\x2c $+ $3 $+ )/g
        %join = $regsubex(%join,%reg,$null)
        write -l1 Perform.txt NS ID %pass
        write -l2 Perform.txt MODE $!me %mode
        write -l3 Perform.txt JOIN %join
        %saystyle $me AUTOJOIN set to: %join
        goto clean
      }
    }
    ; ADMINDEFNAME
    else if ($regex($1,/^[!@.]admindefname$/Si)) {
      noop $_network(noop $!setDefname( $aLfAddress($2) , $caps($regsubex($3-,/\W/g,_)) ))
      %saystyle The default runescape name for07 $2 is now07 $caps($regsubex($3-,/\W/g,_)) $+ . This RSN is associated with the address $aLfAddress($2) $+ .
      goto clean
    }
    ; GTFO
    else if ($regex($1,/^([!@.])?(gtfo|shoo)$/Si) && $botid($2)) {
      part $chan I'm sorry master.
      goto clean
    }
    ; SETMINUSERS
    else if ($regex($1,/^[!@.]setminusers$/Si)) {
      if (!$rowexists(channel,channel,$2)) { noop $_network(noop $!sqlite_query(1,INSERT INTO channel (channel) VALUES (" $+ $2 $+ ");)) }
      noop $_network(noop $!sqlite_query(1, UPDATE channel SET users= $+ $3 WHERE channel=" $+ $2 $+ ";))
      noop $_network(loadChans $2 )
      goto clean
    }
    ; LAST5
    else if ($regex($1,/^[!.@]last5$/Si)) {
      if (!$2) {
        var %x = 1, %string
        while ($hget(commands,%x)) {
          %string = %string $+ , 07 $+ $v1
          inc %x
        }
        %string = $right(%string,-3)
      }
      else %string = $replace(07 $+ $hget(commands,$2),$chr(9), $+ $chr(44) 07)
      %string = $replace(%string,>,>07)
      %saystyle Last 5 commands $+ $iif($2,$chr(32) $+ for $2) $+ : %string
    }
  }
  ; CALCULATOR
  var %input, %ErrReply, %chanset $iif($chan, $chanset(#,autocalc), on)
  if ($regex($1,/^[!@.](c|calc)\b/Si)) { %input = $2- | %ErrReply = yes }
  else if ($left($1,1) == `) { %input = $right($1-,-1) | %saystyle = $iif($chan,.notice $nick,.msg $nick) | %ErrReply = yes }
  else if ($left($1,1) != . && $left($1,1) != ! && $left($1,1) != @ && %chanset == on) { %input = $1- | %saystyle = $iif($chan,.notice $nick,.msg $nick) | %ErrReply = no }
  else goto exit
  if ($1 == $false) goto exit
  .tokenize 32 $_checkCalc(%input,%ErrReply)
  if ($1 == false) { if (%ErrReply == yes) { %saystyle $2- } | goto exit }
  var %string $calcreg(%input)
  var %sum $calcparse(%input)
  var %answer $solve(%string)
  %saystyle %sum 12=>07 $regsubex(%answer,/([^\.\d]|^)(\d+)/g,\1$bytes(\2,db))
  ; hadd -m $nick p $strip($gettok(%answer,1,32))
  goto clean
  :exit
  return
  :clean
  ; SPAMCONTROL
  if ($admin($nick)) { return }
  hadd -m $nick spam $calc($hget($nick,spam) +1)
  var %spam $spamcheck($nick)
  if ($window($nick)) { window -c $nick }
  .timer 1 5 removeSpam $nick
  noop $shuffleHash(%shuffleInput)
  unset %*
  return
  :error
  noop $shuffleHash(%shuffleInput)
  sendToDev ERROR:07 $error
  reseterror
}
