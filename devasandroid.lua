local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- ========= ScreenGui =========
local gui = Instance.new("ScreenGui")
gui.Name = "Painel_evilDrock"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- Detecta se é mobile
local isMobile = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled)

-- ========= Escala automática pelo tamanho da tela =========
local camera = workspace.CurrentCamera or workspace:WaitForChild("Camera")
local viewportSize = camera.ViewportSize

local BASE_WIDTH, BASE_HEIGHT = 520, 480
local scaleX = viewportSize.X / 1920
local scaleY = viewportSize.Y / 1080
local SCALE = math.clamp(math.min(scaleX, scaleY), 0.55, 1)

-- ========= Botão flutuante "Abrir" =========
local openBtn = Instance.new("TextButton")
openBtn.Name = "OpenButton"
openBtn.Size = UDim2.fromOffset(140 * SCALE, 36 * SCALE)
openBtn.Position = UDim2.new(0.02, 0, 0.78, 0)
openBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
openBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openBtn.Font = Enum.Font.GothamBold
openBtn.TextSize = 14 * SCALE
openBtn.Text = "Abrir Painel"
openBtn.Visible = false
openBtn.Parent = gui
local openCorner = Instance.new("UICorner", openBtn)
openCorner.CornerRadius = UDim.new(0, 10)

-- ========= Janela principal =========
local frame = Instance.new("Frame")
frame.Name = "Window"
frame.Size = UDim2.fromOffset(BASE_WIDTH * SCALE, BASE_HEIGHT * SCALE)
frame.Position = UDim2.new(0.5, -(BASE_WIDTH * SCALE)/2, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
frame.BorderSizePixel = 0
frame.Parent = gui
local frameCorner = Instance.new("UICorner", frame)
frameCorner.CornerRadius = UDim.new(0, 14)

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 3 * SCALE
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Color = Color3.fromRGB(150, 0, 255)
local strokeGrad = Instance.new("UIGradient", stroke)
strokeGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0,255,150)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150,0,255))
}

-- ========= Topbar =========
local top = Instance.new("Frame")
top.Name = "Topbar"
top.Size = UDim2.new(1, 0, 0, 46 * SCALE)
top.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
top.BorderSizePixel = 0
top.Parent = frame
local topCorner = Instance.new("UICorner", top)
topCorner.CornerRadius = UDim.new(0, 14)

local title = Instance.new("TextLabel")
title.Name = "Title"
title.BackgroundTransparency = 1
title.Text = "Evil Store"
title.Font = Enum.Font.GothamBold
title.TextSize = 22 * SCALE
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.Size = UDim2.new(1, -110, 1, 0)
title.Position = UDim2.new(0, 16 * SCALE, 0, 0)
title.ZIndex = 2
title.Parent = top

local minimize = Instance.new("TextButton")
minimize.Name = "Minimize"
minimize.Size = UDim2.fromOffset(36 * SCALE, 28 * SCALE)
minimize.Position = UDim2.new(1, -(46 * SCALE), 0.5, -(14 * SCALE))
minimize.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
minimize.Text = "x"
minimize.TextColor3 = Color3.fromRGB(0, 0, 0)
minimize.Font = Enum.Font.GothamBold
minimize.TextSize = 20 * SCALE
minimize.ZIndex = 2
minimize.Parent = top
local minCorner = Instance.new("UICorner", minimize)
minCorner.CornerRadius = UDim.new(0, 8)

-- ========= Drag: mouse + touch =========
do
    local dragging = false
    local dragStart, startPos

    local function updateDrag(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.fromOffset(startPos.X + delta.X, startPos.Y + delta.Y)
    end

    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            updateDrag(input)
        end
    end)
end

-- ========= Minimizar / Restaurar =========
local function setMinimized(state)
    if state then
        frame.Visible = false
        openBtn.Visible = true
    else
        frame.Visible = true
        openBtn.Visible = false
    end
end

openBtn.MouseButton1Click:Connect(function()
    setMinimized(false)
end)

minimize.MouseButton1Click:Connect(function()
    setMinimized(true)
end)

