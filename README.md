Pass The Bomb
=============

This is a remake of the old WC3 Pass The Bomb level, from the maker of Pass The Bomb for Starcraft 2.
Hopefully this time there won't be an SC2 Arcade update that completely breaks loading the source level, forcing me to start from scratch if I want to keep updating it...

Note that the level is currently **very** alpha, don't expect everything to work.

Current Status
==============

Playable, though with limited gamemodes and settings.
`ptb_fast` in the console will switch to shorter rounds (Don't use `ptb_sanic`, it's only for testing)

Implemented gamemodes:
- Normal - Daytime, standard blink and bomb tossing.
- Night - Nighttime, standard blink and bomb tossing.
- Darkest of Nights - Nighttime w/ darkness 60%/50% vision range, only blink on the bomb carrier.
- Super Toss - Daytime, standard blink and longer bomb tosses.
- Super Blink - Daytime, upgraded blink and normal bomb tossing.
- Forest - Daytime, spawns random trees during its duration, only blink on the bomb carrier.

TODO
====

- Needs a nicer countdown
- Actually toss a bomb, like a tiny toss
- Only provide vision on some modes
- Put a minimap notice on the bomb carrier
- Localize all the strings
- More gamemodes: (These are only ideas)
  - Rooted mode, no movement except for blink
  - Incognito mode, no countdown or effect for carrying the bomb
  - Huge tree mode, huge trees covering the playing field, hidden healthbars
  - Barred mode, movement blockers covering the playing field, no vision blocking though
  - Heavyweight mode, bomb tossing ministuns
  - Skillshot mode, can have submodes for all the different skillshots
  - Drunken mode, camera shakes wildly during the round
