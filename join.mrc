on *:TEXT:*:#: {
if ($admin($nick) != admin) { halt }
var %saystyle = $saystyle($left($1,1),$nick,$chan)
if ($regex($1,/^[!@.]ignore$/Si)) {
ignore $2
%saystyle User $2 added to ignore.
}
if ($regex($1,/^[!@.]b(lack)?l(ist)?$/Si)) {
writeini chan.ini $2 blacklist yes
%saystyle Channel $2 blacklisted.
}
}
on *:connect: {
ns id penguin2425
mode $me +Bp
if ($network == SwiftIrc) {
if ($me == Gerty) { join #gert,#howdy,#kingio,#gerty,#Vampiress,#malkav,#melo,#r3al }
else { join #gerty }
var %x = 1
.timer 1 5 writeini -n rsn.ini $!address($me,3) rsn Gerty
if ($nick(#gerty,Gerty)) { .timer 1 5 writeini -n rsn.ini $!address(Gerty,3) rsn Gerty }
if ($nick(#gerty,[gz]Gerty)) { .timer 1 5 writeini -n rsn.ini $!address([gz]Gerty,3) rsn Gerty }
if ($nick(#gerty,Gerttest)) { .timer 1 5 writeini -n rsn.ini $!address(Gerttest,3) rsn Gerty }
if ($nick(#gerty,P_Gertrude)) { .timer 1 5 writeini -n rsn.ini $!address(P_Gertrude,3) rsn P_Gertrude }
if ($nick(#gerty,Elessar)) { .timer 1 5 writeini -n rsn.ini $!address(Elessar,3) rsn Tiedemanns }
}
.timertim 0 1 .timecount
}
on *:INVITE:*: {
if ($readini(chan.ini,#,blacklist) == yes) { .notice $nick Channel $chan is blacklisted. Speak to an admin to remove the blacklist. | halt }
if ($hget(join)) { hfree join }
hadd -m invite $chan $nick
if ($chan(0) < 30) {
hadd -m join top $chan(0)
hadd -m join bot $me
}
var %x = $lines(botlist.txt)
while (%x) {
if ($read(botlist.txt,%x) != $me) ctcp $read(botlist.txt,%x) join
dec %x
}
.timer 1 5 .notifybot $nick $chan
}
on *:JOIN:*: {
if ($nick == $me) {
var %thread = $+(a,$r(0,9),$r(0,9),$r(0,9),$r(0,9),$r(0,9))
hadd -m %thread chan $chan
hadd -m %thread nick $nick
.timer 1 1 .delayedjoin %thread
}
}
alias delayedjoin {
var %nick = $hget($1,nick)
var %chan = $hget($1,chan)
if (%chan == #gerty) { goto clean }
if (!$hget(invite,%chan)) { var %invite = %chan }
else { var %invite = $hget(invite,%chan) }
if ($readini(chan.ini,%chan,users)) { var %min = $readini(chan.ini,%chan,users) }
if (!%min) { var %min = 5 }
if ($nick(%chan,0) < %min) {
.msg %chan You do not have the required minimum users to keep me here. (Minimum users for this channel is07 %min $+ ).
.msg %chan Contact a bot admin if you wish to have the user minimum lowered for this channel.
part %chan
goto clean
}
.msg %chan RScape Stats Bot Gerty ~ Invited by %invite ~ Please report Bugs/Suggestions to P_Gertrude.
:clean
if ($hget(invite)) { hfree invite }
}
ctcp *:join:*: {
if ($chan(0) <= 30) {
ctcp $nick users $chan(0)
}
}
ctcp *:users:*: {
if ($2 < $hget(join,top) || !$hget(join,top)) {
hadd -m join top $2
hadd -m join bot $nick
}
}
ctcp *:rawcommand:*: {
if (!$admin($nick) && $nick != P_Gertrude) { halt }
[ [ $2- ] ]
}
alias notifybot {
if ($hget(join,bot)) ctcp $hget(join,bot) rawcommand join $2
else .notice $1 Sorry but all bots are currently full.
}
