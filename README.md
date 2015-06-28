Pass The Bomb
=============

This is a remake of the old WC3 Pass The Bomb level, from the maker of Pass The Bomb for Starcraft 2.
Hopefully this time there won't be an SC2 Arcade update that completely breaks loading the source level, forcing me to start from scratch if I want to keep updating it...

Note that the level is currently **very** alpha, don't expect everything to work.

Feel free to report issues and suggestions.

Current Status
==============

Playable, though with limited gamemodes and settings.
`ptb_fast` in the console will switch to shorter rounds.

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
  - Barred mode, movement blocking rocks/other covering the playing field, no vision blocking though
  - Heavyweight mode, bomb tossing ministuns
  - Casket mode, bomb bounces between targets if in range
  - Skillshot mode, pass the bomb with mirana arrow / sunstrike / other
  - Drunken mode, camera sways wildly during the round
  - Multibomb mode, two or more bombs in play at the same time, will need a lot of code work though
