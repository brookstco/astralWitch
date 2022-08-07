local path = "astralWitch/"

local astral = Survivor.new("Astral Witch")

-- Load all of our sprites into a table
local sprites = {
    idle = Sprite.load("idle", path .. "Idle", 1, 3, 6),
    walk = Sprite.load("walk", path .. "Walk", 8, 7, 7),
    jump = Sprite.load("jump", path .. "Jump", 1, 4, 6),
    climb = Sprite.load("climb", path .. "Climb", 2, 4, 6),
    death = Sprite.load("death", path .. "Death", 6, 16, 5),
    -- This sprite is used by the Crudely Drawn Buddy
    -- If the player doesn't have one, the Commando's sprite will be used instead
    decoy = Sprite.load("decoy", path .. "Decoy", 1, 9, 18)
}
-- Attack sprites are loaded separately as we'll be using them in our code
local sprShoot1 = Sprite.load("Shoot1", path .. "Shoot1", 6, 3, 6)
local sprShoot2 = Sprite.load("Shoot2", path .. "Shoot2", 6, 3, 8)
local sprShoot3 = Sprite.load("Shoot3", path .. "Shoot3", 14, 6, 9)
local sprShoot4 = Sprite.load("Shoot4", path .. "Shoot4", 5, 3, 7)
-- The sprite used by the skill icons
local sprSkills = Sprite.load("skills", path .. "Skills", 6, 0, 0)

-- Particle Sprites
local sprLightSparks = Sprite.load("lightSparks", path.."lightSparks", 3, 13, 8)
local sprDarkSparks = Sprite.load("darkSparks", path.."darkSparks", 3, 13, 8)
local sprDoubleSparks = Sprite.load("doubleSparks", path.."doubleSparks", 3, 13, 8)
local sprDissonanceExplosion = Sprite.load("dissonanceExplosion", path .. "dissonanceExplosion", 5, 10, 9)
local sprDivergenceExplosion = Sprite.load("divergenceExplosion", path .. "DivergenceExplosion", 7, 40, 30)

-- SFX
local sndSkill1 = Sound.find("ImpGShoot1", "vanilla")
local sndSkill2 = Sound.find("Bullet2", "vanilla")
local sndSkill3 = Sound.find("Smite", "vanilla")
local sndSkillDash = Sound.find("WispShoot1", "vanilla")
local sndSkill4 = Sound.find("Smite", "vanilla")

-- Set the description of the character and the sprite used for skill icons
astral:setLoadoutInfo([[The &y&Astral Witch&!& manipulates the power of stars and space.
Snipe targets from afar or close in to deal with groups.
&y&Divergence&!& can deal massive damage to a large swathe of enemies, 
but will &r&cripple&!& your damage afterwards.
Control mobility with &y&Dissonance&!&, after a moment of vulnerability.]], sprSkills)

-- Set the character select skill descriptions
astral:setLoadoutSkill(1, "Stellar Light", [[Shoot a beam of light for &y&120% damage&!&.]])

astral:setLoadoutSkill(2, "Dark Matter Blast", [[Blast &y&all enemies&!& in front of you for &y&3x80% damage.&!&]])

astral:setLoadoutSkill(3, "Dissonance", [[&y&Explode&!& around you for &y&180%&!&.
Launches you in a &y&controlled direction&!& while &b&invulnerable&!&.]])

astral:setLoadoutSkill(4, "Divergence", [[Light and Dark explode for &y&800% damage&!& in a large area.
Briefly &r&cripple&!& &y&Stellar Light&!& and &y&Dark Matter Blast&!&.]])

-- The color of the character's skill names in the character select
astral.loadoutColor = Color(0xDDF6FF)

-- The character's sprite in the selection pod
astral.loadoutSprite = Sprite.load("astralSelect", path .. "select", 4, 2, 0)
-- Multiplayer selection box
astral.idleSprite = Sprite.load("icon", path .. "Idle", 1, 3, 6)

-- The character's walk animation on the title screen when selected
astral.titleSprite = sprites.walk

-- Quote displayed when the game is beat as the character
astral.endingQuote = "..and so she left, dissatisfied with her discoveries."
-- "..and so she left, displeased with her discoveries."
--"..and so she left, satisfied with her research."

