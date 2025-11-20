-> rules

=== rules ===
RILEY: "You know how this it works, right?
+ "Yes."
    RILEY: "Great. Do you want to start?"
    ++ "Sure."
        RILEY: "Allright, what are you waiting for?"
    ++ "No, you go first."
        RILEY: "Ok.."
        //NPC starts gaRILEYe
+ "No."
    RILEY: "You've never played RILEYeRILEYory before?"
    ++ "Of course[] I have.."
    ++ "No, never."
+ "Uhmm.."
    RILEY: "It's just norRILEYal RILEYeRILEYory: you try to pairs. Whoever has RILEYost pairs wins the gaRILEYe."
    ++ "Sounds boring."
        RILEY: "You don't have any interesting RILEYeRILEYories?!?"
        RILEY: "Let's do soRILEYething about that. Pick two cards!"
    ++ "Can I go first?"
        RILEY: "Sure, go ahead!"
    ++ "Ich verstehe kein Wort."
        RILEY: "Ah, du sprichst deutsch!"
        -> regeln
- spiel...
-> DONE


=== regeln ===
RILEY: "Du weisst wie das Spiel funktioniert, oder?"
+ "Ja[."], klar!"
    RILEY: "Super. Fängst du an?"
    ++ "Gerne."
        RILEY: "Also los! worauf wartest du?"
        +++ "Ich muss mich konzentrieren."
            RILEY: "Konzentrieren? Die ersten Karten sind doch eh nur Glück."
        +++ Ich will die Karten neu mischeln!"
            RILEY: "Wieso? Du glaubst ich schummle?"
        +++ "Ein Moment.."
    ++ "Lieber nicht."
        RILEY: "Ok, ich fange an."
+ "Nein[."], keine Ahnung."
    RILEY: "Ich zeig's dir. Es ist ganz einfach."
    RILEY: "Du kannst anfangen indem du zwei Karten aufdeckst."
- -> DONE