-- ========= Abas (ScrollingFrame horizontal) =========
local tabsBar = Instance.new("ScrollingFrame")
tabsBar.Name = "TabsBar"
tabsBar.Size = UDim2.new(1, -24 * SCALE, 0, 38 * SCALE)
tabsBar.Position = UDim2.new(0, 12 * SCALE, 0, 46 * SCALE + 10 * SCALE)
tabsBar.BackgroundTransparency = 1
tabsBar.ScrollBarThickness = 4
tabsBar.HorizontalScrollBarInset = Enum.ScrollBarInset.Always
tabsBar.ScrollingDirection = Enum.ScrollingDirection.X
tabsBar.Parent = frame

local tabsLayout = Instance.new("UIListLayout", tabsBar)
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.Padding = UDim.new(0, 8 * SCALE)
tabsLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local function updateTabsCanvas()
    task.wait()
    local size = tabsLayout.AbsoluteContentSize
    tabsBar.CanvasSize = UDim2.new(0, size.X + 12 * SCALE, 0, size.Y)
end

local function makeTabButton(txt)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(150 * SCALE, 34 * SCALE)
    b.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    b.Text = txt
    b.TextColor3 = Color3.fromRGB(0,0,0)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 16 * SCALE
    b.AutoButtonColor = false
    b.Parent = tabsBar
    local c = Instance.new("UICorner", b)
    c.CornerRadius = UDim.new(0, 8)
    updateTabsCanvas()
    return b
end

local tabMove   = makeTabButton("Movimentação")
local tabTP     = makeTabButton("Teleporte")
local tabMisc   = makeTabButton("Diversos")

-- ========= Páginas (ScrollingFrame vertical) =========
local pagesHolder = Instance.new("Frame")
pagesHolder.Name = "PagesHolder"
pagesHolder.Size = UDim2.new(1, -24 * SCALE, 1, -(46 * SCALE + 10 * SCALE + 38 * SCALE + 12 * SCALE))
pagesHolder.Position = UDim2.new(0, 12 * SCALE, 0, 46 * SCALE + 10 * SCALE + 38 * SCALE + 6 * SCALE)
pagesHolder.BackgroundTransparency = 1
pagesHolder.Parent = frame

local function newPage()
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1, 0, 1, 0)
    p.CanvasSize = UDim2.new(0, 0, 0, 600) -- altura grande para garantir scroll
    p.ScrollBarThickness = 6
    p.BackgroundTransparency = 1
    p.Visible = false
    p.Parent = pagesHolder
    return p
end

local pageMove  = newPage()
local pageTP    = newPage()
local pageMisc  = newPage()

local function colorActive(btn, active)
    if active then
        btn.BackgroundColor3 = Color3.fromRGB(150, 0, 255)
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        btn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
    end
end

local pages = { Move = pageMove, TP = pageTP, Misc = pageMisc }
local function showPage(name)
    for _,p in pairs(pages) do p.Visible = false end
    pages[name].Visible = true
    colorActive(tabMove, name == "Move")
    colorActive(tabTP,   name == "TP")
    colorActive(tabMisc, name == "Misc")
end

tabMove.MouseButton1Click:Connect(function() showPage("Move") end)
tabTP.MouseButton1Click:Connect(function() showPage("TP") end)
tabMisc.MouseButton1Click:Connect(function() showPage("Misc") end)
showPage("Move")

-- ========= Utils =========
local function getHRP()
    local char = player.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function teleportTo(vec3)
    local hrp = getHRP()
    if hrp then hrp.CFrame = CFrame.new(vec3) end
end