-- Called when the player is created
astral:addCallback("init", function(player)
    local playerAc = player:getAccessor()
    local playerData = player:getData()
    -- Set the player's sprites to those we previously loaded
    player:setAnimations(sprites)
    -- Set the player's starting stats
    player:survivorSetInitialStats(100, 13, 0.011)

    -- Store base jump height for later comparison
    playerData.basepVmax = playerAc.pVmax
    -- Store default gravities for resetting
    playerData.baseGrav1 = playerAc.pGravity1
    playerData.baseGrav2 = playerAc.pGravity2

    -- Set the player's skill icons
    player:setSkill(1, "Stellar Light", "Shoot a beam of light for 120% damage.", sprSkills, 1, 1)
    player:setSkill(2, "Dark Matter Blast", "Blast all enemies in front of you for 3x80% damage.", sprSkills, 2, 3 * 60)
    player:setSkill(3, "Dissonance",
        "Explodes around you for 180%.\nLaunches you in a controlled direction while invincible.", sprSkills, 3,
        5 * 60)
    -- Alternative skill: Resonance: Grants large buffs based on light and dark for a short while. Invuln during cast. Long cooldown.

    player:setSkill(4, "Divergence",
        "Light and Dark explode for 800% damage in a large area.\nBriefly cripple Stellar Light and Dark Matter Blast.",
        sprSkills, 4, 20 * 60)
    -- Alternative skill: Convergence: Light and Dark focus on a point dealing massive single-target damage. Cripples?
end)

-- Called when the player levels up
astral:addCallback("levelUp", function(player)
    player:survivorLevelUpStats(32, 3.5, 0.0025, 2)
end)

-- Called when the player picks up the Ancient Scepter
astral:addCallback("scepter", function(player)
    player:setSkill(4, "Astral Divergence",
        "Light and Dark explode violently for 1000% damage in a large area.\nBriefly cripple Stellar Light and Dark Matter Blast.",
        sprSkills, 5, 20 * 60)
end)

-- Called when the player tries to use a skill
astral:addCallback("useSkill", function(player, skill)
    -- Get player data to check if skills are disabled
    local playerData = player:getData()
    -- Make sure the player isn't doing anything when pressing the button
    if player:get("activity") == 0 then
        local cd = true
        -- Set the player's state
        if skill == 1 then
            -- Z skill
            -- Cannot use the skill if it is disabled
            if not playerData.disabled then
                player:survivorActivityState(1, sprShoot1, 0.30, true, true)
            else
                cd = false
            end
        elseif skill == 2 then
            -- X skill
            -- Cannot use the skill if it is disabled
            if not playerData.disabled then
                player:survivorActivityState(2, sprShoot2, 0.30, true, true)
            else
                cd = false
            end
        elseif skill == 3 then
            -- C skill
            player:survivorActivityState(3, sprShoot3, 0.40, false, false)
        elseif skill == 4 then
            -- V skill
            player:survivorActivityState(4, sprShoot4, 0.20, true, true)
        end

        -- Put the skill on cooldown if needed
        if cd then
            player:activateSkillCooldown(skill)
        end
    end
end)

