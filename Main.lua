print("versik loader v4")

local FILE = "versik/key.txt"
local FALLBACK = "https://raw.githubusercontent.com/shyoma30/Verstik/refs/heads/main/AP.lua"

local function trim(s)
    return (tostring(s or ""):gsub("%s+", ""))
end

local okLib, PUSL = pcall(function()
    return loadstring(game:HttpGet("https://secure.pandauth.com/pv4/lib"))()
end)
if not okLib or type(PUSL) ~= "table" then
    return warn("[Panda] Library failed to initialize.")
end
PUSL.configure({ serviceId = "verstik" })

local function check(k)
    if k == "" then return false end
    local ok, r = pcall(PUSL.validate, k)
    return ok and type(r) == "table" and r.success == true
end

local function save(k)
    pcall(function()
        if not isfolder("versik") then makefolder("versik") end
        writefile(FILE, k)
    end)
end

local function readSaved()
    local ok, d = pcall(function()
        if isfile and isfile(FILE) then return readfile(FILE) end
    end)
    return ok and trim(d) or ""
end

local function run()
    local urls = {
        [142823291] = "https://pastebin.com/raw/sCTg2jJc", -- mm2
        [155615604] = "https://raw.githubusercontent.com/shyoma30/Verstik/refs/heads/main/Prisonlife.lua",
        [537413528] = "https://your-real-url-here",
    }

    local u = urls[game.PlaceId]
    if not u or u:find("your%-real%-url%-here") then
        u = FALLBACK
    end

    local okGet, src = pcall(game.HttpGet, game, u)
    if not okGet then return warn("[Panda] Fetch failed: " .. tostring(src)) end

    local fn, err = loadstring(src)
    if not fn then return warn("[Panda] Compile failed: " .. tostring(err)) end

    local ok, e = xpcall(fn, debug.traceback)
    if not ok then warn("[Panda] Script error: " .. tostring(e)) end
end

local function showUI()
    local function new(c, p, par)
        local o = Instance.new(c)
        for i, v in pairs(p) do o[i] = v end
        o.Parent = par
        return o
    end

    local parent = (gethui and gethui()) or game:GetService("CoreGui")
    local gui = new("ScreenGui", { Name = "VersikKeyUI", ResetOnSpawn = false }, parent)

    local f = new("Frame", {
        AnchorPoint = Vector2.new(.5, .5), Position = UDim2.fromScale(.5, .5),
        Size = UDim2.fromOffset(320, 120), BackgroundColor3 = Color3.fromRGB(10, 11, 24),
        Active = true, Draggable = true,
    }, gui)
    new("UICorner", {}, f)
    new("UIStroke", { Color = Color3.fromRGB(70, 140, 255), Thickness = 2 }, f)

    local box = new("TextBox", {
        Position = UDim2.fromOffset(16, 16), Size = UDim2.new(1, -32, 0, 36),
        BackgroundColor3 = Color3.fromRGB(26, 28, 56), Text = "", PlaceholderText = "paste key",
        TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.Gotham, TextSize = 13,
        ClearTextOnFocus = false,
    }, f)
    new("UICorner", {}, box)

    local btn = new("TextButton", {
        Position = UDim2.fromOffset(16, 64), Size = UDim2.new(1, -32, 0, 38),
        BackgroundColor3 = Color3.fromRGB(70, 140, 255), Text = "VALIDATE",
        TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 12,
    }, f)
    new("UICorner", {}, btn)

    local busy = false
    btn.Activated:Connect(function()
        if busy then return end
        local key = trim(box.Text)
        if key == "" then return end
        busy = true
        btn.Text = "..."
        task.spawn(function()
            if check(key) then
                save(key)
                gui:Destroy()
                run()
            else
                btn.Text = "INVALID"
                task.wait(1.5)
                btn.Text, busy = "VALIDATE", false
            end
        end)
    end)
end

-- env key, then saved key, else UI
local k = trim(getgenv().verstik)
if not check(k) then
    k = readSaved()
    if not check(k) then
        return showUI()
    end
end

save(k)
run()
