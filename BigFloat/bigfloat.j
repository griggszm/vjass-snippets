/**
*  Representation of a very large number (greater than MAXINT)
*  This is achieved by putting the numbers into scientific notation, making them
*  easier to represent
*  For a standard real, any values above 2.14b or so will become negative.
*  This is intended to solve this problem and make very large
*  numbers possible to work with.
*  Does not handle negative numbers. Behavior with negatives is undefined
*  @version 1.0
*/
struct BigFloat

      //Stores the number part of the scientific number
      private real number
      //Stores the exponential part - i.e. 10^25
      private integer exponent

      /**
      *  Default no-args constructor for a large number
      */
      public static method create takes real n, integer e returns thistype
          local thistype new = thistype.allocate()
          call new.change(n,e)
          return new
      endmethod


        public method empty takes nothing returns nothing
            set this.number = 0.
            set this.exponent = 0
        endmethod
        
      /**
      *  Gets the number value of this BigFloat
      */
      public method getNum takes nothing returns real
        return this.number
      endmethod

      /**
      *  Gets the exponent of this BigFloat
      */
      public method getExp takes nothing returns integer
        return this.exponent
      endmethod

      /**
      *  Detects whether this big number is empty or not
      *  Defined as empty if it is 0 * 10^0
      */
      public method isEmpty takes nothing returns boolean
        return (this.getNum() <= 1 and this.getExp()==0)
      endmethod

      /**
      *  Takes as much of this BigFloat as possible and return it as a real
      *  This will be either 2147483646 or all remaining
      */
      public method take takes nothing returns real
          local real toRemove = 2147483646
          if(isEmpty()==false)then
            if((this.exponent < 9) or (this.exponent==9 and this.getNum <= 2.147483646))then
                  set toRemove = this.number * Pow(10,this.exponent)
                  set this.exponent = 0
                  set this.number = 0
              return toRemove
            endif
              set toRemove = toRemove / Pow(10,this.exponent)
              set this.number = this.number - toRemove
              if(this.number <= 0)then
                  set this.number = 10 - this.number
                  set this.exponent = this.exponent-1
            endif
          endif
          return I2R(R2I(toRemove))
      endmethod

      private method change takes real n, integer e returns nothing
          set this.number = n
          set this.exponent = e
          call this.compress()
      endmethod

      private method compress takes nothing returns nothing
          loop
              exitwhen this.getNum() < 10.
              set this.number = this.number / 10
              set this.exponent = this.exponent + 1
          endloop

        if(this.getNum() <= 0) then
          set this.number = 0
          set this.exponent = 0
          elseif(this.getNum() < 1) then
          loop
              exitwhen this.getNum() >= 1.
              set this.number = this.number * 10
              set this.exponent = this.exponent - 1
          endloop
          endif
      endmethod

      /**
      *  Returns the scientific notation
      *  of the big number.
      */
      public method toString takes nothing returns string
        return R2S(number) + " * 10^" + I2S(exponent)
      endmethod

      /**
      *  Destroys this big number.
      */
      public method destroy takes nothing returns nothing
        call this.deallocate()
      endmethod

      /**
      *  Creates a new BigFloat from the specified real num
      *  Num must be less than MAXINT.
      */
      public static method convert takes real num returns thistype
          local real numFinal = num
          local integer expFinal = 0
          return thistype.create(numFinal,expFinal)
      endmethod

      /**
      *  Changes the specified scientific notation string
      *  into a BigFloat
      *  Strings MUST be in the format:
      *  5 * 10^15 for example
      */
      public static method fromScientific takes string num returns thistype
          local real numberSection = 0.
          local integer exponentSection = 0
          local integer pointer = 0
          local integer breakCheck = 0
          local string temp = ""

          loop
              exitwhen ((breakCheck > 200) or (SubString(num,pointer-1,pointer)==" "))
              set temp = SubString(num,0,pointer)
              set pointer = pointer + 1
              set breakCheck = breakCheck + 1
          endloop

          set numberSection = S2R(temp)

          loop
              exitwhen ((breakCheck > 200) or (SubString(num,pointer-1,pointer)=="^"))
              set pointer = pointer + 1
              set breakCheck = breakCheck + 1
          endloop

          set temp = SubString(num,pointer,200)
          set exponentSection = S2I(temp)

          return thistype.create(numberSection,exponentSection)
      endmethod

      /**
      *  Multiplies this with another big number
      *  If destroy is set to true, the second BigFloat will be destroyed after the t
      */
      public method multiply takes BigFloat by, boolean destroy returns nothing
          local real numFinal = by.getNum() * this.getNum()
          local integer expFinal = by.getExp() + this.getExp()

          if(destroy)then
            call by.destroy()
          endif
          call this.change(numFinal,expFinal)
      endmethod

      /**
      *  Divides this with another big number
      *  If destroy is set to true, the second BigFloat will be destroyed after the t
      */
      public method divide takes BigFloat by, boolean destroy returns nothing
          local real numFinal = this.getNum() / by.getNum()
          local integer expFinal = this.getExp() - by.getExp()
          if(destroy)then
            call by.destroy()
          endif
          call this.change(numFinal,expFinal)
      endmethod

      /**
      *  Adds another big number
      *  If destroy is set to true, the second BigFloat will be destroyed after the t
      */
      public method add takes BigFloat by, boolean destroy returns nothing
          local real numFinal = 0.
          local integer expFinal = 0
          local integer diff = this.getExp() - by.getExp()
          if(diff==0)then
              set numFinal = this.getNum() + by.getNum()
              set expFinal = this.getExp()
          elseif(diff>0)then
              set numFinal = this.getNum() + (by.getNum() / (Pow(10,diff)))
              set expFinal = this.getExp()
          else
              set diff = -diff
              set numFinal = by.getNum() + (this.getNum() / (Pow(10,diff)))
              set expFinal = by.getExp()
          endif

          if(destroy)then
            call by.destroy()
          endif
          call this.change(numFinal,expFinal)
      endmethod

      /**
      *  Subtracts another big number
      *  If destroy is set to true, the second BigFloat will be destroyed after the t
      */
      public method subtract takes BigFloat by, boolean destroy returns nothing
          local real numFinal = 0.
          local integer expFinal = 0
          local integer diff = this.getExp() - by.getExp()
          if(diff==0)then
              set numFinal = this.getNum() - by.getNum()
              set expFinal = this.getExp()
          elseif(diff>0)then
              set numFinal = this.getNum() - (by.getNum() / (Pow(10,diff)))
              set expFinal = this.getExp()
          else
            call change(0,0)
        endif

        if(destroy)then
            call by.destroy()
        endif
        call this.change(numFinal,expFinal)
    endmethod

      public method percentOf takes BigFloat small, boolean destroy returns real
          local real percent = 0.
          call small.divide(this,false)
          set percent = small.take() * 100
          if(destroy)then
            call small.destroy()
          endif
          return percent
      endmethod

        public method displayAt takes real x, real y returns nothing
            local texttag txt = CreateTextTag()
            call SetTextTagText(txt,toString(),TextTagSize2Height(10))
            call SetTextTagPos(txt,x,y,0)
            call SetTextTagPermanent(txt,false)
            call SetTextTagVelocity(txt,0,TextTagSpeed2Velocity(40))
            call SetTextTagLifespan(txt,1.5)
            set txt = null
        endmethod
        
        
      /**
      *  Copies the old BigFloat to a new one
      */
      public static method copy takes thistype old returns thistype
        return thistype.create(old.getNum(),old.getExp())
      endmethod
endstruct
