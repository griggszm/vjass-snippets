library Tests initializer onInit

    private function logMsg takes string s returns nothing
        call BJDebugMsg(s)
    endfunction
    
    function sampleAction1 takes nothing returns nothing
        call logMsg("Ran action 1")
    endfunction
    
    function sampleAction2 takes nothing returns nothing
        call logMsg("Ran action 2")
    endfunction
    
    /**
    *   This test will be a full systems test, simulating
    *   an actual battle a user could create. We'll try a 4v1
    *   like a boss battle, multiple heroes, and real user control.
    */
    private function testFullFunctionality takes nothing returns nothing
        local Arena arena = Arena.create(0,0,500)
        local Battle battle
        local unit u1 = CreateUnit(Player(0),'Hpal',0,0,0)
        local unit u2 = CreateUnit(Player(0),'Hpal',0,0,0)
        local unit u3 = CreateUnit(Player(0),'Hpal',0,0,0)
        local unit u5 = CreateUnit(Player(0),'Hpal',0,0,0)
        local unit u4 = CreateUnit(Player(11),'Hpal',0,0,0)
        local group g = CreateGroup()
        local group g2 = CreateGroup()
        
        call SetHeroAgi(u1,1,true)
        call SetHeroAgi(u2,4,true)
        call SetHeroAgi(u3,3,true)
        call SetHeroAgi(u4,2,true)
        call SetHeroAgi(u5,3,true)
        
        call GroupAddUnit(g,u1)
        call GroupAddUnit(g,u2)
        call GroupAddUnit(g,u3)
        call GroupAddUnit(g,u4)
        call GroupAddUnit(g2,u5)
        
        set battle = Battle.create(arena,g,g2)
        call battle.start()
    endfunction
    
    private function testArenaMethodsWorkCorrectly takes nothing returns nothing
        local Arena arena = Arena.create(0,0,500)
        local unit u1 = CreateUnit(Player(0),'Hpal',0,0,0)
        local unit u2 = CreateUnit(Player(0),'Hpal',0,0,0)
        local unit u3 = CreateUnit(Player(11),'Hpal',0,0,0)
        local unit u4 = CreateUnit(Player(11),'Hpal',0,0,0)
        local group g = CreateGroup()
        local group g2 = CreateGroup()
        
        call SetHeroAgi(u1,1,true)
        call SetHeroAgi(u2,4,true)
        call SetHeroAgi(u3,3,true)
        call SetHeroAgi(u4,2,true)
        
        call GroupAddUnit(g,u1)
        call GroupAddUnit(g,u2)
        call GroupAddUnit(g2,u3)
        call GroupAddUnit(g2,u4)
        
        call arena.moveToArenaAllies(g)
        call arena.moveToArenaEnemies(g2)
        call arena.listUnitsByPriority()
        
        call logMsg("Testing getTurnCount. Expected: 1 Returned: " + I2S(arena.getTurnCount()))
        call logMsg("Testing getNextActionUnit. Expected: " + GetUnitName(u2) + " Returned: " + GetUnitName(arena.getNextActionUnit()))
        call logMsg("Testing getNextActionUnit. Expected: " + GetUnitName(u3) + " Returned: " + GetUnitName(arena.getNextActionUnit()))
        call logMsg("Testing getNextActionUnit. Expected: " + GetUnitName(u4) + " Returned: " + GetUnitName(arena.getNextActionUnit()))
        call logMsg("Testing getNextActionUnit. Expected: " + GetUnitName(u1) + " Returned: " + GetUnitName(arena.getNextActionUnit()))
        call logMsg("Testing getNextActionUnit. Expected: " + GetUnitName(u2) + " Returned: " + GetUnitName(arena.getNextActionUnit()))
        call logMsg("Testing getTurnCount. Expected: 2 Returned: " + I2S(arena.getTurnCount()))
        
        if(arena.areAlliesDead())then
            call logMsg("Test failed: areAlliesDead 1. Expects: false, got: true")
        else    
            call logMsg("Test passed: areAlliesDead 1")
        endif
        
        if(arena.areEnemiesDead())then
            call logMsg("Test failed: areEnemiesDead 1. Expects: false, got: true")
        else    
            call logMsg("Test passed: areEnemiesDead 1")
        endif
        
        call KillUnit(u1)
        call KillUnit(u2)
        
        if(arena.areAlliesDead()==false)then
            call logMsg("Test failed: areAlliesDead 2. Expects: true, got: false")
        else    
            call logMsg("Test passed: areAlliesDead 2")
        endif
        
        if(arena.areEnemiesDead())then
            call logMsg("Test failed: areEnemiesDead 2. Expects: false, got: true")
        else    
            call logMsg("Test passed: areEnemiesDead 2")
        endif
        
        call KillUnit(u3)
        call KillUnit(u4)
        
        if(arena.areAlliesDead()==false)then
            call logMsg("Test failed: areAlliesDead 3. Expects: true, got: false")
        else    
            call logMsg("Test passed: areAlliesDead 3")
        endif
        
        if(arena.areEnemiesDead()==false)then
            call logMsg("Test failed: areEnemiesDead 3. Expects: true, got: false")
        else    
            call logMsg("Test passed: areEnemiesDead 3")
        endif

        call RemoveUnit(u1)
        call RemoveUnit(u2)
        call RemoveUnit(u3)
        call RemoveUnit(u4)
        call DestroyGroup(g)
        call DestroyGroup(g2)
        call arena.destroy()
        set g = null
        set g2 = null
        set u1 = null
        set u2 = null
        set u3 = null
        set u4 = null
    endfunction
    
    /**
    *   Basic functionality for Action
    *   - Creating AI
    *   - Running AI
    *   - Getting AI by id
    */
    private function testAIShouldGetCorrectlyAndCallMethods takes nothing returns nothing
        local AI a = AI.create('h000',"sampleAction1")
        local AI b = AI.create('h001',"sampleAction2")
        call logMsg("Testing basic running commands (should see two success messages):")
        call a.execute()
        call b.execute()
        call logMsg("Testing getAIByType. Expected: " + I2S(a) + " Returned: " + I2S(AI.getAIByType('h000')))
        call logMsg("Testing getAIByType. Expected: " + I2S(b) + " Returned: " + I2S(AI.getAIByType('h001')))
        call logMsg("Testing getAIByType. Expected: " + I2S(0) + " Returned: " + I2S(AI.getAIByType('h002')))
        call a.destroy()
        call b.destroy()
    endfunction

    /**
    *   Basic functionality for Action
    *   - Creating actions
    *   - Running actions
    *   - Getting actions by ID
    */
    private function testActionsShouldGetCorrectlyAndCallMethods takes nothing returns nothing
        local Action a = Action.create('A000',"Sample skill 1","No description","sampleAction1")
        local Action b = Action.create('A001',"Sample skill 2","No description","sampleAction2")
        call logMsg("Testing basic running commands (should see two success messages):")
        call a.run(null,null)
        call b.run(null,null)
        call logMsg("Testing getActionById. Expected: " + I2S(a) + " Returned: " + I2S(Action.getActionById('A000')))
        call logMsg("Testing getActionById. Expected: " + I2S(b) + " Returned: " + I2S(Action.getActionById('A001')))
        call logMsg("Testing getActionById. Expected: " + I2S(0) + " Returned: " + I2S(Action.getActionById('A002')))
        call a.destroy()
        call b.destroy()
    endfunction
    
    /**
    *   Tests basic functionality (no edge cases)
    *   - Successfully adds 4 abilities
    *   - Successfully gets the list for a specified unit
    *   - Gets actions correctly
    *   - Removes from middle of list correctly
    *   - Removes from start of list correctly
    *   - Count actions returns right
    */
    private function testActionListMethods takes nothing returns nothing
        local Action a = Action.create('A000',"Sample skill 1","No description","NoAction")
        local Action b = Action.create('A001',"Sample skill 2","No description","NoAction")
        local Action c = Action.create('A002',"Sample skill 3","No description","NoAction")
        local Action d = Action.create('A003',"Sample skill 4","No description","NoAction")
        local unit u = CreateUnit(Player(0),'h000',0,0,0)
        local boolean temp
        local ActionList list = ActionList.create(u)
        
        call logMsg("Testing getUnitAbilityList. Expected: " + I2S(list) + " Returned: " + I2S(ActionList.getUnitAbilityList(u)))
        if(list.addAction(a) and list.addAction(b) and list.addAction(c) and list.addAction(d))then
            call logMsg("Test passed: addAction")
        else  
            call logMsg("Test failed: addAction")
        endif
        call logMsg("Testing getAction(1). Expected: " + I2S(a) + " Returned: " + I2S(list.getAction(1)))
        call logMsg("Testing getAction(2). Expected: " + I2S(b) + " Returned: " + I2S(list.getAction(2)))
        call logMsg("Testing getAction(3). Expected: " + I2S(c) + " Returned: " + I2S(list.getAction(3)))
        call logMsg("Testing getAction(4). Expected: " + I2S(d) + " Returned: " + I2S(list.getAction(4)))
        call logMsg("Testing countAbilities. Expected: " + I2S(4) + " Returned: " + I2S(list.countActions()))
        if(list.removeAction(b))then
            if(list.removeAction(9999))then
                call logMsg("Test failed: removeAction (removed invalid ability)")
            endif
            call logMsg("Test passed: removeAction")
        else
            call logMsg("Test failed: removeAction (did not remove ability")
        endif
        call logMsg("Testing getAction(1). Expected: " + I2S(a) + " Returned: " + I2S(list.getAction(1)))
        call logMsg("Testing getAction(2). Expected: " + I2S(c) + " Returned: " + I2S(list.getAction(2)))
        call logMsg("Testing getAction(3). Expected: " + I2S(d) + " Returned: " + I2S(list.getAction(3)))
        call logMsg("Testing getAction(4). Expected: " + I2S(-1) + " Returned: " + I2S(list.getAction(4)))
        call logMsg("Testing countAbilities. Expected: " + I2S(3) + " Returned: " + I2S(list.countActions()))
        if(list.removeAction(a))then
            call logMsg("Test passed: removeAction")
        else
            call logMsg("Test failed: removeAction (did not remove ability")
        endif
        call logMsg("Testing getAction(1). Expected: " + I2S(c)+ " Returned: " + I2S(list.getAction(1)))
        call logMsg("Testing getAction(2). Expected: " + I2S(d) + " Returned: " + I2S(list.getAction(2)))
        call logMsg("Testing getAction(3). Expected: " + I2S(-1) + " Returned: " + I2S(list.getAction(3)))
        call logMsg("Testing countAbilities. Expected: " + I2S(2) + " Returned: " + I2S(list.countActions()))
        call RemoveUnit(u)
        call a.destroy()
        call b.destroy()
        call c.destroy()
        call d.destroy()
        call list.destroy()
    endfunction

    private function onRunTest takes nothing returns nothing
        local string s = GetEventPlayerChatString()
        set s = SubString(s,7,99999)
        if(s == "ActionListTest")then
            call testActionListMethods()
        elseif(s=="ActionTest")then
            call testActionsShouldGetCorrectlyAndCallMethods()
        elseif(s=="AITest")then
            call testAIShouldGetCorrectlyAndCallMethods()
        elseif(s=="ArenaTest")then
            call testArenaMethodsWorkCorrectly()
        elseif(s=="System")then
            call testFullFunctionality()
        endif
    endfunction

    private function onInit takes nothing returns nothing
        local trigger t = CreateTrigger()
        call TriggerRegisterPlayerChatEvent(t,Player(0),"-test ",false)
        call TriggerAddAction(t,function onRunTest)
        set t = null
    endfunction
    
endlibrary