-- ########################################################
-- ###################### MOVIMENTAÇÃO #####################
-- ########################################################
do
    local header = Instance.new("TextLabel")
    header.BackgroundTransparency = 1
    header.Text = "Movimentacao"
    header.Font = Enum.Font.GothamBold
    header.TextSize = 18 * SCALE
    header.TextColor3 = Color3.fromRGB(200, 200, 220)
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Size = UDim2.new(1, -10, 0, 24 * SCALE)
    header.Position = UDim2.new(0, 6 * SCALE, 0, 4 * SCALE)
    header.Parent = pageMove

    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, -12 * SCALE, 0, 2)
    sep.Position = UDim2.new(0, 6 * SCALE, 0, 30 * SCALE)
    sep.BackgroundColor3 = Color3.fromRGB(60,60,80)
    sep.Parent = pageMove

    local btnFly = Instance.new("TextButton")
    btnFly.Text = "Fly: OFF"
    btnFly.Size = UDim2.new(0, 120 * SCALE, 0, 34 * SCALE)
    btnFly.Position = UDim2.new(0, 8 * SCALE, 0, 46 * SCALE)
    btnFly.BackgroundColor3 = Color3.fromRGB(255, 249, 74)
    btnFly.TextColor3 = Color3.fromRGB(0, 0, 0)
    btnFly.Font = Enum.Font.GothamBold
    btnFly.TextSize = 16 * SCALE
    btnFly.Parent = pageMove
    Instance.new("UICorner", btnFly).CornerRadius = UDim.new(0, 8)

    local btnUp = Instance.new("TextButton")
    btnUp.Text = "UP"
    btnUp.Size = UDim2.new(0, 80 * SCALE, 0, 34 * SCALE)
    btnUp.Position = UDim2.new(0, 140 * SCALE, 0, 46 * SCALE)
    btnUp.BackgroundColor3 = Color3.fromRGB(79, 255, 152)
    btnUp.TextColor3 = Color3.fromRGB(0, 0, 0)
    btnUp.Font = Enum.Font.GothamBold
    btnUp.TextSize = 16 * SCALE
    btnUp.Parent = pageMove
    Instance.new("UICorner", btnUp).CornerRadius = UDim.new(0, 8)

    local btnDown = Instance.new("TextButton")
    btnDown.Text = "DOWN"
    btnDown.Size = UDim2.new(0, 80 * SCALE, 0, 34 * SCALE)
    btnDown.Position = UDim2.new(0, 230 * SCALE, 0, 46 * SCALE)
    btnDown.BackgroundColor3 = Color3.fromRGB(215, 255, 121)
    btnDown.TextColor3 = Color3.fromRGB(0, 0, 0)
    btnDown.Font = Enum.Font.GothamBold
    btnDown.TextSize = 16 * SCALE
    btnDown.Parent = pageMove
    Instance.new("UICorner", btnDown).CornerRadius = UDim.new(0, 8)

    local btnMinus = Instance.new("TextButton")
    btnMinus.Text = "−"
    btnMinus.Size = UDim2.new(0, 50 * SCALE, 0, 34 * SCALE)
    btnMinus.Position = UDim2.new(0, 320 * SCALE, 0, 46 * SCALE)
    btnMinus.BackgroundColor3 = Color3.fromRGB(123, 255, 247)
    btnMinus.TextColor3 = Color3.fromRGB(0,0,0)
    btnMinus.Font = Enum.Font.GothamBold
    btnMinus.TextSize = 20 * SCALE
    btnMinus.Parent = pageMove
    Instance.new("UICorner", btnMinus).CornerRadius = UDim.new(0, 8)

    local btnPlus = Instance.new("TextButton")
    btnPlus.Text = "+"
    btnPlus.Size = UDim2.new(0, 50 * SCALE, 0, 34 * SCALE)
    btnPlus.Position = UDim2.new(0, 380 * SCALE, 0, 46 * SCALE)
    btnPlus.BackgroundColor3 = Color3.fromRGB(133, 145, 255)
    btnPlus.TextColor3 = Color3.fromRGB(0,0,0)
    btnPlus.Font = Enum.Font.GothamBold
    btnPlus.TextSize = 20 * SCALE
    btnPlus.Parent = pageMove
    Instance.new("UICorner", btnPlus).CornerRadius = UDim.new(0, 8)

    local speedDisp = Instance.new("TextLabel")
    speedDisp.Size = UDim2.new(0, 50 * SCALE, 0, 34 * SCALE)
    speedDisp.Position = UDim2.new(0, 440 * SCALE, 0, 46 * SCALE)
    speedDisp.BackgroundColor3 = Color3.fromRGB(255, 85, 0)
    speedDisp.TextColor3 = Color3.fromRGB(0, 0, 0)
    speedDisp.Text = "1"
    speedDisp.TextScaled = true
    speedDisp.Font = Enum.Font.GothamBold
    speedDisp.Parent = pageMove
    Instance.new("UICorner", speedDisp).CornerRadius = UDim.new(0, 8)

    local speedBtn = Instance.new("TextButton")
    speedBtn.Text = "SPEED: OFF"
    speedBtn.Size = UDim2.new(0, 160 * SCALE, 0, 34 * SCALE)
    speedBtn.Position = UDim2.new(0, 8 * SCALE, 0, 90 * SCALE)
    speedBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    speedBtn.TextColor3 = Color3.fromRGB(255,255,255)
    speedBtn.Font = Enum.Font.GothamBold
    speedBtn.TextSize = 16 * SCALE
    speedBtn.Parent = pageMove
    Instance.new("UICorner", speedBtn).CornerRadius = UDim.new(0, 8)

    local infJumpBtn = Instance.new("TextButton")
    infJumpBtn.Text = "INF JUMP: OFF"
    infJumpBtn.Size = UDim2.new(0, 160 * SCALE, 0, 34 * SCALE)
    infJumpBtn.Position = UDim2.new(0, 180 * SCALE, 0, 90 * SCALE)
    infJumpBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    infJumpBtn.TextColor3 = Color3.fromRGB(255,255,255)
    infJumpBtn.Font = Enum.Font.GothamBold
    infJumpBtn.TextSize = 16 * SCALE
    infJumpBtn.Parent = pageMove
    Instance.new("UICorner", infJumpBtn).CornerRadius = UDim.new(0, 8)

    local flyOn = false
    local speeds = 1
    local cleanupFly = nil
    local upConn, downConn

    local walkEnabled = false
    local walkSpeed = 16
    local infJumpEnabled = false

    -- UP/DOWN
    btnUp.MouseButton1Down:Connect(function()
        if upConn then upConn:Disconnect() end
        upConn = RunService.Heartbeat:Connect(function()
            local hrp = getHRP()
            if hrp then hrp.CFrame = hrp.CFrame * CFrame.new(0, 1, 0) end
        end)
    end)
    btnUp.MouseButton1Up:Connect(function()
        if upConn then upConn:Disconnect(); upConn=nil end
    end)

    btnDown.MouseButton1Down:Connect(function()
        if downConn then downConn:Disconnect() end
        downConn = RunService.Heartbeat:Connect(function()
            local hrp = getHRP()
            if hrp then hrp.CFrame = hrp.CFrame * CFrame.new(0, -1, 0) end
        end)
    end)
    btnDown.MouseButton1Up:Connect(function()
        if downConn then downConn:Disconnect(); downConn=nil end
    end)

    -- Fly V5
    local bgRef, bvRef, ibRef, ieRef, animateRef
    local function startFly()
        if flyOn then return end
        flyOn = true
        btnFly.Text = "Fly: ON"

        local char = player.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        animateRef = char:FindFirstChild("Animate")
        if animateRef then animateRef.Disabled = true end
        hum.PlatformStand = true

        local torso = (hum.RigType == Enum.HumanoidRigType.R6) and (char:FindFirstChild("Torso")) or (char:FindFirstChild("UpperTorso"))
        if not torso then torso = hrp end

        local bg = Instance.new("BodyGyro")
        bg.P = 9e4
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.CFrame = torso.CFrame
        bg.Parent = torso
        bgRef = bg

        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new(0, 0.1, 0)
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = torso
        bvRef = bv

        local ctrl = {f=0,b=0,l=0,r=0,up=0,down=0}
        local function onBegan(input, gp)
            if gp then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local k = input.KeyCode
                if k == Enum.KeyCode.W then ctrl.f = 1 end
                if k == Enum.KeyCode.S then ctrl.b = -1 end
                if k == Enum.KeyCode.A then ctrl.l = -1 end
                if k == Enum.KeyCode.D then ctrl.r = 1 end
                if k == Enum.KeyCode.Space then ctrl.up = 1 end
                if k == Enum.KeyCode.LeftControl or k == Enum.KeyCode.C then ctrl.down = -1 end
            end
        end
        local function onEnded(input, gp)
            if gp then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                local k = input.KeyCode
                if k == Enum.KeyCode.W then ctrl.f = 0 end
                if k == Enum.KeyCode.S then ctrl.b = 0 end
                if k == Enum.KeyCode.A then ctrl.l = 0 end
                if k == Enum.KeyCode.D then ctrl.r = 0 end
                if k == Enum.KeyCode.Space then ctrl.up = 0 end
                if k == Enum.KeyCode.LeftControl or k == Enum.KeyCode.C then ctrl.down = 0 end
            end
        end
        ibRef = UserInputService.InputBegan:Connect(onBegan)
        ieRef = UserInputService.InputEnded:Connect(onEnded)

        local curSpeed = 0
        local maxspeed = 55
        local running = true
        task.spawn(function()
            while running and flyOn and char.Parent do
                RunService.RenderStepped:Wait()

                if (ctrl.l + ctrl.r ~= 0) or (ctrl.f + ctrl.b ~= 0) then
                    curSpeed = curSpeed + 0.6 + (curSpeed / maxspeed)
                    if curSpeed > maxspeed then curSpeed = maxspeed end
                elseif curSpeed ~= 0 then
                    curSpeed = curSpeed - 1
                    if curSpeed < 0 then curSpeed = 0 end
                end

                local cam = workspace.CurrentCamera
                local move = (cam.CFrame:VectorToWorldSpace(Vector3.new(ctrl.r + ctrl.l, 0, ctrl.f + ctrl.b)))
                if move.Magnitude > 0 then move = move.Unit end

                local vertical = (ctrl.up + ctrl.down) * (speeds * 2)
                if move.Magnitude > 0 then
                    bv.Velocity = (cam.CFrame.lookVector * (ctrl.f + ctrl.b) + (cam.CFrame * CFrame.new(ctrl.l + ctrl.r, (ctrl.f + ctrl.b) * .2, 0).p - cam.CFrame.p)) * (curSpeed * (speeds/10))
                    hrp.Velocity = Vector3.new(0, 0, 0)
                else
                    bv.Velocity = Vector3.new(0, vertical, 0)
                end

                bg.CFrame = cam.CFrame * CFrame.Angles(-math.rad((ctrl.f + ctrl.b) * 50 * curSpeed / maxspeed), 0, 0)
            end

            if bg and bg.Parent then bg:Destroy() end
            if bv and bv.Parent then bv:Destroy() end
        end)

        cleanupFly = function()
            running = false
            flyOn = false
            btnFly.Text = "Fly: OFF"
            if ibRef then ibRef:Disconnect(); ibRef=nil end
            if ieRef then ieRef:Disconnect(); ieRef=nil end
            if animateRef then animateRef.Disabled = false end
            if hum and hum.Parent then hum.PlatformStand = false end
            if bgRef and bgRef.Parent then bgRef:Destroy(); bgRef=nil end
            if bvRef and bvRef.Parent then bvRef:Destroy(); bvRef=nil end
        end
    end

    local function stopFly()
        if cleanupFly then cleanupFly() end
    end

    btnFly.MouseButton1Click:Connect(function()
        if flyOn then stopFly() else startFly() end
    end)

    btnPlus.MouseButton1Click:Connect(function()
        speeds = math.clamp(speeds + 1, 1, 200)
        speedDisp.Text = tostring(speeds)
    end)
    btnMinus.MouseButton1Click:Connect(function()
        speeds = math.clamp(speeds - 1, 1, 200)
        speedDisp.Text = tostring(speeds)
    end)

    player.CharacterAdded:Connect(function()
        stopFly()
    end)

    -- Speed (WalkSpeed)
    speedBtn.MouseButton1Click:Connect(function()
        walkEnabled = not walkEnabled
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if walkEnabled then
            walkSpeed = 50
            if hum then hum.WalkSpeed = walkSpeed end
            speedBtn.BackgroundColor3 = Color3.fromRGB(0,200,0)
            speedBtn.Text = "SPEED: ON ("..walkSpeed..")"
        else
            if hum then hum.WalkSpeed = 16 end
            speedBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
            speedBtn.Text = "SPEED: OFF"
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if walkEnabled then
            if input.KeyCode == Enum.KeyCode.Equals then
                walkSpeed = walkSpeed + 5
            elseif input.KeyCode == Enum.KeyCode.Minus then
                walkSpeed = math.max(16, walkSpeed - 5)
            else
                return
            end
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = walkSpeed end
            speedBtn.Text = "SPEED: ON ("..walkSpeed..")"
        end
    end)

    RunService.Heartbeat:Connect(function()
        if walkEnabled then
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= walkSpeed then
                hum.WalkSpeed = walkSpeed
            end
        end
    end)

    -- Infinite Jump
    infJumpBtn.MouseButton1Click:Connect(function()
        infJumpEnabled = not infJumpEnabled
        infJumpBtn.BackgroundColor3 = infJumpEnabled and Color3.fromRGB(0,200,0) or Color3.fromRGB(150,0,0)
        infJumpBtn.Text = infJumpEnabled and "INF JUMP: ON" or "INF JUMP: OFF"
    end)

    UserInputService.JumpRequest:Connect(function()
        if infJumpEnabled then
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end
    end)
