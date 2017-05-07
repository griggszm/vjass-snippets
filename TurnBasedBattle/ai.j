//  -- Creating an AI --
//  create(integer id, String behavior)
//
//  -- Using an AI --
//  run(unit aiUnit, Battle whichBattle)

struct AI

    private string behavior
    private integer id
    private unit aiUnit
    private Battle battle
    private string inspect
    
    public method getBattle takes nothing returns Battle
        return .battle
    endmethod
    
    public method setBattle takes Battle battle returns nothing
        set .battle = battle
    endmethod
    
    public method getId takes nothing returns integer
        return .id
    endmethod
    
    public method setId takes integer id returns nothing
        set .id = id
    endmethod
    
    public method getBehavior takes nothing returns string
        return .behavior
    endmethod

    public method setBehavior takes string behavior returns nothing
        set .behavior = behavior
    endmethod
    
    public method getAIUnit takes nothing returns unit
        return .aiUnit
    endmethod
    
    public method setInspect takes string s returns nothing
        set .inspect = s
    endmethod
    
    public method getInspect takes nothing returns string
        return .inspect
    endmethod
    
    /**
    *   Executes the specified AI function
    */
    public method run takes unit aiUnit, Battle whichBattle returns nothing
        set .battle = whichBattle
        set AIList_whichAI = this
        set .aiUnit = aiUnit
        call ExecuteFunc(this.behavior)
        set .battle = 0
        set .aiUnit = null

    endmethod

    static method create takes integer id, string behavior, string inspect returns thistype
        local thistype new = thistype.allocate()
        call new.setBehavior(behavior)
        call new.setId(id)
        call new.setInspect(inspect)
        return new
    endmethod
    
endstruct
