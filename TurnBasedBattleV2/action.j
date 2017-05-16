/**
*   List of actions that units can perform in battle
*   Need to be added to units with the UnitAddAction command
*/
library ActionFunctions initializer onInit
    
    /**
    *   Represents a singe action that can
    *   can be executed and shown
    */
    struct Action

        private static hashtable table
        
        private integer id
        private string name
        private string desc
        private string exec
        
        /**
        *   Creates a new action that can be
        *   displayed (name/desc) and ran (exec)
        */
        public static method create takes integer id,string name, string desc, string exec returns thistype
            local thistype new = thistype.allocate()
            set new.id = id
            set new.name = name
            set new.desc = desc
            set new.exec = exec
            call SaveInteger(table,id,0,new)
            return new
        endmethod
        
        /**
        *   Runs this selected action, setting
        *   the target and source as expected.
        */
        public method run takes unit src, unit target returns nothing
            set srcContext = src
            set targetContext = target
            call ExecuteFunc(exec)
        endmethod
        
        public static method getActionById takes integer id returns thistype
            return LoadInteger(table,id,0)
        endmethod
        
        private static method createActions takes nothing returns nothing
            call Action.create('Aatk',"Attack","Attacks the target unit","AttackFunction")
            call Action.create('Adef',"Defend","Increases def for one turn","DefendFunction")
        endmethod
        
        private static method onInit takes nothing returns nothing
            set table = InitHashtableBJ()
            call createActions()
        endmethod
    endstruct
    
    /**
    *   Represents a list of actions that
    *   a unit can have (up to 9)
    */
    struct ActionList
    
        private static hashtable table
        private Action array acts[10]
        private integer index = 1
        private unit owner
        
        /**
        *   Creates an action list for a unit
        */
        public static method create takes unit owner returns thistype
            local thistype new = thistype.allocate()
            set new.owner = owner
            call SaveInteger(table,GetUnitUserData(owner),0,new)
            return new
        endmethod
        
        /**
        *   Gets ability list for a unit
        */
        public static method getUnitAbilityList takes unit u returns thistype
            return LoadInteger(table,GetUnitUserData(u),0)
        endmethod
        
        /**
        *   Adds an action to this ability list
        *   Returns true if successful, false if not
        */
        public method addAction takes Action act returns boolean
            if(index<=9)then
                set acts[index] = act
                set index = index + 1
                return true
            endif
            return false
        endmethod
        
        /**
        *   Removes a single action from this list
        *   Returns true if successful, false if not
        */
        public method removeAction takes Action act returns boolean
            local integer i = 1
            local integer remover = -1
            loop
                if(acts[i]==act)then
                    //found one to delete
                    set remover = i
                    loop
                        set acts[remover] = acts[remover]+1
                        set remover = remover + 1
                        exitwhen remover > 8
                    endloop
                    return true
                endif
                set i = i + 1
                exitwhen i > 9
            endloop
            return false
        endmethod
        
        /**
        *   Gets action at the selected index
        */
        public method getAction takes integer i returns Action
            if(i<=9 and i > 0)then
                return acts[i]
            else
                return -1
            endif
        endmethod
        
        /**
        *   Counts how many abilities this unit has
        */
        public method countActions takes nothing returns integer
            local integer i = 1
            local integer count = 0
            loop
                if(acts[i]>0)then
                    set count = count + 1
                endif
                set i = i + 1
                exitwhen i > 9
            endloop
            return count
        endmethod
        
        /**
        *   Deletes an action list. Use after unit
        *   permanently dies.
        */
        public method destroy takes nothing returns nothing
            call SaveInteger(table,GetUnitUserData(owner),0,0-1)
            set owner = null
        endmethod
        
        /**
        *   Initializes hashtable
        */
        private static method onInit takes nothing returns nothing
            set table = InitHashtableBJ()
        endmethod
    endstruct
    
endlibrary