end

-- ########################################################
-- ######################## TELEPORTE ######################
-- ########################################################
do
    local header = Instance.new("TextLabel")
    header.BackgroundTransparency = 1
    header.Text = "Teleporte"
    header.Font = Enum.Font.GothamBold
    header.TextSize = 18 * SCALE
    header.TextColor3 = Color3.fromRGB(200, 200, 220)
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Size = UDim2.new(1, -10, 0, 24 * SCALE)
    header.Position = UDim2.new(0, 6 * SCALE, 0, 4 * SCALE)
    header.Parent = pageTP

    local sep = Instance.new("Frame")
    sep.Size = UDim2.new(1, -12 * SCALE, 0, 2)
    sep.Position = UDim2.new(0, 6 * SCALE, 0, 30 * SCALE)
    sep.BackgroundColor3 = Color3.fromRGB(60,60,80)
    sep.Parent = pageTP

    local coordLabel = Instance.new("TextLabel")
    coordLabel.Size = UDim2.new(1, -12 * SCALE, 0, 24 * SCALE)
    coordLabel.Position = UDim2.new(0, 6 * SCALE, 0, 40 * SCALE)
    coordLabel.BackgroundTransparency = 1
    coordLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    coordLabel.TextXAlignment = Enum.TextXAlignment.Left
    coordLabel.Font = Enum.Font.Gotham
    coordLabel.TextSize = 14 * SCALE
    coordLabel.Text = "X: 0 | Y: 0 | Z: 0"
    coordLabel.Parent = pageTP

    task.spawn(function()
        while true do
            local hrp = getHRP()
            if hrp then
                local p = hrp.Position
                coordLabel.Text = string.format("X: %.2f  |  Y: %.2f  |  Z: %.2f", p.X, p.Y, p.Z)
            end
            task.wait(0.05)
        end
    end)

    local inputX = Instance.new("TextBox")
    inputX.PlaceholderText = "X"
    inputX.Size = UDim2.new(0, 150 * SCALE, 0, 30 * SCALE)
    inputX.Position = UDim2.new(0, 8 * SCALE, 0, 72 * SCALE)
    inputX.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    inputX.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputX.Font = Enum.Font.Gotham
    inputX.TextSize = 14 * SCALE
    inputX.Parent = pageTP
    Instance.new("UICorner", inputX).CornerRadius = UDim.new(0, 8)

    local inputY = inputX:Clone()
    inputY.PlaceholderText = "Y"
    inputY.Position = UDim2.new(0, 168 * SCALE, 0, 72 * SCALE)
    inputY.Parent = pageTP

    local inputZ = inputX:Clone()
    inputZ.PlaceholderText = "Z"
    inputZ.Position = UDim2.new(0, 328 * SCALE, 0, 72 * SCALE)
    inputZ.Parent = pageTP

    local tpButton = Instance.new("TextButton")
    tpButton.Text = "TELEPORTAR"
    tpButton.Size = UDim2.new(0, 470 * SCALE, 0, 34 * SCALE)
    tpButton.Position = UDim2.new(0, 8 * SCALE, 0, 112 * SCALE)
    tpButton.BackgroundColor3 = Color3.fromRGB(60, 60, 180)
    tpButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    tpButton.Font = Enum.Font.GothamBold
    tpButton.TextSize = 16 * SCALE
    tpButton.Parent = pageTP
    Instance.new("UICorner", tpButton).CornerRadius = UDim.new(0, 8)

    tpButton.MouseButton1Click:Connect(function()
        local x = tonumber(inputX.Text)
        local y = tonumber(inputY.Text)
        local z = tonumber(inputZ.Text)
        if x and y and z then
            teleportTo(Vector3.new(x, y, z))
        else
            tpButton.Text = "COORD INVÁLIDA!"
            task.delay(0.8, function()
                tpButton.Text = "TELEPORTAR"
            end)
        end
    end)

    local presetsTitle = Instance.new("TextLabel")
    presetsTitle.Size = UDim2.new(1, -12 * SCALE, 0, 22 * SCALE)
    presetsTitle.Position = UDim2.new(0, 6 * SCALE, 0, 154 * SCALE)
    presetsTitle.BackgroundTransparency = 1
    presetsTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
    presetsTitle.TextXAlignment = Enum.TextXAlignment.Left
    presetsTitle.Font = Enum.Font.GothamBold
    presetsTitle.TextSize = 16 * SCALE
    presetsTitle.Text = "Presets"
    presetsTitle.Parent = pageTP

    local function makePreset(txt, x, y, color, vec)
        local b = Instance.new("TextButton")
        b.Text = txt
        b.Size = UDim2.new(0, 150 * SCALE, 0, 34 * SCALE)
        b.Position = UDim2.new(0, x * SCALE, 0, y * SCALE)
        b.BackgroundColor3 = color
        b.TextColor3 = Color3.fromRGB(255,255,255)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 16 * SCALE
        b.Parent = pageTP
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        b.MouseButton1Click:Connect(function()
            teleportTo(vec)
        end)
    end

    -- linha 1
    makePreset("SnowHide",      8,   184, Color3.fromRGB(100, 50, 180), Vector3.new(952.79, -14.86, -485.84))
    makePreset("Karnak",        178, 184, Color3.fromRGB(180, 120, 60), Vector3.new(-3000.62, 224.26, -1336.11))
    makePreset("Catacumba",     348, 184, Color3.fromRGB(180, 40, 40), Vector3.new(1415.66, -245.12, -3618.99))

    -- linha 2
    makePreset("DG Lendaria",   8,   224, Color3.fromRGB(100, 40, 200), Vector3.new(2304.44, -26.19, -2884.72))
    makePreset("DG Unica",      178, 224, Color3.fromRGB(50, 180, 140), Vector3.new(1886.06, 14.03, -3712.80))
    makePreset("Piramide",      348, 224, Color3.fromRGB(180, 100, 40), Vector3.new(12079.64, 48.27, -1020.79))

    -- linha 3
    makePreset("Baium",         8,   264, Color3.fromRGB(255, 0, 0), Vector3.new(1040.37, -250.56, -5337.07))
    -- linha 4 (adicionado)
