/**
*   The battle class is responsible for creating and
*   running the actual battle. A battle can be thought
*   of as a series of turns where a single unit is
*   allowed to act, finishing when either the allies or
*   enemies have all died. The battle is self-running:
*   you only need create it and call start(), then it
*   will keep executing. You also need to handle when the
*   battle ends: to do so, call the getFinished() method
*   to check, and then getAlliedVictory() to see who won.
*/
struct Battle

    private static constant player AI_PLAYER = Player(11)
    
    private Arena arena
    private unit actingUnit
    
    /**
    *   Creates a battle with the given arena
    *   Arena should be instantiated and left alone
    *   Do not add the allies/enemies to it.
    *   This will be handled in the battle class
    */
    public static method create takes Arena arena, group allies, group enemies returns thistype
        local thistype new = thistype.allocate()
        set new.arena = arena
        call arena.moveToArenaAllies(allies)
        call arena.moveToArenaEnemies(enemies)
        call arena.listUnitsByPriority()
        return new
    endmethod
    
    /**
    *   Creates a floating text action menu for the unit
    */
    private method makeActionMenu takes unit u returns nothing
    
    endmethod
    
    /**
    *   Runs the selected units AI
    */
    private method runAI takes unit u returns nothing
    
    endmethod
    
    /**
    *   Allows the next unit to take a turn
    */
    private method nextTurn takes nothing returns nothing
        set actingUnit = arena.getNextActionUnit()
        if(GetOwningPlayer(actingUnit)!=AI_PLAYER)then
            call makeActionMenu(actingUnit)
        else
            call runAI(actingUnit)
        endif
    endmethod
    
    /**
    *   Starts the battle, allowing the first unit to act
    */
    public method start takes nothing returns nothing
        call nextTurn()
    endmethod
    
endstruct
