return {
    ["inkVersion"] = 20,
    ["root"] = {{{
        ["->"] = "start"
    }, {"done", {
        ["#n"] = "g-0"
    }}, "TERM"}, "done", {
        ["start"] = {
            [1] = {
                ["->t->"] = "tunnel"
            }, 
            [2] = "^The end", 
            [3] = "\n", 
            [4] = "end", 
            [5] = "TERM"
        },
        ["tunnel"] = {
                [1] = "thread", 
                [2] = {["->"] = "place1"}, 
                [3] = "thread", 
                [4] = {["->"] = "place2"}, 
                [5] = "done", 
                [6] = "TERM"
        },
        ["place1"] = {{"^This is place 1.", "\n", {"ev", {
            ["^->"] = "place1.0.2.$r1"
        }, {
            ["temp="] = "$r"
        }, "str", {
            ["->"] = ".^.s"
        }, {{
            ["#n"] = "$r1"
        }}, "/str", "/ev", {
            ["*"] = ".^.^.c-0",
            ["flg"] = 18
        }, {
            ["s"] = {"^choice in place 1", {
                ["->"] = "$r",
                ["var"] = true
            }, "TERM"}
        }}, {
            ["c-0"] = {"ev", {
                ["^->"] = "place1.0.c-0.$r2"
            }, "/ev", {
                ["temp="] = "$r"
            }, {
                ["->"] = ".^.^.2.s"
            }, {{
                ["#n"] = "$r2"
            }}, "\n", {
                ["->"] = ".^.^.g-0"
            }, {
                ["#f"] = 5
            }},
            ["g-0"] = {"ev", "void", "/ev", "->->", "TERM"}
        }}, "TERM"},
        ["place2"] = {{"^This is place 2.", "\n", {"ev", {
            ["^->"] = "place2.0.2.$r1"
        }, {
            ["temp="] = "$r"
        }, "str", {
            ["->"] = ".^.s"
        }, {{
            ["#n"] = "$r1"
        }}, "/str", "/ev", {
            ["*"] = ".^.^.c-0",
            ["flg"] = 18
        }, {
            ["s"] = {"^choice in place 2", {
                ["->"] = "$r",
                ["var"] = true
            }, "TERM"}
        }}, {
            ["c-0"] = {"ev", {
                ["^->"] = "place2.0.c-0.$r2"
            }, "/ev", {
                ["temp="] = "$r"
            }, {
                ["->"] = ".^.^.2.s"
            }, {{
                ["#n"] = "$r2"
            }}, "\n", {
                ["->"] = ".^.^.g-0"
            }, {
                ["#f"] = 5
            }},
            ["g-0"] = {"ev", "void", "/ev", "->->", "TERM"}
        }}, "TERM"}
    }},
    ["listDefs"] = {}
}
