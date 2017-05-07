library Spells initializer onInit
 
    globals
        public Battle thisBattle
        public Action spellCast
        public unit turnUnit
        private Action array actions
        private integer count = 0
        private integer array savedSkills
    endglobals
   
    private function createSpell takes string name, string behavior, integer id, real cost, integer learn, integer learnCost returns nothing
        set actions[count] = Action.create(name,behavior,id,cost,learn,learnCost)
        set count = count + 1
    endfunction
   
    /**
    *   Gets an ability from an id
    */
    public function convertAbilityIdToAction takes integer id returns Action
        local integer i = 0
        local Action returnAbility = 0
        local Action temp = 0
        loop
            exitwhen i>count
            set temp = actions[i]
            if(temp!=0)then
                if(temp.getId()==id)then
                    set returnAbility = actions[i]    
                endif
            endif
            set i = i + 1
        endloop
        return returnAbility
    endfunction
   
    /**
    *   Gets an ability from a name
    */
    public function convertAbilityNameToAction takes string name returns Action
        local integer i = 0
        local Action returnAbility = 0
        local Action temp = 0
        loop
            exitwhen i>count
            set temp = actions[i]
            if(temp!=0)then
                if(temp.getName()==name)then
                    set returnAbility = actions[i]    
                endif
            endif
            set i = i + 1
        endloop
        return returnAbility
    endfunction
   
    /**
    *   Gets an ability from an id
    */
    public function convertAbilityIdToName takes integer id returns string
        local integer i = 0
        local string name
        local Action temp = 0
        loop
            exitwhen i>count
            set temp = actions[i]
            if(temp!=0)then
                if(temp.getId()==id)then
                    set name = actions[i].getName()    
                endif
            endif
            set i = i + 1
        endloop
        return name
    endfunction
   
    /**
    *   Gets an ability id from a name
    */
    public function convertAbilityNameToId takes string name returns integer
        local integer i = 0
        local integer id = 0
        local Action temp = 0
        loop
            exitwhen i>count
            set temp = actions[i]
            if(temp!=0)then
                if(temp.getName()==name)then
                    set id = actions[i].getId()    
                endif
            endif
            set i = i + 1
        endloop
        return id
    endfunction
   
    /**
    *   Gets an ability from a learncode
    */
    public function convertAbilityLearncodeToAbility takes integer learncode returns Action
        local integer i = 0
        local Action desired = 0
        local Action temp = 0
        loop
            exitwhen i>count
            set temp = actions[i]
            if(temp!=0)then
                if(temp.getLearn()==learncode)then
                    set desired = temp
                endif
            endif
            set i = i + 1
        endloop
        return desired
    endfunction
   
    /**
    *   Gets an ability id from a learncode
    */
    public function convertAbilityLearncodeToAbilityId takes integer learncode returns integer
        return convertAbilityLearncodeToAbility(learncode).getId()
    endfunction
   
    /**
    *   Transfers abilities from source to u
    */
    public function giveAbilities takes unit source, unit u returns nothing
        local integer i = 0
        local integer abil = 0
        loop
            exitwhen i>count
            set abil = actions[i].getId()
            if(GetUnitAbilityLevel(source,abil)>0)then
                call UnitAddAbility(u,abil)
            endif
            set i = i + 1
        endloop
    endfunction
   
    public function learnSkill takes integer learncode, unit u returns nothing
        local Action toLearn = convertAbilityLearncodeToAbility(learncode)
        local integer apRequired
        local item apOfHero
        if(toLearn!=0)then
            set apRequired = toLearn.getLearnCost()
            set apOfHero = GetItemOfTypeFromUnitBJ(u,'I006')
            if(GetItemCharges(apOfHero)>=apRequired)then
                call SetItemCharges(apOfHero,GetItemCharges(apOfHero)-apRequired)
                call UnitAddAbility(u,toLearn.getId())
                call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIem\\AIemTarget.mdl",u,"origin"))
            else
                call DisplayTextToPlayer(GetOwningPlayer(u),0,0,"|cFF0080FFYou do not have enough AP!|r")
            endif
        endif
    endfunction
   
    /**
    *   Removes the specified ability from the unit.
    */
    public function parseRemovalString takes player p, string s returns nothing
        local string retrieved = ""
        local string heroname = ""
        local string temp = ""
        local integer toRemove
        local integer i = 8
        local integer breaker = 0
        local group g = CreateGroup()
        local unit fog = null
        loop
            set temp = SubString(s,i,i+1)
            exitwhen temp == "," or breaker==100
            set heroname = heroname + temp
            set i = i + 1
            set breaker = breaker + 1
        endloop
        set i = i + 1
        loop
            set temp = SubString(s,i,i+1)
            exitwhen temp == "" or breaker==100
            set retrieved = retrieved + temp
            set i = i + 1
            set breaker = breaker + 1
        endloop
        set toRemove = convertAbilityNameToId(retrieved)
       
        if(heroname=="Beast")then
            call DisplayTextToPlayer(p,0,0,"|cFF0080FFDo not remove spells from Beast-type heroes.|r")
            return
       endif
       
        if(breaker==100 or toRemove==0)then
            call DisplayTextToPlayer(p,0,0,"|cFF0080FFInvalid ability input. Please follow the exact format: ''-remove Hero Name,Ability Name''|r")
        else
            call GroupEnumUnitsInRect(g,GetPlayableMapRect(),null)
            loop
                set fog = FirstOfGroup(g)
                exitwhen fog==null or (GetUnitName(fog)==heroname and GetOwningPlayer(fog)==p)
                call GroupRemoveUnit(g,fog)
            endloop
            if(fog==null)then
                call DisplayTextToPlayer(p,0,0,"|cFF0080FFInvalid unit input. Please follow the exact format: ''-remove Hero Name,Ability Name''|r")
            else
                call UnitRemoveAbility(fog,toRemove)
                call DisplayTextToPlayer(p,0,0,"|cFF0080FFSuccessfully removed " + retrieved + " from " + heroname + "|r")
            endif
        endif
    endfunction
   
    /**
    *   Returns how many abilities unit u has
    */
    public function countAbilities takes unit u returns integer
        local integer i = 0
        local integer abil = 0
        local integer abilities = 0
        loop
            exitwhen i>count
            set abil = actions[i].getId()
            if(GetUnitAbilityLevel(u,abil)>0)then
                set abilities = abilities + 1
            endif
            set i = i + 1
        endloop
        return abilities
    endfunction
   
    public function saveSkills takes unit u returns nothing
        local integer which = 0
        local integer i = 0
        local integer abil = 0
        local integer abilities = 0
        loop
            exitwhen i>count
            set abil = actions[i].getId()
            if(GetUnitAbilityLevel(u,abil)>0)then
                set savedSkills[which]=abil
                set which = which + 1
            endif
            set i = i + 1
        endloop
    endfunction
   
    public function restoreSkills takes unit u returns nothing
        local integer i = 0
        loop
            exitwhen i>4
            if(savedSkills[i]!=0)then
                call UnitAddAbility(u,savedSkills[i])
            endif
            set savedSkills[i]=0
            set i = i + 1
        endloop
    endfunction
   
    private function onInit takes nothing returns nothing

    endfunction
   

    endlibrary
