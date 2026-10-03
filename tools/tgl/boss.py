"""How each corridor boss moves and fires, read off its handler (bank 6 object dispatch).

Everything here is read from the code, not observed: only Fleepa's setup values were checked
against a savestate (``...fish.fcs``: ``$0668`` = ``$10``, ``$07A0`` = ``$0F``, y 116 at velocity
about 1.9, what the bounce predicts). Direction numbers are 0-15 in 22.5 degree steps; 0/4/8/12
= right/down/left/up - CORRECTED: it said down/right/up/left; ``$F8CE`` run on the NES model gives
x +3.75 for 0 and y +3.75 for 4, and the player's own shot, fixed at 12 in a corridor, goes up (the
on-screen sense of each boss's own counter-driven fans is not checked). ``$0518`` is y, ``$0530`` is x.
"""

from __future__ import annotations

# The shared routines every handler is built from: (address, what it does)
PRIMITIVES = [
    ("$F863 (via $C0FF)", "aim at the player: compares the object's x/y with slot 0's and "
     "returns one of 16 directions (table $F95E)"),
    ("$F8CE", "turn a direction (masked AND #$0F) into an x/y velocity (tables $F986/$F98E)"),
    ("$CD12 / $CD46 (via $C09C / $C09F)", "accelerate y / x toward a target held in $0668 / "
     "$0680, by the amount in A. With a fixed target this is a spring: a bounce or a swing"),
    ("$A325 (and $A337 for y)", "move the object one pixel toward the player's x (y)"),
    ("$CD7A (via $C0A5)", "add A to a phase counter ($0650 fraction, $0638 whole), wrapping at "
     "Y; a wrap is the usual moment to fire"),
    ("$F9D1 / $AD9A", "$F9D1 is the random number; $AD9A is not random, it toggles $6A bit 0"),
    ("$FA5B + $FA4B", "find a free slot (5-23) and spawn an object of type A there, at the "
     "boss's position"),
]

