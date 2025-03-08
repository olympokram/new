local cloneref = cloneref or function(x)
	return x;
end;
local Library = {RainbowColorValue=0,HueSelectionPosition=0,Connections={},AnimateText=false,Debug=true,MobileButton=false};
local InputService = cloneref(game:GetService("UserInputService"));
local TextService = cloneref(game:GetService("TextService"));
local CoreGui = cloneref(game:GetService("CoreGui"));
local Teams = cloneref(game:GetService("Teams"));
local Players = cloneref(game:GetService("Players"));
local RunService = cloneref(game:GetService("RunService"));
local TweenService = cloneref(game:GetService("TweenService"));
local RenderStepped = RunService.RenderStepped;
local LocalPlayer = Players.LocalPlayer;
local Mouse = LocalPlayer:GetMouse();
local ThemeColor, GameID, LibraryBind = Color3.fromRGB(255, 0, 0), game.GameId, Enum.KeyCode.LeftControl;
local getgenv = getgenv or function()
	return {};
end;
if (Destruct and Destruct.Unload) then
	Destruct:Unload();
end
getgenv().Destruct = {};
local Toggles, Options = {}, {};
getgenv().Toggles = Toggles;
getgenv().Options = Options;
local ScreenGui = Instance.new("ScreenGui", CoreGui);
ScreenGui.Name = "Horizon";
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
task.spawn(function()
	while ScreenGui.Parent do
		Library.RainbowColorValue = Library.RainbowColorValue + (1 / 255);
		Library.HueSelectionPosition = Library.HueSelectionPosition + 1;
		if (Library.RainbowColorValue >= 1) then
			Library.RainbowColorValue = 0;
		end
		if (Library.HueSelectionPosition == 80) then
			Library.HueSelectionPosition = 0;
		end
		task.wait();
	end
end);
local function AnimateText(display, text, repeatCount, delay)
	if not display then
		return;
	end
	local animatedRandom = "1234567890";
	for i = 1, #text do
		local revealChar = text:sub(i, i);
		local displayText = text:sub(1, i - 1);
		for _ = 1, math.random(1, 6) do
			local random = math.random(1, #animatedRandom);
			local randomChar = animatedRandom:sub(random, random);
			display.Text = displayText .. randomChar;
			task.wait(delay);
			if Library.AnimateText then
				break;
			end
		end
		display.Text = displayText .. revealChar;
		task.wait(delay);
		if Library.AnimateText then
			break;
		end
	end
	task.wait(5);
end
local blacklistedKeybinds = {Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Up,Enum.KeyCode.Left,Enum.KeyCode.Down,Enum.KeyCode.Right,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Backspace,Enum.KeyCode.Escape};
Library.BlacklistKeybinds = function(self, keybinds)
	if (type(keybinds) ~= "table") then
		return warn("Invalid Argument");
	end
	for _, key in next, keybinds do
		if (typeof(key) == "EnumItem") then
			table.insert(blacklistedKeybinds, key);
		end
	end
end;
local function CheckDevice()
	if (InputService.KeyboardEnabled and not InputService.TouchEnabled) then
		return "PC";
	elseif (InputService.TouchEnabled and not InputService.KeyboardEnabled) then
		return "Mobile";
	elseif (InputService.KeyboardEnabled and InputService.TouchEnabled) then
		return "Emulator";
	elseif (InputService.GamepadEnabled and not InputService.TouchEnabled) then
		return "Console";
	end
	return "Unknow Device";
end
Library.Unload = function(self)
	if ScreenGui then
		ScreenGui:Destroy();
	end
	for i, v in next, Library.Connections do
		v:Disconnect();
		Library.Connections[i] = nil;
	end
	getgenv().Destruct = nil;
end;
Destruct.Unload = function(self)
	if ScreenGui:FindFirstChild("UI") then
		ScreenGui['UI']:Destroy();
	end
	if ScreenGui then
		ScreenGui:Destroy();
	end
	for i, v in next, Library.Connections do
		v:Disconnect();
		Library.Connections[i] = nil;
	end
	getgenv().Destruct = nil;
end;
Library.MakeDraggable = function(self, topbarobject, object)
	local Dragging = nil;
	local DragInput = nil;
	local DragStart = nil;
	local StartPosition = nil;
	local function Update(input)
		local Delta = input.Position - DragStart;
		local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y);
		object.Position = pos;
	end
	Library.Connections[#Library.Connections + 1] = topbarobject.InputBegan:Connect(function(input)
		if ((input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch)) then
			Dragging = true;
			DragStart = input.Position;
			StartPosition = object.Position;
			Library.Connections[#Library.Connections + 1] = input.Changed:Connect(function()
				if (input.UserInputState == Enum.UserInputState.End) then
					Dragging = false;
				end
			end);
		end
	end);
	Library.Connections[#Library.Connections + 1] = topbarobject.InputChanged:Connect(function(input)
		if ((input.UserInputType == Enum.UserInputType.MouseMovement) or (input.UserInputType == Enum.UserInputType.Touch)) then
			DragInput = input;
		end
	end);
	Library.Connections[#Library.Connections + 1] = InputService.InputChanged:Connect(function(input)
		if ((input == DragInput) and Dragging) then
			Update(input);
		end
	end);
end;
local function GetPlayersString()
	local PlayerList = Players:GetPlayers();
	for i = 1, #PlayerList do
		PlayerList[i] = PlayerList[i].Name;
	end
	table.sort(PlayerList, function(str1, str2)
		return str1 < str2;
	end);
	return PlayerList;
end
local function GetTeamsString()
	local TeamList = Teams:GetTeams();
	for i = 1, #TeamList do
		TeamList[i] = TeamList[i].Name;
	end
	table.sort(TeamList, function(str1, str2)
		return str1 < str2;
	end);
	return TeamList;
end
local notifications = {};
Library.Notify = function(self, text, delay, size)
	local Delay = delay or 5;
	local ScreenGui = Instance.new("ScreenGui", CoreGui);
	local MainFrame = Instance.new("Frame", ScreenGui);
	ScreenGui.Name = "2X";
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
	MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
	MainFrame.BorderColor3 = Color3.fromRGB(70, 70, 70);
	MainFrame.BorderSizePixel = 1.2;
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5);
	MainFrame.BackgroundTransparency = 0.25;
	MainFrame.Position = UDim2.new(0.5, 0, 0.5, -325);
	MainFrame.Size = size or UDim2.fromOffset(350, 40);
	local UICorner = Instance.new("UICorner", MainFrame);
	UICorner.CornerRadius = UDim.new(0.5, 0);
	local MainLabel = Instance.new("TextLabel", MainFrame);
	MainLabel.Font = Enum.Font.GothamBlack;
	MainLabel.Text = text or "Fail";
	MainLabel.AnchorPoint = Vector2.new(0.5, 0.5);
	MainLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
	MainLabel.Position = UDim2.new(0.5, 0, 0.5, 0);
	MainLabel.Size = size or UDim2.new(0, 350, 0, 40);
	MainLabel.BackgroundTransparency = 1;
	MainLabel.TextSize = 18;
	MainLabel.TextXAlignment = Enum.TextXAlignment.Center;
	MainLabel.TextYAlignment = Enum.TextYAlignment.Center;
	local ws = cloneref(game:GetService("Workspace"));
	local StartPositionY = 0.2;
	local Spacing = 45;
	table.insert(notifications, ScreenGui);
	local NewY = StartPositionY + ((#notifications * Spacing) / ws.CurrentCamera.ViewportSize.Y);
	MainFrame.Position = UDim2.new(0.5, 0, NewY, 0);
	task.delay(Delay, function()
		for i, v in next, notifications do
			if (v == ScreenGui) then
				table.remove(notifications, i);
				break;
			end
		end
		ScreenGui:Destroy();
	end);
end;
Library.CreateLabel = function(self, label)
	assert(label.Text, "Missing text");
	assert(label.Title, "Missing title");
	local ScreenGui = Instance.new("ScreenGui", CoreGui);
	local MainFrame = Instance.new("Frame", ScreenGui);
	MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0);
	MainFrame.BorderColor3 = Color3.fromRGB(70, 70, 70);
	MainFrame.BorderSizePixel = 1.2;
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5);
	MainFrame.BackgroundTransparency = 0.25;
	MainFrame.Position = UDim2.new(0.4, 0, 0.45, 0);
	MainFrame.Size = UDim2.new(0.1, label.widthx or 0, 0.1, label.widthx or 0);
	local UICorner = Instance.new("UICorner", MainFrame);
	UICorner.CornerRadius = UDim.new(0.1, 0);
	local TitleLabel = Instance.new("TextLabel", MainFrame);
	TitleLabel.Font = Enum.Font.GothamBlack;
	TitleLabel.Text = label.Title;
	TitleLabel.AnchorPoint = Vector2.new(0.5, 0.5);
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
	TitleLabel.Position = UDim2.new(0.5, 0, 0.5, -35);
	TitleLabel.Size = UDim2.new(1, label.widthx or 0, 0, label.widthy or -20);
	TitleLabel.BackgroundTransparency = 1;
	TitleLabel.TextSize = 18;
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Center;
	local MainLabel = Instance.new("TextLabel", MainFrame);
	MainLabel.Font = Enum.Font.GothamBlack;
	MainLabel.Text = label.Text;
	MainLabel.AnchorPoint = Vector2.new(0.5, 0.5);
	MainLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
	MainLabel.Position = UDim2.new(0.5, 0, 0.5, 10);
	MainLabel.Size = UDim2.new(1, label.widthx or 0, 1, label.widthy or -20);
	MainLabel.BackgroundTransparency = 1;
	MainLabel.TextSize = 18;
	MainLabel.TextXAlignment = Enum.TextXAlignment.Left;
	MainLabel.TextYAlignment = Enum.TextYAlignment.Top;
	return MainLabel, MainFrame;
end;
Library.SafeCallback = function(self, f, ...)
	if not f then
		return;
	end
	if not Library.Debug then
		return f(...);
	end
	local success, event = pcall(f, ...);
	if not success then
		local _, i = event:find(":%d+:");
		if not i then
			return Library:Notify(event, 3, nil);
		end
		return Library:Notify(event:sub(i + 1), 3, nil);
	end
end;
Library.AttemptSave = function(self)
	if Library.SaveManager then
		Library.SaveManager:Save();
	end
end;
Library.Create = function(self, Class, Properties)
	local _Instance = Class;
	if (type(Class) == "string") then
		_Instance = Instance.new(Class);
	end
	for Property, Value in next, Properties do
		_Instance[Property] = Value;
	end
	return _Instance;
end;
local BaseAddons = {};
Library.ChangeBind = function(self, key)
	LibraryBind = key;
