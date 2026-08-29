local GAME_PLACE_ID = 72167803024670
if game.PlaceId ~= GAME_PLACE_ID then
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Wrong Game",
		Text = "This script only works in Find Who Slapped. Unloading.",
		Duration = 6,
	})
	error("HB Slap: this script only works in Find Who Slapped (Wrong Game)")
end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local Events = RS.Events
local ASY = Enum.AutomaticSize.Y
local GFM = Enum.Font.Gotham
local GFB = Enum.Font.GothamBold
local TL = Enum.TextXAlignment.Left
local MAG_NEAR = 60 * 60
local PEAK_THRESHOLD = 0.96
local lp = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local S = getgenv().__HBConfig or {}
S.autoCoconut = S.autoCoconut or false
S.autoInterval = S.autoInterval or 3
S.slapDetect = S.slapDetect ~= nil and S.slapDetect or true
S.autoDodge = S.autoDodge ~= nil and S.autoDodge or true
S.maxForce = S.maxForce ~= nil and S.maxForce or true
getgenv().__HBConfig = S

local D = getgenv().__SlapD or {}
getgenv().__SlapD = D

for _, c in ipairs({ D.hook, D.posUpdaterConn, D.forcePosConn }) do
	if c and c.Connected then pcall(function() c:Disconnect() end) end
end
D.hook = nil
D.posUpdaterConn = nil
D.forcePosConn = nil
if D.loop and D.loop.cancelled == false then task.cancel(D.loop) end

D.positions = {}
local positions = D.positions

D.posUpdaterConn = RunService.Heartbeat:Connect(function()
	local occ = positions
	for _, p in ipairs(Players:GetPlayers()) do
		local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		local ar = p:GetAttribute("Arena")
		occ[p.Name] = (root and { pos = root.Position, arena = ar }) or nil
	end
end)

local function getRoot()
	local c = lp.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function collectAll()
	local folder = workspace:FindFirstChild("_ClientSummerCoconuts")
	local root = getRoot()
	if not folder or not root then return end
	local lastPos = root.CFrame
	for _, m in ipairs(folder:GetChildren()) do
		if not S.autoCoconut or not m:IsA("Model") or not m.Parent then break end
		local p = m:GetPivot().Position
		local r = getRoot()
		if r then r.CFrame = CFrame.new(p.X, p.Y + 2, p.Z) end
		local deadline = os.clock() + 5
		while os.clock() < deadline do
			if not S.autoCoconut or not m.Parent or not m:IsA("Model") then break end
			local r2 = getRoot()
			if r2 and (r2.Position - p).Magnitude > 4.5 then
				r2.CFrame = CFrame.new(p.X, r2.Position.Y, p.Z)
			end
			task.wait(0.15)
		end
	end
	task.wait(0.4)
	if getRoot() then getRoot().CFrame = lastPos end
end

local function startLoop()
	if D.loop then task.cancel(D.loop) end
	D.loop = task.spawn(function()
		while S.autoCoconut do
			pcall(collectAll)
			task.wait(S.autoInterval)
		end
	end)
end
local function stopLoop()
	if D.loop then task.cancel(D.loop) D.loop = nil end
end

