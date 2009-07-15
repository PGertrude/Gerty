alias price {
  var %item = $1
  if ($hget(prices,$replace(%item,$chr(32),-))) return $v1
  var %socket = $+(price.,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
  var %url = http://p-gertrude.rsportugal.org/gerty/price.php?type=price&item= $+ %item
  var %string = $downloadstring(%socket, %url)
  if ($numtok($gettok(%string,1,10),9) == 2) {
    hadd -m prices $replace($gettok($gettok(%string,1,10),1,9),$chr(32),-) $gettok($gettok(%string,1,10),2,9)
    return $gettok($gettok(%string,1,10),2,9)
  }
  return 0
}



on *:START: {
  .hmake prices
  if ($exists($mircdirData\price.data)) { .hload prices $mircdirData\price.data }
}
on *:QUIT: {
  .hsave prices $mircdirData\price.data
}
