alias checkchans { var %x = 1 | while ($chan(%x)) { var %y = $+(%y $chan(%x),[,$nick($chan(%x),0),]) | inc %x } | return %y }
