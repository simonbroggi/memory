VAR cards_turned = 0

-> rules

=== rules ===
NPC: You know how this it works, right??
NPC: It's called memory, or concentration...
NPC: I'll explain.
NPC: We turned {cards_turned} cards so far.
{cards_turned:
- 0:
  NPC: You need to turn two cards.
- 1:
  NPC: You need to turn another card.
- else:
  -> first_cards
}

-(loop_start)
* {cards_turned < 2} ->
    NPC: Go on.
* {cards_turned < 2} ->
    NPC: You can do it.
+ ->
    NPC: wait until player turns some cards.
    ->loop_end
- NPC: Just play with it.
->loop_start

-(loop_end)
NPC: what are you waiting for?
-> DONE

=== first_cards ===
NPC: Let's see what you've got..
-> DONE


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
