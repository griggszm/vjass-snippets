//  -- Initializing a Battle --
//  create()
//  setX(real x) - Sets the x location to battle in (center)
//  setY(real y) - Sets the y location to battle in (center)
//  setLocation(Location loc) - Sets x/y of arena to Loc
//  setEnemies(group enemies) - Declares which group are the
//                                    enemies to fight in battle
//  setHeroes(group heroes) - Same for heroes.
//   (note: these groups are NOT destroyed after use)
//  setArenaSize(real x, real y) - Sets the dimensions of
//                                       the arena to use.
//  start() - Initiates the battle. Moves heroes/enemies in,
//                  and starts the first move.
//
//  -- Battle Flow --
//  pause() - Stops battling units from acting
//  resume() - Resumes action - same unit may go again
//  next() - Allows the next unit in order to act
//
//  -- Ending a Battle --
//  boolean isBattleOver() - Returns whether or not battle has ended
//  Boolean hasPlayerWon() - Returns true if player won the battle
//      (so, if (not)hasPlayerWon() and isBattleOver(), then AI won)
//  Destroy() - Call after battle is no longer used to free resources
 
struct Battle
 
    /**
    *   Some general constants. You should edit these.
    *   ENEMY is self explanatory.
    *   The characters that belong to the enemy.
   
    *   SELECTOR is the unit-type of the command selector dummy
    *   Players use this unit to select what they want to do.
    *
    *   The size of the orders array plus one is the limit of
    *   units in the arena. Same thing for the array heroList,
    *   but for max heroes in arena. MAX_HEROES is this index + 1
    */  
    public static constant player ENEMY = Player(11)
    private static constant integer SELECTOR = 'h002'
    private unit array order[12]
   
    /**
    *    Gets a unit speed to determine turn order
    *    Should be edited by user. This is just an example function.
    */
    private static method getUnitSpeed takes unit u returns integer
        if(GetOwningPlayer(u)!=ENEMY)then
            return (GetUnitPointValue(u) + (GetHeroAgi(u,true)/20))+1
        else
            return (GetUnitPointValue(u) + (GetHeroAgi(u,true)/20))
        endif
    endmethod
   
    /** Do not edit below **/
   
    /**
    *   Results
    */
    private boolean battleOver = false
    private boolean playerWon = false
   
    /**
    *   For internal trigger work.
    */
    private static Battle array battles
    private static integer battleCount = 0
    private static boolean triggersExist = false
   
    /**
    *   Instance variables
    */
    public group enemies
    public group heroes
    public integer turn = 1
    public real arenaX = 0
    public real arenaY = 0
    public real x = 0
    public real y = 0
    private real maxHeroes = 4
    private real maxEnemies = 4
    private real enemyIndex = 0
    private real heroIndex = 0
    private integer nextUnit = 0
    private unit orderingUnit = null
    private unit actionSelector
 
   
    //---------- SETTERS ----------//
   
    public method setEnemies takes group g returns nothing
        set .enemies = g
    endmethod
   
    public method setHeroes takes group g returns nothing
        set .heroes = g
    endmethod
 
    public method setArenaX takes real arenaX returns nothing
        set .arenaX = arenaX
    endmethod
 
    public method setArenaY takes real arenaY returns nothing
        set .arenaY = arenaY
    endmethod
   
    public method setArenaSize takes real x, real y returns nothing
        call .setArenaX(x)
        call .setArenaY(y)
    endmethod
   
    public method setX takes real x returns nothing
        set .x = x
    endmethod
   
    public method setY takes real y returns nothing
        set .y = y
    endmethod
   
    public method setLocation takes location loc returns nothing
        call .setX(GetLocationX(loc))
        call .setY(GetLocationY(loc))
    endmethod
   
    public method setEnemyCapacity takes integer i returns nothing
        set .maxEnemies = i
    endmethod
   
    public method setHeroCapacity takes integer i returns nothing
        set .maxHeroes = i
    endmethod
   
    public method isBattleOver takes nothing returns boolean
        return battleOver
    endmethod
   
    public method hasPlayerWon takes nothing returns boolean
        return playerWon
    endmethod
   
    //---------- HELPER METHODS ----------//
   
    public method unitInBattle takes unit u returns boolean
        return(IsUnitInGroup(u,.heroes) or IsUnitInGroup(u,.enemies))
    endmethod
   
    /**
    *   Moves the selected unit to its appropriate battle spot.
    *   Top area for enemies, bottom area for heroes.
    */
    private method moveUnitToBattle takes unit u, boolean enemy returns nothing
        local real d = 0
        local real theta = 0
        local real x1 = .x
        local real y1 = .y
        call PauseUnit(u,true)
        call SetUnitVertexColor(u,100,100,100,200)
       
        //Move up/down
        set d = arenaY/3
        if(enemy)then
            set theta = 90
        else
            set theta = 270
        endif
        set y1 = Position_polarProjectY(.y,d,theta)
       
        //Move to the far end of the right side
        if(enemy)then
            if(maxEnemies>1)then
                set d = arenaX/4
                set theta = 180
                set x1 = Position_polarProjectX(.x,d,theta)
            endif
        elseif(maxHeroes>1)then
            set d = arenaX/4
            set theta = 180
            set x1 = Position_polarProjectX(.x,d,theta)
        endif
 
        //Move left by intervals, for each unit added.
        set theta = 0
        if(enemy)then
            if(maxEnemies>1)then
                set d = (arenaX/2) * ((enemyIndex)/(maxEnemies))
                set enemyIndex = enemyIndex + 1
                set d = d * 1.3
                set x1 = Position_polarProjectX(x1,d,theta)
            endif
        elseif(maxHeroes>1)then
            set d = (arenaX/2) * ((heroIndex)/(maxHeroes))
            set heroIndex = heroIndex + 1
            set d = d * 1.3
            set x1 = Position_polarProjectX(x1,d,theta)
        endif
 
        //Move unit to final position
        call SetUnitX(u,x1)
        call SetUnitY(u,y1)
        if(enemy)then
            call SetUnitFacing(u,270)
        else
            call SetUnitFacing(u,90)
        endif
    endmethod
   
    /**
    *    Obtains the fastest unit from a group.
    *    Does not edit initial list.
    */
    private method getFastestUnitFromGroup takes group g returns unit
        local group temp = CreateGroup()
        local unit fog = null
        local integer highestSpeed = 0
        local unit fastestUnit = null
        local integer speed = 0
        call GroupAddGroup(g,temp)
        loop
            set fog = FirstOfGroup(temp)
            exitwhen fog == null
            set speed = getUnitSpeed(fog)
            if(speed>highestSpeed)then
                set highestSpeed = speed
                set fastestUnit = fog
            endif
            call GroupRemoveUnit(temp,fog)
        endloop
        call DestroyGroup(temp)
        set fog = null
        set temp = null
        return fastestUnit
    endmethod
   
    /**
    *    Sorts units by speed and adds to order (array)
    *    Group will be destroyed after completion
    */
    private method populateActionList takes group g returns nothing
        local integer i = 1
        local integer count = CountUnitsInGroup(g)
        local unit u = null
        loop
            exitwhen i>count
            set u=getFastestUnitFromGroup(g)
            set order[i]=u
            //call BJDebugMsg("Unit " + I2S(i) + ": " + GetUnitName(u) + " of " + GetPlayerName(GetOwningPlayer(u)))
            call GroupRemoveUnit(g,u)
            set i = i + 1
        endloop
        call DestroyGroup(g)
        set g = null
        set u = null
    endmethod
   
    //--------- PARSING ORDERS ---------//
 
    /**
    *   Gives all items from src to target
    */
    private method exchangeItems takes unit src, unit target returns nothing
        local integer i = 0
        loop
            exitwhen i > 5
            if(GetItemType(UnitItemInSlot(target, i)) != ITEM_TYPE_PERMANENT )then
                call UnitAddItem(target,UnitRemoveItemFromSlot(src,i))
            endif
            set i = i + 1
        endloop
    endmethod
   
    /**
    *    Forces AI to take an action
    *    Uses behavior from AI List scope
    */
    private method aiAction takes nothing returns nothing
        local AI temp
        set temp = AIList_getAIOfUnitType(GetUnitTypeId(orderingUnit))
        if(temp!=0)then
            call temp.run(orderingUnit,this)
        else
            call DisplayTextToForce(GetPlayersAll(),"AI not found: " + GetUnitName(orderingUnit))
            call next()
        endif
    endmethod
   
    /**
    *   Create a command selector for the player.
    */
    private method createMenu takes nothing returns nothing
        local integer i = 0
        local unit selector = CreateUnit(GetOwningPlayer(orderingUnit),SELECTOR,.x,.y,0)
        call exchangeItems(orderingUnit,selector)
        call SelectUnitForPlayerSingle(selector,GetOwningPlayer(orderingUnit))
        call UnitRemoveAbility(selector,'Amov')
        call UnitRemoveAbility(selector,'Astp')
        set .actionSelector = selector
        call Spells_giveAbilities(orderingUnit,selector)
    endmethod
   
    //--------- FLOW - SELECTION OF UNITS, ALLOWING CAST---------//
   
    /**
    *   Checks whether the battle is over, and if so, who won.
    */
    private method battleStatus takes nothing returns nothing
        local unit fog = null
        local boolean playerDead = true
        local boolean aiDead = true
        local group tempHeroes = CreateGroup()
        local group tempEnemies = CreateGroup()
       
        call GroupAddGroup(.heroes,tempHeroes)
        call GroupAddGroup(.enemies,tempEnemies)
       
        //check if player wiped
        loop
            set fog = FirstOfGroup(tempHeroes)
            exitwhen fog==null
            if(IsUnitAliveBJ(fog))then
                set playerDead=false
            endif
            call GroupRemoveUnit(tempHeroes,fog)
        endloop
        //now for AI
        set fog = null
        loop
            set fog = FirstOfGroup(tempEnemies)
            exitwhen fog==null
            if(IsUnitAliveBJ(fog))then
                set aiDead=false
            endif
            call GroupRemoveUnit(tempEnemies,fog)
        endloop
       
        if(aiDead or playerDead)then
            set battleOver = true
            set playerWon = aiDead
        endif
       
        set fog = null
        call DestroyGroup(tempHeroes)
        call DestroyGroup(tempEnemies)
        set tempHeroes = null
        set tempEnemies = null
    endmethod
   
    /**
    *   Stops all units from ordering, until next or resume is called.
    */
    public method pause takes nothing returns nothing
        call exchangeItems(actionSelector,orderingUnit)
        call RemoveUnit(actionSelector)
    endmethod
   
    /**
    *   Allows the same unit to attack again
    *   Might be useful for spells that allow you to move again after
    */
    public method resume takes nothing returns nothing
        call battleStatus()
        if(battleOver==false)then
            call SetUnitVertexColor(orderingUnit,255,255,255,255)
            if(GetOwningPlayer(orderingUnit)==ENEMY)then
                call aiAction()
            else
                call createMenu()
            endif
        endif
    endmethod
   
    /**
    *    Allows the next unit in order to attack
    */
    public method next takes nothing returns nothing
        set Spells_turnUnit = orderingUnit
        call ExecuteFunc("Behavior_onTurnEnd")
        call battleStatus()
        if(battleOver==false)then
            call SetUnitVertexColor(orderingUnit,100,100,100,200)
       
            set orderingUnit = order[nextUnit]
            set nextUnit = nextUnit + 1
            loop
                //filter out dead units
                exitwhen orderingUnit != null and IsUnitAliveBJ(orderingUnit) and General_checkAct(orderingUnit)
                set orderingUnit = order[nextUnit]
                set nextUnit = nextUnit + 1
                if(nextUnit>=12)then
                    set nextUnit=0
                    set turn = turn + 1
                endif
            endloop
            //call BJDebugMsg(I2S(nextUnit))
           
            call battleStatus()
            if(battleOver==false)then
                //call BJDebugMsg("Ordering: " + GetUnitName(orderingUnit) + " of " + GetPlayerName(GetOwningPlayer(orderingUnit)))
                call SetUnitVertexColor(orderingUnit,255,255,255,255)
                if(GetOwningPlayer(orderingUnit)==ENEMY)then
                    call aiAction()
                else
                    call createMenu()
                endif
            endif
               
        endif
    endmethod
   
    //---------- USER METHODS ----------//
   
    /**
    *   Move all units to their respective areas in the battle arena.
    *   Pauses and changes their coloring
    */
    public method start takes nothing returns nothing
        local unit fog = null
        local group allUnits = CreateGroup()
        local group tempHeroes = CreateGroup()
        local group tempEnemies = CreateGroup()
       
        call GroupAddGroup(.enemies,allUnits)
        call GroupAddGroup(.heroes,allUnits)
        call GroupAddGroup(.heroes,tempHeroes)
        call GroupAddGroup(.enemies,tempEnemies)
       
        loop
            set fog = FirstOfGroup(tempEnemies)
            exitwhen fog == null
            call moveUnitToBattle(fog,true)
            call GroupRemoveUnit(tempEnemies,fog)
        endloop
        loop
            set fog = FirstOfGroup(tempHeroes)
            exitwhen fog == null
            call moveUnitToBattle(fog,false)
            call GroupRemoveUnit(tempHeroes,fog)
        endloop
       
        //note: this call destroys and nulls allUnits
        call .populateActionList(allUnits)
        call .next()
       
        set fog = null
        call DestroyGroup(tempHeroes)
        call DestroyGroup(tempEnemies)
        set tempHeroes = null
        set tempEnemies = null
    endmethod
   
    //---------- PROCESSING BATTLE FLOW ----------//
   
    /**
    *   Confirms that the caster is a command selector
    */
    private static method isSelector takes nothing returns boolean
        return(GetUnitTypeId(GetTriggerUnit())==thistype.SELECTOR)
    endmethod
   
    /**
    *   Parses the command that the user gave, and executes it.  
    */
    private static method onCast takes nothing returns nothing
        local Battle whichBattle = 0
        local integer count = 0
        local unit caster = GetTriggerUnit()
        local Action whichAction = 0
        local unit target = GetSpellTargetUnit()
        loop
            exitwhen count > battleCount
            if(caster==battles[count].actionSelector)then
                set whichBattle=battles[count]
            endif
            set count = count + 1
        endloop
        if(whichBattle!=0)then
            set whichAction = Spells_convertAbilityIdToAction(GetSpellAbilityId())
            if(whichAction!=0)then
                call whichAction.run(whichBattle.orderingUnit,target,whichBattle)
            else
                call DisplayTextToForce(GetPlayersAll(),"Unknown action: " + I2S(GetSpellAbilityId()))
            endif
        endif
        set caster = null
        set target = null
        set whichAction = 0
        set whichBattle = 0
    endmethod
   
    /**
    *
    */
    private static method onDeath takes nothing returns nothing
        call purge(GetDyingUnit())
    endmethod
   
    /**
    *   Create basic triggers that all instances use.
    */
    private method makeTriggers takes nothing returns nothing
        local trigger t = CreateTrigger()
        local trigger t2 = CreateTrigger()
        call TriggerAddAction(t,function thistype.onCast)
        call TriggerRegisterAnyUnitEventBJ(t,EVENT_PLAYER_UNIT_SPELL_EFFECT)
        call TriggerAddCondition(t,function thistype.isSelector)
        call TriggerAddAction(t2,function thistype.onDeath)
        call TriggerRegisterAnyUnitEventBJ(t2,EVENT_PLAYER_UNIT_DEATH)
        set t = null
        set t2 = null
    endmethod
   
    //---------- CONSTRUCTOR/DESTRUCTOR ----------//
   
    /**
    *   Required constructor.
    *   Creates triggers if none exist currently
    *   Saves reference to this battle in an array,
    *   and counts how many battles exist.
    */
    public static method create takes nothing returns thistype
        local thistype new = thistype.allocate()
        if(thistype.triggersExist==false)then
            call new.makeTriggers()
            set triggersExist=true
        endif
        set battles[battleCount]=new
        set battleCount=battleCount+1
        return new
    endmethod
   
    /**
    *   Destroys this battle
    *   Note: does NOT destroy the heroes/enemies unit group.
    *   Since the user might want to keep their group intact
    *   after the battle ends.
    */
    public method destroy takes nothing returns nothing
        local unit u = null
        local integer i = 0
        local unit fog = null
 
        loop
            set fog = FirstOfGroup(.enemies)
            exitwhen fog == null
            call RemoveUnit(fog)
            call GroupRemoveUnit(.enemies,fog)
        endloop
       
        call RemoveUnit(actionSelector)
        set actionSelector = null
        set orderingUnit = null
        call DestroyGroup(.enemies)
        set heroes = null
        set enemies = null
        loop
            set u = order[i]
            exitwhen u == null
            set order[i] = null
            set i = i + 1
        endloop
        call this.deallocate()
    endmethod
   
endstruct
