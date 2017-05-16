library AIList

    /**
    *   Represents an AI that can run an AI function
    */
    struct AI
        
        private static hashtable table
        
        private integer unitType
        private string aiCode
        
        /**
        *   Creates a new AI type, taking 
        *   unit type and an ai function
        */ 
        public static method create takes integer unitType, string aiCode returns thistype
            local thistype new = thistype.allocate()
            set new.unitType = unitType
            set new.aiCode = aiCode
            call SaveInteger(table,unitType,0,new)
            return new
        endmethod
        
        /**
        *   Runs this AI function
        */
        public method execute takes nothing returns nothing
            call ExecuteFunc(aiCode)
        endmethod
        
        /**
        *   Gets a specific unit AI by unit type
        */
        public static method getAIByType takes integer unitType returns thistype
            return LoadInteger(table,unitType,0)
        endmethod
        
        /**
        *   Creates all AIs to be used
        */
        private static method createAIs takes nothing returns nothing
        
        endmethod
        
        /**
        *   Makes the table and creates AIs  
        */
        private static method onInit takes nothing returns nothing
            set table = InitHashtableBJ()
            call createAIs()
        endmethod
        
    endstruct
    
    
endlibrary