local key = getgenv().verstik

if type(key) ~= "string" or key == "" then
    return warn("[Panda] Set getgenv().verstik before running.")
end

local PUSL = loadstring(game:HttpGet("https://secure.pandauth.com/pv4/lib"))()

if not PUSL or type(PUSL.configure) ~= "function" then
    return warn("[Panda] Library failed to initialize.")
end

PUSL.configure({
    serviceId = "verstik",
})

local result = PUSL.validate(key)

if not result or not result.success then
    warn("[Panda] Get a key: " .. PUSL.getKeyUrl())
    return
end

-- Put your script's main code below this line.
print("[Panda] Key validated.")

if game.PlaceId == 142823291 then -- mm2
    loadstring(game:HttpGet('https://pastebin.com/raw/sCTg2jJc'))()
elseif game.PlaceId == 107535308163741 then -- game
    loadstring(game:HttpGet("https://your-real-url-here"))()
elseif game.PlaceId == 537413528 then -- game
    loadstring(game:HttpGet("https://your-real-url-here"))()
end
