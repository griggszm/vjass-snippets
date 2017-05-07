What this system does:
    - Moves units to an arena, allows them to take turns attacking
    - Provides a simple way to create custom skills to use in battle
    - Provides a simple way to make AI for enemy units

What you must do to use it:
    - Make your own abilities
    - Make your own AI methods
    - Link your abilities to your heroes
    - Start the battle
    - When battle ends perform an action with the result

For more details on any part, look at the appropriate readme files.


This is not as simple as just creating an ability in the object
editor and adding it onto your hero. Every unit is paused, and
remains paused for the entire battle, while a dummy unit lets
you select your abilities. So, we do not want any default skills
here. Instead, create an ability based on "Channel", name it how
you want, and remember the rawcode. For this example, we will use
rawcode 'A000' and name "Attack" - this will teach you how to make
a basic attack function.

First, lets register this new skill with the system, to tell it 
this is indeed a custom skill. To do this, find the library "Spells"
Find the onInit function. Here is where we register the spell.
Type the following line:

    call createSpell("Attack","Behavior_attack",'A000',0)

This line creates a new ability:
    - The name is "Attack"
    - The behavior is "Behavior_attack"
    - The rawcode is 'A000'
    - The mana cost is 0
    
These are all self explanatory, besides the behavior part. The
behavior of a spell is the actual functionality it gets, the code
that runs when someone casts the spell. Since attack is registered,
lets go make the behavior. Find the "Behaviors" library in the
system, and scroll to the comment //-- User made behaviors --//

First, we name our behavior the same as we specified before:

    public function attack takes nothing returns nothing
    endfunction

Now, when a unit attacks, this function will run. But it takes
nothing, so how do we know who the attacker is? Well, we have
an Action reference that saves those. So, inside the body, type
the following:

    local Action act = Spells_spellCast
    local unit src = act.getSource()
    local unit target = act.getTarget()
    local Battle whichBattle = act.getBattle()

Spells_spellCast saves the last used Action. We can then use this
action to get the source, target, and battle that its in, as seen
above. The next thing: the action selector can still give orders
right now, but we do not want that.. or else the user could just
order a bunch of times, and attack more than once. So, call
the following:

    call whichBattle.pause()

Now we need to code the actual attack. This is different
for each map, and its up to you how you want to code it. In general
though, the attack would play the attack animation and deal some
damage. After this though, we are not done! If we leave the
function off after dealing damage, the battle will never continue
because we paused it! Instead, we call the following:

    call whichBattle.next()

If you want the same unit to be able to take another action, you
could call the following:

    call whichBattle.resume()
    
Note: item abilities work exactly the same as normal abilities.
So give your heroes any items you want, just code the skills!

Note: If the Behaviors library gets cluttered, extract each spell
code to a new library, and have Behaviors call it!
    
//--------------------------------------------------------------//

Short version/recap:

1) In Spells library, add the following to onInit:
    call createSpell("myName","Behavior_myFunction",'RAW',manaCost)
2) In Behavior library, add the following function:
    public function myFunction takes nothing returns nothing
        local Action act = Spells_spellCast
        local unit src = act.getSource()
        local unit target = act.getTarget()
        local Battle whichBattle = act.getBattle()
        call whichBattle.pause()
        //Code for this ability goes here!
        call whichBattle.next()
    endfunction


Coding AI is much harder than coding abilities, but as far as the
system goes, its registered much the same. Find the "AI List" library
and go to the onInit function, and register the AI. For this example,
I will use a footman for the unit I want to make AI for:

    call createAI('hfoo',"Behavior_Footman_AI")
    
Now we registered 'hfoo' (footman) to Behavior_Footman_AI. Now
we need to go code it in the behaviors section. Find "Behaviors"
and go to the comment //-- User AIs --//
Add the following code:

    public function Footman_AI takes nothing returns nothing
    endfunction
    
Now, whenever its a footmans turn in battle, this function will
immediately be called. In the same way as spells, we have a
reference to the AI that we can grab to find out which battle hes
in, and who the unit is to begin with:

    local AI ai = AIList_whichAI
    local unit aiUnit = ai.getAIUnit()
    local Battle battle = ai.getBattle()
    local unit target = null
    local Action whichAction = 0
        
ai is the reference to the AI object corresponding to this unit.
aiUnit is the ai unit whose turn it is
battle is the battle the ai is in.
target and whichAction are not set. We will use those later.

Now its time to actually code the AI. Youll need to add whatever
logic you want in (maybe an hp check, for example), and then force
the unit to take an appropriate action. We will do this by using
the whichAction object. Set it like this:

    set whichAction = Spells_convertAbilityNameToAction("Attack")

This will return the action with the name specified. In this
example, I get the Attack action - this obviously has to be created
and registered previous to using. Now, we need our target. You may
want to include some logic here to find a target too, but for this
we will just select a random hero:

    loop
        exitwhen target != null and IsUnitAliveBJ(target)
        set target = GroupPickRandomUnit(battle.heroes)
    endloop