end;
Library.Window = function(self, title, version, info, preset, closebind)
	LibraryBind = closebind or Enum.KeyCode.LeftShift;
	ThemeColor = preset or Color3.fromRGB(255, 0, 0);
	fs = false;
	local Main = Instance.new("Frame");
	local TabHold = Instance.new("Frame");
	local TabHoldLayout = Instance.new("UIListLayout");
	local Title = Instance.new("TextLabel");
	local TabFolder = Instance.new("Folder");
	local DragFrame = Instance.new("Frame");
	local close = Instance.new("ImageButton");
	Main.Name = "Main";
	Main.Parent = ScreenGui;
	Main.AnchorPoint = Vector2.new(0.5, 0.5);
	Main.BackgroundColor3 = Color3.fromRGB(1, 1, 1);
	Main.BorderSizePixel = 0;
	Main.Position = UDim2.new(0.5, 0, 0.5, 0);
	Main.Size = UDim2.new(0, 560, 0, 319);
	Main.ClipsDescendants = false;
	Main.Visible = true;
	Library:Create("UICorner", {CornerRadius=UDim.new(0.1, 0),Parent=Main});
	local background = Instance.new("ImageLabel", Main);
	background.Name = "Background";
	background.Image = "rbxassetid://128314866000502";
	background.AnchorPoint = Vector2.new(0.5, 0.5);
	background.Position = UDim2.new(Main.Position.X, Main.Position.Y);
	background.Size = UDim2.new(0, Main.AbsoluteSize.X, 0, Main.AbsoluteSize.Y);
	background.ImageTransparency = 0.5;
	background.BackgroundTransparency = 1;
	background.ZIndex = 1;
	Library:Create("UICorner", {CornerRadius=UDim.new(0.1, 0),Parent=background});
	Library.ChangeBackground = function(self, id)
		background.Image = "rbxassetid://" .. tostring(id);
	end;
	Library.RemoveBackground = function(self)
		background.Image = "";
	end;
	local FadeBackgroundFrame = Instance.new("Frame");
	FadeBackgroundFrame.Name = "FadeBackgroundFrame";
	FadeBackgroundFrame.Parent = Main;
	FadeBackgroundFrame.BackgroundColor3 = Color3.fromRGB(27, 27, 27);
	FadeBackgroundFrame.BackgroundTransparency = 1;
	FadeBackgroundFrame.BorderSizePixel = 0;
	FadeBackgroundFrame.Size = UDim2.new(1, 0, 1, 0);
	FadeBackgroundFrame.ZIndex = 3;
	close.Name = "close";
	close.Parent = Main;
	close.BackgroundTransparency = 1;
	close.Position = UDim2.new(0.94, 4, 0, 8.5);
	close.Size = UDim2.new(0, 21, 0, 21);
	close.ZIndex = 2;
	close.Image = "rbxassetid://3926305904";
	close.ImageRectOffset = Vector2.new(284, 4);
	close.ImageRectSize = Vector2.new(24, 24);
	Library.Connections[#Library.Connections + 1] = close.MouseButton1Click:Connect(function()
		Main.Visible = false;
	end);
	TabHold.Name = "TabHold";
	TabHold.Parent = Main;
	TabHold.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	TabHold.BackgroundTransparency = 1;
	TabHold.Position = UDim2.new(0.0339285731, 0, 0.147335425, 0);
	TabHold.Size = UDim2.new(0, 107, 0, 254);
	TabHoldLayout.Name = "TabHoldLayout";
	TabHoldLayout.Parent = TabHold;
	TabHoldLayout.SortOrder = Enum.SortOrder.LayoutOrder;
	TabHoldLayout.Padding = UDim.new(0, 11);
	Title.Name = "Title";
	Title.Parent = Main;
	Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	Title.BackgroundTransparency = 1;
	Title.Position = UDim2.new(0.0339285731, 0, 0.0274263314, -5);
	Title.Size = UDim2.new(0, 200, 0, 23);
	Title.Font = Enum.Font.GothamBlack;
	Title.Text = title or "Unknown Title";
	local Version = version or "Unknown Version";
	local Information = info or "No Information";
	local textDisplays = {title,Version,Information};
	task.spawn(function()
		while ScreenGui.Parent do
			local repeatCount = 10;
			local delay = 0.05;
			for _, v in ipairs(textDisplays) do
				AnimateText(Title, v, repeatCount, delay);
			end
			if Library.AnimateText then
				Title.Text = title .. " " .. Version;
				break;
			end
			task.wait(5);
		end
	end);
	task.spawn(function()
		while ScreenGui.Parent do
			Title.TextColor3 = ThemeColor;
			task.wait();
		end
	end);
	Title.TextSize = 20;
	Title.TextXAlignment = Enum.TextXAlignment.Left;
	DragFrame.Name = "DragFrame";
	DragFrame.Parent = Main;
	DragFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
	DragFrame.BackgroundTransparency = 1;
	DragFrame.Size = UDim2.new(0, 560, 0, 41);
	Library:MakeDraggable(DragFrame, Main);
	Library.Connections[#Library.Connections + 1] = InputService.InputBegan:Connect(function(io, p)
		if ((io.KeyCode == LibraryBind) and not table.find(blacklistedKeybinds, io.KeyCode)) then
			if Main.Visible then
				Main.Visible = false;
			elseif (Main.Visible == false) then
				Main.Visible = true;
			end
			task.spawn(function()
				while Main and Main.Visible and Main.Parent do
					if (Main and Main.Visible and (CheckDevice() == "PC") and (InputService.MouseBehavior ~= Enum.MouseBehavior.Default)) then
						InputService.MouseBehavior = Enum.MouseBehavior.Default;
					end
					if ((CheckDevice() ~= "PC") or not ScreenGui.Parent) then
						break;
					end
					task.wait();
				end
			end);
		end
	end);
	if ((CheckDevice() == "Mobile") or (CheckDevice() == "Emulator")) then
		local rbxguix = CoreGui:FindFirstChild("Horizon");
		if not rbxguix then
			warn("Library not found!");
			return;
		end
		local QuickCapture = Instance.new("TextButton", rbxguix);
		QuickCapture.Name = "UI";
		QuickCapture.BackgroundColor3 = Color3.fromRGB(1, 1, 1);
		QuickCapture.BackgroundTransparency = 0.14;
		QuickCapture.Position = UDim2.new(0.93, 0, 0, 40);
		QuickCapture.Size = UDim2.new(0, 33, 0, 33);
		QuickCapture.Font = Enum.Font.SourceSansBold;
		QuickCapture.Text = "ON";
		QuickCapture.TextColor3 = Color3.fromRGB(0, 255, 0);
		QuickCapture.TextSize = 20;
		QuickCapture.TextWrapped = true;
		QuickCapture.Draggable = (Library and Library.OCbtn) or false;
		Library.Connections = Library.Connections or {};
		table.insert(Library.Connections, QuickCapture.MouseButton1Click:Connect(function()
			if (Main and (typeof(Main.Visible) == "boolean")) then
				Main.Visible = not Main.Visible;
				QuickCapture.Text = (Main.Visible and "ON") or "OFF";
				QuickCapture.TextColor3 = (Main.Visible and Color3.fromRGB(0, 255, 0)) or Color3.fromRGB(255, 0, 0);
			else
				warn("Library property is missing!");
			end
		end));
	end
	TabFolder.Name = "TabFolder";
	TabFolder.Parent = Main;
	Library.ChangePresetColor = function(self, toch)
		ThemeColor = toch;
	end;
	Library.Notification = function(self, texttitle, textdesc, delay, autodestroy)
		local NotificationHold = Instance.new("TextButton");
		local NotificationFrame = Instance.new("Frame");
		local OkayBtn = Instance.new("TextButton");
		local OkayBtnCorner = Instance.new("UICorner");
		local OkayBtnTitle = Instance.new("TextLabel");
		local NotificationTitle = Instance.new("TextLabel");
		local NotificationDesc = Instance.new("TextLabel");
		local Delay = delay or 6;
		local autoDestroy = autodestroy or false;
		NotificationHold.Name = "NotificationHold";
		NotificationHold.Parent = Main;
		NotificationHold.BackgroundColor3 = ThemeColor;
		NotificationHold.BackgroundTransparency = 1;
		NotificationHold.BorderSizePixel = 0;
		NotificationHold.Size = UDim2.new(0, 560, 0, 319);
		NotificationHold.AutoButtonColor = false;
		NotificationHold.Font = Enum.Font.SourceSans;
		NotificationHold.Text = "";
		NotificationHold.TextColor3 = Color3.fromRGB(0, 0, 0);
		NotificationHold.TextSize = 14;
		NotificationFrame.Name = "NotificationFrame";
		NotificationFrame.Parent = NotificationHold;
		NotificationFrame.AnchorPoint = Vector2.new(0.5, 0.5);
		NotificationFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
		NotificationFrame.BackgroundTransparency = 0.5;
		NotificationFrame.BorderSizePixel = 0;
		NotificationFrame.ClipsDescendants = true;
		NotificationFrame.Position = UDim2.new(0.5, 0, 0.498432577, 0);
		NotificationFrame.Size = UDim2.new(0, 164, 0, 193);
		OkayBtn.Name = "OkayBtn";
		OkayBtn.Parent = NotificationFrame;
		OkayBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0);
		OkayBtn.BackgroundTransparency = 0.8;
		OkayBtn.Position = UDim2.new(0.0609756112, 0, 0.720207274, 0);
		OkayBtn.Size = UDim2.new(0, 144, 0, 42);
		OkayBtn.AutoButtonColor = false;
		OkayBtn.Font = Enum.Font.SourceSans;
		OkayBtn.Text = "";
		OkayBtn.TextColor3 = Color3.fromRGB(0, 0, 0);
		OkayBtn.TextSize = 14;
		OkayBtnCorner.CornerRadius = UDim.new(0, 5);
		OkayBtnCorner.Name = "OkayBtnCorner";
		OkayBtnCorner.Parent = OkayBtn;
		OkayBtnTitle.Name = "OkayBtnTitle";
		OkayBtnTitle.Parent = OkayBtn;
		OkayBtnTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
		OkayBtnTitle.BackgroundTransparency = 1;
		OkayBtnTitle.Position = UDim2.new(0.0763888881, 0, 0, 0);
		OkayBtnTitle.Size = UDim2.new(0, 181, 0, 42);
		OkayBtnTitle.Font = Enum.Font.GothamBlack;
		OkayBtnTitle.Text = (autoDestroy and "Destroying...") or "Ok";
		OkayBtnTitle.TextColor3 = Color3.fromRGB(0, 255, 255);
		OkayBtnTitle.TextSize = 14;
		OkayBtnTitle.TextXAlignment = Enum.TextXAlignment.Left;
		NotificationTitle.Name = "NotificationTitle";
		NotificationTitle.Parent = NotificationFrame;
		NotificationTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
		NotificationTitle.BackgroundTransparency = 1;
		NotificationTitle.Position = UDim2.new(0.0670731738, 0, 0.0829015523, 0);
		NotificationTitle.Size = UDim2.new(0, 143, 0, 26);
		NotificationTitle.Font = Enum.Font.GothamBlack;
		NotificationTitle.Text = texttitle .. "\n------------------------";
		NotificationTitle.TextColor3 = Color3.fromRGB(255, 0, 0);
		NotificationTitle.TextSize = 18;
		NotificationTitle.TextXAlignment = Enum.TextXAlignment.Left;
		NotificationDesc.Name = "NotificationDesc";
		NotificationDesc.Parent = NotificationFrame;
		NotificationDesc.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
		NotificationDesc.BackgroundTransparency = 1;
		NotificationDesc.Position = UDim2.new(0.0670000017, 0, 0.218999997, 0);
		NotificationDesc.Size = UDim2.new(0, 143, 0, 91);
		NotificationDesc.Font = Enum.Font.GothamBlack;
		NotificationDesc.Text = textdesc;
		NotificationDesc.TextColor3 = Color3.fromRGB(255, 255, 0);
		NotificationDesc.TextSize = 15;
		NotificationDesc.TextWrapped = true;
		NotificationDesc.TextXAlignment = Enum.TextXAlignment.Left;
		NotificationDesc.TextYAlignment = Enum.TextYAlignment.Top;
		Library.Connections['Notify'] = OkayBtn.MouseButton1Click:Connect(function()
			if not autoDestroy then
				NotificationFrame.Size = UDim2.new(0, 164, 0, 193);
				task.wait(0.5);
				NotificationHold:Destroy();
				if Library.Connections['Notify'] then
					Library.Connections['Notify']:Disconnect();
					Library.Connections['Notify'] = nil;
				end
			end
		end);
		if autoDestroy then
			task.delay(delay, function()
				NotificationHold:Destroy();
				if Library.Connections['Notify'] then
					Library.Connections['Notify']:Disconnect();
					Library.Connections['Notify'] = nil;
				end
			end);
		end
	end;
	local Content = {};
	Content.Tab = function(self, text)
		local TabBtn = Instance.new("TextButton");
		local TabTitle = Instance.new("TextLabel");
		local TabBtnIndicator = Instance.new("Frame");
		local TabBtnIndicatorCorner = Instance.new("UICorner");
		TabBtn.Name = "TabBtn";
		TabBtn.Parent = TabHold;
		TabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
		TabBtn.BackgroundTransparency = 1;
		TabBtn.Size = UDim2.new(0, 107, 0, 21);
		TabBtn.Font = Enum.Font.SourceSans;
		TabBtn.Text = "";
		TabBtn.TextColor3 = Color3.fromRGB(0, 0, 0);
		TabBtn.TextSize = 14;
		TabTitle.Name = "TabTitle";
		TabTitle.Parent = TabBtn;
		TabTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
		TabTitle.BackgroundTransparency = 1;
		TabTitle.Size = UDim2.new(0, 107, 0, 21);
		TabTitle.Font = Enum.Font.GothamBlack;
		TabTitle.Text = text or "No Name";
		TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255);
		TabTitle.TextSize = 14;
		TabTitle.TextXAlignment = Enum.TextXAlignment.Left;
		TabBtnIndicator.Name = "TabBtnIndicator";
		TabBtnIndicator.Parent = TabBtn;
		TabBtnIndicator.BackgroundColor3 = ThemeColor;
		TabBtnIndicator.BorderSizePixel = 0;
		TabBtnIndicator.Position = UDim2.new(0, 0, 1, 0);
		TabBtnIndicatorCorner.Name = "TabBtnIndicatorCorner";
		TabBtnIndicatorCorner.Parent = TabBtnIndicator;
		task.spawn(function()
			while ScreenGui.Parent do
				TabBtnIndicator.BackgroundColor3 = ThemeColor;
				task.wait();
			end
		end);
		local Tab = Instance.new("ScrollingFrame");
		local TabLayout = Instance.new("UIListLayout");
		Tab.Name = "Tab";
		Tab.Parent = TabFolder;
		Tab.Active = true;
		Tab.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
		Tab.BackgroundTransparency = 1;
		Tab.BorderSizePixel = 0;
		Tab.Position = UDim2.new(0.31400001, 0, 0.147, 0);
		Tab.Size = UDim2.new(0, 373, 0, 254);
		Tab.CanvasSize = UDim2.new(0, 0, 0, 0);
		Tab.ScrollBarThickness = 3;
		Tab.Visible = false;
		TabLayout.Name = "TabLayout";
		TabLayout.Parent = Tab;
		TabLayout.SortOrder = Enum.SortOrder.LayoutOrder;
		TabLayout.Padding = UDim.new(0, 6);
		if (fs == false) then
			fs = true;
			TabBtnIndicator.Size = UDim2.new(0, 13, 0, 2);
			TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255);
			Tab.Visible = true;
		end
		Library.Connections[#Library.Connections + 1] = TabBtn.MouseButton1Click:Connect(function()
			for i, v in next, TabFolder:GetChildren() do
				if (v.Name == "Tab") then
					v.Visible = false;
				end
				Tab.Visible = true;
			end
			for i, v in next, TabHold:GetChildren() do
				if (v.Name == "TabBtn") then
					v.TabBtnIndicator.Size = UDim2.new(0, 0, 0, 2);
					TabBtnIndicator.Size = UDim2.new(0, 13, 0, 2);
				end
			end
		end);
		local Container = {};
		Container.Button = function(self, text, callback)
			local MainButton = Instance.new("TextButton");
			local ButtonCorner = Instance.new("UICorner");
			local ButtonTitle = Instance.new("TextLabel");
			MainButton.Name = "Button";
			MainButton.Parent = Tab;
			MainButton.BackgroundColor3 = Color3.fromRGB(34, 34, 34);
			MainButton.Size = UDim2.new(0, 363, 0, 42);
			MainButton.AutoButtonColor = false;
			MainButton.BackgroundTransparency = 0.5;
			MainButton.Font = Enum.Font.SourceSans;
			MainButton.Text = "";
			MainButton.TextColor3 = Color3.fromRGB(0, 0, 0);
			MainButton.TextSize = 14;
			ButtonCorner.CornerRadius = UDim.new(0, 5);
			ButtonCorner.Name = "ButtonCorner";
			ButtonCorner.Parent = MainButton;
			ButtonTitle.Name = "ButtonTitle";
			ButtonTitle.Parent = MainButton;
			ButtonTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			ButtonTitle.BackgroundTransparency = 1;
			ButtonTitle.Position = UDim2.new(0.0358126722, 0, 0, 0);
			ButtonTitle.Size = UDim2.new(0, 187, 0, 42);
			ButtonTitle.Font = Enum.Font.GothamBlack;
			ButtonTitle.Text = text;
			ButtonTitle.TextColor3 = Color3.fromRGB(255, 255, 255);
			ButtonTitle.TextSize = 14;
			ButtonTitle.TextXAlignment = Enum.TextXAlignment.Left;
			task.spawn(function()
				while ScreenGui.Parent do
					MainButton.BackgroundColor3 = ThemeColor;
					task.wait();
				end
			end);
			local Button = {};
			Button.Click = function()
				Library:SafeCallback(callback);
			end;
			Library.Connections[#Library.Connections + 1] = MainButton.MouseButton1Click:Connect(function()
				Library:SafeCallback(callback);
			end);
			Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y);
			Options[text] = Button;
			return Button;
		end;
		Container.MakeToggle = function(self, Idx, Info)
			assert(Info.Text, "AddInput: Missing `Text` string.");
			local Toggle = {Value=(Info.Default or false),Type="Toggle",Callback=(Info.Callback or function(Value)
			end),Addons={},Risky=Info.Risky};
			local MainToggle = Library:Create("TextButton", {Name="Toggle",Parent=Tab,BackgroundTransparency=0.5,Position=UDim2.new(0.215625003, 0, 0.446271926, 0),Size=UDim2.new(0, 363, 0, 42),AutoButtonColor=false,Font=Enum.Font.SourceSans,Text="",TextColor3=Color3.fromRGB(0, 0, 0),TextSize=14});
			local ToggleCorner = Library:Create("UICorner", {CornerRadius=UDim.new(0, 5),Name="ToggleCorner",Parent=MainToggle});
			local ToggleTitle = Library:Create("TextLabel", {Name="ToggleTitle",Parent=MainToggle,BackgroundColor3=Color3.fromRGB(255, 255, 255),BackgroundTransparency=1,Position=UDim2.new(0.0358126722, 0, 0, 0),Size=UDim2.new(0.95, 0, 0, 40),Font=Enum.Font.GothamBlack,Text=(Info.Text or "Example Text"),TextColor3=Color3.fromRGB(255, 255, 255),TextSize=14,TextXAlignment=Enum.TextXAlignment.Left});
			local FrameToggle1 = Library:Create("Frame", {Name="FrameToggle1",Parent=MainToggle,BackgroundTransparency=0.5,BackgroundColor3=Color3.fromRGB(50, 50, 50),Position=UDim2.new(0.859504104, 0, 0.285714298, 0),Size=UDim2.new(0, 37, 0, 18)});
			local FrameToggle1Corner = Library:Create("UICorner", {Name="FrameToggle1Corner",Parent=FrameToggle1});
			local FrameToggle2 = Library:Create("Frame", {Name="FrameToggle2",Parent=FrameToggle1,BackgroundTransparency=0.5,BackgroundColor3=Color3.fromRGB(34, 34, 34),Position=UDim2.new(0.0489999987, 0, 0.0930000022, 0),Size=UDim2.new(0, 33, 0, 14)});
			local FrameToggle2Corner = Library:Create("UICorner", {Name="FrameToggle2Corner",Parent=FrameToggle2});
			local FrameToggle3 = Library:Create("Frame", {Name="FrameToggle3",Parent=FrameToggle1,BackgroundColor3=ThemeColor,BackgroundTransparency=0.5,BackgroundTransparency=1,Size=UDim2.new(0, 37, 0, 18)});
			local FrameToggle3Corner = Library:Create("UICorner", {Name="FrameToggle3Corner",Parent=FrameToggle3});
			local FrameToggleCircle = Library:Create("Frame", {Name="FrameToggleCircle",Parent=FrameToggle1,BackgroundTransparency=0,BackgroundColor3=Color3.fromRGB(255, 0, 0),Position=UDim2.new(0.127000004, 0, 0.222000003, 0),Size=UDim2.new(0, 10, 0, 10)});
			local FrameToggleCircleCorner = Library:Create("UICorner", {Name="FrameToggleCircleCorner",Parent=FrameToggleCircle});
			task.spawn(function()
				while ScreenGui.Parent do
					FrameToggle1.BackgroundColor3 = ThemeColor;
					FrameToggle2.BackgroundColor3 = ThemeColor;
					FrameToggle3.BackgroundColor3 = ThemeColor;
					MainToggle.BackgroundColor3 = ThemeColor;
					task.wait();
				end
			end);
			Toggle.OnChanged = function(self, Func)
				Toggle.Changed = Func;
				Func(Toggle.Value);
			end;
			Toggle.SetValue = function(self, Bool)
				Bool = not not Bool;
				if Bool then
					MainToggle.BackgroundColor3 = Color3.fromRGB(37, 37, 37);
					FrameToggleCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 0);
					FrameToggleCircle.Position = UDim2.new(0.587, 0, 0.222000003, 0);
				else
					MainToggle.BackgroundColor3 = Color3.fromRGB(34, 34, 34);
					FrameToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0);
					FrameToggleCircle.Position = UDim2.new(0.127000004, 0, 0.222000003, 0);
				end
				Toggle.Value = Bool;
				for _, Addon in next, Toggle.Addons do
					if ((Addon.Type == "KeyPicker") and Addon.SyncToggleState) then
						Addon.Toggled = Bool;
						Addon:Update();
					end
				end
				Library:SafeCallback(Toggle.Callback, Toggle.Value);
				Library:SafeCallback(Toggle.Changed, Toggle.Value);
			end;
			Library.Connections[#Library.Connections + 1] = MainToggle.InputBegan:Connect(function(Input)
				if (Input.UserInputType == Enum.UserInputType.MouseButton1) then
					Toggle:SetValue(not Toggle.Value);
					Library:AttemptSave();
				end
			end);
			if Info.Default then
				Toggle:SetValue(true);
			end
			Toggle.TextLabel = ToggleLabel;
			Toggle.Container = Tab;
			setmetatable(Toggle, BaseAddons);
			Toggles[Idx] = Toggle;
			Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y);
			return Toggle;
		end;
		Container.KeybindToggle = function(self, Idx, Info)
			local Toggled = default or false;
			local SelectingKey = false;
			local assignedKey = Info.KeyDefault or "";
			local Toggle = {Value=(Info.Default or false),Type="Toggle",Callback=(Info.Callback or function(Value)
			end),Addons={},Risky=Info.Risky};
			local Textbox = {Value="",Default=Info.KeySave,Type="Input",Callback=(Info.Callback or function(Value)
			end)};
			local MainToggle = Library:Create("TextButton", {Name="Toggle",Parent=Tab,BackgroundTransparency=0.5,Position=UDim2.new(0.215625003, 0, 0.446271926, 0),Size=UDim2.new(0, 363, 0, 42),AutoButtonColor=false,Font=Enum.Font.SourceSans,Text="",TextColor3=Color3.fromRGB(0, 0, 0),TextSize=14});
			local ToggleCorner = Library:Create("UICorner", {CornerRadius=UDim.new(0, 5),Name="ToggleCorner",Parent=MainToggle});
			local ToggleTitle = Library:Create("TextLabel", {Name="ToggleTitle",Parent=MainToggle,BackgroundColor3=Color3.fromRGB(255, 255, 255),BackgroundTransparency=1,Position=UDim2.new(0.0358126722, 0, 0, 0),Size=UDim2.new(0.95, 0, 0, 40),Font=Enum.Font.GothamBlack,Text=(Info.Text or "Example Text"),TextColor3=Color3.fromRGB(255, 255, 255),TextSize=14,TextXAlignment=Enum.TextXAlignment.Left});
			local FrameToggle1 = Library:Create("Frame", {Name="FrameToggle1",Parent=MainToggle,BackgroundTransparency=0.5,BackgroundColor3=Color3.fromRGB(50, 50, 50),Position=UDim2.new(0.859504104, 0, 0.285714298, 0),Size=UDim2.new(0, 37, 0, 18)});
			local FrameToggle1Corner = Library:Create("UICorner", {Name="FrameToggle1Corner",Parent=FrameToggle1});
			local FrameToggle2 = Library:Create("Frame", {Name="FrameToggle2",Parent=FrameToggle1,BackgroundTransparency=0.5,BackgroundColor3=Color3.fromRGB(34, 34, 34),Position=UDim2.new(0.0489999987, 0, 0.0930000022, 0),Size=UDim2.new(0, 33, 0, 14)});
			local FrameToggle2Corner = Library:Create("UICorner", {Name="FrameToggle2Corner",Parent=FrameToggle2});
			local FrameToggle3 = Library:Create("Frame", {Name="FrameToggle3",Parent=FrameToggle1,BackgroundColor3=ThemeColor,BackgroundTransparency=0.5,Size=UDim2.new(0, 37, 0, 18)});
			local FrameToggle3Corner = Library:Create("UICorner", {Name="FrameToggle3Corner",Parent=FrameToggle3});
			local FrameToggleCircle = Library:Create("Frame", {Name="FrameToggleCircle",Parent=FrameToggle1,BackgroundTransparency=0.5,BackgroundColor3=Color3.fromRGB(255, 0, 0),BackgroundTransparency=0,Position=UDim2.new(0.127000004, 0, 0.222000003, 0),Size=UDim2.new(0, 10, 0, 10)});
			local FrameToggleCircleCorner = Library:Create("UICorner", {Name="FrameToggleCircleCorner",Parent=FrameToggleCircle});
			local KeybindLabel = Instance.new("TextButton");
			KeybindLabel.Name = "KeybindLabel";
			KeybindLabel.Parent = MainToggle;
			KeybindLabel.BackgroundTransparency = 1;
			KeybindLabel.Position = UDim2.new(0.65, 0, 0, -1);
			KeybindLabel.Size = UDim2.new(0, 50, 0, 42);
			KeybindLabel.Font = Enum.Font.Gotham;
			KeybindLabel.Text = ((assignedKey == "") and "Enter Key") or assignedKey;
			KeybindLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
			KeybindLabel.TextSize = 14;
			KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left;
			task.spawn(function()
				while ScreenGui.Parent do
					MainToggle.BackgroundColor3 = ThemeColor;
					FrameToggle3.BackgroundColor3 = ThemeColor;
					FrameToggle1.BackgroundColor3 = ThemeColor;
					FrameToggle2.BackgroundColor3 = ThemeColor;
					task.wait();
				end
			end);
			Toggle.OnChanged = function(self, Func)
				Toggle.Changed = Func;
				Func(Toggle.Value);
			end;
			Textbox.SetKey = function(self, key)
				assignedKey = Enum.KeyCode[key];
				KeybindLabel.Text = key;
			end;
			Toggle.SetValue = function(self, Bool)
				Bool = not not Bool;
				if Bool then
					MainToggle.BackgroundColor3 = Color3.fromRGB(37, 37, 37);
					FrameToggleCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 0);
					FrameToggleCircle.Position = UDim2.new(0.587, 0, 0.222000003, 0);
				else
					MainToggle.BackgroundColor3 = Color3.fromRGB(34, 34, 34);
					FrameToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0);
					FrameToggleCircle.Position = UDim2.new(0.127000004, 0, 0.222000003, 0);
				end
				Toggle.Value = Bool;
				for _, Addon in next, Toggle.Addons do
					if ((Addon.Type == "KeyPicker") and Addon.SyncToggleState) then
						Addon.Toggled = Bool;
						Addon:Update();
					end
				end
				Library:SafeCallback(Toggle.Callback, Toggle.Value);
				Library:SafeCallback(Toggle.Changed, Toggle.Value);
			end;
			KeybindLabel.MouseButton1Click:Connect(function()
				if SelectingKey then
					return;
				end
				SelectingKey = true;
				KeybindLabel.Text = "Press Key";
				local connection;
				connection = InputService.InputBegan:Connect(function(input)
					if (not table.find(blacklistedKeybinds, input.KeyCode) and (input.UserInputType == Enum.UserInputType.Keyboard)) then
						assignedKey = input.KeyCode;
						KeybindLabel.Text = assignedKey.Name;
						SelectingKey = false;
						connection:Disconnect();
					end
					Library:AttemptSave();
				end);
			end);
			Library.Connections[#Library.Connections + 1] = InputService.InputBegan:Connect(function(input, gameProcessed)
				if (gameProcessed or SelectingKey) then
					return;
				end
				if (input.KeyCode == assignedKey) then
					Toggle:SetValue(not Toggle.Value);
				end
				Library:AttemptSave();
			end);
			Library.Connections[#Library.Connections + 1] = MainToggle.MouseButton1Click:Connect(function()
				if not SelectingKey then
					Toggle:SetValue(not Toggle.Value);
				end
				Library:AttemptSave();
			end);
			if Info.Default then
				Toggle:SetValue(true);
			end
			Toggles[Idx] = Toggle;
			Options[Idx] = Textbox;
			Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y);
			return Toggle;
		end;
		Container.NewSlider = function(self, Idx, Info)
			assert(Info.Default, "AddSlider: Missing default value.");
			assert(Info.Text, "AddSlider: Missing slider text.");
			assert(Info.Min, "AddSlider: Missing minimum value.");
			assert(Info.Max, "AddSlider: Missing maximum value.");
			local MainSlider = Instance.new("TextButton");
			local SliderLabel = Instance.new("TextLabel");
			local SliderCorner = Instance.new("UICorner");
			local Sliding = Instance.new("Frame");
			local SlidingCorner = Instance.new("UICorner");
			local Circle = Instance.new("Frame");
			local HideColor = Instance.new("Frame");
			local HideColorCorner = Instance.new("UICorner");
			local CircleCorner = Instance.new("UICorner");
			local Progress = Instance.new("Frame");
			local ProgressCorner = Instance.new("UICorner");
			local CircleStroke = Instance.new("UIStroke");
			local ValueLabel = Instance.new("TextLabel");
			MainSlider.Name = "MainSlider";
			MainSlider.Parent = Tab;
			MainSlider.BackgroundTransparency = 0.5;
			MainSlider.BorderSizePixel = 0;
			MainSlider.Position = UDim2.new(0.286780387, 0, 0, 0);
			MainSlider.Size = UDim2.new(0, 363, 0, 40);
			MainSlider.AutoButtonColor = false;
			MainSlider.Font = Enum.Font.SourceSans;
			MainSlider.Text = "";
			MainSlider.TextColor3 = Color3.fromRGB(0, 0, 0);
			MainSlider.TextSize = 14;
			SliderLabel.Name = "SliderLabel";
			SliderLabel.Parent = MainSlider;
			SliderLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			SliderLabel.BackgroundTransparency = 1;
			SliderLabel.BorderColor3 = Color3.fromRGB(27, 42, 53);
			SliderLabel.BorderSizePixel = 0;
			SliderLabel.Position = UDim2.new(0.0358126722, 0, 0, 0);
			SliderLabel.Size = UDim2.new(0.95, 0, 0, 40);
			SliderLabel.Font = Enum.Font.GothamBlack;
			SliderLabel.Text = Info.Text or "Text Example";
			SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
			SliderLabel.TextSize = 14;
			SliderLabel.TextXAlignment = Enum.TextXAlignment.Left;
			SliderCorner.CornerRadius = UDim.new(0, 5);
			SliderCorner.Name = "SliderCorner";
			SliderCorner.Parent = MainSlider;
			Sliding.Name = "Sliding";
			Sliding.Parent = MainSlider;
			Sliding.BackgroundColor3 = Color3.fromRGB(43, 43, 43);
			Sliding.BorderSizePixel = 0;
			Sliding.Position = UDim2.new(0.58, 0, 0.421052635, 0);
			Sliding.Size = UDim2.new(0, 140, 0, 5);
			SlidingCorner.CornerRadius = UDim.new(0, 15);
			SlidingCorner.Name = "SlidingCorner";
			SlidingCorner.Parent = Sliding;
			Circle.Name = "Circle";
			Circle.Parent = Progress;
			Circle.AnchorPoint = Vector2.new(0, 0.5);
			Circle.BackgroundColor3 = Color3.fromRGB(0, 123, 255);
			Circle.BorderSizePixel = 0;
			Circle.Position = UDim2.new(1, 0, 0.5, 0);
			Circle.Size = UDim2.new(0, 12, 0, 12);
			Circle.ZIndex = 2;
			CircleStroke.Parent = Circle;
			CircleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
			CircleStroke.Thickness = 2;
			CircleStroke.Color = Color3.fromRGB(43, 43, 43);
			ValueLabel.Name = "ValueLabel";
			ValueLabel.Parent = Circle;
			ValueLabel.AnchorPoint = Vector2.new(0.5, 0);
			ValueLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			ValueLabel.BackgroundTransparency = 1;
			ValueLabel.BorderSizePixel = 0;
			ValueLabel.Position = UDim2.new(0.5, 0, -1.49128079, 0);
			ValueLabel.Size = UDim2.new(0, 25, 0, 18);
			ValueLabel.Font = Enum.Font.GothamSemibold;
			ValueLabel.Text = (Info.Rounding and string.format("%.1f", tostring(Info.Default))) or (math.floor(Info.Default));
			ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255);
			ValueLabel.TextSize = 14;
			HideColor.Name = "HideColor";
			HideColor.Parent = Circle;
			HideColor.AnchorPoint = Vector2.new(0.5, 0.5);
			HideColor.BackgroundColor3 = Color3.fromRGB(43, 43, 43);
			HideColor.BorderSizePixel = 0;
			HideColor.Position = UDim2.new(0.5, 0, 0.5, 0);
			HideColor.Size = UDim2.new(1, 1, 1, 1);
			HideColor.ZIndex = 2;
			HideColorCorner.CornerRadius = UDim.new(0, 100);
			HideColorCorner.Name = "HideColorCorner";
			HideColorCorner.Parent = HideColor;
			CircleCorner.CornerRadius = UDim.new(0, 100);
			CircleCorner.Name = "CircleCorner";
			CircleCorner.Parent = Circle;
			Progress.Name = "Progress";
			Progress.Parent = Sliding;
			Progress.BackgroundColor3 = Color3.fromRGB(0, 123, 255);
			Progress.BorderSizePixel = 0;
			Progress.Size = UDim2.new(0.5, 0, 1, 0);
			ProgressCorner.CornerRadius = UDim.new(0, 15);
			ProgressCorner.Name = "ProgressCorner";
			ProgressCorner.Parent = Progress;
			task.spawn(function()
				while ScreenGui.Parent do
					Circle.BackgroundColor3 = ThemeColor;
					Progress.BackgroundColor3 = ThemeColor;
					MainSlider.BackgroundColor3 = ThemeColor;
					task.wait();
				end
			end);
			local Slider = {Value=Info.Default,Min=Info.Min,Max=Info.Max,Rounding=Info.Rounding,MaxSize=232,Type="Slider",Callback=(Info.Callback or function(Value)
			end)};
			local function UpdateSlider(val)
				local percent = (Mouse.X - Progress.AbsolutePosition.X) / Progress.AbsoluteSize.X;
				if val then
					percent = (val - Info.Min) / (Info.Max - Info.Min);
				end
				percent = math.clamp(percent, 0, 1);
				Progress.Size = UDim2.new(percent, 0, 1, 0);
			end
			UpdateSlider(Info.Default);
			local IsSliding, Dragging = false, false;
			local RealValue = Info.Value;
			local function DragSlider(Pressed)
				if not Dragging then
					return;
				end
				IsSliding = true;
				local pos = UDim2.new(math.clamp((Pressed.Position.X - Sliding.AbsolutePosition.X) / Sliding.AbsoluteSize.X, 0, 1), 0, 1, 0);
				local size = UDim2.new(math.clamp((Pressed.Position.X - Sliding.AbsolutePosition.X) / Sliding.AbsoluteSize.X, 0, 1), 0, 1, 0);
				Progress.Size = size;
				RealValue = (((pos.X.Scale * Info.Max) / Info.Max) * (Info.Max - Info.Min)) + Info.Min;
				Slider.Value = (Info.Precise and string.format("%.1f", tostring(RealValue))) or (math.floor(RealValue));
				ValueLabel.Text = tostring(Slider.Value);
				Library:SafeCallback(Slider.Callback, Slider.Value);
				Library:SafeCallback(Slider.Changed, Slider.Value);
			end
			Library.Connections[#Library.Connections + 1] = MainSlider.InputBegan:Connect(function(Pressed)
				if ((Pressed.UserInputType == Enum.UserInputType.MouseButton1) or (Pressed.UserInputType == Enum.UserInputType.Touch)) then
					Dragging = true;
					IsSliding = false;
					DragSlider(Pressed);
					Library:AttemptSave();
				end
			end);
			Library.Connections[#Library.Connections + 1] = MainSlider.InputEnded:Connect(function(Pressed)
				if ((Pressed.UserInputType == Enum.UserInputType.MouseButton1) or (Pressed.UserInputType == Enum.UserInputType.Touch)) then
					Dragging = false;
					IsSliding = false;
				end
			end);
			Library.Connections[#Library.Connections + 1] = InputService.InputChanged:Connect(function(Pressed)
				if (Dragging and ((Pressed.UserInputType == Enum.UserInputType.MouseMovement) or (Pressed.UserInputType == Enum.UserInputType.Touch))) then
					DragSlider(Pressed);
					Library:AttemptSave();
				end
			end);
			Library.Connections[#Library.Connections + 1] = MainSlider.MouseEnter:Connect(function()
				HideColor.Size = UDim2.new(0, 0, 0, 0);
			end);
			Library.Connections[#Library.Connections + 1] = MainSlider.MouseLeave:Connect(function()
				if not Dragging then
					HideColor.Size = UDim2.new(1, 1, 1, 1);
				end
			end);
			Slider.OnChanged = function(self, Func)
				Slider.Changed = Func;
				Func(Slider.Value);
			end;
			Slider.SetValue = function(self, Str)
				local Num = tonumber(Str);
				if not Num then
					return;
				end
				Num = math.clamp(Num, Slider.Min, Slider.Max);
				Slider.Value = Num;
				ValueLabel.Text = tostring(Slider.Value);
				UpdateSlider(Slider.Value);
				Library:SafeCallback(Slider.Callback, Slider.Value);
				Library:SafeCallback(Slider.Changed, Slider.Value);
			end;
			Options[Idx] = Slider;
			Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y);
			return Slider;
		end;
		Container.MakeDropdown = function(self, Idx, Info)
			if (Info.SpecialType == "Player") then
				Info.Values = GetPlayersString();
				Info.AllowNull = true;
			elseif (Info.SpecialType == "Team") then
				Info.Values = GetTeamsString();
				Info.AllowNull = true;
			end
			assert(Info.Values, "AddDropdown: Missing dropdown value list.");
			assert(Info.AllowNull or Info.Default, "AddDropdown: Missing default value. Pass `AllowNull` as true if this was intentional.");
			if not Info.Text then
				Info.Compact = true;
			end
			local Dropdown = {Values=Info.Values,Value=(Info.Multi and {}),Multi=Info.Multi,Type="Dropdown",SpecialType=Info.SpecialType,Callback=(Info.Callback or function(Value)
			end)};
			local RelativeOffset = 0;
			for _, Element in next, Tab:GetChildren() do
				if not Element:IsA("UIListLayout") then
					RelativeOffset = RelativeOffset + Element.Size.Y.Offset;
				end
			end
			local MainDropdown = Library:Create("Frame", {Parent=Tab,BackgroundTransparency=0.5,ClipsDescendants=true,Position=UDim2.new(-0.541071415, 0, -0.532915354, 0),Size=UDim2.new(0, 363, 0, 42)});
			local DropdownButton = Library:Create("TextButton", {Parent=MainDropdown,BackgroundColor3=Color3.fromRGB(255, 255, 255),BackgroundTransparency=1,Size=UDim2.new(0, 363, 0, 42),Font=Enum.Font.SourceSans,Text="",TextColor3=Color3.fromRGB(0, 0, 0),TextSize=14});
			local DropdownCorner = Library:Create("UICorner", {CornerRadius=UDim.new(0, 5),Parent=MainDropdown});
			local DropdownTitle = Library:Create("TextLabel", {Name="ButtonTitle",Parent=MainDropdown,BackgroundColor3=Color3.fromRGB(255, 255, 255),BackgroundTransparency=1,Position=UDim2.new(0.0358126722, 0, 0, 0),Size=UDim2.new(0, 187, 0, 42),Font=Enum.Font.GothamBlack,Text=(Info.Text or "Unknown Text"),TextColor3=Color3.fromRGB(255, 255, 255),TextSize=14,TextXAlignment=Enum.TextXAlignment.Left});
			local DropdownArrow = Library:Create("ImageLabel", {Parent=DropdownTitle,BackgroundColor3=Color3.fromRGB(255, 255, 255),BackgroundTransparency=1,Position=UDim2.new(1.65240645, 0, 0.190476194, 0),Size=UDim2.new(0, 26, 0, 26),Image="http://www.roblox.com/asset/?id=6034818375"});
			local MAX_DROPDOWN_ITEMS = 8;
			Dropdown.Flag = false;
			Dropdown.Frame = 0;
			DropdownButton.MouseButton1Click:Connect(function()
				if (Dropdown.Flag == false) then
					MainDropdown.Size = UDim2.new(0, 363, 0, 130);
					DropdownArrow.Rotation = 270;
					Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y);
				else
					MainDropdown.Size = UDim2.new(0, 363, 0, 42);
					DropdownArrow.Rotation = 0;
					Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y);
				end
				Dropdown.Flag = not Dropdown.Flag;
			end);
			local Scrolling = Library:Create("ScrollingFrame", {Parent=DropdownTitle,Active=true,BackgroundColor3=Color3.fromRGB(255, 255, 255),BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.new(-0.00400000019, 0, 1.04999995, 0),Size=UDim2.new(0, 342, 0, 0),CanvasSize=UDim2.new(0, 0, 0, 0),ScrollBarThickness=3});
			local Layout = Library:Create("UIListLayout", {Parent=Scrolling,SortOrder=Enum.SortOrder.LayoutOrder});
			Dropdown.Display = function(self)
				local Values = Dropdown.Values;
				local Str = "";
				if Info.Multi then
					for Idx, Value in next, Values do
						if Dropdown.Value[Value] then
							Str = Str .. Value .. ", ";
						end
					end
					Str = Str:sub(1, #Str - 2);
				else
					Str = Dropdown.Value or "";
				end
			end;
			Dropdown.GetActiveValues = function(self)
				if Info.Multi then
					local T = {};
					if (type(Dropdown.Value) == "table") then
						for Value, Bool in next, Dropdown.Value do
							table.insert(T, Value);
						end
					else
						for Value, Bool in next, {Dropdown.Value} do
							table.insert(T, Value);
						end
					end
					return T;
				else
					return (Dropdown.Value and 1) or 0;
				end
			end;
			Dropdown.Buttons = {};
			Dropdown.Selected = {};
			Dropdown.BuildDropdownList = function(self)
				local Values = Dropdown.Values;
				local Buttons = {};
				for _, Element in next, Scrolling:GetChildren() do
					if not Element:IsA("UIListLayout") then
						Element:Destroy();
					end
				end
				local Count = 0;
				for Idx, Value in next, Values do
					local Table = {};
					Count += 1
					if (Count <= 3) then
						Dropdown.Frame = Dropdown.Frame + 20;
						Scrolling.Size = UDim2.new(0, 342, 0, 80);
						Scrolling.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y);
					end
					Scrolling.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 25);
					local Button = Library:Create("TextButton", {Parent=Scrolling,ClipsDescendants=true,Size=UDim2.new(0, 335, 0, 25),AutoButtonColor=false,BackgroundColor3=(ThemeColor or Color3.fromRGB(0, 0, 255)),Font=Enum.Font.SourceSans,Text=Value,TextColor3=Color3.fromRGB(255, 255, 255),TextSize=15,LayoutOrder=Idx});
					local ButtonCorner = Library:Create("UICorner", {CornerRadius=UDim.new(0, 4),Parent=Button});
					task.spawn(function()
						while ScreenGui.Parent do
							MainDropdown.BackgroundColor3 = ThemeColor;
							Button.BackgroundTransparency = 0.5;
							task.wait();
						end
					end);
					table.insert(Dropdown.Buttons, Button);
					local Selected;
					Dropdown.StoredValues = {};
					Table.UpdateButton = function(self)
						if Info.Multi then
							if (#Dropdown.StoredValues >= 2) then
								Selected = table.find(Dropdown.StoredValues, Value) ~= nil;
							else
								Selected = Dropdown.Value == Value;
							end
						else
							Selected = Dropdown.Value == Value;
						end
						if Selected then
							if (Info.Multi and not Dropdown.Selected[Value]) then
								Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
								Button.BackgroundTransparency = 0.3;
								Dropdown.Selected[Value] = true;
							else
								Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
								Button.BackgroundTransparency = 0.3;
							end
						else
							Button.BackgroundColor3 = ThemeColor or Color3.fromRGB(255, 0, 0);
							Button.BackgroundTransparency = 0;
							if Dropdown.Selected[Value] then
								Dropdown.Selected[Value] = nil;
							end
						end
					end;
					if Info.Default then
						for _, v in next, Dropdown.Buttons do
							if (v.Text == Info.Default) then
								v.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
								v.BackgroundTransparency = 0.3;
								table.insert(Dropdown.StoredValues, Info.Default);
								Dropdown.Value = Info.Default;
								break;
							end
						end
					end
					Library.Connections[#Library.Connections + 1] = Button.MouseEnter:Connect(function()
						if not Selected then
							Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
							Button.BackgroundTransparency = 0.3;
						end
					end);
					Library.Connections[#Library.Connections + 1] = Button.MouseLeave:Connect(function()
						if not Selected then
							Button.BackgroundColor3 = ThemeColor or Color3.fromRGB(255, 255, 255);
							Button.BackgroundTransparency = 0;
						end
					end);
					Library.Connections[#Library.Connections + 1] = Button.MouseButton1Click:Connect(function()
						local Try = not Selected;
						if ((Dropdown:GetActiveValues() == 1) and not Try and not Info.AllowNull) then
							return;
						end
						if Info.Multi then
							if Try then
								table.insert(Dropdown.StoredValues, Value);
							else
								local index = table.find(Dropdown.StoredValues, Value);
								if index then
									table.remove(Dropdown.StoredValues, index);
								end
							end
							if (#Dropdown.StoredValues == 1) then
								Dropdown.Value = Dropdown.StoredValues[1];
							elseif (#Dropdown.StoredValues > 1) then
								Dropdown.Value = Dropdown.StoredValues;
							else
								Dropdown.Value = nil;
							end
						else
							if Try then
								Dropdown.Value = Value;
							else
								Dropdown.Value = nil;
							end
							for _, OtherButton in next, Buttons do
								OtherButton:UpdateButton();
							end
						end
						Table:UpdateButton();
						Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
						Library:SafeCallback(Dropdown.Changed, Dropdown.Value);
						Buttons[Button] = Table;
						Library:AttemptSave();
					end);
				end
			end;
			Dropdown.RemoveDropdown = function(self)
				for i, v in next, Dropdown.Buttons do
					v:Destroy();
				end
				table.clear(Dropdown.Buttons);
				DropdownArrow.Rotation = 0;
				MainDropdown.Size = UDim2.new(0, 363, 0, 42);
				Dropdown.Flag = false;
				Dropdown.Frame = 0;
				Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y);
			end;
			Dropdown.SetValues = function(self, NewValues)
				Dropdown.Values = NewValues;
				Dropdown:BuildDropdownList();
			end;
			Dropdown.OpenDropdown = function(self)
			end;
			Dropdown.CloseDropdown = function(self)
			end;
			Dropdown.OnChanged = function(self, Func)
				Dropdown.Changed = Func;
				Func(Dropdown.Value);
			end;
			Dropdown.SetValue = function(self, Val)
				if not Val then
					Dropdown.Value = nil;
				elseif Val then
					Dropdown.Value = Val;
				end
				Dropdown:BuildDropdownList();
				Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
				Library:SafeCallback(Dropdown.Changed, Dropdown.Value);
			end;
			Dropdown.Value = Info.Default;
			Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
			Library:SafeCallback(Dropdown.Changed, Dropdown.Value);
			Dropdown:BuildDropdownList();
			Options[Idx] = Dropdown;
			Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y);
			return Dropdown;
		end;
		Container.Colorpicker = function(self, Idx, Info)
			assert(Info.Default, "AddColorPicker: Missing default value.");
			local ColorPickerToggled = false;
			local OldToggleColor = Color3.fromRGB(0, 0, 0);
			local OldColor = Color3.fromRGB(0, 0, 0);
			local OldColorSelectionPosition = nil;
			local OldHueSelectionPosition = nil;
			local ColorH, ColorS, ColorV = 1, 1, 1;
			local RainbowColorPicker = false;
			local ColorPickerInput = nil;
			local ColorInput = nil;
			local HueInput = nil;
			local Colorpicker = Instance.new("Frame");
			local ColorpickerCorner = Instance.new("UICorner");
			local ColorpickerTitle = Instance.new("TextLabel");
			local BoxColor = Instance.new("Frame");
			local BoxColorCorner = Instance.new("UICorner");
			local ConfirmBtn = Instance.new("TextButton");
			local ConfirmBtnCorner = Instance.new("UICorner");
			local ConfirmBtnTitle = Instance.new("TextLabel");
			local ColorpickerBtn = Instance.new("TextButton");
			local RainbowToggle = Instance.new("TextButton");
			local RainbowToggleCorner = Instance.new("UICorner");
			local RainbowToggleTitle = Instance.new("TextLabel");
			local FrameRainbowToggle1 = Instance.new("Frame");
			local FrameRainbowToggle1Corner = Instance.new("UICorner");
			local FrameRainbowToggle2 = Instance.new("Frame");
			local FrameRainbowToggle2_2 = Instance.new("UICorner");
			local FrameRainbowToggle3 = Instance.new("Frame");
			local FrameToggle3 = Instance.new("UICorner");
			local FrameRainbowToggleCircle = Instance.new("Frame");
			local FrameRainbowToggleCircleCorner = Instance.new("UICorner");
			local Color = Instance.new("ImageLabel");
			local ColorCorner = Instance.new("UICorner");
			local ColorSelection = Instance.new("ImageLabel");
			local Hue = Instance.new("ImageLabel");
			local HueCorner = Instance.new("UICorner");
			local HueGradient = Instance.new("UIGradient");
			local HueSelection = Instance.new("ImageLabel");
			Colorpicker.Name = "Colorpicker";
			Colorpicker.Parent = Tab;
			Colorpicker.BackgroundTransparency = 0.5;
			Colorpicker.ClipsDescendants = true;
			Colorpicker.Position = UDim2.new(-0.541071415, 0, -0.532915354, 0);
			Colorpicker.Size = UDim2.new(0, 363, 0, 42);
			ColorpickerCorner.CornerRadius = UDim.new(0, 5);
			ColorpickerCorner.Name = "ColorpickerCorner";
			ColorpickerCorner.Parent = Colorpicker;
			ColorpickerTitle.Name = "ColorpickerTitle";
			ColorpickerTitle.Parent = Colorpicker;
			ColorpickerTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			ColorpickerTitle.BackgroundTransparency = 1;
			ColorpickerTitle.Position = UDim2.new(0.0358126722, 0, 0, 0);
			ColorpickerTitle.Size = UDim2.new(0, 187, 0, 42);
			ColorpickerTitle.Font = Enum.Font.GothamBlack;
			ColorpickerTitle.Text = Info.Title or "Example Text";
			ColorpickerTitle.TextColor3 = Color3.fromRGB(255, 255, 255);
			ColorpickerTitle.TextSize = 14;
			ColorpickerTitle.TextXAlignment = Enum.TextXAlignment.Left;
			BoxColor.Name = "BoxColor";
			BoxColor.Parent = ColorpickerTitle;
			BoxColor.BackgroundColor3 = Color3.fromRGB(255, 0, 4);
			BoxColor.Position = UDim2.new(1.60427809, 0, 0.214285716, 0);
			BoxColor.Size = UDim2.new(0, 41, 0, 23);
			BoxColorCorner.CornerRadius = UDim.new(0, 5);
			BoxColorCorner.Name = "BoxColorCorner";
			BoxColorCorner.Parent = BoxColor;
			ConfirmBtn.Name = "ConfirmBtn";
			ConfirmBtn.Parent = ColorpickerTitle;
			ConfirmBtn.BackgroundColor3 = Color3.fromRGB(34, 34, 34);
			ConfirmBtn.Position = UDim2.new(1.25814295, 0, 1.09037197, 0);
			ConfirmBtn.Size = UDim2.new(0, 105, 0, 32);
			ConfirmBtn.AutoButtonColor = false;
			ConfirmBtn.Font = Enum.Font.SourceSans;
			ConfirmBtn.Text = "";
			ConfirmBtn.BackgroundTransparency = 0.5;
			ConfirmBtn.TextColor3 = Color3.fromRGB(0, 0, 0);
			ConfirmBtn.TextSize = 14;
			ConfirmBtnCorner.CornerRadius = UDim.new(0, 5);
			ConfirmBtnCorner.Name = "ConfirmBtnCorner";
			ConfirmBtnCorner.Parent = ConfirmBtn;
			ConfirmBtnTitle.Name = "ConfirmBtnTitle";
			ConfirmBtnTitle.Parent = ConfirmBtn;
			ConfirmBtnTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			ConfirmBtnTitle.BackgroundTransparency = 1;
			ConfirmBtnTitle.Size = UDim2.new(0, 33, 0, 32);
			ConfirmBtnTitle.Font = Enum.Font.GothamBlack;
			ConfirmBtnTitle.Text = "Confirm";
			ConfirmBtnTitle.TextColor3 = Color3.fromRGB(255, 255, 255);
			ConfirmBtnTitle.TextSize = 14;
			ConfirmBtnTitle.TextXAlignment = Enum.TextXAlignment.Left;
			ColorpickerBtn.Name = "ColorpickerBtn";
			ColorpickerBtn.Parent = ColorpickerTitle;
			ColorpickerBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			ColorpickerBtn.BackgroundTransparency = 1;
			ColorpickerBtn.Size = UDim2.new(0, 363, 0, 42);
			ColorpickerBtn.Font = Enum.Font.SourceSans;
			ColorpickerBtn.Text = "";
			ColorpickerBtn.TextColor3 = Color3.fromRGB(0, 0, 0);
			ColorpickerBtn.TextSize = 14;
			RainbowToggle.Name = "RainbowToggle";
			RainbowToggle.Parent = ColorpickerTitle;
			RainbowToggle.BackgroundColor3 = Color3.fromRGB(34, 34, 34);
			RainbowToggle.Position = UDim2.new(1.26349044, 0, 2.12684202, 0);
			RainbowToggle.Size = UDim2.new(0, 104, 0, 32);
			RainbowToggle.AutoButtonColor = false;
			RainbowToggle.BackgroundTransparency = 0.5;
			RainbowToggle.Font = Enum.Font.SourceSans;
			RainbowToggle.Text = "";
			RainbowToggle.TextColor3 = Color3.fromRGB(0, 0, 0);
			RainbowToggle.TextSize = 14;
			RainbowToggleCorner.CornerRadius = UDim.new(0, 5);
			RainbowToggleCorner.Name = "RainbowToggleCorner";
			RainbowToggleCorner.Parent = RainbowToggle;
			RainbowToggleTitle.Name = "RainbowToggleTitle";
			RainbowToggleTitle.Parent = RainbowToggle;
			RainbowToggleTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			RainbowToggleTitle.BackgroundTransparency = 1;
			RainbowToggleTitle.Size = UDim2.new(0, 33, 0, 32);
			RainbowToggleTitle.Font = Enum.Font.GothamBlack;
			RainbowToggleTitle.Text = "Rainbow";
			RainbowToggleTitle.TextColor3 = Color3.fromRGB(255, 255, 255);
			RainbowToggleTitle.TextSize = 14;
			RainbowToggleTitle.TextXAlignment = Enum.TextXAlignment.Left;
			FrameRainbowToggle1.Name = "FrameRainbowToggle1";
			FrameRainbowToggle1.Parent = RainbowToggle;
			FrameRainbowToggle1.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
			FrameRainbowToggle1.BackgroundTransparency = 0.5;
			FrameRainbowToggle1.Position = UDim2.new(0.649999976, 0, 0.186000004, 0);
			FrameRainbowToggle1.Size = UDim2.new(0, 37, 0, 18);
			FrameRainbowToggle1Corner.Name = "FrameRainbowToggle1Corner";
			FrameRainbowToggle1Corner.Parent = FrameRainbowToggle1;
			FrameRainbowToggle2.Name = "FrameRainbowToggle2";
			FrameRainbowToggle2.Parent = FrameRainbowToggle1;
			FrameRainbowToggle2.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
			FrameRainbowToggle2.BackgroundTransparency = 0.5;
			FrameRainbowToggle2.Position = UDim2.new(0.0590000004, 0, 0.112999998, 0);
			FrameRainbowToggle2.Size = UDim2.new(0, 33, 0, 14);
			FrameRainbowToggle2_2.Name = "FrameRainbowToggle2";
			FrameRainbowToggle2_2.Parent = FrameRainbowToggle2;
			FrameRainbowToggle3.Name = "FrameRainbowToggle3";
			FrameRainbowToggle3.Parent = FrameRainbowToggle1;
			FrameRainbowToggle3.BackgroundColor3 = Color3.fromRGB(30, 30, 30);
			FrameRainbowToggle3.BackgroundTransparency = 1;
			FrameRainbowToggle3.Size = UDim2.new(0, 37, 0, 18);
			FrameToggle3.Name = "FrameToggle3";
			FrameToggle3.Parent = FrameRainbowToggle3;
			FrameRainbowToggleCircle.Name = "FrameRainbowToggleCircle";
			FrameRainbowToggleCircle.Parent = FrameRainbowToggle1;
			FrameRainbowToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0);
			FrameRainbowToggleCircle.Position = UDim2.new(0.127000004, 0, 0.222000003, 0);
			FrameRainbowToggleCircle.Size = UDim2.new(0, 10, 0, 10);
			FrameRainbowToggleCircleCorner.Name = "FrameRainbowToggleCircleCorner";
			FrameRainbowToggleCircleCorner.Parent = FrameRainbowToggleCircle;
			Color.Name = "Color";
			Color.Parent = ColorpickerTitle;
			Color.BackgroundColor3 = Color3.fromRGB(255, 0, 4);
			Color.Position = UDim2.new(0, 0, 0, 42);
			Color.Size = UDim2.new(0, 194, 0, 80);
			Color.ZIndex = 10;
			Color.Image = "rbxassetid://4155801252";
			ColorCorner.CornerRadius = UDim.new(0, 3);
			ColorCorner.Name = "ColorCorner";
			ColorCorner.Parent = Color;
			ColorSelection.Name = "ColorSelection";
			ColorSelection.Parent = Color;
			ColorSelection.AnchorPoint = Vector2.new(0.5, 0.5);
			ColorSelection.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			ColorSelection.BackgroundTransparency = 1;
			ColorSelection.Position = UDim2.new(ThemeColor and select(3, Color3.toHSV(ThemeColor)));
			ColorSelection.Size = UDim2.new(0, 18, 0, 18);
			ColorSelection.Image = "http://www.roblox.com/asset/?id=4805639000";
			ColorSelection.ScaleType = Enum.ScaleType.Fit;
			ColorSelection.Visible = false;
			Hue.Name = "Hue";
			Hue.Parent = ColorpickerTitle;
			Hue.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			Hue.Position = UDim2.new(0, 202, 0, 42);
			Hue.Size = UDim2.new(0, 25, 0, 80);
			HueCorner.CornerRadius = UDim.new(0, 3);
			HueCorner.Name = "HueCorner";
			HueCorner.Parent = Hue;
			HueGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 4)),ColorSequenceKeypoint.new(0.2, Color3.fromRGB(234, 255, 0)),ColorSequenceKeypoint.new(0.4, Color3.fromRGB(21, 255, 0)),ColorSequenceKeypoint.new(0.6, Color3.fromRGB(0, 255, 255)),ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0, 17, 255)),ColorSequenceKeypoint.new(0.9, Color3.fromRGB(255, 0, 251)),ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 4))});
			HueGradient.Rotation = 270;
			HueGradient.Name = "HueGradient";
			HueGradient.Parent = Hue;
			HueSelection.Name = "HueSelection";
			HueSelection.Parent = Hue;
			HueSelection.AnchorPoint = Vector2.new(0.5, 0.5);
			HueSelection.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			HueSelection.BackgroundTransparency = 1;
			HueSelection.Position = UDim2.new(0.48, 0, 1 - select(1, Color3.toHSV(ThemeColor)));
			HueSelection.Size = UDim2.new(0, 18, 0, 18);
			HueSelection.Image = "http://www.roblox.com/asset/?id=4805639000";
			HueSelection.Visible = false;
			task.spawn(function()
				while ScreenGui.Parent do
					FrameRainbowToggle3.BackgroundColor3 = ThemeColor;
					Colorpicker.BackgroundColor3 = ThemeColor;
					ConfirmBtn.BackgroundColor3 = ThemeColor;
					RainbowToggle.BackgroundColor3 = ThemeColor;
					task.wait();
				end
			end);
			local ColorPicker = {Value=Info.Default,Transparency=(Info.Transparency or 0),Type="ColorPicker",Title=(((type(Info.Title) == "string") and Info.Title) or "Color picker"),Callback=(Info.Callback or function(Color)
			end)};
			ColorPicker.Display = function(self)
				ColorPicker.Value = Color3.fromHSV(ColorH, ColorS, ColorV);
				BoxColor.BackgroundColor3 = Color3.fromHSV(ColorH, ColorS, ColorV);
				Color.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1);
				Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value);
				Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value);
			end;
			Library.Connections[#Library.Connections + 1] = ColorpickerBtn.MouseButton1Click:Connect(function()
				if (ColorPickerToggled == false) then
					ColorSelection.Visible = true;
					HueSelection.Visible = true;
					Colorpicker.Size = UDim2.new(0, 363, 0, 132);
					task.wait(0.2);
					Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y);
				else
					ColorSelection.Visible = false;
					HueSelection.Visible = false;
					Colorpicker.Size = UDim2.new(0, 363, 0, 42);
					task.wait(0.2);
					Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y);
				end
				ColorPickerToggled = not ColorPickerToggled;
			end);
			local function UpdateColorPicker(nope)
				BoxColor.BackgroundColor3 = Color3.fromHSV(ColorH, ColorS, ColorV);
				Color.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1);
				Library:SafeCallback(ColorPicker.Callback, BoxColor.BackgroundColor3);
				Library:SafeCallback(ColorPicker.Changed, BoxColor.BackgroundColor3);
			end
			ColorH = 1 - (math.clamp(HueSelection.AbsolutePosition.Y - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y) / Hue.AbsoluteSize.Y);
			ColorS = math.clamp(ColorSelection.AbsolutePosition.X - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X) / Color.AbsoluteSize.X;
			ColorV = 1 - (math.clamp(ColorSelection.AbsolutePosition.Y - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y);
			ColorPicker.Value = Info.Default;
			BoxColor.BackgroundColor3 = Info.Default;
			Color.BackgroundColor3 = Info.Default;
			Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value);
			Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value);
			Library.Connections[#Library.Connections + 1] = Color.InputBegan:Connect(function(input)
				if ((input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch)) then
					if RainbowColorPicker then
						return;
					end
					if ColorInput then
						ColorInput:Disconnect();
					end
					ColorInput = RunService.RenderStepped:Connect(function()
						local ColorX = math.clamp(Mouse.X - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X) / Color.AbsoluteSize.X;
						local ColorY = math.clamp(Mouse.Y - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y;
						ColorSelection.Position = UDim2.new(ColorX, 0, ColorY, 0);
						ColorS = ColorX;
						ColorV = 1 - ColorY;
						ColorPicker:Display();
					end);
					Library:AttemptSave();
				end
			end);
			Library.Connections[#Library.Connections + 1] = Color.InputEnded:Connect(function(input)
				if ((input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch)) then
					if ColorInput then
						ColorInput:Disconnect();
					end
				end
			end);
			Library.Connections[#Library.Connections + 1] = Hue.InputBegan:Connect(function(input)
				if ((input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch)) then
					if RainbowColorPicker then
						return;
					end
					if HueInput then
						HueInput:Disconnect();
					end
					HueInput = RunService.RenderStepped:Connect(function()
						local HueY = math.clamp(Mouse.Y - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y) / Hue.AbsoluteSize.Y;
						HueSelection.Position = UDim2.new(0.48, 0, HueY, 0);
						ColorH = 1 - HueY;
						ColorPicker:Display();
					end);
					Library:AttemptSave();
				end
			end);
			Library.Connections[#Library.Connections + 1] = Hue.InputEnded:Connect(function(input)
				if ((input.UserInputType == Enum.UserInputType.MouseButton1) or (input.UserInputType == Enum.UserInputType.Touch)) then
					if HueInput then
						HueInput:Disconnect();
					end
				end
			end);
			RainbowToggle.MouseButton1Down:Connect(function()
				RainbowColorPicker = not RainbowColorPicker;
				if ColorInput then
					ColorInput:Disconnect();
				end
				if HueInput then
					HueInput:Disconnect();
				end
				if RainbowColorPicker then
					FrameRainbowToggleCircle.BackgroundColor3 = Color3.fromRGB(0, 255, 0);
					FrameRainbowToggleCircle.Position = UDim2.new(0.587, 0, 0.222000003, 0);
					OldToggleColor = BoxColor.BackgroundColor3;
					OldColor = Color.BackgroundColor3;
					OldColorSelectionPosition = ColorSelection.Position;
					OldHueSelectionPosition = HueSelection.Position;
					while RainbowColorPicker do
						BoxColor.BackgroundColor3 = Color3.fromHSV(Library.RainbowColorValue, 1, 1);
						Color.BackgroundColor3 = Color3.fromHSV(Library.RainbowColorValue, 1, 1);
						ColorSelection.Position = UDim2.new(1, 0, 0, 0);
						HueSelection.Position = UDim2.new(0.48, 0, 0, Library.HueSelectionPosition);
						Library:SafeCallback(ColorPicker.Callback, BoxColor.BackgroundColor3);
						Library:SafeCallback(ColorPicker.Changed, BoxColor.BackgroundColor3);
						task.wait();
					end
				elseif not RainbowColorPicker then
					FrameRainbowToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 0, 0);
					FrameRainbowToggleCircle.Position = UDim2.new(0.127000004, 0, 0.222000003, 0);
					BoxColor.BackgroundColor3 = OldToggleColor;
					Color.BackgroundColor3 = OldColor;
					ColorSelection.Position = OldColorSelectionPosition;
					HueSelection.Position = OldHueSelectionPosition;
					Library:SafeCallback(ColorPicker.Callback, BoxColor.BackgroundColor3);
					Library:SafeCallback(ColorPicker.Changed, BoxColor.BackgroundColor3);
				end
			end);
			Library.Connections[#Library.Connections + 1] = ConfirmBtn.MouseButton1Click:Connect(function()
				ColorSelection.Visible = false;
				HueSelection.Visible = false;
				Colorpicker.Size = UDim2.new(0, 363, 0, 42);
				task.wait(0.2);
				Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y);
			end);
			ColorPicker.OnChanged = function(self, Func)
				ColorPicker.Changed = Func;
				Func(ColorPicker.Value);
			end;
			ColorPicker.SetHSVFromRGB = function(self, col)
				local H, S, V = Color3.toHSV(col);
				ColorPicker.Hue = H;
				ColorPicker.Sat = S;
				ColorPicker.Vib = V;
			end;
			ColorPicker.SetValueRGB = function(self, col, Transparency)
				ColorPicker.Transparency = Transparency or 0;
				ColorPicker.Value = col;
				BoxColor.BackgroundColor3 = col;
				Color.BackgroundColor3 = col;
				Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value);
				Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value);
			end;
			Options[Idx] = ColorPicker;
			Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y);
			return ColorPicker;
		end;
		Container.Label = function(self, text)
			local Label = Instance.new("TextButton");
			local DropdownCorner = Instance.new("UICorner");
			local LabelTitle = Instance.new("TextLabel");
			Label.Name = "Button";
			Label.Parent = Tab;
			Label.Size = UDim2.new(0, 363, 0, 42);
			Label.AutoButtonColor = false;
			Label.Font = Enum.Font.SourceSans;
			Label.BackgroundTransparency = 0.5;
			Label.Text = "";
			Label.TextColor3 = Color3.fromRGB(0, 0, 0);
			Label.TextSize = 14;
			DropdownCorner.CornerRadius = UDim.new(0, 5);
			DropdownCorner.Name = "ButtonCorner";
			DropdownCorner.Parent = Label;
			LabelTitle.Name = "ButtonTitle";
			LabelTitle.Parent = Label;
			LabelTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			LabelTitle.BackgroundTransparency = 1;
			LabelTitle.Position = UDim2.new(0.0358126722, 0, 0, 0);
			LabelTitle.Size = UDim2.new(0, 187, 0, 42);
			LabelTitle.Font = Enum.Font.GothamBlack;
			LabelTitle.Text = text;
			LabelTitle.TextColor3 = Color3.fromRGB(255, 255, 255);
			LabelTitle.TextSize = 14;
			LabelTitle.TextXAlignment = Enum.TextXAlignment.Left;
			task.spawn(function()
				while ScreenGui.Parent do
					Label.BackgroundColor3 = ThemeColor;
					task.wait();
				end
			end);
			local Label = {};
			Label.SetText = function(self, Text)
				LabelTitle.Text = Text;
			end;
			Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y);
			return Label;
		end;
		Container.MakeTextbox = function(self, Idx, Info)
			assert(Info.Text, "AddInput: Missing `Text` string.");
			local Textbox = {Value=(Info.Default or ""),Default=Info.Default,Type="Input",Callback=(Info.Callback or function(Value)
			end)};
			local MainTextbox = Instance.new("Frame");
			local TextboxCorner = Instance.new("UICorner");
			local TextboxTitle = Instance.new("TextLabel");
			local TextboxFrame = Instance.new("Frame");
			local TextboxFrameCorner = Instance.new("UICorner");
			local TextBox = Instance.new("TextBox");
			MainTextbox.Name = "MainTextbox";
			MainTextbox.Parent = Tab;
			MainTextbox.BackgroundTransparency = 0.5;
			MainTextbox.ClipsDescendants = true;
			MainTextbox.Position = UDim2.new(-0.541071415, 0, -0.532915354, 0);
			MainTextbox.Size = UDim2.new(0, 363, 0, 42);
			TextboxCorner.CornerRadius = UDim.new(0, 5);
			TextboxCorner.Name = "TextboxCorner";
			TextboxCorner.Parent = MainTextbox;
			TextboxTitle.Name = "TextboxTitle";
			TextboxTitle.Parent = MainTextbox;
			TextboxTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			TextboxTitle.BackgroundTransparency = 1;
			TextboxTitle.Position = UDim2.new(0.0358126722, 0, 0, 0);
			TextboxTitle.Size = UDim2.new(0, 187, 0, 42);
			TextboxTitle.Font = Enum.Font.GothamBlack;
			TextboxTitle.Text = Info.Text or "Text Example";
			TextboxTitle.TextColor3 = Color3.fromRGB(255, 255, 255);
			TextboxTitle.TextSize = 14;
			TextboxTitle.TextXAlignment = Enum.TextXAlignment.Left;
			TextboxFrame.Name = "TextboxFrame";
			TextboxFrame.Parent = TextboxTitle;
			TextboxFrame.BackgroundTransparency = 1;
			TextboxFrame.BackgroundColor3 = Color3.fromRGB(37, 37, 37);
			TextboxFrame.Position = UDim2.new(1.28877008, 0, 0.214285716, 0);
			TextboxFrame.Size = UDim2.new(0, 100, 0, 23);
			TextboxFrameCorner.CornerRadius = UDim.new(0, 5);
			TextboxFrameCorner.Name = "TextboxFrameCorner";
			TextboxFrameCorner.Parent = TextboxFrame;
			TextBox.Parent = TextboxFrame;
			TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			TextBox.BackgroundTransparency = 1;
			TextBox.Size = UDim2.new(0, 100, 0, 23);
			TextBox.Font = Enum.Font.Gotham;
			TextBox.Text = Info.Default or "Enter Text";
			TextBox.TextColor3 = Color3.fromRGB(255, 255, 255);
			TextBox.TextSize = 14;
			task.spawn(function()
				while ScreenGui.Parent do
					MainTextbox.BackgroundColor3 = ThemeColor;
					task.wait();
				end
			end);
			Textbox.SetValue = function(self, Text)
				if (Info.MaxLength and (#Text > Info.MaxLength)) then
					Text = Text:sub(1, Info.MaxLength);
				end
				if Textbox.Numeric then
					if (not tonumber(Text) and (Text:len() > 0)) then
						Text = Textbox.Value;
					end
				end
				Textbox.Value = Text;
				TextBox.Text = Text;
				Library:SafeCallback(Textbox.Callback, Textbox.Value);
				Library:SafeCallback(Textbox.Changed, Textbox.Value);
			end;
			if Textbox.Finished then
				TextBox.FocusLost:Connect(function(enter)
					if not enter then
						return;
					end
					Textbox:SetValue(TextBox.Text);
					Library:AttemptSave();
				end);
			else
				TextBox:GetPropertyChangedSignal("Text"):Connect(function()
					Textbox:SetValue(TextBox.Text);
					Textbox.LastText = TextBox.Text;
					Library:AttemptSave();
				end);
			end
			Textbox.OnChanged = function(self, Func)
				Textbox.Changed = Func;
				Func(Textbox.Value);
			end;
			Options[Idx] = Textbox;
			Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y);
			return Textbox;
		end;
		Container.Bind = function(self, Idx, Info)
			assert(Info.Text, "AddInput: Missing `Text` string.");
			local Textbox = {Value=(Info.Default or ""),Default=Info.Default,Type="Input",Callback=(Info.Callback or function(Value)
			end)};
			local binding = false;
			local Key = Info.Default or "None";
			local Bind = Instance.new("TextButton");
			local BindCorner = Instance.new("UICorner");
			local BindTitle = Instance.new("TextLabel");
			local BindText = Instance.new("TextLabel");
			Bind.Name = "Bind";
			Bind.Parent = Tab;
			Bind.Size = UDim2.new(0, 363, 0, 42);
			Bind.AutoButtonColor = false;
			Bind.Font = Enum.Font.SourceSans;
			Bind.BackgroundTransparency = 0.5;
			Bind.Text = "";
			Bind.TextColor3 = Color3.fromRGB(0, 0, 0);
			Bind.TextSize = 14;
			BindCorner.CornerRadius = UDim.new(0, 5);
			BindCorner.Name = "BindCorner";
			BindCorner.Parent = Bind;
			BindTitle.Name = "BindTitle";
			BindTitle.Parent = Bind;
			BindTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			BindTitle.BackgroundTransparency = 1;
			BindTitle.Position = UDim2.new(0.0358126722, 0, 0, 0);
			BindTitle.Size = UDim2.new(0, 187, 0, 42);
			BindTitle.Font = Enum.Font.GothamBlack;
			BindTitle.Text = Info.Text or "Default Bind";
			BindTitle.TextColor3 = Color3.fromRGB(255, 255, 255);
			BindTitle.TextSize = 14;
			BindTitle.TextXAlignment = Enum.TextXAlignment.Left;
			BindText.Name = "BindText";
			BindText.Parent = Bind;
			BindText.BackgroundColor3 = Color3.fromRGB(255, 255, 255);
			BindText.BackgroundTransparency = 1;
			BindText.Position = UDim2.new(0.0358126722, 0, 0, 0);
			BindText.Size = UDim2.new(0, 337, 0, 42);
			BindText.Font = Enum.Font.Gotham;
			BindText.Text = Info.Default or "Enter Key";
			BindText.TextColor3 = Color3.fromRGB(255, 255, 255);
			BindText.TextSize = 14;
			BindText.TextXAlignment = Enum.TextXAlignment.Right;
			task.spawn(function()
				while ScreenGui.Parent do
					Bind.BackgroundColor3 = ThemeColor;
					task.wait();
				end
			end);
			Library.Connections[#Library.Connections + 1] = Bind.MouseButton1Click:Connect(function()
				BindText.Text = "...";
				binding = true;
				local inputwait = InputService.InputBegan:wait();
				if (inputwait.KeyCode.Name ~= "Unknown") then
					BindText.Text = inputwait.KeyCode.Name;
					Key = inputwait.KeyCode.Name;
					binding = false;
				else
					binding = false;
				end
				Library:AttemptSave();
			end);
			Library.Connections[#Library.Connections + 1] = InputService.InputBegan:connect(function(current, pressed)
				if not pressed then
					if ((current.KeyCode.Name == Key) and (binding == false) and not table.find(blacklistedKeybinds, current.KeyCode)) then
						Textbox.Value = Key;
						Library:SafeCallback(Textbox.Callback, Textbox.Value);
						Library:SafeCallback(Textbox.Changed, Textbox.Value);
					end
				end
				Library:AttemptSave();
			end);
			Textbox.OnChanged = function(self, Func)
				Textbox.Changed = Func;
				Func(Textbox.Value);
			end;
			Textbox.SetValue = function(self, Text)
				Textbox.Value = tostring(Text);
				BindText.Text = tostring(Text);
				Library:SafeCallback(Textbox.Callback, Textbox.Value);
				Library:SafeCallback(Textbox.Changed, Textbox.Value);
			end;
			Options[Idx] = Textbox;
			Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y);
			return Textbox;
		end;
		return Container;
	end;
	return Content;
end;
return Library;
