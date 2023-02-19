local LevelGen = {}

local bit = require "SoTClient.Utils.BitOperators"

local seed1
local seed2
local iterations_per_seed = 10

function LevelGen.setSeed(s1, s2)
    seed1 = s1
    seed2 = s2
end 

function LevelGen.getPortableRandom()
    io.write(BitXOR(seed1, 65535) .. "\n")
    seed1 = ((36969 * BitXOR(seed1, 65535)) % 4294967296 + BitRShift(seed1, 16)) % 4294967296
    seed2 = ((18000 * BitXOR(seed2, 65535)) % 4294967296 + BitRShift(seed2, 16)) % 4294967296
    io.write(seed1 .. " " .. seed2 .. "\n")
    local combined = (BitLShift(seed1, 16) % 4294967296 + seed2) % 4294967296;
    io.write(combined .. "\n")
	return (combined + 1.0) * 2.328306435454494e-10;		-- between 0 and 1
end

function LevelGen.generateNRandoms(n)

    local p_random = LevelGen.getPortableRandom()
    io.write(p_random .. "\n")
    local temp_input = p_random
    local random_nums = {}
    local i, max_iterations = 1, iterations_per_seed

    while i <= n do

        temp_input = p_random
       
        while i <= n and i <= max_iterations do

            temp_input = temp_input * 10
            random_nums[i] = math.floor(temp_input)
            temp_input = temp_input - random_nums[i]
            io.write(random_nums[i] .. "\n")
            i = i + 1

        end

        if i <= n then

            max_iterations = max_iterations + iterations_per_seed

            temp_input = p_random * ((10 ^ (iterations_per_seed/2)) % 4294967296) % 4294967296
            seed1 = math.floor(temp_input)

            temp_input = p_random
            for j = 1, iterations_per_seed, 1 do
                temp_input = temp_input * 10 % 4294967296
            end

            seed2 = (math.floor(temp_input) - seed1) % 4294967296 * seed1 % 4294967296

            p_random = LevelGen.getPortableRandom()
        end
 
    end

    return random_nums
end

function LevelGen.generateRandomBetween(min, max)
    local range = max - min
    local random =  math.floor(range/2)
    local max_divs = (math.floor(range/9) + 1) * 2  -- number of values between 0 and 9 necessary to achieve "range". This value is doubled because i is the value and i+1 defines addition/subtraction (if higher/leq than 4) 

    local n_nums = LevelGen.generateNRandoms(max_divs)

    for i = 1, max_divs, 2 do

        if(n_nums[i+1] > 4) then
            random = random + n_nums[i]
        else
            random = random - n_nums[i]
        end

        if(random > range) then
            random = range - math.min(range, 10 - n_nums[i])
        elseif (random < 0) then
            random = 0 + math.min(range, 10 - n_nums[i])
        end

    end

    return math.min(min + random, max)
end

return LevelGen