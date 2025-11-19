local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local plr = Players.LocalPlayer

local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

local TWEEN_TIME = 0.5
local LOOP_COUNT = 7

RunService.Stepped:Connect(function()
    if noclipEnabled then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

local function MoveToPart(part)
    local startPos = hrp.CFrame
    local endPos = part.CFrame + Vector3.new(0, 2, 0)
    local distance = (startPos.Position - endPos.Position).Magnitude
    local steps = math.ceil(distance / 10)
    
    for i = 1, steps do
        local alpha = i / steps
        hrp.CFrame = startPos:Lerp(endPos, alpha)
        task.wait(0.1)
    end
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
end

local Window = Rayfield:CreateWindow({
   Name = "Chainsawman",
   Icon = "mouse-pointer-2",
   LoadingTitle = "Rayfield Interface Suite",
   LoadingSubtitle = "by OmerByG",
   ShowText = "Rayfield",
   Theme = "Default",
   ToggleUIKeybind = "K",
   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false,
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "Big Hub"
   },
})

local mainTab = Window:CreateTab("Main", "app-window")

local autoFarmButton = mainTab:CreateButton({
   Name = "AutoFarm",
   Callback = function()
      local DumpstersFolder = workspace.Interactable.dumpsters

      local function GetClosestEnabledPrompt()
         local closestPrompt = nil
         local closestDistance = math.huge

         for _, model in ipairs(DumpstersFolder:GetChildren()) do
            if model:IsA("Model") then
               local part = model:FindFirstChild("Part")
               if part then
                  local prompt = part:FindFirstChildOfClass("ProximityPrompt")
                  if prompt and prompt.Enabled == true then
                     local distance = (hrp.Position + part.Position).Magnitude
                     if distance < closestDistance then
                        closestDistance = distance
                        closestPrompt = prompt
                     end
                  end
               end
            end
         end

         return closestPrompt
      end

      for i = 1, LOOP_COUNT do
         local prompt = GetClosestEnabledPrompt()
         if not prompt then
            break
         end

         local targetPart = prompt.Parent

         MoveToPart(targetPart)

         local duration = 1
         local elapsed = 0
         while elapsed < duration do
            fireproximityprompt(prompt)
            task.wait(0.1)
            elapsed = elapsed + 0.1
         end
         
         task.wait(1)
         prompt.Enabled = false
      end
      MoveToPart(workspace.DialogNPCs["Homeless joe"].HumanoidRootPart)
   end
})

local espTab = Window:CreateTab("ESP", "eye")

local devilHeartESPConnection
local playerESPConnection
local tracersConnection

local playerESPToggle

local function createNameLabel(parent, name)
    local old = parent:FindFirstChild("ESPNameLabel")
    if old then old:Destroy() end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPNameLabel"
    billboard.Adornee = parent
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = parent

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.Text = name
    text.TextColor3 = Color3.new(1,1,1)
    text.TextStrokeTransparency = 0
    text.TextSize = 14
    text.Font = Enum.Font.GothamBold
    text.Parent = billboard
end

local function applyPlayerESP(player, character)
    if not playerESPToggle.CurrentValue then return end
    if not character then return end
    
    if not character:FindFirstChild("PlayerESP_Highlight") then
        local h = Instance.new("Highlight")
        h.Name = "PlayerESP_Highlight"
        h.FillColor = Color3.fromRGB(0,255,0)
        h.OutlineColor = Color3.new(1,1,1)
        h.FillTransparency = 0.5
        h.OutlineTransparency = 0
        h.Parent = character
    end

    local hrpTarget = character:FindFirstChild("HumanoidRootPart")
    if hrpTarget then
        createNameLabel(hrpTarget, player.Name)
    end
end

playerESPToggle = espTab:CreateToggle({
    Name = "Player ESP",
    CurrentValue = false,
    Flag = "Toggle1",
    Callback = function(State)
        if State then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= plr then
                    if p.Character then
                        applyPlayerESP(p, p.Character)
                    end
                    p.CharacterAdded:Connect(function(char)
                        task.wait(0.2)
                        applyPlayerESP(p, char)
                    end)
                end
            end

            playerESPConnection = Players.PlayerAdded:Connect(function(p)
                p.CharacterAdded:Connect(function(char)
                    task.wait(0.2)
                    applyPlayerESP(p, char)
                end)
            end)

        else
            if playerESPConnection then playerESPConnection:Disconnect() end

            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    local h = p.Character:FindFirstChild("PlayerESP_Highlight")
                    if h then h:Destroy() end

                    local hrpTarget = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrpTarget then
                        local label = hrpTarget:FindFirstChild("ESPNameLabel")
                        if label then label:Destroy() end
                    end
                end
            end
        end
    end
})

