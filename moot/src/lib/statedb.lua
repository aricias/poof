statedb = {}

function create_state_db()
    return db:create('statedb', {
        spots = { name = '',
                  last_visited = -1,
                  last_killed = -1,
                  _unique = {'name'}},
        msco = { name = '',
                 source = '',
                 raw_line = ''},
        mud_options = { name = '', 
                        old_val = ''}
    })
end

statedb.db = create_state_db()

return statedb