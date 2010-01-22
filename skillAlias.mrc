>start<|skillAlias.mrc|new|1.0|a
compares {
  if ($regex($1,/^(at|att|attack)$/Si)) { return Attack }
  if ($regex($1,/^(st|str|strength)$/Si)) { return Strength }
  if ($regex($1,/^(de|def|defen[cs]e)$/Si)) { return Defence }
  if ($regex($1,/^(hp|hits|hitpoint|hitpoints)$/Si)) { return Hitpoints }
  if ($regex($1,/^(pr|pray|prayer)$/Si)) { return Prayer }
  if ($regex($1,/^(ra|range|ranged|ranging)$/Si)) { return Ranged }
  if ($regex($1,/^(ma|mage|magic)$/Si)) { return Magic }
  if ($regex($1,/^(rc|runecraft|runecrafting|rune)$/Si)) { return Runecraft }
  if ($regex($1,/^(con|cons|const|constr|construction)$/Si)) { return Construction }
  if ($regex($1,/^(ag|agil|agility|agi)$/Si)) { return Agility }
  if ($regex($1,/^(he|herb|herblore)$/Si)) { return Herblore }
  if ($regex($1,/^(th|thieve|theive|thief|theif|thieving|theiving)$/Si)) { return Thieving }
  if ($regex($1,/^(cr|craft|crafting)$/Si)) { return Crafting }
  if ($regex($1,/^(sm|smd|smith|smithing)$/Si)) { return Smithing }
  if ($regex($1,/^(hu|hunt|hunter|hunting)$/Si)) { return Hunter }
  if ($regex($1,/^(fa|farm|farming)$/Si)) { return Farming }
  if ($regex($1,/^(sl|slay|slayer|slaying)$/Si)) { return Slayer }
  if ($regex($1,/^(mi|mine|mining)$/Si)) { return Mining }
  if ($regex($1,/^(fm|fming|firemake|firemaking)$/Si)) { return Firemaking }
  if ($regex($1,/^(fi|fish|fishing)$/Si)) { return Fishing }
  if ($regex($1,/^(fl|fletch|fletching)$/Si)) { return Fletching }
  if ($regex($1,/^(wc|wcing|wood|woodcutting|woodcut)$/Si)) { return Woodcutting }
  if ($regex($1,/^(cok|cook|cooking|coo)$/Si)) { return Cooking }
  if ($regex($1,/^(su|sum|summy|summon|summoning)$/Si)) { return Summoning }
  if ($regex($1,/^(oa|overall|total)$/Si)) { return Overall }
  if ($regex($1,/^(bh|bo|bount|bounty|bountyhunter|Bounty Hunter)$/Si)) { return Bounty Hunter }
  if ($regex($1,/^(bhr|bor|bountrogue|bountyrogue|bountyhunterrogue|rogue|rogues|Bounty Hunter Rogues)$/Si)) { return Bounty Hunter Rogues }
  if ($regex($1,/^(fog|fist|fisting|fistofguth|guth|guthix|fistofguthix|fist of guthix)$/Si)) { return Fist of Guthix }
  if ($regex($1,/^(du|duel|tournament)$/Si)) { return Duel }
  if ($regex($1,/^(mob?|mobilise|mobilising)(ar|army|armies|armys)?$/Si)) { return Mobilising Armies }
  if ($regex($1,/^(st|sk|all|skill|skills|stat|stats|statistics)$/Si)) { return Stats }
  if ($regex($1,/^(cb|cmb|comb|combat|warrior)$/Si)) { return Combat }
  if ($regex($1,/^(cmb%|combat%)$/Si)) { return combat% }
  if ($regex($1,/^(p2p%)$/Si)) { return p2p% }
  if ($regex($1,/^(f2p%)$/Si)) { return f2p% }
  if ($regex($1,/^(sl%|slay%|slayer%)$/Si)) { return slayer% }
  if ($regex($1,/^(skill%|skiller%)$/Si)) { return skiller% }
  if ($regex($1,/^(pc%|pest%|pestcontrol%|pest control%)$/Si)) { return pest control% }
}
lookups {
  if ($regex($1,/^(at|att|attack)$/Si)) { return Attack }
  if ($regex($1,/^(st|str|strength)$/Si)) { return Strength }
  if ($regex($1,/^(de|def|defen[cs]e)$/Si)) { return Defence }
  if ($regex($1,/^(hp|hits|hitpoint|hitpoints)$/Si)) { return Hitpoints }
  if ($regex($1,/^(pr|pray|prayer)$/Si)) { return Prayer }
  if ($regex($1,/^(ra|range|ranged|ranging)$/Si)) { return Ranged }
  if ($regex($1,/^(ma|mage|magic)$/Si)) { return Magic }
  if ($regex($1,/^(rc|runecraft|runecrafting|rune)$/Si)) { return Runecraft }
  if ($regex($1,/^(con|cons|const|constr|construction)$/Si)) { return Construction }
  if ($regex($1,/^(ag|agil|agility|agi)$/Si)) { return Agility }
  if ($regex($1,/^(he|herb|herblore)$/Si)) { return Herblore }
  if ($regex($1,/^(th|thieve|theive|thief|theif|thieving|theiving)$/Si)) { return Thieving }
  if ($regex($1,/^(cr|craft|crafting)$/Si)) { return Crafting }
  if ($regex($1,/^(sm|smd|smith|smithing)$/Si)) { return Smithing }
  if ($regex($1,/^(hu|hunt|hunter|hunting)$/Si)) { return Hunter }
  if ($regex($1,/^(fa|farm|farming)$/Si)) { return Farming }
  if ($regex($1,/^(sl|slay|slayer|slaying)$/Si)) { return Slayer }
  if ($regex($1,/^(mi|mine|mining)$/Si)) { return Mining }
  if ($regex($1,/^(fm|fming|firemake|firemaking)$/Si)) { return Firemaking }
  if ($regex($1,/^(fi|fish|fishing)$/Si)) { return Fishing }
  if ($regex($1,/^(fl|fletch|fletching)$/Si)) { return Fletching }
  if ($regex($1,/^(wc|wcing|wood|woodcutting|woodcut)$/Si)) { return Woodcutting }
  if ($regex($1,/^(cok|cook|cooking|coo)$/Si)) { return Cooking }
  if ($regex($1,/^(su|sum|summy|summon|summoning)$/Si)) { return Summoning }
  if ($regex($1,/^(oa|overall|total)$/Si)) { return Overall }
  if ($regex($1,/^(bh|bo|bount|bounty|bountyhunter|Bounty Hunter)$/Si)) { return Bounty Hunter }
  if ($regex($1,/^(bhr|bor|bountrogue|bountyrogue|bountyhunterrogue|rogue|rogues|Bounty Hunter Rogues)$/Si)) { return Bounty Hunter Rogues }
  if ($regex($1,/^(fog|fist|fisting|fistofguth|guth|guthix|fistofguthix|fist of guthix)$/Si)) { return Fist of Guthix }
  if ($regex($1,/^(du|duel|tournament)$/Si)) { return Duel }
  if ($regex($1,/^(mob?|mobilise|mobilising)(ar|army|armies|armys)?$/Si)) { return Mobilising Armies }
  if ($regex($1,/^(st|sk|all|skill|skills|stat|stats|statistics)$/Si)) { return Stats }
  if ($regex($1,/^(cb|cmb|comb|combat|warrior)$/Si)) { return Combat }
  if ($regex($1,/^(ncb|noncmb|non-cmb|non-comb|noncomb|non-combat|noncombat|non-warrior)$/Si)) { return Noncmb }
  if ($regex($1,/^(req|reqs|ssreq|ssreqs|requirements)$/Si)) { return reqs }
  if ($regex($1,/^(le|left|lc|lcol|leftcol|leftcolumn)$/Si)) { return left }
  if ($regex($1,/^(ri|right|rightc|rightcol|rightcolumn)$/Si)) { return right }
  if ($regex($1,/^(mid|middle|midc|midcol|middlec|middlecol|middlecolumn)$/Si)) { return mid }
}
scores {
  if ($regex($1,/^(at|att|attack)$/Si)) { return Attack }
  if ($regex($1,/^(st|str|strength)$/Si)) { return Strength }
  if ($regex($1,/^(de|def|defen[cs]e)$/Si)) { return Defence }
  if ($regex($1,/^(hp|hits|hitpoint|hitpoints)$/Si)) { return Hitpoints }
  if ($regex($1,/^(pr|pray|prayer)$/Si)) { return Prayer }
  if ($regex($1,/^(ra|range|ranged|ranging)$/Si)) { return Ranged }
  if ($regex($1,/^(ma|mage|magic)$/Si)) { return Magic }
  if ($regex($1,/^(rc|runecraft|runecrafting|rune)$/Si)) { return Runecraft }
  if ($regex($1,/^(con|cons|const|constr|construction)$/Si)) { return Construction }
  if ($regex($1,/^(ag|agil|agility|agi)$/Si)) { return Agility }
  if ($regex($1,/^(he|herb|herblore)$/Si)) { return Herblore }
  if ($regex($1,/^(th|thieve|theive|thief|theif|thieving|theiving)$/Si)) { return Thieving }
  if ($regex($1,/^(cr|craft|crafting)$/Si)) { return Crafting }
  if ($regex($1,/^(sm|smd|smith|smithing)$/Si)) { return Smithing }
  if ($regex($1,/^(hu|hunt|hunter|hunting)$/Si)) { return Hunter }
  if ($regex($1,/^(fa|farm|farming)$/Si)) { return Farming }
  if ($regex($1,/^(sl|slay|slayer|slaying)$/Si)) { return Slayer }
  if ($regex($1,/^(mi|mine|mining)$/Si)) { return Mining }
  if ($regex($1,/^(fm|fming|firemake|firemaking)$/Si)) { return Firemaking }
  if ($regex($1,/^(fi|fish|fishing)$/Si)) { return Fishing }
  if ($regex($1,/^(fl|fletch|fletching)$/Si)) { return Fletching }
  if ($regex($1,/^(wc|wcing|wood|woodcutting|woodcut)$/Si)) { return Woodcutting }
  if ($regex($1,/^(cok|cook|cooking|coo)$/Si)) { return Cooking }
  if ($regex($1,/^(su|sum|summy|summon|summoning)$/Si)) { return Summoning }
  if ($regex($1,/^(oa|overall|total)$/Si)) { return Overall }
  if ($regex($1,/^(bh|bo|bount|bounty|bountyhunter|Bounty Hunter)$/Si)) { return Bounty Hunter }
  if ($regex($1,/^(bhr|bor|bountrogue|bountyrogue|bountyhunterrogue|rogue|rogues|Bounty Hunter Rogues)$/Si)) { return Bounty Hunter Rogues }
  if ($regex($1,/^(fog|fist|fisting|fistofguth|guth|guthix|fistofguthix|fist of guthix)$/Si)) { return Fist of Guthix }
  if ($regex($1,/^(du|duel|tournament)$/Si)) { return Duel }
  if ($regex($1,/^(mob?|mobilise|mobilising)(ar|army|armies|armys)?$/Si)) { return Mobilising Armies }
}
skills {
  if ($regex($1,/^(at|att|attack)$/Si)) { return Attack }
  if ($regex($1,/^(st|str|strength)$/Si)) { return Strength }
  if ($regex($1,/^(de|def|defen[cs]e)$/Si)) { return Defence }
  if ($regex($1,/^(hp|hits|hitpoint|hitpoints)$/Si)) { return Hitpoints }
  if ($regex($1,/^(pr|pray|prayer)$/Si)) { return Prayer }
  if ($regex($1,/^(ra|range|ranged|ranging|rang)$/Si)) { return Ranged }
  if ($regex($1,/^(ma|mage|magic)$/Si)) { return Magic }
  if ($regex($1,/^(rc|runecraft|runecrafting|rune)$/Si)) { return Runecraft }
  if ($regex($1,/^(con|cons|const|constr|construct|construction)$/Si)) { return Construction }
  if ($regex($1,/^(ag|agil|agility|agi)$/Si)) { return Agility }
  if ($regex($1,/^(he|herb|herblore)$/Si)) { return Herblore }
  if ($regex($1,/^(th|thieve|theive|thief|theif|thieving|theiving)$/Si)) { return Thieving }
  if ($regex($1,/^(cr|craft|crafting)$/Si)) { return Crafting }
  if ($regex($1,/^(sm|smd|smith|smithing)$/Si)) { return Smithing }
  if ($regex($1,/^(hu|hunt|hunter|hunting)$/Si)) { return Hunter }
  if ($regex($1,/^(fa|farm|farming)$/Si)) { return Farming }
  if ($regex($1,/^(sl|slay|slayer|slaying)$/Si)) { return Slayer }
  if ($regex($1,/^(mi|mine|mining)$/Si)) { return Mining }
  if ($regex($1,/^(fm|fming|firemake|firemaking)$/Si)) { return Firemaking }
  if ($regex($1,/^(fi|fish|fishing)$/Si)) { return Fishing }
  if ($regex($1,/^(fl|fletch|fletching)$/Si)) { return Fletching }
  if ($regex($1,/^(wc|wcing|wood|woodcutting|woodcut)$/Si)) { return Woodcutting }
  if ($regex($1,/^(cok|cook|cooking|coo)$/Si)) { return Cooking }
  if ($regex($1,/^(su|sum|summy|summon|summoning)$/Si)) { return Summoning }
  if ($regex($1,/^(oa|overall|total)$/Si)) { return Overall }
}
minigames {
  if ($regex($1,/^(bh|bo|bount|bounty|bountyhunter|Bounty Hunter)$/Si)) { return Bounty Hunter }
  if ($regex($1,/^(bhr|bor|bountrogue|bountyrogue|bountyhunterrogue|rogue|rogues|Bounty Hunter Rogues)$/Si)) { return Bounty Hunter Rogues }
  if ($regex($1,/^(fog|fist|fisting|fistofguth|guth|guthix|fistofguthix|fist of guthix)$/Si)) { return Fist of Guthix }
  if ($regex($1,/^(du|duel|tournament)$/Si)) { return Duel }
  if ($regex($1,/^(mob?|mobilise|mobilising) ?(ar|army|armies|armys)?$/Si)) { return Mobilising Armies }
}
misc {
  if ($regex($1,/^(st|sk|all|skill|skills|stat|stats|statistics)$/Si)) { return Stats }
  if ($regex($1,/^(cb|cmb|comb|combat|warrior)$/Si)) { return Combat }
  if ($regex($1,/^(ncb|noncmb|non-cmb|non-comb|noncomb|non-combat|noncombat|non-warrior)$/Si)) { return Noncmb }
  if ($regex($1,/^(cm|cp|cmp|comp|compare)$/Si)) { return Compare }
  if ($regex($1,/^(ne|next|nextlvl|nextlevel|close|cl|closest)$/Si)) { return Next }
  if ($regex($1,/^(hi|high|highest|lo|low|lowest|hilow|hilo|highlow)$/Si)) { return Hilow }
  if ($regex($1,/^(le|left|lc|lcol|leftcol|leftcolumn)$/Si)) { return left }
  if ($regex($1,/^(ri|right|rightc|rightcol|rightcolumn)$/Si)) { return right }
  if ($regex($1,/^(mid|middle|midc|midcol|middlec|middlecol|middlecolumn)$/Si)) { return mid }
  if ($regex($1,/^(cmb%|combat%)$/Si)) { return combat% }
  if ($regex($1,/^(p2p%)$/Si)) { return p2p% }
  if ($regex($1,/^(f2p%)$/Si)) { return f2p% }
  if ($regex($1,/^(sl%|slay%|slayer%)$/Si)) { return slayer% }
  if ($regex($1,/^(skill%|skiller%)$/Si)) { return skiller% }
  if ($regex($1,/^(pc%|pest%|pestcontrol%|pest control%)$/Si)) { return pest control% }
}
state {
  if ($regex($remove($1,@),/^(r|ra|ran|rank|ranking)$/Si)) { return 1 }
  if ($regex($remove($1,@),/^(l|lv|lvl|level)$/Si)) { return 2 }
  if ($regex($remove($1,@),/^(x|xp|ex|exp|experience)$/Si)) { return 3 }
  if ($regex($remove($1,@),/^(v|vi|vir|virt|virtual)$/Si)) { return 4 }
}
tracks {
  if ($regex($remove($1,@),/^(2day|today)$/Si)) { return Today }
  if ($regex($remove($1,@),/^(week)$/Si)) { return Week }
  if ($regex($remove($1,@),/^(month)$/Si)) { return Month }
  if ($regex($remove($1,@),/^(year)$/Si)) { return Year }
}
statnum {
  var %skill = $skills($1)
  if (%skill == overall) { return 1 }
  if (%skill == attack) { return 2 }
  if (%skill == strength) { return 4 }
  if (%skill == defence) { return 3 }
  if (%skill == hitpoints) { return 5 }
  if (%skill == ranged) { return 6 }
  if (%skill == prayer) { return 7 }
  if (%skill == magic) { return 8 }
  if (%skill == cooking) { return 9 }
  if (%skill == woodcutting) { return 10 }
  if (%skill == fletching) { return 11 }
  if (%skill == fishing) { return 12 }
  if (%skill == firemaking) { return 13 }
  if (%skill == crafting) { return 14 }
  if (%skill == smithing) { return 15 }
  if (%skill == mining) { return 16 }
  if (%skill == herblore) { return 17 }
  if (%skill == agility) { return 18 }
  if (%skill == thieving) { return 19 }
  if (%skill == slayer) { return 20 }
  if (%skill == farming) { return 21 }
  if (%skill == runecraft) { return 22 }
  if (%skill == hunter) { return 23 }
  if (%skill == construction) { return 24 }
  if (%skill == summoning) { return 25 }
  if ($minigames($1) == Duel) { return 26 }
  if ($minigames($1) == Bounty Hunter) { return 27 }
  if ($minigames($1) == Bounty Hunter Rogues) { return 28 }
  if ($minigames($1) == Fist Of Guthix) { return 29 }
  if ($minigames($1) == Mobilising Armies) { return 30 }
  if ($1 == 1) { return overall }
  if ($1 == 2) { return attack }
  if ($1 == 3) { return defence }
  if ($1 == 4) { return strength }
  if ($1 == 5) { return hitpoints }
  if ($1 == 6) { return ranged }
  if ($1 == 7) { return prayer }
  if ($1 == 8) { return magic }
  if ($1 == 9) { return cooking }
  if ($1 == 10) { return woodcutting }
  if ($1 == 11) { return fletching }
  if ($1 == 12) { return fishing }
  if ($1 == 13) { return firemaking }
  if ($1 == 14) { return crafting }
  if ($1 == 15) { return smithing }
  if ($1 == 16) { return mining }
  if ($1 == 17) { return herblore }
  if ($1 == 18) { return agility }
  if ($1 == 19) { return thieving }
  if ($1 == 20) { return slayer }
  if ($1 == 21) { return farming }
  if ($1 == 22) { return runecraft }
  if ($1 == 23) { return hunter }
  if ($1 == 24) { return construction }
  if ($1 == 25) { return summoning }
  if ($1 == 26) { return duel }
  if ($1 == 27) { return bounty hunter }
  if ($1 == 28) { return bounty hunter rogues }
  if ($1 == 29) { return fist of guthix }
  if ($1 == 30) { return mobilising armies }
}
catno {
  if ($1 != duel && $1 != bounty hunter && $1 != bounty hunter rogues && $1 != fist of guthix && $1 != mobilising armies) { return 0 }
  return 1
}
smartno {
  if ($1 == Overall) { return 0 }
  if ($1 == Attack) { return 1 }
  if ($1 == Defence) { return 2 }
  if ($1 == Strength) { return 3 }
  if ($1 == Hitpoints) { return 4 }
  if ($1 == Ranged) { return 5 }
  if ($1 == Prayer) { return 6 }
  if ($1 == Magic) { return 7 }
  if ($1 == Cooking) { return 8 }
  if ($1 == Woodcutting) { return 9 }
  if ($1 == Fletching) { return 10 }
  if ($1 == Fishing) { return 11 }
  if ($1 == Firemaking) { return 12 }
  if ($1 == Crafting) { return 13 }
  if ($1 == Smithing) { return 14 }
  if ($1 == Mining) { return 15 }
  if ($1 == Herblore) { return 16 }
  if ($1 == Agility) { return 17 }
  if ($1 == Thieving) { return 18 }
  if ($1 == Slayer) { return 19 }
  if ($1 == Farming) { return 20 }
  if ($1 == Runecraft) { return 21 }
  if ($1 == Hunter) { return 22 }
  if ($1 == Construction) { return 23 }
  if ($1 == summoning) { return 24 }
  if ($1 == duel) { return 0 }
  if ($1 == bounty hunter) { return 1 }
  if ($1 == bounty hunter Rogues) { return 2 }
  if ($1 == fist of guthix) { return 3 }
  if ($1 == mobilising armies) { return 4 }
}
