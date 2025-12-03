VAR cards_revealed = 0
VAR pairs_collected = 0
VAR npc_pairs = 0

-> rules

=== rules ===
NPC: You know how this it works, right?
+ Yes.
    NPC: Great. You go first.
    -> first_cards_revealed
+ No[.], I've never played it.
    NPC: I doubt that.
    NPC: You need to find pairs of matching cards.
    NPC: It's very simple. I'll show you.
+ Not sure.[] Is it the one where you try to find matching pairs?
    NPC: Yes, excatly.
- NPC: So far {cards_revealed} were flipped.
{cards_revealed:
- 0:
    NPC: You need to turn two cards.
- 1:
    NPC: You need to turn another card.
}
-> DONE // wait for game to go to first_cards_revealed
// -> first_cards_revealed

=== first_cards_revealed ===
NPC: Let's see what you've got..
{pairs_collected:
- 0:
    NPC: No luck. Now it's my turn.
- 1:
    NPC: Lucky start! You can go again.
}
-> DONE

=== completed ===
NPC: That's it. Let's see who won...
NPC: I've got {npc_pairs} pairs. What about you?
+ {pairs_collected + 1}
    NPC: You sure?
+ {pairs_collected}
    NPC: Ok..
+ {pairs_collected + 2}
    NPC: I don't believe it!
- -> DONE

=== something ===
+ Yes.
    NPC: Great. Do you want to start?
    ++ Sure.
        NPC: Allright, what are you waiting for?
    ++ No, you go first.
        NPC: Ok..
        //NPC starts game
+ No.
    NPC: You've never played memory before?
    ++ Of course[] I have..
    ++ No, never.
+ Uhmm..
    NPC: It's just normal memory: you try to pairs. Whoever has most pairs wins the game.
    ++ Sounds boring.
        NPC: You don't have any interesting memories?!?
        NPC: Let's do something about that. Pick two cards!
    ++ Can I go first?
        NPC: Sure, go ahead!
    ++ Ich verstehe kein Wort.
        NPC: Ah, du sprichst deutsch!
        -> regeln
- spiel...
-> DONE
=== regeln ===
NPC: Du weisst wie das Spiel funktioniert, oder?
+ Ja[.], klar!
    NPC: Super. Fängst du an?
    ++ Gerne.
        NPC: Also los! worauf wartest du?
        +++ Ich muss mich konzentrieren.
            NPC: Konzentrieren? Die ersten Karten sind doch eh nur Glück.
        +++ Ich will die Karten neu mischeln!
            NPC: Wieso? Du glaubst ich schummle?
        +++ Ein Moment..
    ++ Lieber nicht.
        NPC: Ok, ich fange an.
+ Nein[.], keine Ahnung.
    NPC: Ich zeig's dir. Es ist ganz einfach.
    NPC: Du kannst anfangen indem du zwei Karten aufdeckst.
- -> DONE

=== remember ===
NPC: You don't remember me?
+ No, should I?
+ NO, sorry..
+ Of course I remember you! Nice to see you! How are you doing?
    NPC: Good, thanks! Nice to
- ->DONE

=== erinnern ===
NPC: Du kannst dich nicht mehr an mich erinnern oder?
+ Doch, klar erinnere ich mich an dich.
+ Nein, leider nicht.
+ Hmm, du kommst mir bekannt vor.
- -> DONE
