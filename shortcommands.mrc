alias moveparam {
var %file = woodcutting.txt
var %abre = WOOD|
var %x = 1
while (%x <= $lines(%file)) {
write param.txt %abre $+ $read(%file,%x)
inc %x
}
}
alias asciiconv {
var %string = $1-, %x = 1
while (%x <= $len(%string)) {
var %c = %c $asc($mid(%string,%x,1))
inc %x
}
return %c
}
alias hexconv {
var %string = $1-, %x = 1
while (%x <= $len(%string)) {
var %c = %c $base($asc($mid(%string,%x,1)),10,16)
inc %x
}
return %c
}
on $*:TEXT:/^[!@.]bhtimer */Si:#: {
var %out = $saystyle($left($1,1),$nick,$chan)
%out Your Bounty Hunter death timer has been set.
.timer 1 30 %out Your Bounty Hunter timer has Expired.
}
on $*:TEXT:/^[!@.]timer */Si:#: {
var %out = $saystyle($left($1,1),$nick,$chan)
if ($2 isnum) {
var %time = $calc($2 * 60 + $ctime($asctime($gmt)))
write timer.txt %time $+ $chr(124) $+ %out $nick $+ , your timer has expired.
%out Your timer will expire in $duration($calc($2 * 60)) $+ .
}
else { %out You must specify a time(mins) for your timer to expire. }
}
alias cleanhash {
.hfree -w a*
.hfree -w e*
.hfree -w d*
}
on $*:TEXT:/^[!@.]shards? */Si:#: {
var %out = $saystyle($left($1,1),$nick,$chan)
var %familiar = $read(summoning.txt,w,$gettok($2-,2,64) $+ *)
var %expgain = $calculate($2)
if (!$3 || !%familiar || %expgain !isnum) { %out Syntax Error: !shards <exp gain> @<familiar> | goto clear }
var %familiar.name = $gettok(%familiar,1,124)
var %familiar.exp = $gettok(%familiar,2,124)
var %familiar.shards = $gettok(%familiar,5,124)
var %familiar.total = $ceil($calc( %expgain / %familiar.exp ))
var %shard.total = $calc( %familiar.shards * %familiar.total )
var %shard.left = $calc( %shard.total * 0.1 )
if (%shard.left > 100000) { %shard.left = 100000 }
if (%shard.left < $calc( 5 * 25 * %familiar.shards ) && %shard.total > $calc( 5 * 25 * %familiar.shards )) { %shard.left = $calc( 5 * 25 * %familiar.shards ) }
var %y = $calc( (%expgain / %familiar.exp ) * 0.3 * %familiar.shards )
%out For07 $bytes(%expgain,db) experience making familiar %familiar.name $+ ,07 $bytes(%shard.total,db) shards, or07 $bytes($ceil(%y),db) minimum including trading in pouches
:clear
unset %*
}
alias addtime {
var %oldtime = $1
var %increase = $2
if !$3 {
var %format = $numtok(%increase,58)
; seconds
:start
if %format == 1 {
var %time = x:y:z
var %hour = %increase / 3600
var %mins = $round($calc($+(0.,$gettok(%hour,2,46)) * 60),2)
var %secs = $round($calc($+(0.,$gettok(%mins,2,46)) * 60),2)
var %time = $replace(%time,x,$floor(%hour),y,$floor(%mins),z,$floor(%secs))
}
if %format == 2 {
var %increase = $calc($gettok(%increase,1,58) * 60 + $gettok(%increase,2,58))
var %format = 1
goto start
}
if %format == 3 {
var %time = %increase
}
; add the times
var %addition = x:y:z
; deal with seconds
var %seconds = $calc( $gettok(%time,3,58) + $gettok(%oldtime,3,58) )
if (%seconds > 59) {
var %newseconds = $floor($round($calc($+(0.,$gettok($calc(%seconds / 60),2,46)) * 60),2))
var %minutes = $floor($calc(%seconds / 60)))
}
else {
var %newseconds = %seconds
}
; deal with minutes
var %minutes = $calc(%minutes + $gettok(%oldtime,2,58) + $gettok(%time,2,58))
if (%minutes > 59) {
var %newminutes = $floor($round($calc($+(0.,$gettok($calc(%minutes / 60),2,46)) * 60),2))
var %hours = $floor($calc(%minutes / 60)))
}
else {
var %newminutes = %minutes
}
; deal with hours
var %hours = $calc(%hours + $gettok(%oldtime,1,58) + $gettok(%time,1,58))
if (%hours > 23) {
var %newhours = $floor($round($calc($+(0.,$gettok($calc(%hours / 24),2,46)) * 24),2))
}
else {
var %newhours = %hours
}
; put into date format
var %addition = $replace(%addition,z,%newseconds,y,%newminutes,x,%newhours)
; add in 0s for numbres < 10
var %addition = $regsubex(%addition,/^(\d):/,0\1:)
var %addition = $regsubex(%addition,/^(\d{2}):(\d):/,\1:0\2:)
var %addition = $regsubex(%addition,/^(\d{2}):(\d{2}):(\d)$/,\1:\2:0\3)
return %addition
}
if $3 {
; future option to increase the date as well as time if time passes midnight
}
}
alias movesumtxt {
if ($1 == 1) { return z1|g0|r0|b0 }
if ($1 == 2) { return z1|g0|r0|b0 }
if ($1 == 3) { return z1|g0|r0|b0 }
if ($1 == 4) { return z2|g0|r0|b0 }
if ($1 == 5) { return z2|g0|r0|b0 }
if ($1 == 6) { return z2|g0|r0|b0 }
if ($1 == 7) { return z2|g0|r0|b0 }
if ($1 == 8) { return z2|g0|r0|b0 }
if ($1 == 9) { return z2|g0|r0|b0 }
if ($1 == 10) { return z3|g0|r0|b0 }
if ($1 == 11) { return z3|g0|r0|b0 }
if ($1 == 12) { return z3|g0|r0|b0 }
if ($1 == 13) { return z4|g0|r0|b0 }
if ($1 == 14) { return z4|g0|r0|b0 }
if ($1 == 15) { return z4|g0|r0|b0 }
if ($1 == 16) { return z5|g0|r0|b0 }
if ($1 == 17) { return z6|g0|r0|b0 }
if ($1 == 18) { return z6|g7|r0|b0 }
if ($1 == 19) { return z6|g7|r8|b0 }
if ($1 == 20) { return z6|g7|r8|b0 }
if ($1 == 21) { return z6|g7|r8|b0 }
if ($1 == 22) { return z6|g7|r8|b0 }
if ($1 == 23) { return z6|g7|r8|b10 }
if ($1 == 24) { return z6|g7|r8|b10 }
if ($1 == 25) { return z6|g7|r8|b11 }
if ($1 == 26) { return z6|g7|r8|b11 }
if ($1 == 27) { return z6|g7|r8|b11 }
if ($1 == 28) { return g12|z6|r8|b11 }
if ($1 == 29) { return g12|z6|r8|b13 }
if ($1 == 30) { return g12|z6|r8|b13 }
if ($1 == 31) { return g12|z6|r14|b13 }
if ($1 == 32) { return g12|z6|r15|b13 }
if ($1 == 33) { return g16|z6|r15|b13 }
if ($1 == 34) { return g16|z6|r15|b13 }
if ($1 == 35) { return g16|z6|r15|b13 }
if ($1 == 36) { return g16|z6|r15|b21 }
if ($1 == 37) { return g16|z6|r15|b21 }
if ($1 == 38) { return g16|z6|r15|b21 }
if ($1 == 39) { return g16|z6|r15|b21 }
if ($1 == 40) { return z22|g16|r15|b21 }
if ($1 == 41) { return z22|g23|r15|b21 }
if ($1 == 42) { return ||| }
if ($1 == 43) { return ||| }
if ($1 == 44) { return ||| }
if ($1 == 45) { return ||| }
if ($1 == 46) { return ||| }
if ($1 == 47) { return ||| }
if ($1 == 48) { return ||| }
if ($1 == 49) { return ||| }
if ($1 == 50) { return ||| }
if ($1 == 51) { return ||| }
if ($1 == 52) { return ||| }
if ($1 == 53) { return ||| }
if ($1 == 54) { return ||| }
if ($1 == 55) { return ||| }
if ($1 == 56) { return ||| }
if ($1 == 57) { return ||| }
if ($1 == 58) { return ||| }
if ($1 == 59) { return ||| }
if ($1 == 60) { return ||| }
if ($1 == 61) { return ||| }
if ($1 == 62) { return ||| }
if ($1 == 63) { return ||| }
if ($1 == 64) { return ||| }
if ($1 == 65) { return ||| }
if ($1 == 66) { return ||| }
if ($1 == 67) { return ||| }
if ($1 == 68) { return ||| }
if ($1 == 69) { return ||| }
if ($1 == 70) { return ||| }
if ($1 == 71) { return ||| }
if ($1 == 72) { return ||| }
if ($1 == 73) { return ||| }
if ($1 == 74) { return ||| }
if ($1 == 75) { return ||| }
if ($1 == 76) { return ||| }
if ($1 == 77) { return ||| }
if ($1 == 78) { return ||| }
if ($1 == 79) { return ||| }
if ($1 == 80) { return ||| }
if ($1 == 81) { return ||| }
if ($1 == 82) { return ||| }
if ($1 == 83) { return ||| }
if ($1 == 84) { return ||| }
if ($1 == 85) { return ||| }
if ($1 == 86) { return ||| }
if ($1 == 87) { return ||| }
if ($1 == 88) { return ||| }
if ($1 == 89) { return ||| }
if ($1 == 90) { return ||| }
if ($1 == 91) { return ||| }
if ($1 == 92) { return ||| }
if ($1 == 93) { return ||| }
if ($1 == 94) { return ||| }
if ($1 == 95) { return ||| }
if ($1 == 96) { return ||| }
if ($1 == 97) { return ||| }
if ($1 == 98) { return ||| }
if ($1 == 99) { return ||| }
}
menu status,channel,query {
Hash Table Editor:hedit
}
alias hedit { dialog -m hedit hedit }
dialog hedit {
title Hash Table Editor
size -1 -1 260 142
option dbu
edit "Coded By: Imrac", 1, 0 131 260 11, read right autohs
box "Tables", 2, 2 3 75 125
list 3, 7 13 65 94, vsbar sort
button "Add", 4, 7 101 32 11
button "Remove", 5, 40 101 32 11
button "Rename", 6, 7 113 32 11
button "Clear", 7, 40 113 32 11
box "Items", 8, 80 3 178 125
list 9, 85 13 65 102, vsbar sort
button "Add", 10, 85 113 32 11
button "Remove", 11, 118 113 32 11
box "Data", 12, 155 9 98 63
text "Item", 13, 158 17 50 9
edit "",14, 158 25 92 11, autohs
text "Data", 15, 158 37 50 9
edit "", 16, 158 45 92 11, autohs
button "Update", 17, 189 58 30 11
box "Search", 18, 155 74 98 51
check "Data", 19, 179 83 24 9
check "Table", 20, 207 83 24 9
edit "", 21, 158 95 92 11, autohs
check "Regular Ex.", 22, 158 111 35 9
button "Clear", 23, 215 109 35 11
}
on *:Dialog:hedit:*:*:{
if ($devent == init) {
var %x = $hget(0)
did -o $dname 2 1 Tables $+($chr(40),%x,$chr(41))
did -b $dname 5-23
while (%x) {
did -a $dname 3 $hget(%x)
dec %x
}
did -f $dname 3
}
if ($devent == sclick) {
var %tb = $did($dname,3).seltext
var %it = $did($dname,9).seltext
If ($did == 1) { did -j $dname 3 }
; // Click On Table List //
If ($did == 3) && (%tb) {
did -e $dname 5-10
did -u $dname 9
iu
If ($did($dname,21).text) { itemsearch }
did -o $dname 1 1 Table: ' $+ %tb $+ ' Items: $hget(%tb,0).item Size: $hget(%tb).size
}
; // Click On Item List //
If ($did == 9) && ($did($dname,$did).seltext) {
did -e $dname 11-17
var %t = $did($dname,3).seltext
var %i = $did($dname,9).seltext
did -o $dname 14 1 %i
did -o $dname 16 1 $hget(%t,%i)
}
; // ADD NEW HASH TABLE BUTTON //
If ($did == 4) {
var %n = $input(Hash Table Name:,equd,New Hash Table)
If (%n == $null) { derror -c No Name Given }
ElseIf ($regex(%n,/ /)) { derror -c Hash Table Name Can Not Contain Spaces }
ElseIf ($hget(%n)) { derror -c Hash Table Name Already Exists }
Else {
var %s = $input(Hash Table Size:,equd,New Hash Table,100)
If (%s == $null) { derror -c No Size Specified }
ElseIf (%s !isnum 1-) || (%s != $int(%s)) { derror -c Invalid Size Specified }
Else {
hmake %n %s
did -o $dname 1 1 Success: Made Hash Table.
did -a $dname 3 %n
did -o $dname 2 1 Tables $+($chr(40),$hget(0),$chr(41))
}
}
}
; // Remove Hash table //
If ($did == 5) {
If ($input(Are You Sure You Want To Remove Hash Table ' $+ %tb $+ ', wudy, Remove Table)) {
hfree %tb
did -o $dname 1 1 Success: Removed Hash Table.
did -d $dname 3 $did($dname,3).sel
did -r $dname 14,16,9,21
did -b $dname 5-23
did -o $dname 2 1 Tables $+($chr(40),$hget(0),$chr(41))
did -o $dname 8 1 Items
}
}
; // Rename Hash Table
If ($did == 6) {
var %n = $input(Hash Table's New Name:,equd,Rename Hash Table)
If (%n == $null) { derror -r No New Name Specified }
ElseIf ($regex(%n,/ /)) { derror -r Hash Table Name Can Not Contain Spaces }
Else {
did -o $dname 1 1 Success: Renamed Hash Table.
hrename %tb %n
did -d $dname 3 $did($dname,3).sel
did -ac $dname 3 %n
}
}
; // Clear Hash Table //
If ($did == 7) {
var %c = $input(Are You Sure You Want To Clear All Items From ' $+ %tb $+ '?, wudy, Clear Table)
If (%c) { hdel -w %tb * | iu | did -o $dname 1 1 Success: Removed Hash Table. }
}
; // Add item to table //
If ($did = 10) {
var %ni = $input(New Item Name:,equd,Add Item)
If (%ni == $null) { derror -a No Item Name Specified }
ElseIf ($regex(%ni,/ /)) { derror -a Item Name Can Not Contain Spaces }
ElseIf ($hget(%tb,%ni)) { derror -a Item Already Exists }
Else {
var %nd = $input(New Item Data:,equdv,Add Item)
If (%nd == $cancel) { derror -a Cancelled }
Else {
hadd %tb %ni %nd
did -o $dname 1 1 Success: Added Item.
itemsearch
}
}
}
; // Remove an item from the table //
If ($did = 11) {
var %yn = $input(Are You Sure You Want To Delete ' $+ %it $+ '.,wdyu,Remove Item)
if (%yn) {
hdel %tb %it
itemsearch
did -o $dname 1 1 Success: Removed Item.
}
}
; // Update an item //
If ($did == 17) {
var %ni = $did($dname,14).text
If (%ni == $null) { derror -u No Item Name Given }
ElseIf ($regex(%ni,/ /)) { derror -u Item Name Can Not Contain Spaces }
Else {
did -o $dname 1 1 Success: Updated Item.
hdel %tb %it
hadd %tb %ni $did($dname,16).text
did -d $dname 9 $did($dname,9).sel
did -ac $dname 9 %ni
If ($did($dname,21).text) { itemsearch }
}
}
If ($did == 19) { if ($did($dname,21).text) { itemsearch } }
If ($did == 20) { if ($did($dname,21).text) { itemsearch } }
If ($did == 22) { if ($did($dname,21).text) { itemsearch } }
If ($did == 23) { did -r $dname 21 | did -u $dname 19,20,22 | itemsearch }
}
If ($devent == edit) {
If ($did = 21) { itemsearch | did -f $dname 21 }
}
}
alias -l itemsearch {
If ($did($dname,21).text) {
var %t = $did($dname,3).seltext
var %sel = $did($dname,9).seltext
var %f = $iif($did($dname,22).state,r,w)
var %f = $iif($did($dname,20).state,$upper(%f),$lower(%f))
var %d = $iif($did($dname,19).state,.$true,)
var %s = $did($dname,21).text
var %x = $iif(%d,$hfind(%t,%s,0,%f).data,$hfind(%t,%s,0,%f))
did -o $dname 8 1 Items $+($chr(40),%x,/,$hget(%t,0).item,$chr(41))
did -r $dname 9
while (%x) {
if (%d) var %st = $hfind(%t,%s,%x,%f).data
else var %st = $hfind(%t,%s,%x,%f)
did -a $dname 9 %st
dec %x
}
If (%sel) && ($didreg($dname,9,/^ $+ %sel $+ $/)) { did -c $dname 9 $v1 }
Else {
did -r $dname 14,16
did -b $dname 11-17
}
}
Else {
iu
}
}
alias -l iu {
var %tb = $did($dname,3).seltext
var %it = $did($dname,9).seltext
var %x = $hget(%tb,0).item
did -r $dname 9
did -o $dname 8 1 Items $+($chr(40),%x,$chr(41))
did -e $dname 18-23
while (%x) { did -a $dname 9 $hget(%tb,%x).item | dec %x }
If (%it) && ($didreg($dname,9,/^ $+ %it $+ $/)) { did -c $dname 9 $v1 }
Else {
did -r $dname 14,16
did -b $dname 11-17
}
}
alias hrename {
var %t1 = $1, %t2 = $2
hmake %t2 $hget(%t1).size
var %x = $hget(%t1,0).item
while (%x) {
hadd %t2 $hget(%t1,%x).item $hget(%t1,%x).data
dec %x
}
hfree %t1
}
alias -l derror {
If ($1 == -c) { did -o $dname 1 1 Error: Unable To Create Hash Table. ( $+ $2- $+ ) }
ElseIf ($1 == -r) { did -o $dname 1 1 Error: Unable To Rename Hash Table. ( $+ $2- $+ ) }
ElseIf ($1 == -a) { did -o $dname 1 1 Error: Unable To Add Item. ( $+ $2- $+ ) }
ElseIf ($1 == -u) { did -o $dname 1 1 Error: Unable To Update Item. ( $+ $2- $+ ) }
}
:END
