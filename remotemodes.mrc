on $*:TEXT:sodomise*:#: {
if ($nick isop $chan || $nick ishop $chan || $admin($nick) == admin) {
if ($3) { var %bantime = $3 }
if (!$3) { var %bantime = 5 }
mode $chan +bb $address($2,3) $address($2,2)
kick $chan $2 $2 has a penis stuck up their ass for %bantime minutes
.timer 1 $calc(%bantime * 60) mode $chan -bb $address($2,3) $address($2,2)
}
}
on $*:TEXT:/^[!@.]amsg */Si:*: {
if ($admin($nick) == admin) {
amsg $2-
}
}
on *:TEXT:*:#: {
if ($admin($rsn($nick)) == admin || $nick isop $chan) {
if (!$regex($mid($1,2,20),/^[A-Za-z]+$/Si)) { halt }
var %mode = $1
if ($left(%mode,1) == + || $left(%mode,1) == -) {
if ($left($2,1) != $chr(35)) {
if (*b* iswm %mode) {
if (*+* iswm %mode) { mode $chan +bbbbbbbb $address($2,2) $2 $address($2,3)
if (*k* iswm %mode) {
kick $chan $2 $3-
}
halt
}
if (*-* iswm %mode) { mode $chan -bbbbbbbb $address($2,2) $2 $address($2,3)
if (*k* iswm %mode) {
kick $chan $2 $3-
}
halt
}
}
else {
if (*k* iswm %mode) {
kick $chan $2 $3-
}
else {
mode $chan %mode $2- | halt
}
}
}
else {
if (*b* iswm %mode) {
if (*+* iswm %mode) { mode $2 +bbbbbbbb $address($3,2) $3 $address($3,3)
if (*k* iswm %mode) {
kick $2 $3 $4-
}
halt
}
if (*-* iswm %mode) { mode $2 -bbbbbbbb $address($3,2) $3 $address($3,3)
if (*k* iswm %mode) {
kick $2 $3 $4-
}
halt
}
}
else {
if (*k* iswm %mode) {
kick $2 $3 $4-
}
else {
mode $2 %mode $3- | halt
}
}
}
}
}
}
on *:TEXT:*:?: {
if ($admin($rsn($nick)) == admin || $nick isop $chan) {
if ($mid($1,2,1) isnum) { halt }
var %mode = $1
if ($left(%mode,1) == + || $left(%mode,1) == -) {
if ($left($2,1) != $chr(35)) {
if (*b* iswm %mode) {
if (*+* iswm %mode) { mode $chan +bbb $address($2,2) $2 $address($2,3)
if (*k* iswm %mode) {
kick $chan $2 $3-
}
halt
}
if (*-* iswm %mode) { mode $chan -bbb $address($2,2) $2 $address($2,3)
if (*k* iswm %mode) {
kick $chan $2 $3-
}
halt
}
}
else {
if (*k* iswm %mode) {
kick $chan $2 $3-
}
else {
mode $chan %mode $2- | halt
}
}
}
else {
if (*b* iswm %mode) {
if (*+* iswm %mode) { mode $2 +bbb $address($3,2) $3 $address($3,3)
if (*k* iswm %mode) {
kick $2 $3 $4-
}
halt
}
if (*-* iswm %mode) { mode $2 -bbb $address($3,2) $3 $address($3,3)
if (*k* iswm %mode) {
kick $2 $3 $4-
}
halt
}
}
else {
if (*k* iswm %mode) {
kick $2 $3 $4-
}
else {
mode $2 %mode $3- | halt
}
}
}
}
}
}
:END
