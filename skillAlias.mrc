>start<|skillAlias.mrc|new|3.17|a
skillNames {
  var %skills at|att|attack
  %skills = %skills $+ |strength|str|st
  %skills = %skills $+ |defen[cs]e|def|de
  %skills = %skills $+ |hitpoints|hitpoint|hits|hp|constitution
  %skills = %skills $+ |prayer|pray|pr
  %skills = %skills $+ |ranging|ranged|range|ra
  %skills = %skills $+ |magic|mage|ma
  %skills = %skills $+ |runecrafting|runecraft|rune|rc
  %skills = %skills $+ |construction|constr|const|cons|con
  %skills = %skills $+ |agility|agil|agi|ag
  %skills = %skills $+ |herblore|herb|he
  %skills = %skills $+ |thieving|theiving|thieve|theive|thief|theif|th
  %skills = %skills $+ |cr|craft|crafting
  %skills = %skills $+ |sm|smd|smith|smithing
  %skills = %skills $+ |hu|hunt|hunter|hunting
  %skills = %skills $+ |fa|farm|farming
  %skills = %skills $+ |sl|slay|slayer|slaying
  %skills = %skills $+ |mi|mine|mining
  %skills = %skills $+ |fm|fming|firemake|firemaking
  %skills = %skills $+ |fi|fish|fishing
  %skills = %skills $+ |fl|fletch|fletching
  %skills = %skills $+ |wc|wcing|wood|woodcutting|woodcut
  %skills = %skills $+ |cok|cook|cooking|coo
  %skills = %skills $+ |su|sum|summy|summon|summoning
  %skills = %skills $+ |oa|overall|total
  %skills = %skills $+ |du|dun|dungeon|dungeoneering
  return %skills
}
compares {
  if ($regex($1,/^(at|att|attack)$/Si)) { return Attack }
  if ($regex($1,/^(st|str|strength)$/Si)) { return Strength }
  if ($regex($1,/^(de|def|defen[cs]e)$/Si)) { return Defence }
  if ($regex($1,/^(hp|hits|hitpoint|hitpoints|constitution)$/Si)) { return Constitution }
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
  if ($regex($1,/^(du|dun|dungeon|dungeoneering)$/Si)) { return Dungeoneering }
  if ($regex($1,/^(oa|overall|total)$/Si)) { return Overall }
  if ($regex($1,/^(bh|bo|bount|bounty|bountyhunter|Bounty Hunter)$/Si)) { return Bounty Hunter }
  if ($regex($1,/^(bhr|bor|bountrogue|bountyrogue|bountyhunterrogue|rogue|rogues|Bounty Hunter Rogues)$/Si)) { return Bounty Hunter Rogues }
  if ($regex($1,/^(fog|fist|fisting|fistofguth|guth|guthix|fistofguthix|fist of guthix)$/Si)) { return Fist of Guthix }
  if ($regex($1,/^(duel|tournament)$/Si)) { return Duel }
  if ($regex($1,/^(mob?|mobilise|mobilising)(ar|army|armies|armys)?$/Si)) { return Mobilising Armies }
  if ($regex($1,/^(baat|baatt|baattack|baattacker|baattackers|ba attackers|ba_attackers)$/Si)) { return BA Attackers }
  if ($regex($1,/^(bade|badef|badefend|badefender|badefenders|ba defenders|ba_defenders)$/Si)) { return BA Defenders }
  if ($regex($1,/^(baco|bacol|bacollect|bacollector|bacollectors|ba collectors|ba_collectors)$/Si)) { return BA Collectors }
  if ($regex($1,/^(bahe|baheal|bahealer|bahealers|ba healers|ba_healers)$/Si)) { return BA Healers }
  if ($regex($1,/^(st|sk|all|skill|skills|stat|stats|statistics)$/Si)) { return Stats }
  if ($regex($1,/^(cb|cmb|comb|combat|warrior)$/Si)) { return Combat }
  if ($regex($1,/^(cmb%|combat%)$/Si)) { return combat% }
  if ($1 == p2p%) { return p2p% }
  if ($1 == f2p%) { return f2p% }
  if ($regex($1,/^(sl%|slay%|slayer%)$/Si)) { return slayer% }
  if ($regex($1,/^(skill%|skiller%)$/Si)) { return skiller% }
  if ($regex($1,/^(pc%|pest%|pestcontrol%|pest control%)$/Si)) { return pest control% }
}
lookups {
  if ($regex($1,/^(at|att|attack)$/Si)) { return Attack }
  if ($regex($1,/^(st|str|strength)$/Si)) { return Strength }
  if ($regex($1,/^(de|def|defen[cs]e)$/Si)) { return Defence }
  if ($regex($1,/^(hp|hits|hitpoint|hitpoints|constitution)$/Si)) { return Constitution }
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
  if ($regex($1,/^(du|dun|dungeon|dungeoneering)$/Si)) { return Dungeoneering }
  if ($regex($1,/^(oa|overall|total)$/Si)) { return Overall }
  if ($regex($1,/^(bh|bo|bount|bounty|bountyhunter|Bounty Hunter)$/Si)) { return Bounty Hunter }
  if ($regex($1,/^(bhr|bor|bountrogue|bountyrogue|bountyhunterrogue|rogue|rogues|Bounty Hunter Rogues)$/Si)) { return Bounty Hunter Rogues }
  if ($regex($1,/^(fog|fist|fisting|fistofguth|guth|guthix|fistofguthix|fist of guthix)$/Si)) { return Fist of Guthix }
  if ($regex($1,/^(duel|tournament)$/Si)) { return Duel }
  if ($regex($1,/^(mob?|mobilise|mobilising)(ar|army|armies|armys)?$/Si)) { return Mobilising Armies }
  if ($regex($1,/^(baat|baatt|baattack|baattacker|baattackers|ba attackers|ba_attackers)$/Si)) { return BA Attackers }
  if ($regex($1,/^(bade|badef|badefend|badefender|badefenders|ba defenders|ba_defenders)$/Si)) { return BA Defenders }
  if ($regex($1,/^(baco|bacol|bacollect|bacollector|bacollectors|ba collectors|ba_collectors)$/Si)) { return BA Collectors }
  if ($regex($1,/^(bahe|baheal|bahealer|bahealers|ba healers|ba_healers)$/Si)) { return BA Healers }
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
  if ($regex($1,/^(hp|hits|hitpoint|hitpoints|constitution)$/Si)) { return Constitution }
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
  if ($regex($1,/^(du|dun|dungeon|dungeoneering)$/Si)) { return Dungeoneering }
  if ($regex($1,/^(oa|overall|total)$/Si)) { return Overall }
  if ($regex($1,/^(bh|bo|bount|bounty|bountyhunter|Bounty Hunter)$/Si)) { return Bounty Hunter }
  if ($regex($1,/^(bhr|bor|bountrogue|bountyrogue|bountyhunterrogue|rogue|rogues|Bounty Hunter Rogues)$/Si)) { return Bounty Hunter Rogues }
  if ($regex($1,/^(fog|fist|fisting|fistofguth|guth|guthix|fistofguthix|fist of guthix)$/Si)) { return Fist of Guthix }
  if ($regex($1,/^(duel|tournament)$/Si)) { return Duel }
  if ($regex($1,/^(mob?|mobilise|mobilising)(ar|army|armies|armys)?$/Si)) { return Mobilising Armies }
  if ($regex($1,/^(baat|baatt|baattack|baattacker|baattackers|ba attackers|ba_attackers)$/Si)) { return BA Attackers }
  if ($regex($1,/^(bade|badef|badefend|badefender|badefenders|ba defenders|ba_defenders)$/Si)) { return BA Defenders }
  if ($regex($1,/^(baco|bacol|bacollect|bacollector|bacollectors|ba collectors|ba_collectors)$/Si)) { return BA Collectors }
  if ($regex($1,/^(bahe|baheal|bahealer|bahealers|ba healers|ba_healers)$/Si)) { return BA Healers }
}
skills {
  if ($regex($1,/^(at|att|attack)$/Si)) { return Attack }
  if ($regex($1,/^(st|str|strength)$/Si)) { return Strength }
  if ($regex($1,/^(de|def|defen[cs]e)$/Si)) { return Defence }
  if ($regex($1,/^(hp|hits|hitpoint|hitpoints|constitution)$/Si)) { return Constitution }
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
  if ($regex($1,/^(du|dun|dungeon|dungeoneering)$/Si)) { return Dungeoneering }
  if ($regex($1,/^(oa|overall|total)$/Si)) { return Overall }
}
minigames {
  if ($regex($1,/^(bh|bo|bount|bounty|bountyhunter|Bounty Hunter)$/Si)) { return Bounty Hunter }
  if ($regex($1,/^(bhr|bor|bountrogue|bountyrogue|bountyhunterrogue|rogue|rogues|Bounty Hunter Rogues)$/Si)) { return Bounty Hunter Rogues }
  if ($regex($1,/^(fog|fist|fisting|fistofguth|guth|guthix|fistofguthix|fist of guthix)$/Si)) { return Fist of Guthix }
  if ($regex($1,/^(duel|tournament)$/Si)) { return Duel }
  if ($regex($1,/^(mob?|mobilise|mobilising) ?(ar|army|armies|armys)?$/Si)) { return Mobilising Armies }
  if ($regex($1,/^(baat|baatt|baattack|baattacker|baattackers|ba attackers|ba_attackers)$/Si)) { return BA Attackers }
  if ($regex($1,/^(bade|badef|badefend|badefender|badefenders|ba defenders|ba_defenders)$/Si)) { return BA Defenders }
  if ($regex($1,/^(baco|bacol|bacollect|bacollector|bacollectors|ba collectors|ba_collectors)$/Si)) { return BA Collectors }
  if ($regex($1,/^(bahe|baheal|bahealer|bahealers|ba healers|ba_healers)$/Si)) { return BA Healers }
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
  if ($1 == p2p%) { return p2p% }
  if ($1 == f2p%) { return f2p% }
  if ($regex($1,/^(sl%|slay%|slayer%)$/Si)) { return slayer% }
  if ($regex($1,/^(skill%|skiller%)$/Si)) { return skiller% }
  if ($regex($1,/^(pc%|pest%|pestcontrol%|pest control%)$/Si)) { return pest control% }
}
state {
  var %state $remove($1,@)
  if ($regex(%state,/^(r|ra|ran|rank|ranking)s?$/Si)) { return 1 }
  if ($regex(%state,/^(l|lv|lvl|level)s?$/Si)) { return 2 }
  if ($regex(%state,/^(x|xp|ex|exp|experience)$/Si)) { return 3 }
  if ($regex(%state,/^(v|vi|vir|virt|virtual)$/Si)) { return 4 }
}
tracks {
  var %timePeriod $remove($1,@)
  if (%timePeriod == 2day || %timePeriod == today) { return Today }
  if (%timePeriod == week) { return Week }
  if (%timePeriod == month) { return Month }
  if (%timePeriod == year) { return Year }
}
statnum {
  if ($1 == overall) { return 1 }
  if ($1 == attack) { return 2 }
  if ($1 == defence) { return 3 }
  if ($1 == strength) { return 4 }
  if ($1 == hitpoints || $1 == constitution) { return 5 }
  if ($1 == ranged) { return 6 }
  if ($1 == prayer) { return 7 }
  if ($1 == magic) { return 8 }
  if ($1 == cooking) { return 9 }
  if ($1 == woodcutting) { return 10 }
  if ($1 == fletching) { return 11 }
  if ($1 == fishing) { return 12 }
  if ($1 == firemaking) { return 13 }
  if ($1 == crafting) { return 14 }
  if ($1 == smithing) { return 15 }
  if ($1 == mining) { return 16 }
  if ($1 == herblore) { return 17 }
  if ($1 == agility) { return 18 }
  if ($1 == thieving) { return 19 }
  if ($1 == slayer) { return 20 }
  if ($1 == farming) { return 21 }
  if ($1 == runecraft) { return 22 }
  if ($1 == hunter) { return 23 }
  if ($1 == construction) { return 24 }
  if ($1 == summoning) { return 25 }
  if ($1 == dungeoneering) { return 26 }
  if ($1 == duel || $1 == dueling) { return 27 }
  if ($1 == bounty hunter) { return 28 }
  if ($1 == bounty hunter rogues) { return 29 }
  if ($1 == fist of guthix) { return 30 }
  if ($1 == mobilising armies) { return 31 }
  if ($1 == ba attackers || $1 == ba attacker) { return 32 }
  if ($1 == ba defenders || $1 == ba defender) { return 33 }
  if ($1 == ba collectors || $1 == ba collector) { return 34 }
  if ($1 == ba healers || $1 == ba healer) { return 35 }
  if ($1 == 1) { return overall }
  if ($1 == 2) { return attack }
  if ($1 == 3) { return defence }
  if ($1 == 4) { return strength }
  if ($1 == 5) { return constitution }
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
  if ($1 == 26) { return dungeoneering }
  if ($1 == 27) { return duel }
  if ($1 == 28) { return bounty hunter }
  if ($1 == 29) { return bounty hunter rogues }
  if ($1 == 30) { return fist of guthix }
  if ($1 == 31) { return mobilising armies }
  if ($1 == 32) { return ba attackers }
  if ($1 == 33) { return ba defenders }
  if ($1 == 34) { return ba collectors }
  if ($1 == 35) { return ba healers }
}
catno {
  if (!$minigames($1)) { return 0 }
  return 1
}
smartno {
  if ($1 == Overall) { return 0 }
  if ($1 == Attack) { return 1 }
  if ($1 == Defence) { return 2 }
  if ($1 == Strength) { return 3 }
  if ($1 == Hitpoints || $1 == constitution) { return 4 }
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
  if ($1 == dungeoneering) { return 25 }
  if ($1 == duel) { return 0 }
  if ($1 == bounty hunter) { return 1 }
  if ($1 == bounty hunter Rogues) { return 2 }
  if ($1 == fist of guthix) { return 3 }
  if ($1 == mobilising armies) { return 4 }
  if ($1 == ba attackers) { return 5 }
  if ($1 == ba defenders) { return 6 }
  if ($1 == ba collectors) { return 7 }
  if ($1 == ba healers) { return 8 }
}
