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
    skill1_char_down    = 12, 
    skill1_char_left    = 13,
    skill1_char_right   = 14,
    skill1_char_up      = 15,
    skill1_projectile   = 16, 
    skill2_char_down    = 17, 
    skill2_char_left    = 18,
    skill2_char_right   = 19,
    skill2_char_up      = 20,
    skill2_projectile   = 21,
    skill3_char_down    = 22, 
    skill3_char_left    = 23,
    skill3_char_right   = 24,
    skill3_char_up      = 25,
    skill3_projectile   = 26,
    skill4_char_down    = 27, 
    skill4_char_left    = 28,
    skill4_char_right   = 29,
    skill4_char_up      = 30,
    skill4_projectile   = 31
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