-- Called each frame the player is in a skill state
astral:addCallback("onSkill", function(player, skill, relevantFrame)
    -- The 'relevantFrame' argument is set to the current animation frame only when the animation frame is changed
    -- Otherwise, it will be 0
    local playerAc = player:getAccessor()
    local playerData = player:getData()

    if skill == 1 then
        -- Z skill: Stellar Light

        if relevantFrame == 1 then
            -- The "survivorFireHeavenCracker" method handles the effects of the item Heaven Cracker
            -- If the effect is triggered, it returns the fired bullet, otherwise it returns nil
            if player:survivorFireHeavenCracker(0.9) == nil then
                -- The player's "sp" variable is the attack multiplier given by Shattered Mirror
                for i = 0, player:get("sp") do
                    local bullet = player:fireBullet(player.x, player.y, player:getFacingDirection(), 10000, 1.2, sprLightSparks)
                    if i ~= 0 then
                        -- Makes the damage text pop up higher if firing multiple attacks at once
                        bullet:set("climb", i * 8)
                    end
                end
            end

            -- Plays the sound effect
            sndSkill1:play(1.5 + math.random() * 0.2, 0.7)
        end

    elseif skill == 2 then
        -- X skill: Dark Matter

        if relevantFrame == 2 or relevantFrame == 3 or relevantFrame == 4 then
            for i = 0, player:get("sp") do
                -- Change hit box sizes to grow per hit?
                -- Add a small amount of knockback?
                local blast = player:fireExplosion(player.x + player.xscale * (23), player.y, 40 / 19, 16 / 4, 0.8, nil,
                    sprDarkSparks)
                if relevantFrame == 4 then
                    blast:set("knockback", 4)
                else
                    blast:set("knockback", 1)
                end
                blast:set("knockback_direction", player.xscale)
                if i ~= 0 then
                    blast:set("climb", i * 8)
                end
            end

            sndSkill2:play(0.9 + math.random() * 0.2)
        end

    elseif skill == 3 then
        -- C skill: Dissonance
        -- Moves farther based on move-speed. Also moves higher based on jump.

        -- Calculate dash speeds at the start and then store them so that we don't have to recalculate (or change speed based on button holding)
        if relevantFrame == 1 then
            local inputRight = false
            local inputLeft = false
            local inputUp = false
            local inputDown = false

            local gamepad = input.getPlayerGamepad(player)
            if gamepad == nil then
                inputRight = (player:control("right") == input.HELD)
                inputLeft = (player:control("left") == input.HELD)
                inputUp = (player:control("up") == input.HELD)
                inputDown = (player:control("down") == input.HELD)
            else
                -- DPAD
                inputRight =  input.checkGamepad("padl", gamepad) == input.HELD  
                inputLeft = input.checkGamepad("padr", gamepad) == input.HELD
                inputUp = input.checkGamepad("padu", gamepad) == input.HELD
                inputDown = input.checkGamepad("padd", gamepad) == input.HELD

                local deadZone = 0.15

                -- L JOYSTICK
                inputRight = input.getGamepadAxis("lh", gamepad) > deadZone
                inputLeft = input.getGamepadAxis("lh", gamepad) < -deadZone
                inputUp = input.getGamepadAxis("lv", gamepad) < -deadZone
                inputDown = input.getGamepadAxis("lv", gamepad) > deadZone
            end


            
            local baseSpeed = math.abs(player:get("pHmax") * player.xscale)
            -- Vertical speed is based on character speed + bonus from jump height items, reduces to account for a higher base jump height than speed (3 vs 1.3)
            local vertBonus = ((player:get("pVmax") - playerData.basepVmax) * 0.4)

            -- Increases by 50% of attack speed
            local speed = baseSpeed * 3 + (1 + (playerAc.attack_speed - 1) / 2)
            local angleConst = 0.71 -- Unit Constant from a = sqrt(c/2), given pythagorean theorem and 45 degree angle (a=b)


            local hSpeed = 0
            local vSpeed = 0

            -- free checks if the character is in free-fall.
            if player:get("free") == 1 and inputDown and not inputUp then
                -- Down is positive vspeed
                if inputLeft and not inputRight then
                    -- Down-left
                    vSpeed = (speed + vertBonus) * angleConst
                    hSpeed = speed * angleConst * -1

                elseif inputRight and not inputLeft then
                    -- Down-right
                    vSpeed = (speed + vertBonus) * angleConst
                    hSpeed = speed * angleConst
                else
                    -- Straight down
                    vSpeed = (speed + vertBonus)
                end

            elseif inputUp and not inputDown then
                -- Up is negative vspeed
                if inputLeft and not inputRight then
                    -- Up-left
                    vSpeed = (speed + vertBonus) * angleConst * -1
                    hSpeed = speed * angleConst * -1
                elseif inputRight and not inputLeft then
                    -- Up-right
                    vSpeed = (speed + vertBonus) * angleConst * -1
                    hSpeed = speed * angleConst
                else
                    -- Straight up
                    vSpeed = (speed + vertBonus) * -1
                end

            elseif inputRight and not inputLeft and not inputUp then
                -- Right
                hSpeed = speed

            elseif inputLeft and not inputRight and not inputUp then
                -- Left (is negative)
                hSpeed = speed * -1

            else
                --By default go in the left/right direction that the character is facing.
                if player:getFacingDirection() == 0 then
                    --right
                    hSpeed = speed
                else
                    --left
                    hSpeed = speed * -1
                end
            end

            playerData.hDashSpeed = hSpeed
            playerData.vDashSpeed = vSpeed
        end

        -- Create the blast
        if relevantFrame == 4 then
            for i = 0, player:get("sp") do
                -- Explosion should happen at the characters middle and low range
                local blast = player:fireExplosion(player.x, player.y - (player.yscale * 3), 20 / 19, 16 / 4, 1.8,
                    sprDissonanceExplosion, sprDoubleSparks)
                if i ~= 0 then
                    blast:set("climb", i * 8)
                end
            end

            sndSkill3:play(1 + math.random() * 0.2, 0.9)
            sndSkillDash:play(0.9 + math.random() * 0.2)
        end

        -- Gravity
        if relevantFrame == 1 then
            -- Disable gravity a the start to make air control easier
            playerAc.pGravity1 = 0
            playerAc.pGravity2 = 0
        elseif relevantFrame == 10 then
            playerData.gravReset = true
        end
       
        --Invicibility
        if relevantFrame == 13 then
            --last frame disabled the invincibility
            if playerAc.invincible <= 5 then
                playerAc.invincible = 0
            end
        elseif relevantFrame > 4 then
            -- Only invincible during the dash.
            if playerAc.invincible <= 5 then
                playerAc.invincible = 5
            end
        end

        -- Movement speed
        if relevantFrame > 4 and relevantFrame <= 10 then
            -- After the explosion wind-up, actually set the speed for the remaining frames
            player:set("pVspeed", playerData.vDashSpeed)
            player:set("pHspeed", playerData.hDashSpeed)
        elseif relevantFrame > 10 and relevantFrame <= 13 then
            -- Wind down speed at the end.
            player:set("pVspeed", playerData.vDashSpeed / 2)
            player:set("pHspeed", playerData.hDashSpeed / 2)
        end
    
    elseif skill == 4 then
        -- V skill: Dissonance

        if relevantFrame == 4 then
            for i = 0, player:get("sp") do
                local debuffDuration = 0

                if player:get("scepter") <= 0 then
                    -- No scepter
                    player:fireExplosion(player.x + player.xscale * 37, player.y - player.yscale * 6, 76/19, 56/4, 8.0,
                        sprDivergenceExplosion, sprDoubleSparks)
                    debuffDuration = (2 + (3 / playerAc.attack_speed)) * 60
                else
                    -- We have a scepter
                    player:fireExplosion(player.x + player.xscale * 37, player.y - player.yscale * 6, 76/19, 56/4, 10.0,
                        sprDivergenceExplosion, sprDoubleSparks)
                    -- Layer sound effects when scepter is active
                    sndSkill4:play(1 + math.random() * 0.3, 0.5)
                    debuffDuration = (2 + (2 / playerAc.attack_speed)) * 60
                end

                -- Deactivates the first 2 stages for 1 second
                playerData.disabled = math.ceil(1.5 * 60)
                player:setSkillIcon(1, sprSkills, 6)
                player:setSkillIcon(2, sprSkills, 6)

                --Gives self Erosion debuff, which reduces damage dealt
                local erosion = Buff.find("erosion", "astralWitch")
                player:applyBuff(erosion, debuffDuration)

                -- Play a sound effect
                sndSkill4:play(0.8 + math.random() * 0.3, 1.3)
            end
        end
    end
end)

astral:addCallback("step", function(player)
    local playerAc = player:getAccessor()
    local playerData = player:getData()

    -- Count down the disable timer
    if playerData.disabled ~= nil then
        if playerData.disabled <= 0 then
            playerData.disabled = nil
            player:setSkillIcon(1, sprSkills, 1)
            player:setSkillIcon(2, sprSkills, 2)
            -- play a sound, or anim that the skills are back?
        else
            playerData.disabled = playerData.disabled - 1
        end
    end

    -- Set gravity back to what it should be
    if playerData.gravReset ~= nil then
        playerAc.pGravity1 = playerData.baseGrav1
        playerAc.pGravity2 = playerData.baseGrav2
        playerData.gravReset = nil
    end
end)