local notifySelf
do
	for _, g in ipairs(CoreGui:GetChildren()) do
		if g:IsA("ScreenGui") and g.Name == "HBSlapNotif" then
			pcall(function() g:Destroy() end)
		end
	end
	local function ensure()
		local notifScreen = Instance.new("ScreenGui")
		notifScreen.Name = "HBSlapNotif"
		notifScreen.ResetOnSpawn = false
		notifScreen.IgnoreGuiInset = true
		local holder = Instance.new("Frame")
		holder.Size = UDim2.fromOffset(320, 0)
		holder.Position = UDim2.new(1, -340, 0, 30)
		holder.AnchorPoint = Vector2.new(1, 0)
		holder.BackgroundTransparency = 1
		holder.AutomaticSize = ASY
		local list = Instance.new("UIListLayout")
		list.Padding = UDim.new(0, 6)
		list.Parent = holder
		holder.Parent = notifScreen
		notifScreen.Parent = CoreGui
		return holder
	end
	notifySelf = function(title, content, color)
		pcall(function()
			StarterGui:SetCore("SendNotification", { Title = title, Text = content, Duration = 6 })
		end)
		local hh = ensure()
		local card = Instance.new("Frame")
		card.Size = UDim2.fromOffset(320, 0)
		card.AutomaticSize = ASY
		card.BackgroundColor3 = Color3.fromRGB(24, 26, 31)
		card.BackgroundTransparency = 0.08
		card.BorderSizePx = 0
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = card
		local line = Instance.new("Frame")
		line.Size = UDim2.fromOffset(5, 100)
		line.BackgroundColor3 = color or Color3.fromRGB(255, 77, 77)
		line.BorderSizePx = 0
		local lc = Instance.new("UICorner")
		lc.CornerRadius = UDim.new(0.5, 0)
		lc.Parent = line
		line.Parent = card
		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 16)
		pad.PaddingRight = UDim.new(0, 12)
		pad.PaddingTop = UDim.new(0, 8)
		pad.PaddingBottom = UDim.new(0, 8)
		pad.Parent = card
		local titleL = Instance.new("TextLabel")
		titleL.Text = title or ""
		titleL.TextColor3 = Color3.fromRGB(255, 255, 255)
		titleL.BackgroundTransparency = 1
		titleL.Font = GFB
		titleL.TextSize = 16
		titleL.TextXAlignment = TL
		titleL.Size = UDim2.fromOffset(300, 0)
		titleL.AutomaticSize = ASY
		titleL.Parent = card
		local contentL = Instance.new("TextLabel")
		contentL.Text = content or ""
		contentL.TextColor3 = Color3.fromRGB(200, 200, 200)
		contentL.BackgroundTransparency = 1
		contentL.Font = GFM
		contentL.TextSize = 14
		contentL.TextXAlignment = TL
		contentL.Size = UDim2.fromOffset(300, 0)
		contentL.AutomaticSize = ASY
		contentL.TextWrapped = true
		contentL.Parent = card
		local bar = Instance.new("Frame")
		bar.Position = UDim2.new(0, 0, 1, 0)
		bar.Size = UDim2.new(1, 0, 0, 3)
		bar.BackgroundColor3 = color or Color3.fromRGB(255, 77, 77)
		bar.BorderSizePx = 0
		bar.Parent = card
		card.Parent = hh
		task.spawn(function()
			card.Position = UDim2.fromOffset(340, 0)
			TweenService:Create(card, TweenInfo.new(0.3), { Position = UDim2.fromOffset(0, 0) }):Play()
			task.wait(5)
			TweenService:Create(card, TweenInfo.new(0.3), { Position = UDim2.fromOffset(340, 0) }):Play()
			task.wait(0.35)
			card:Destroy()
		end)
	end
end

local function nearestSlapper(myName)
	local me = getRoot()
	if not me then return nil end
	local myArena = lp:GetAttribute("Arena")
	local mx, my, mz = me.Position.X, me.Position.Y, me.Position.Z
	local best, bestD
	local function consider(name, pos)
		local dx, dy, dz = pos.X - mx, pos.Y - my, pos.Z - mz
		local d = dx * dx + dy * dy + dz * dz
		if not bestD or d < bestD then best, bestD = name, d end
	end
	for name, k in pairs(positions) do
		if name ~= myName and k then
			if typeof(k) == "table" and k.pos then
				if not myArena or k.arena == myArena then consider(name, k.pos) end
			elseif typeof(k) == "Vector3" then
				consider(name, k)
			end
		end
	end
	if bestD and bestD <= MAG_NEAR then return best end
	return nil
end

local N = getgenv().__HBNotif or {}
getgenv().__HBNotif = N
N.lastNotifT = N.lastNotifT or -99
N.lastNotifPlayer = N.lastNotifPlayer or nil
N.lastNotifPlayerT = N.lastNotifPlayerT or -99

local function tryNotify(cand, myName)
	if not cand or cand == myName then return end
	local now = os.clock()
	if now - N.lastNotifT < 5 then return end
	if cand == N.lastNotifPlayer and now - N.lastNotifPlayerT < 8 then return end
	D.lastSlapper = cand
	N.lastNotifT = now
	N.lastNotifPlayer = cand
	N.lastNotifPlayerT = now
	task.spawn(function()
		notifySelf("SOMEONE SLAPPED YOU:", cand, Color3.fromRGB(255, 77, 77))
	end)
end

local function getInGame()
	local f = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Frames")
	return f and f:FindFirstChild("InGame")
end