# (types, kind, handler, movement, fire); kind is a key of FOLLOW
BEHAVIOUR = [
    ((0x45,), "tracks", "bank 6 $9088",
     "Enters at (128, 96) and holds y near $30 with a spring (accel 9). Its x target $0680 is "
     "loaded from the PLAYER's x every frame (LDA $0530), accel 4: it chases the player "
     "sideways.",
     "A phase counter ($CD7A, +$20, wrap 8) fires a type $2C shot about every 16 frames in the "
     "direction $F863 returns: aimed at the player."),
    ((0x23,), "tracks", "bank 6 $8D70",
     "Starts at a random x, y $C0 with y velocity -5, then falls under a constant acceleration "
     "($18); when y reaches $C0 it is relaunched, so it jumps and drops in a cycle. x homes on "
     "the player's x (accel 8).",
     "Fires three type $27 shots on a phase wrap: aim, aim+4 and aim+12 (a cross around the "
     "player's direction)."),
    ((0x40, 0x41), "tracks", "bank 3 $952E (bank 6 $9081 far-calls it)",
     "Random start x, y $10. After the 120-frame entry it is kicked down at +4 and pulled back "
     "toward y $10 (accel $10), so it bounces. Every second frame $0530 moves one pixel toward "
     "the player's x.",
     "Fires a type $27 shot when its y velocity is 0 or -1 (the ends of the bounce) and the "
     "frame counter ANDed with its mask ($0F / $07) is 0. The shot's direction is a counter "
     "ORed with 8, so it cycles through 8-15: a fixed sweep, not aimed."),
    ((0x24, 0x25, 0x26), "tracks", "bank 6 $8E68",
     "Random start x, y $28, 60-frame entry. Then $A325 creeps x one pixel toward the player "
     "every other frame. The two arm pieces spread by a phase counter; the body changes state "
     "by hit points (thresholds $14, $32, $64, $C8), spawning side modules.",
     "Fires type $27 shots on the phase counter in direction 0 or 8, alternating ($AD9A << 3): "
     "a fixed pattern."),
    ((0x48, 0x49), "aims", "bank 6 $93DC",
     "Enters from x $C0 and settles at (128, 104) by spring (targets $0668 / $0680 fixed). "
     "Fixed position; its body animation flickers every 8 frames.",
     "At particular animation frames fires pairs of shots in the direction $F863 returns "
     "(aimed), alternating type $4E and $27 ($AD9A); also spawns type $0B and a $2A shot with "
     "a random x velocity. Hit-point stages change its state."),
    ((0x46, 0x4C, 0x4D), "teleports", "bank 6 $9188",
     "A 120-frame cycle: blink in, solid, blink out, hidden, then a new random position ($F9E9). "
     "It does not move between teleports.",
     "Re-aims at the player once per cycle (direction stored in $0668). Type $46 sweeps shots "
     "through aim-4 to aim+4 as its phase counter runs; $4C and $4D fire 16 shots (type $27) in "
     "a ring offset by the aim."),
    ((0x2D, 0x2E, 0x2F), "fixed", "bank 3 $93FA (bank 6 $907A far-calls it)",
     "Starts at (128, 48) with velocity (x +4, y +1) and is pulled back to that point by two "
     "springs (x accel $12, y accel $20): it swings side to side about the centre with a small "
     "vertical bob. It never reads the player's position for movement.",
     "Spawns shots with a random vertical speed of 1-4; the sign depends on whether the boss "
     "is above the player ($0518 against slot 0's), and a type $0B object every 32 frames."),
    ((0x18, 0x19), "fixed", "bank 6 $8C98",
     "Enters from the top (y velocity +1) to y $60, then holds still at x $80.",
     "On the frame counter $41: every 32 frames an object spawned by $EA8C at an x offset taken "
     "from the counter; every 16 frames a minion at x offset -32 / +32 alternating ($AD9A)."),
    ((0x47,), "fixed", "bank 6 $931A",
     "Flies in to (128, 96) by spring, then hovers there.",
     "Counts down a phase; then fires type $27 shots in fixed directions from the table at "
     "$93D8, and waits a random $50-$CF frames before the next burst."),
    ((0x4F,), "fixed", "bank 1 $82B5 (bank 6 $9605 far-calls it)",
     "Body at (128, 64) by spring, alternating between a moving phase and a still one on a "
     "random timer. Its two arms wander: each follows a pattern chosen from a table ($8430) "
     "every 16-79 frames, clamped to $30-$70.",
     "Fires type $27 shots and type $2A shots with random x speed, on a frame-counter mask that "
     "tightens as its hit points fall."),
    ((0x06,), "stage", "bank 6 $A889 (controller); parts $A8D8 ($36/$37), $B851 ($7E/$7F)",
     "Nothing moves: type $06 is an invisible controller. It waits until the scroll has "
     "stopped ($B8 and $B9 both 0), counts the live objects of types $36, $37, $7E and $7F, and "
     "dies when none is left (bank 6 $A8A6-$A8C3). Those parts are ground objects spawned by "
     "the stage's own metatiles (bank 5 $89FB) and drawn over background tiles.",
     "The eyes ($7E, $7F; $B851) shoot at random intervals - $07B8 plus a random 0-31 - aimed at "
     "the player with $F863 (type $27 from $7E, $4E from $7F), and have four times their "
     "hit points once the boss phase starts. The cannons ($36, $37; $A8D8) animate by "
     "patching background tiles ($AA21) and fire a type $2B shot, aimed ($AA12), at animation "
     "phase 3."),
]

FOLLOW = {"stage": "part of the stage; its parts fire aimed shots",
          "tracks": "follows the player's x", "aims": "aimed shots",
          "teleports": "random position, re-aims each cycle", "fixed": "fixed pattern"}

NOT_READ = (
    "<strong>Not established.</strong> <strong>Corridor 21</strong> never reads bank 3 "
    "<code>$9151</code>: bank 4's command 5 carries the boss type (<code>$E7AF</code>), and its "
    "stream names six in turn - Fleepa, Zibzub, Clawbot (<code>$25</code>), Optomon "
    "(<code>$2F</code>), Grimgrin (<code>$48</code>) and Bombarder (<code>$4D</code>) - a boss "
    "gauntlet. After it the game plays a short scene (<code>$ECC7</code> far-calls bank 0) and "
    "does <code>INC $51</code> into <strong>corridor 22</strong>, whose slot in "
    "<code>$9151</code> is <code>$4F</code>: <strong>It</strong>, the final boss, in a short "
    "corridor of its own (bank 4 stream <code>$8511</code>, 11 records). Corridors 0, 7 and 17 name type "
    "<code>$06</code>, the stage bosses (see the next section). The "
    "shared shot, type <code>$27</code> (<code>$A0C6</code>), can turn toward the player when its "
    "<code>$07A0</code> timer reaches zero; which bosses' shots do so is not worked out, so "
    "&ldquo;aimed&rdquo; means the direction at the moment of firing. Non-boss enemies have not "
    "been read.")
