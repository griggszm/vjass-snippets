library General requires Behavior
    public function checkAct takes unit u returns boolean
        local boolean returnVal = true
        set Spells_turnUnit = u
        call ExecuteFunc("Behavior_onTurnStart")
        if(IsUnitAliveBJ(u)==false)then
            set returnVal = false
        endif
        return returnVal
    endfunction
endlibrary
