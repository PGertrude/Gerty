>start<|spamcontrol.mrc|more covered|2.3|rs
on $*:TEXT:/^[!@.]([\w\d]+) */Si:*: {
  if ($skills($right($1,-1)) != nomatch || $minigames($right($1,-1)) != nomatch || $misc($right($1,-1)) != nomatch) { goto spam }
  if ($regex($right($1,-1),/(uptime|track|urban|google|ge|epenis|life|iq|today|week|month|year|yesterday|lastweek|lastmonth|item|npc|drop)/i)) { goto spam }
  if ($regex($right($1,-1),/(start|check|end|stop|clan)/i)) { goto spam }
  goto end
  :spam
  hadd -m $nick spam $calc($hget($nick,spam) +1)
  spamcheck $nick
  if ($window($nick)) { window -c $nick }
  .timer 1 5 hadd -m $nick spam 0
  :end
}
alias spamcheck {
  if ($hget($1,spam) >= 5) {
    ignore -pcntikdu18000 $1
    if ($address($1,3)) { ignore -pcntikdu18000 $address($1,3) }
    msg $1 $1 Blacklisted for 5 hours for spamming. (5 commands in 5 seconds).
  }
}
