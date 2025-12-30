VAR cards_revealed = 0
VAR pairs_collected = 0
VAR npc_pairs = 0

// player character: inventor.
// friend: musician playing in a solarpunk band. You modified his instruments.
// story takes place near future: 2035.

-> create_invention

=== create_invention ===
//todo: define where. home? lab? how's it furnished. anyone else around? weather?..

// Inventor lives and works in a house alone with his dog. locaten in Baden AG.
// todo: try to get some sort of pseudo realistic future of zurich/ baden into a 2d space cycle game. can it work?
    -> physics_or_audio_puzzle

    = physics_or_audio_puzzle
    solve physics or audio puzzle.
    -> write_report

    = write_report
    Write the documentation about your invention.
    Start with a title
    + Turbo Blast Engine
    + Hyper Drive Exaust
    + Supersonar Propulsion
    - Great choice.
    Now continue your report.
    - (report_loop)
    * stuff
        it's stuffed.
    * more
        the more the marry.
    + conclude
        -> save_report
    - ->report_loop

    = save_report
    You staple the paper and put it in your drawer.
    -> publication

=== publication ===
    You need to decide on how to tell the world about your genious invention.
    + Pubicate in a scientifig journal.
        You publish your findings an a renown scientific journa.
        After some weeks, the Senegal Space Symposium invites you to present your work.
        -> go_to_conference
    + Propose a talk in a relevant conference.
        -> go_to_conference
    + Write a colegue directly
        You write a mail about your discovery to Sarah. She proposes to present it at Senegal Spaceflight Symposium.
        -> go_to_conference

=== go_to_conference ===
    Your arrive at Senegal Space Symposium just in time for your presentation.
    -> present_work
    
    = present_work
    You present your work.
    Croud applauds.
    -> meet_people
    
    = meet_people
    try and find some partners to create a prototype.
    find someone else has it already. stolen?!
    -> END

=== Campfire ===
Campfire close to the beach. Sun is down. Json strumming a guitar, Arnet smoking. It's warm.
+ (sit) Sit down
    It's cosy.
    ++ Ask for a smoke
        -> sit
    ++ Stand up
        -> Campfire
+ Leave
    ++ Hostel
    ++ Beach
    ++ Vilage
-> DONE


-> rules

=== rules ===
NPC: You know how this it works, right?
+ Yes.
    NPC: Great. You go first.
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
-> DONE // wait for game to go to first_pair_revealed
// -> first_pair_revealed

// -(loop_start)
// * {cards_revealed < 2} ->
//     NPC: Go on.
// * {cards_revealed < 2} ->
//     NPC: You can do it.
// + ->
//     NPC: wait until player turns some cards.
//     ->loop_end
// - NPC: Just play with it.
// ->loop_start
// -(loop_end)
// -> DONE

=== first_pair_revealed ===
{first_pair_revealed >= 2:
    -> DONE
}
NPC: Let's see what you've got..
{pairs_collected:
- 0:
    NPC: No luck. Now it's my turn.
- 1:
    NPC: Lucky start! You can go again.
}
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
