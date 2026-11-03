local FILE = "versik/key.txt"

local okLib, PUSL = pcall(function()
    return loadstring(game:HttpGet("https://secure.pandauth.com/pv4/lib"))()
end)
if not okLib or type(PUSL) ~= "table" then
    return warn("[Panda] Library failed to initialize.")
end
PUSL.configure({ serviceId = "verstik" })

local function check(k)
    local ok, r = pcall(PUSL.validate, k)
    return ok and type(r) == "table" and r.success == true
end

local function save(k)
    pcall(function()
        if not isfolder("versik") then makefolder("versik") end
        writefile(FILE, k)
    end)
end

local function run()
    local urls = {
        [142823291]       = "https://pastebin.com/raw/sCTg2jJc", -- mm2
        [107535308163741] = "https://your-real-url-here",
        [537413528]       = "https://your-real-url-here",
    }
    local u = urls[game.PlaceId]
    if u then loadstring(game:HttpGet(u))() end
end

-- env key, then saved key
local k = getgenv().verstik
if type(k) ~= "string" or k == "" then
    local ok, d = pcall(readfile, FILE)
    k = (ok and type(d) == "string") and d:gsub("%s+", "") or nil
end
if type(k) == "string" and k ~= "" and check(k) then
    save(k)
    return run()
end

-- key UI
local function new(c, p, par)
    local o = Instance.new(c)
    for i, v in pairs(p) do o[i] = v end
    o.Parent = par
    return o
end

local gui = new("ScreenGui", { Name = "VersikKeyUI", ResetOnSpawn = false },
    (gethui and gethui()) or game:GetService("CoreGui"))

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
    local key = box.Text:gsub("%s+", "")
    if key == "" then return end
    busy = true
    btn.Text = "..."
    task.spawn(function()
        if check(key) then
            save(key)
            gui:Destroy()
            local ok, err = pcall(run)
            if not ok then warn("[Panda] Script error: " .. tostring(err)) end
        else
            btn.Text = "INVALID"
            task.wait(1.5)
            btn.Text, busy = "VALIDATE", false
        end
    end)
end)
