-- Secret Generator
-- string.random made by haggen @ https://gist.github.com/haggen/2fd643ea9a261fea2094
-- Allows attaching values to a generated secret value
-- Main purpose is to generate validation keys
-- Secondary purpose is to mask values by assigning a random string instead

local charset = {}

-- qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890
for i = 48,  57 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end

function string.random(length)
    if length > 0 then
        return string.random(length - 1) .. charset[math.random(1, #charset)]
    else
        return ""
    end
end

local VALID_SECRETS = {}
function GenerateSecret(value)
    local secret = string.random(30)
    if IsValidSecret(secret) then
        return GenerateSecret(value)
    end
    table.insert(VALID_SECRETS, {secret, value})
    return secret
end

function IsValidSecret(secret)
    for _, _secret in next, VALID_SECRETS do
        if _secret[1] == secret then return true, _secret[2] end
    end
    return false, ""
end
