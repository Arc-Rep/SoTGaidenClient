local CharAnimationList = {
    -- idle states
    idle         = 0,
    idle_healthy = 0,
    -- movement
    move        = 1,
    move_down   = 1,
    move_left   = 2,
    move_right  = 3,
    move_up     = 4,
    move_end    = 4,
    -- basic attack
    attack              = 6,
    attack_up           = 6,
    attack_down         = 7,
    attack_left         = 8,
    attack_right        = 9,
    attack_projectile   = 10,
    -- hurt
    hurt = 11,
    -- skill
    skill1              = 12, 
    skill1_projectile   = 13, 
    skill2              = 14, 
    skill2_projectile   = 15,
    skill3              = 16,
    skill3_projectile   = 17,
    skill4              = 18, 
    skill4_projectile   = 19
}

function CharAnimationList.convertMoveCoordsToAnimation(dir_x, dir_y)
    if (dir_x > 0) then
        return CharAnimationList.move_right
    elseif (dir_x < 0) then
        return CharAnimationList.move_left
    elseif (dir_y < 0) then
        return CharAnimationList.move_up
    end
    return CharAnimationList.move_down
end

function CharAnimationList.convertAnimationIndexToAnimationID(index)
  local moves = {"idle", "move_down", "move_left", "move_right", "move_up"}
  return moves[index + 1]
end

return CharAnimationList