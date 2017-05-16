/**
*   Represents an arena that holds both allies and enemies.
*   An arena can be thought of as a place to store and align
*   units. As such, this holds all methods needed to
*   modify and retrieve those units
*   Implemented methods:
*
*   public static method create takes real x, real y, real size returns thistype
*   public method moveToArenaAllies takes group units returns nothing
*   public method moveToArenaEnemies takes group units returns nothing
*   public method listUnitsByPriority takes nothing returns nothing
*   public method getNextActionUnit takes nothing returns unit 
*   public method areAlliesDead takes nothing returns boolean
*   public method areEnemiesDead takes nothing returns boolean
*   public method isBattleOver takes nothing returns boolean
*/
struct Arena

    /**
    *   Can modify
    */
    
    /**
    *   Gets the priority of a unit 
    *   Default implementation is agi
    *   You can replace this with any speed stat you want
    */
    private static method getUnitPriority takes unit u returns integer
        return GetHeroAgi(u,true)
    endmethod
    
    
    /**
    *   Do not modify
    */
    
    private real x
    private real y
    private real size
    
    private real centerXAllies
    private real centerYAllies
    
    private real centerXEnemies
    private real centerYEnemies
    
    private group alliesGroup
    private group enemiesGroup
    
    private integer turnCount = 1
    
    //1 indexed array of units sorted by priority
    private unit array arenaUnitsSorted[30]
    private integer currentUnit = 1
    private integer maxIndex = 0
    
    /**
    *   Required constructor.
    *   Takes the x and y at the center of arena.
    */
    public static method create takes real x, real y, real size returns thistype
        local thistype new = thistype.allocate()
        set new.x = x
        set new.y = y
        set new.size = size
        call new.calculateCoordinates()
        return new
    endmethod
    
    /**
    *   Calculates the x/y coordinates to eventually
    *   move units to.
    */
    private method calculateCoordinates takes nothing returns nothing
        //Project ally locs down
        set centerXAllies = PolarProjectX(x,size/3,270)
        set centerYAllies = PolarProjectY(y,size/3,270)
        //Project enemies up
        set centerXEnemies = PolarProjectX(x,size/3,90)
        set centerYEnemies = PolarProjectY(y,size/3,90)
    endmethod
    
    private method moveUnitToArena takes unit u, real delta, real deltaInitial, integer unitNum, boolean ally returns nothing
        local real x0
        local real y0
        if(ally)then
            set x0 = centerXAllies
            set y0 = centerYAllies
        else
            set x0 = centerXEnemies
            set y0 = centerYEnemies
        endif
        //Project the unit to the left (180)
        //by the amount specified by initial delta
        set x0 = PolarProjectX(x0,deltaInitial,180)
        set y0 = PolarProjectY(y0,deltaInitial,180)
        
        //Project the unit to the right (0) to match
        //his unitNum
        set x0 = PolarProjectX(x0,delta*unitNum,0)
        set y0 = PolarProjectY(y0,delta*unitNum,0)
        
        call SetUnitPosition(u,x0,y0)
    endmethod
    
    /**
    *   Internal helper to move units to the arena
    *   Takes a group containing units to move and
    *   whether they are allies or not.
    */
    private method moveToArenaInternal takes group units, boolean allies returns nothing
        local group g = CreateGroup()
        local unit fog = null
        local integer countUnits = CountUnitsInGroup(units)
        local real delta
        local real deltaInitial
        local integer unitNum = 0
        
        if(countUnits == 1)then
            set deltaInitial = 0.
        elseif(countUnits == 2)then
            set deltaInitial = size * 0.25
        elseif(countUnits == 3)then
            set deltaInitial = size * 0.35
        else
            set deltaInitial = size * 0.40
        endif
        
        set delta = size * countUnits * 0.25
        
        call DebugMsg("Adjusting units with count " + I2S(countUnits) + ", delta " + R2S(delta) + ", and delta initial " + R2S(deltaInitial))
        
        //Copy group since we're going to destroy it
        call GroupAddGroup(units,g)
        loop
            set fog = FirstOfGroup(g)
            exitwhen fog == null
            call moveUnitToArena(fog,delta,deltaInitial,unitNum,allies)
            set unitNum = unitNum + 1
            call GroupRemoveUnit(g,fog)
        endloop
        call DestroyGroup(g)
        set g = null
    endmethod
    
    /**
    *   Moves allied units to the arena.
    *   By convention, allies are located at the
    *   south end of the arena.
    */
    public method moveToArenaAllies takes group units returns nothing
        call GroupAddGroup(units,alliesGroup)
        call moveToArenaInternal(units,true)
        call DebugMsg("Allies added")
    endmethod
    
    /**
    *   Moves enemy units to the arena.
    *   By convention, enemies are located at the
    *   north end of the arena.
    */
    public method moveToArenaEnemies takes group units returns nothing
        call GroupAddGroup(units,enemiesGroup)
        call moveToArenaInternal(units,false)
        call DebugMsg("Enemies added")
    endmethod
    
    /**
    *   Getter for allies
    */
    public method getAllies takes nothing returns group
        return alliesGroup
    endmethod
    
    /**
    *   Getter for enemies
    */
    public method getEnemies takes nothing returns group
        return alliesGroup
    endmethod
    
    /**
    *   Internal method to get the single 
    *   fastest unit from a group
    */
    private method getTopPriorityFromList takes group units returns unit 
        local group g = CreateGroup()
        local unit fog = null
        local integer topPriority = -1
        local integer currentPriority = 0
        local unit topUnit = null
        call GroupAddGroup(units,g)
        loop
            set fog = FirstOfGroup(g)
            exitwhen fog == null
            set currentPriority = getUnitPriority(fog)
            if(currentPriority > topPriority)then
                set topPriority = currentPriority
                set topUnit = fog
            endif
            call GroupRemoveUnit(g,fog)
        endloop
        call DestroyGroup(g)
        set fog = null
        set g = null
        return topUnit
    endmethod
    
    /**
    *   Lists units by priority
    */
    public method listUnitsByPriority takes nothing returns nothing
        local group g = CreateGroup()
        local unit top = null
        local integer count = 1
        call GroupAddGroup(enemiesGroup,g)
        call GroupAddGroup(alliesGroup,g)
        loop
            exitwhen(CountUnitsInGroup(g) > 0)
            set top = getTopPriorityFromList(g)
            call GroupRemoveUnit(g,top)
            set arenaUnitsSorted[count] = top
            call DebugMsg("Priority #" + I2S(count) + ": " + GetUnitName(top))
            set count = count + 1
            set maxIndex = maxIndex + 1
        endloop
        call DestroyGroup(g)
        set g = null
        set top = null
    endmethod
    
    /**
    *   Gets the next unit to act in this arena
    */
    public method getNextActionUnit takes nothing returns unit 
        local unit returnUnit = arenaUnitsSorted[currentUnit]
        call DebugMsg("Current unit: " + GetUnitName(returnUnit) + " at index " + I2S(currentUnit))
        set currentUnit = currentUnit + 1
        if(currentUnit > maxIndex)then
            set currentUnit = 1
            set turnCount = turnCount + 1
        endif
        return returnUnit
    endmethod
    
    /**
    *   Gets how many turns have elapsed, starting at 1
    */
    public method getTurnCount takes nothing returns integer
        return turnCount
    endmethod
    
    /**
    *   Helper method to see whether all units in group are dead
    */  
    private method areUnitsDead takes group g2 returns boolean
        local boolean dead = true
        local unit fog = null
        local group g = CreateGroup() //copy allies group
        call GroupAddGroup(g2,g)
        loop
            set fog = FirstOfGroup(g)
            exitwhen fog == null
            if(IsUnitAliveBJ(fog))then
                set dead = false
            endif
            call GroupRemoveUnit(g,fog)
        endloop
        return dead
    endmethod
    
    /**
    *   Checks to see whether all allies have died in battle
    */
    public method areAlliesDead takes nothing returns boolean
        return(areUnitsDead(alliesGroup))
    endmethod
    
    /**
    *   Checks to see whether all enemies have died in battle
    */
    public method areEnemiesDead takes nothing returns boolean
        return(areUnitsDead(enemiesGroup))
    endmethod
    
    public method isBattleOver takes nothing returns boolean
        return areAlliesDead() or areEnemiesDead()
    endmethod
endstruct