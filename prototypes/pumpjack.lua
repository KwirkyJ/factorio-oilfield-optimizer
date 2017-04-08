return {
    foot = {x=3, y=3},
    requires_power = true,
    is_source = true,
    pipe_rule = 'first',
    rotations = {
        ['^'] = {tiles = {{'P', 'P', '^'},
                          {'P', '@', 'P'},
                          {'P', 'P', 'P'}},
                 pipe_attachments = {{x=1, y=-2}},
        },
        ['>'] = {tiles = {{'P', 'P', '>'},
                          {'P', '@', 'P'},
                          {'P', 'P', 'P'}},
                 pipe_attachments = {{x=2, y=-1}},
        },
        ['v'] = {tiles = {{'P', 'P', 'P'},
                          {'P', '@', 'P'},
                          {'v', 'P', 'P'}},
                 pipe_attachments = {{x=-1, y=2}},
        },
        ['<'] = {tiles = {{'P', 'P', 'P'},
                          {'P', '@', 'P'},
                          {'<', 'P', 'P'}},
                 pipe_attachments = {{x=-2, y=1}},
        }
    },
}

