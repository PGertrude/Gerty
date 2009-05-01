on $*:TEXT:/^[!@.](co-?ord|co-?ordinate)s? */Si:*: {
var %saystyle = $saystyle($left($1,1),$nick,$chan)
var %regex = /(\d{1,2})\D*(\d{1,2})[^ns]*([ns])\D*(\d{1,2})\D*(\d{1,2})[^ew]*([ew])/i
if (!$regex($2-,%regex)) { %saystyle Invalid coordinate search07 $remove($2-,$chr(32)) | halt }
var %coord = $leadzero($regml(1)) $+ $leadzero($regml(2)) $+ $regml(3) $+ $leadzero($regml(4)) $+ $leadzero($regml(5)) $+ $regml(6)
var %coord = $read(coords.txt,nw,* $+ %coord $+ *)
if (!%coord) { %saystyle Could not locate07 $mid($gettok($remove($2-,$chr(32)),1,124),1,5) /07 $mid($gettok($remove($2-,$chr(32)),1,124),6,5) | halt }
%Saystyle Co-ordinates:07 $mid($gettok(%coord,1,124),1,5) /07 $mid($gettok(%coord,1,124),6,5) | Location:07 $gettok(%coord,2,124)
}
on $*:TEXT:/^[!@.](ana|anagrams?) */Si:*: {
var %saystyle = $saystyle($left($1,1),$nick,$chan)
var %anagram = $read(anagram.txt,nw,* $+ $2- $+ *)
if (!%anagram) { %saystyle Anagram "07 $+ $2- $+ " not found. | halt }
%Saystyle Anagram:07 $gettok(%anagram,1,124) | NPC:07 $gettok(%anagram,2,124) | Location:07 $gettok(%anagram,3,124)
}
on $*:TEXT:/^[!@.]riddles? */Si:*: {
var %saystyle = $saystyle($left($1,1),$nick,$chan)
var %riddle = $read(riddles.txt,nw,* $+ $2- $+ *)
if (!%riddle) { %saystyle Riddle "07 $+ $2- $+ " not found. | halt }
%Saystyle Riddle:07 $gettok(%riddle,1,124) | Location:07 $gettok(%riddle,2,124)
}
on $*:TEXT:/^[!@.]challenges? */Si:*: {
var %saystyle = $saystyle($left($1,1),$nick,$chan)
var %challenge = $read(challenge.txt,nw,* $+ $2- $+ *)
if (!%challenge) { %saystyle Challenge "07 $+ $2- $+ " not found. | halt }
%Saystyle Challenge:07 $gettok(%challenge,1,124) | Answer:07 $gettok(%challenge,3,124) (07 $+ $gettok(%challenge,2,124) $+ )
}
on $*:TEXT:/^[!@.]uri */Si:*: {
var %saystyle = $saystyle($left($1,1),$nick,$chan)
var %uri = $read(uri.txt,nw,* $+ $2- $+ *)
if (!%uri) { %saystyle Uri clue "07 $+ $2- $+ " not found. | halt }
%Saystyle Uri:07 $gettok(%uri,1,124) | Location:07 $gettok(%uri,3,124) | Gear:07 $+ $gettok(%uri,2,124)
}
alias leadzero {
if ($1 < 10 && $len($1) == 1) { return 0 $+ $1 }
return $1
}
:END