makePreset("Tarantox",      178, 264, Color3.fromRGB(120, 200, 40), Vector3.new(3197.20, 69.14, -896.13))
end

-- ########################################################
-- ######################## DIVERSOS #######################
-- ########################################################
do
    local eventsFolder = ReplicatedStorage:WaitForChild("Events")
    local questFolder = eventsFolder:WaitForChild("Quest")
    local GrantQuest = questFolder:WaitForChild("GrantQuest")
    local UpdateQuest = questFolder:WaitForChild("UpdateQuest")

    local autoHeader = Instance.new("TextLabel")
    autoHeader.BackgroundTransparency = 1
    autoHeader.Text = "AutoQuestBOX"
    autoHeader.Font = Enum.Font.GothamBold
    autoHeader.TextSize = 16 * SCALE
    autoHeader.TextColor3 = Color3.fromRGB(200, 200, 220)
    autoHeader.TextXAlignment = Enum.TextXAlignment.Left
    autoHeader.Size = UDim2.new(1, -12 * SCALE, 0, 20 * SCALE)
    autoHeader.Position = UDim2.new(0, 6 * SCALE, 0, 70 * SCALE)
    autoHeader.Parent = pageMisc

    local autoBtn = Instance.new("TextButton")
    autoBtn.Text = "AutoQuestBOX: OFF"
    autoBtn.Size = UDim2.new(0, 200 * SCALE, 0, 30 * SCALE)
    autoBtn.Position = UDim2.new(0, 6 * SCALE, 0, 100 * SCALE)
    autoBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    autoBtn.TextColor3 = Color3.fromRGB(255,255,255)
    autoBtn.Font = Enum.Font.GothamBold
    autoBtn.TextSize = 14 * SCALE
    autoBtn.Parent = pageMisc
    Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0, 6)

    local stopBtn = Instance.new("TextButton")
    stopBtn.Text = "STOP"
    stopBtn.Size = UDim2.new(0, 80 * SCALE, 0, 30 * SCALE)
    stopBtn.Position = UDim2.new(0, 216 * SCALE, 0, 100 * SCALE)
    stopBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    stopBtn.TextColor3 = Color3.fromRGB(255,255,255)
    stopBtn.Font = Enum.Font.GothamBold
    stopBtn.TextSize = 14 * SCALE
    stopBtn.Parent = pageMisc
    Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 6)

    local logFrame = Instance.new("Frame")
    logFrame.Size = UDim2.new(1, -12 * SCALE, 0, 140 * SCALE)
    logFrame.Position = UDim2.new(0, 6 * SCALE, 0, 140 * SCALE)
    logFrame.BackgroundColor3 = Color3.fromRGB(18,18,24)
    logFrame.BorderSizePixel = 0
    logFrame.Parent = pageMisc
    Instance.new("UICorner", logFrame).CornerRadius = UDim.new(0,6)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -12 * SCALE, 1, -12 * SCALE)
    scroll.Position = UDim2.new(0, 6 * SCALE, 0, 6 * SCALE)
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.BackgroundTransparency = 1
    scroll.Parent = logFrame
    scroll.ScrollBarThickness = 6

    local uiList = Instance.new("UIListLayout", scroll)
    uiList.Padding = UDim.new(0,4)
    uiList.HorizontalAlignment = Enum.HorizontalAlignment.Left

    local function updateLogCanvas()
        task.wait()
        local contentY = uiList.AbsoluteContentSize.Y
        scroll.CanvasSize = UDim2.new(0,0,0,contentY + 8)
        scroll.CanvasPosition = Vector2.new(0, math.max(0, contentY - scroll.AbsoluteSize.Y))
    end

    local function appendLog(text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -8 * SCALE, 0, 18 * SCALE)
        lbl.BackgroundTransparency = 1
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14 * SCALE
        lbl.TextColor3 = Color3.fromRGB(220,220,220)
        lbl.Text = ("[%s] %s"):format(os.date("%H:%M:%S"), text)
        lbl.Parent = scroll
        updateLogCanvas()
    end

    local function gettheretardedquest(QuestFn, TpPositionfq)
        local args = {QuestFn}

        local ok1, err1 = pcall(function()
            GrantQuest:FireServer(unpack(args))
        end)
        if ok1 then appendLog("GrantQuest enviado: " .. QuestFn)
        else appendLog("ERRO GrantQuest: " .. tostring(err1)) end

        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local ok2, err2 = pcall(function()
                hrp.CFrame = CFrame.new(TpPositionfq)
            end)
            if ok2 then
                appendLog(("Teleport para (%.1f, %.1f, %.1f)"):format(TpPositionfq.X, TpPositionfq.Y, TpPositionfq.Z))
            else
                appendLog("ERRO teleport: " .. tostring(err2))
            end
        end

        task.wait(0.08)

        local ok3, err3 = pcall(function()
            UpdateQuest:FireServer(unpack(args))
        end)
        if ok3 then appendLog("UpdateQuest enviado: " .. QuestFn)
        else appendLog("ERRO UpdateQuest: " .. tostring(err3)) end
    end

    local steps = {
        { "StonesOfBurden", Vector3.new(1215, -168, 259) },
        { "StonesOfBurden", Vector3.new(1220, -154, 200) },
        { "StonesOfBurden", Vector3.new(1771, -242, 1206) },
    }

    local running = false
    local loopThread = nil

    local function startAuto()
        if running then return end
        running = true

        autoBtn.Text = "AutoQuestBOX: ON"
        autoBtn.BackgroundColor3 = Color3.fromRGB(0,200,0)
        appendLog("AutoQuestBOX iniciado")

        loopThread = task.spawn(function()
            while running do
                for _, st in ipairs(steps) do
                    if not running then break end
                    gettheretardedquest(st[1], st[2])
                end
                task.wait()
            end
        end)
    end

    local function stopAuto()
        if not running then return end
        running = false
        autoBtn.Text = "AutoQuestBOX: OFF"
        autoBtn.BackgroundColor3 = Color3.fromRGB(150,0,0)
        appendLog("AutoQuestBOX parado")
        loopThread = nil
    end

    autoBtn.MouseButton1Click:Connect(function()
        if running then stopAuto() else startAuto() end
    end)
    stopBtn.MouseButton1Click:Connect(function()
        stopAuto()
    end)

    appendLog("AutoQuestBOX carregado — pronto para iniciar.")
end