This part will make sure that we select a living unit. We dont
want to try to attack a dead unit, so we loop until we find
a living one. Now all thats left to do is run the action!

    call whichAction.run(aiUnit,target,battle)

And thats it. We dont need to advance the battle here, since the
action does it for us.

//------------------------------------------------------------//

Short version/recap:

1) In AI List library, register the new AI type
    - call createAI('UNITTYPE',"Behavior_My_AI")
2) In Behavior, code the AI function like this
        public function My_AI takes nothing returns nothing
            local AI ai = AIList_whichAI
            local unit aiUnit = ai.getAIUnit()
            local Battle battle = ai.getBattle()
            local unit target = null
            local Action whichAction = 0
            //Your AI logic here
            set whichAction = Spells_convertAbilityNameToAction("Action to take")
            call whichAction.run(aiUnit,target,battle)
        endfunction

This is by far the easiest part. We need two unit groups, one for
heroes, one for enemies. We need a point (center of battle) to
create it at, and we need to know the size of the arena to use.

So first, we create a new battle:

    local Battle b = Battle.create()

Now we set where the battle will take place:

    call b.setX(myX)
    call b.setY(myY)
    
Here, we pass in the groups of heroes and enemies. Note that these
groups will not be destroyed by the system, so you must destroy them
(or reuse them, if thats what makes sense for your map)

    call b.setEnemies(udg_TempGroup1)
    call b.setHeroes(udg_TempGroup2)
    
Now the size. If you have trouble finding this, create a region
over the arena and measure ((x2 - x1), (y2 - y1)). For here, Ill
assume an area of 1000 x 1000

    call b.setArenaSize(1000,1000)

All thats left is starting the battle.

    call b.start()

//---------------------------------------------------------------//

Short version/recap:

    local Battle b = Battle.create()
    call b.setX(myX)
    call b.setY(myY)
    call b.setEnemies(udg_TempGroup1)
    call b.setHeroes(udg_TempGroup2)
    call b.setArenaSize(1000,1000)
    call b.start()

Since ability use it entirely triggered with a dummy, you need to 
save which heroes can use which abilities. Simply adding them to
the hero will do nothing in battle. There is a structure to do this:
the SkillsList. AI does not need a skills list, but the heroes in
the battle need one - there should be only one SkillList for the
whole heroes group.

First, initiate a skills list.

            local SkillsList skills = SkillsList.create()
            
Now, for the FIRST hero in the group of heroes, add your skills.

            call skills.add('A000')
            call skills.add('A001')
            
Now if there is another hero, tell the system that youre entering
a new one by using the next function.

            call skills.next()

Now add abilities for the second hero.

            call skills.add('A002')
            call skills.add('A003')
            
Finally, when all heroes have been added, call next one more time.

            call skills.next()
            
All thats left to do is pass this to the battle youve created.

            call b.setSkills(skills)
            
And youre done! In addition, there are several convience functions
in the SkillsList structure. These can:
1) Add a skill to a previously added hero
2) Remove a skill (by id)
3) Remove a skill (by location) (make sure to select the correct one)

            call skills.insert(heroNum,abilityId)
            call skills.remove(abilityId)
            call skills.removeAt(index) 
            //BEWARE: each "next" creates an entry too. You can
            //remove the "nexts", but should be done with caution
            
//--------------------------------------------------------------//

Short version/recap:

    local SkillsList skills = SkillsList.create()
    call skills.add('A000')
    call skills.add('A001')
    call skills.next()
    call skills.add('A002')
    call skills.add('A003')
    call skills.next()
    call b.setSkills(skills)

Since every map is different, we need code to do something when
the battle ends. This might be giving gold/exp to the player, or
game-overing the player depending on the result. So first, detecting
when its over. We have several functions to help with this.
Assuming we have Battle b running:

    b.isBattleOver() //determines whether it is over at all
    b.hasPlayerWon() //determines if player won
    //so if battle is over, and player hasn't won, then AI won
    
There are many different ways of detecting this; you can decide on
your own, or use my way:

    loop
        exitwhen b.isBattleOver()
        call PolledWait(1.0)
    endloop
    
Simple enough. Some might object to it because it has a wait, but
this code is for your map, not the system, so its completely your
choice. Now, determine the result.

    if(b.hasPlayerWon())then
        //give gold/xp
    else
        //game over
    endif
    
Move all units back to their original locations. How you want to
do this depends entirely on your map. The last action to do is
to destroy the battle to free up memory.

    call b.destroy()
    
//--------------------------------------------------------------//

Short version/recap:

    loop
        exitwhen b.isBattleOver()
        call PolledWait(1.0)
    endloop
    if(b.hasPlayerWon())then
        //give gold/xp
    else
        //game over
    endif
    //move heroes to original locations
    call b.destroy()
