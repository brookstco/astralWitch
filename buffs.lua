local path = "buffs/"

-- Buff that reduces damage and attack speed by 50%
-- Currently broken: Buff that reduces attack power and attack speed based on the time remaining
-- WARNING: Unsafe to stack this buff. Make sure to remove this buff before stacking another.
local erosion = Buff.new("erosion")
erosion.sprite = Sprite.load("erosion", path.."ErosionBuff", 1, 9, 9)

erosion:addCallback("start", function(actor)
    -- Start doesn't actually get the duration, so we can't set it initially. Instead we use stored vars to make the step trigger the proper start action.
	local a = actor:getAccessor()
    --a.erosionAdded = true
    log("Starting damage: "..a.damage.." Starting speed: "..a.attack_speed)
    local damageDecrease = math.max(a.damage - 1, 0) / 2
    a.erosionDamageChange = damageDecrease
    a.damage = a.damage - damageDecrease
    local speedDecrease = math.max(a.attack_speed - 0.75, 0) / 2
    a.erosionSpeedChange = speedDecrease
    a.attack_speed = a.attack_speed - speedDecrease
end)

-- erosion:addCallback("step", function(actor, timeLeft)
-- 	local a = actor:getAccessor()

--     if a.erosionAdded == true then
--         -- A new erosion buff was added.
--         a.erosionAdded = nil
--         -- If the previous magnitude is non-null, that means we extended the duration, so we should only decrease partially.
--         local prevMagnitude = a.erosionMagnitude
--         if prevMagnitude ~= nil then
--             -- New Buff. Add duration

--         else
--             -- Existing Buff. Add duration difference
--             local diffMagnitude = prevMagnitude - timeLeft
--             if diffMagnitude > 0 then
--                 -- more debuff
--             else
--                 -- Less? Less debuff then
--             end
--         end
--     end
--     a.erosionMagnitude = timeLeft
--     log(timeLeft)

--     -- TODO: Safety? What happens if they go negative? If its clamped to 0, how do we prevent a permanent damage increase after the mismatching timing happens, without increasing the damage permanently?
--     -- Maybe compare magnitude to time, and cap magnitude but not the time, so if there is a mismatch, the attack isn't restored until they become equal again?
--     local increment = 0.1
-- 	a.damage = a.damage + increment
-- 	a.attack_speed = a.attack_speed + increment
-- end)

erosion:addCallback("end", function(actor, timeLeft)
	local a = actor:getAccessor()
    --log(timeLeft)
    --local magnitude = a.erosionMagnitude

    local damageIncrease = a.erosionDamageChange
    if damageIncrease ~= nil then
        a.damage = a.damage + damageIncrease
        a.erosionDamageChange = nil
    end
    local speedIncrease = a.erosionSpeedChange
    if speedIncrease ~= nil then
        a.attack_speed = a.attack_speed + speedIncrease
        a.erosionSpeedChange = nil
    end
end)