local hitRemote = Events:FindFirstChild("Hit")
local armedForce = false
local function doPerfectHit()
	if not hitRemote then return end
	D.perfectHitCount = (D.perfectHitCount or 0) + 1
	for _ = 1, 3 do pcall(function() hitRemote:FireServer(0.98) end) end
end

local function armLineMonitor()
	local ig = getInGame()
	if ig then
		local line = ig:FindFirstChild("Bar") and ig.Bar:FindFirstChild("Line")
		if line then
			D.forcePosConn = line:GetPropertyChangedSignal("Position"):Connect(function()
				if not S.maxForce then return end
				local ig2 = getInGame()
				if not ig2 then return end
				local hit = ig2:FindFirstChild("Hit")
				if not hit or not hit.Visible then armedForce = false return end
				local y = line.Position.Y.Scale
				if y >= PEAK_THRESHOLD and not armedForce then
					armedForce = true
					D.lastForcePeak = y
					doPerfectHit()
				elseif y < 0.9 and armedForce then
					armedForce = false
				end
			end)
		end
		local hit = ig:FindFirstChild("Hit")
		if hit then
			hit:GetPropertyChangedSignal("Visible"):Connect(function()
				if hit.Visible then armedForce = false end
			end)
		end
	end
end

armLineMonitor()

local hookConn = Events.SendToClient.OnClientEvent:Connect(function(...)
	local args = { ... }
	local kind = tostring(args[1])
	if not kind then return end
	if kind == "Dodge" then
		if S.autoDodge then
			pcall(function() Events.Dodge:FireServer(tostring(args[2])) end)
		end
		if S.slapDetect then
			task.spawn(function() tryNotify(nearestSlapper(tostring(lp)), tostring(lp)) end)
		end
		return
	end
	if kind == "Cutscene" or kind == "Cutscene2" then
		if args[2] == false and typeof(args[3]) == "Instance" then
			cutOther = tostring(args[3])
		end
		return
	end
	if kind ~= "Hit" or not S.slapDetect then return end
	local cand = (cutOther and cutOther ~= tostring(lp)) and cutOther or nearestSlapper(tostring(lp))
	tryNotify(cand, tostring(lp))
end)

local Window = Rayfield:CreateWindow({
	Name = "HB Slap | Find Who Slapped You",
	LoadingTitle = "HB Slap",
	LoadingSubtitle = "Loading...",
	ConfigurationSaving = { Enabled = false },
	KeySystem = false,
})

local Tab = Window:CreateTab("HB Slap", 4483362458)

Tab:CreateSection("Auto Slap")
Tab:CreateToggle({
	Name = "Auto Max Force",
	CurrentValue = S.maxForce,
	Flag = "MaxForce",
	Callback = function(v)
		S.maxForce = v == true
	end,
})
Tab:CreateLabel("Perfect Hit: when you are the slapper, it fires at max force automatically.")

Tab:CreateSection("Who Slapped You")
Tab:CreateToggle({
	Name = "Slap Detector",
	CurrentValue = S.slapDetect,
	Flag = "SlapDetect",
	Callback = function(v)
		S.slapDetect = v == true
	end,
})
Tab:CreateToggle({
	Name = "Auto Dodge",
	CurrentValue = S.autoDodge,
	Flag = "AutoDodge",
	Callback = function(v)
		S.autoDodge = v == true
	end,
})
Tab:CreateButton({
	Name = "Show Last Slapper",
	Callback = function()
		pcall(function()
			notifySelf("Last Slapper", D.lastSlapper or "Not recorded yet. Get slapped!", Color3.fromRGB(90, 200, 250))
		end)
	end,
})

Tab:CreateSection("Auto Coconut")
Tab:CreateToggle({
	Name = "Auto Coconut (loop)",
	CurrentValue = S.autoCoconut,
	Flag = "AutoCoconut",
	Callback = function(v)
		S.autoCoconut = v == true
		if S.autoCoconut then startLoop() else stopLoop() end
	end,
})
Tab:CreateSlider({
	Name = "Loop Interval (s)",
	Range = { 1, 15 },
	Increment = 1,
	Suffix = "s",
	CurrentValue = S.autoInterval,
	Flag = "CocoInterval",
	Callback = function(v)
		S.autoInterval = v
	end,
})
Tab:CreateButton({
	Name = "Collect Coconuts Now",
	Callback = function()
		pcall(collectAll)
	end,
})

return { status = "menu_ok_v836" }