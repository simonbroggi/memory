-> rules

=== rules ===
NPC: "You know how this it works, right?
+ "Yes."
    NPC: "Great. Do you want to start?"
    ++ "Sure."
        NPC: "Allright, what are you waiting for?"
    ++ "No, you go first."
        NPC: "Ok.."
        //NPC starts game
+ "No."
    NPC: "You've never played memory before?"
    ++ "Of course[] I have.."
    ++ "No, never."
+ "Uhmm.."
    NPC: "It's just normal memory: you try to pairs. Whoever has most pairs wins the game."
    ++ "Sounds boring."
        NPC: "You don't have any interesting memories?!?"
        NPC: "Let's do something about that. Pick two cards!"
    ++ "Can I go first?"
        NPC: "Sure, go ahead!"
    ++ "Ich verstehe kein Wort."
        NPC: "Ah, du sprichst deutsch!"
        -> regeln
- spiel...
-> DONE


=== regeln ===
NPC: "Du weisst wie das Spiel funktioniert, oder?"
+ "Ja[."], klar!"
    NPC: "Super. Fängst du an?"
    ++ "Gerne."
        NPC: "Also los! worauf wartest du?"
        +++ "Ich muss mich konzentrieren."
            NPC: "Konzentrieren? Die ersten Karten sind doch eh nur Glück."
        +++ Ich will die Karten neu mischeln!"
            NPC: "Wieso? Du glaubst ich schummle?"
        +++ "Ein Moment.."
    ++ "Lieber nicht."
        NPC: "Ok, ich fange an."
+ "Nein[."], keine Ahnung."
    NPC: "Ich zeig's dir. Es ist ganz einfach."
    NPC: "Du kannst anfangen indem du zwei Karten aufdeckst."
- -> DONE
