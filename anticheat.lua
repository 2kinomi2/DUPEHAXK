local suspiciousFuncs = {
    "loadstring", "load", "loadfile", "execute",
    "getgenv", "getgc", "getrawmetatable", "setmetatable", 
    "setfenv", "getfenv", "debug.getregistry", "debug.getinfo",
}

local function checkForSuspiciousFunctions()
    for _, funcName in ipairs(suspiciousFuncs) do
        if rawget(_G, funcName) or rawget(getfenv(0), funcName) then
            return funcName
        end
    end
end

local function detectExploit()
    local detectedFunc = checkForSuspiciousFunctions()
    if detectedFunc then
        game.Players.LocalPlayer:Kick("[Anti-Cheat] Exploit Detected: " .. detectedFunc)
    end
end

local function base64Decode(s)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    s = s:gsub("[^"..b.."=]", "")
    return (s:gsub('.', function(x)
        if x == '=' then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i - f%2^(i-1) > 0 and '1' or '0') end
        return r
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if #x ~= 8 then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

local suspiciousPatterns = {
    "loadstring", "load", "loadfile",
    "base64decode", "loadstring%(%s*base64",
    "getgenv", "getgc",
}

local function detectDynamicCodeExecution()
    for _, pattern in ipairs(suspiciousPatterns) do
        if rawget(_G, pattern) then
            return true
        end
    end
    return false
end

local function disableExploitFunctions()
    rawset(_G, "loadstring", nil)
    rawset(_G, "load", nil)
    rawset(_G, "loadfile", nil)
end

game.ReplicatedStorage.MyRemote.OnServerEvent:Connect(function(player, data)
    if data and type(data) == "table" then
        if data.someKey and data.someValue then
        else
            player:Kick("[Anti-Cheat] Invalid Data Detected.")
        end
    else
        player:Kick("[Anti-Cheat] Invalid Remote Call.")
    end
end)

task.spawn(function()
    while task.wait(1) do
        detectExploit()
        if detectDynamicCodeExecution() then
            game.Players.LocalPlayer:Kick("[Anti-Cheat] Suspicious Dynamic Code Detected.")
        end
    end
end)

CoreGui.ChildAdded:Connect(function(child)
    if child:IsA("ScreenGui") and not child.Name:match("YourGameGui") then
        game.Players.LocalPlayer:Kick("[Anti-Cheat] Unauthorized UI Detected: " .. child.Name)
    end
end)

disableExploitFunctions()

local m = getrawmetatable(game)
setreadonly(m, false)

local o = m.__namecall
m.__namecall = function(...)
    local p = {...}
    if tostring(p[#p]) == "Kick" then
    end
    return o(...)
end