local function applyHeartESP(heart)
    if not heart:IsA("BasePart") then return end

    if not heart:FindFirstChild("ESP_Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.new(1,1,1)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.Parent = heart
    end

    createNameLabel(heart, "Devil's Heart")
end

local function findHeart()
    return workspace:FindFirstChild("Devil's Heart", true)
end

local devilHeartESPToggle = espTab:CreateToggle({
    Name = "Devil Heart ESP",
    CurrentValue = false,
    Flag = "Toggle2",
    Callback = function(State)
        if State then
            local h = findHeart()
            if h then applyHeartESP(h) end

            devilHeartESPConnection = workspace.DescendantAdded:Connect(function(obj)
                if obj.Name == "Devil's Heart" then
                    task.wait(0.1)
                    applyHeartESP(obj)
                end
            end)

        else
            if devilHeartESPConnection then devilHeartESPConnection:Disconnect() end

            local h = findHeart()
            if h then
                local hl = h:FindFirstChild("ESP_Highlight")
                if hl then hl:Destroy() end

                local lbl = h:FindFirstChild("ESPNameLabel")
                if lbl then lbl:Destroy() end
            end
        end
    end
})

local tracersToggle = espTab:CreateToggle({
    Name = "Tracers",
    CurrentValue = false,
    Flag = "Toggle3",
    Callback = function(Value)
        if Value then
            tracersConnection = RunService.RenderStepped:Connect(function()
                if playerESPToggle.CurrentValue then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= plr and player.Character then
                            local character = player.Character
                            local hrpTarget = character:FindFirstChild("HumanoidRootPart")
                            if hrpTarget then
                                local beam = hrpTarget:FindFirstChild("TracerBeam")
                                if not beam then
                                    local attachment0 = Instance.new("Attachment")
                                    attachment0.Parent = hrp
                                    
                                    local attachment1 = Instance.new("Attachment")
                                    attachment1.Parent = hrpTarget
                                    
                                    beam = Instance.new("Beam")
                                    beam.Name = "TracerBeam"
                                    beam.Attachment0 = attachment0
                                    beam.Attachment1 = attachment1
                                    beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
                                    beam.FaceCamera = true
                                    beam.Width0 = 0.1
                                    beam.Width1 = 0.1
                                    beam.Parent = hrpTarget
                                end
                            end
                        end
                    end
                end
                
                if devilHeartESPToggle.CurrentValue then
                    local heart = findHeart()
                    if heart then
                        local beam = heart:FindFirstChild("TracerBeamHeart")
                        if not beam then
                            local attachment0 = Instance.new("Attachment")
                            attachment0.Parent = hrp
                            
                            local attachment1 = Instance.new("Attachment")
                            attachment1.Parent = heart
                            
                            beam = Instance.new("Beam")
                            beam.Name = "TracerBeamHeart"
                            beam.Attachment0 = attachment0
                            beam.Attachment1 = attachment1
                            beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
                            beam.FaceCamera = true
                            beam.Width0 = 0.1
                            beam.Width1 = 0.1
                            beam.Parent = heart
                        end
                    end
                end
            end)
        else
            if tracersConnection then
                tracersConnection:Disconnect()
            end
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    local hrpTarget = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrpTarget then
                        local beam = hrpTarget:FindFirstChild("TracerBeam")
                        if beam then
                            beam:Destroy()
                            for _, attachment in pairs(hrpTarget:GetChildren()) do
                                if attachment:IsA("Attachment") then
                                    attachment:Destroy()
                                end
                            end
                        end
                    end
                end
            end
            
            local heart = findHeart()
            if heart then
                local beam = heart:FindFirstChild("TracerBeamHeart")
                if beam then
                    beam:Destroy()
                    for _, attachment in pairs(heart:GetChildren()) do
                        if attachment:IsA("Attachment") then
                            attachment:Destroy()
                        end
                    end
                end
            end
        end
    end,
})
