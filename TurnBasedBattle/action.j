// -- Creating an Action --
//  create(String name, String behavior, int id, real cost)
//  
//  -- Using an Action --
//  run(unit source, unit target, Battle whichBattle)

struct Action

    private string behavior
    private string name
    private real cost
    private unit source
    private unit target
    private integer id
    private integer learn
    private integer learnCost
    private Battle battle
    
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

    public method getName takes nothing returns string
        return .name
    endmethod

    public method setName takes string name returns nothing
        set .name = name
    endmethod

    public method getCost takes nothing returns real
        return .cost
    endmethod

    public method setCost takes real cost returns nothing
        set .cost = cost
    endmethod
    
    public method getSource takes nothing returns unit
        return .source
    endmethod
    
    public method getTarget takes nothing returns unit
        return .target
    endmethod
    
    method getLearn takes nothing returns integer
        return .learn
    endmethod

    method setLearn takes integer learn returns nothing
        set .learn = learn
    endmethod

    method getLearnCost takes nothing returns integer
        return .learnCost
    endmethod

    method setLearnCost takes integer learnCost returns nothing
        set .learnCost = learnCost
    endmethod

    
    /**
    *   Performs an action for the spell
    */
    public method run takes unit source, unit target, Battle whichBattle returns nothing
        local real mana = GetUnitState(source,UNIT_STATE_MANA)
        if(mana>=cost)then
            call SetUnitState(source,UNIT_STATE_MANA,mana-cost)
            call redText("Uses: " + .getName() + " (Mana: " + I2S(R2I(GetUnitState(source,UNIT_STATE_MANA))) + "/" + I2S(R2I(GetUnitState(source,UNIT_STATE_MAX_MANA)))+")",source,0)
            set Spells_spellCast = this
            set .source = source
            set .target = target
            set .battle = whichBattle
            call ExecuteFunc(this.behavior)
            set .source = null
            set .target = null
            set .battle = 0
        else
            call redText("Not enough mana: " + .getName(),source,0)
            if(GetOwningPlayer(source)==Player(11))then
                call whichBattle.next()
                call SetUnitState(source,UNIT_STATE_MANA,mana+GetUnitState(source,UNIT_STATE_MAX_MANA)*0.10)
            endif
        endif
        
    endmethod

    static method create takes string name, string behavior, integer id, real cost, integer learn, integer learnCost returns thistype
        local thistype new = thistype.allocate()
        call new.setName(name)
        call new.setBehavior(behavior)
        call new.setCost(cost)
        call new.setId(id)
        call new.setLearn(learn)
        call new.setLearnCost(learnCost)
        return new
    endmethod
    
endstruct
