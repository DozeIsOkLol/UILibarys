-- Setup

makefolder("edge_ui_library")


-- Variables

local players = game:GetService("Players")
local tween_service = game:GetService("TweenService")
local user_input_service = game:GetService("UserInputService")
local http_service = game:GetService('HttpService')
local core_gui = game:GetService("CoreGui")

local local_player = players.LocalPlayer

local mouse = local_player:GetMouse()

if not getgenv().color_scheme then
	getgenv().color_schemes = {
		white_blue = {
			dark_color = Color3.fromRGB(0, 78, 152),
			dark_hover_color = Color3.fromRGB(0, 65, 125),
			background_color = Color3.fromRGB(235, 235, 235),
			section_background_color = Color3.fromRGB(192, 192, 192),
			misc_elements_color = Color3.fromRGB(235, 235, 235),
			elements_color = Color3.fromRGB(58, 110, 165),
			elements_hover_color = Color3.fromRGB(49, 94, 139),
			enabled_color = Color3.fromRGB(255, 103, 0),
			enabled_hover_color = Color3.fromRGB(221, 88, 0),
			scroll_bar_color = Color3.fromRGB(0, 0, 0)
		}
	}

	getgenv().color_scheme = getgenv().color_schemes.white_blue
end



local function create_window(window_info)
	-- Variables

	local window_functions = {}

	local tabs = 0

	window_functions.window_name = math.random(1, 3e8)




	-- Setup

	if isfile("edge_ui_library/last_window_name" .. "_" .. local_player.Name .. ".txt") then
		-- Variables

		local last_window_name = readfile("edge_ui_library/last_window_name" .. "_" .. local_player.Name .. ".txt")



		if core_gui:FindFirstChild(last_window_name) and last_window_name ~= window_functions.window_name then
			core_gui[last_window_name]:Destroy()
		end
	end

	writefile("edge_ui_library/last_window_name" .. "_" .. local_player.Name .. ".txt", window_functions.window_name)




	-- Create instances

	local edge_ui_library = Instance.new("ScreenGui")



	-- Properties

	edge_ui_library.IgnoreGuiInset = true
	edge_ui_library.ResetOnSpawn = false
	edge_ui_library.Name = window_functions.window_name
	edge_ui_library.Parent = core_gui

	if syn and syn.protect_gui then
		syn.protect_gui(edge_ui_library)
	end





	-- Functions

	function window_functions.new_tab(tab_name)
		-- Variables

		local tab_functions = {}

		local auto_resize_enabled = false

		local tab_busy = false


		-- Create instances

		local tab_button = Instance.new("Frame")
		local UICorner = Instance.new("UICorner")
		local tab_info = Instance.new("TextLabel")
		local ImageButton = Instance.new("ImageButton")

		local tab_content = Instance.new("Frame")
		local UICorner_1 = Instance.new("UICorner")

		local ScrollingFrame = Instance.new("ScrollingFrame")
		local UIListLayout = Instance.new("UIListLayout")



		-- Properties

		tab_button.BackgroundColor3 = getgenv().color_scheme.dark_color
		tab_button.BorderSizePixel = 0
		tab_button.Position = UDim2.new(0.0645833313, tabs * 240, 0.0851851851, 0)
		tab_button.Size = UDim2.new(0, 230, 0, 34)
		tab_button.ZIndex = 2 + tabs
		tab_button.Parent = edge_ui_library

		UICorner.Parent = tab_button

		tab_info.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
		tab_info.BackgroundTransparency = 1.000
		tab_info.BorderSizePixel = 0
		tab_info.Position = UDim2.new(0.0299999993, 0, 0.205999941, 0)
		tab_info.Size = UDim2.new(0.730434775, 0, 0.600000024, 0)
		tab_info.ZIndex = 2 + tabs
		tab_info.Font = Enum.Font.Gotham
		tab_info.TextColor3 = getgenv().color_scheme.misc_elements_color
		tab_info.TextScaled = true
		tab_info.TextSize = 14.000
		tab_info.TextWrapped = true
		tab_info.TextXAlignment = Enum.TextXAlignment.Left
		tab_info.Text = tab_name
		tab_info.Parent = tab_button

		ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ImageButton.BackgroundTransparency = 1.000
		ImageButton.BorderSizePixel = 0
		ImageButton.Position = UDim2.new(0.88, 0, 0.125, 0)
		ImageButton.Size = UDim2.new(0.111086987, 0, 0.75, 0)
		ImageButton.ZIndex = 2 + tabs
		ImageButton.Image = "rbxassetid://3926305904"
		ImageButton.ImageColor3 = getgenv().color_scheme.misc_elements_color
		ImageButton.ImageRectOffset = Vector2.new(404, 283)
		ImageButton.ImageRectSize = Vector2.new(36, 36)
		ImageButton.Parent = tab_button



		tab_content.BackgroundColor3 = getgenv().color_scheme.background_color
		tab_content.BorderSizePixel = 0
		tab_content.Position = UDim2.new(0, 0, 0.125, 0)
		tab_content.Size = UDim2.new(1, 0, 0, 0)
		tab_content.ZIndex = 1 + tabs
		tab_content.ClipsDescendants = true
		tab_content.Parent = tab_button

		UICorner_1.Parent = tab_content



		ScrollingFrame.Active = true
		ScrollingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ScrollingFrame.BackgroundTransparency = 1.000
		ScrollingFrame.BorderSizePixel = 0
		ScrollingFrame.Position = UDim2.new(0, 0, 0, 36)
		ScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
		ScrollingFrame.ScrollBarThickness = 5
		ScrollingFrame.ScrollBarImageColor3 = getgenv().color_scheme.scroll_bar_color
		ScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
		ScrollingFrame.ZIndex = 2 + tabs
		ScrollingFrame.Parent = tab_content

		UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		UIListLayout.Padding = UDim.new(0, 7)
		UIListLayout.Parent = ScrollingFrame




		-- Connections

		tab_button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputState == Enum.UserInputState.Begin then
				-- Variables

				local frame_start_position = tab_button.Position


				-- Connections

				local move_connection = mouse.Move:Connect(function()
					local delta = UDim2.fromOffset(mouse.X - input.Position.X, mouse.Y - input.Position.Y)

					tween_service:Create(tab_button, TweenInfo.new(0.035, Enum.EasingStyle.Linear), {Position = frame_start_position + delta}):Play()
				end)


				-- Disconnect

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						move_connection:Disconnect()
					end
				end)
			end
		end)


		UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			if auto_resize_enabled then
				tab_content.Size = UDim2.new(1, 0, 0, math.clamp(UIListLayout.AbsoluteContentSize.Y + 42, 0, 780))

				if tab_content.Size.Y.Offset == 780 then
					ScrollingFrame.CanvasSize = UDim2.fromOffset(0, UIListLayout.AbsoluteContentSize.Y + 42)
				else
					ScrollingFrame.CanvasSize = UDim2.fromOffset(0, 0)
				end
			end
		end)


		ImageButton.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputState == Enum.UserInputState.Begin and not tab_busy then
				tab_busy = true


				if tab_content.Size.Y.Offset == 0 then
					tween_service:Create(ImageButton, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {Rotation = 180}):Play()

					tween_service:Create(tab_content, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, math.clamp(UIListLayout.AbsoluteContentSize.Y + 42, 0, 780))}):Play()


					task.delay(0.35, function()
						auto_resize_enabled = true
					end)
				else
					auto_resize_enabled = false


					tween_service:Create(ImageButton, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {Rotation = 0}):Play()

					tween_service:Create(tab_content, TweenInfo.new(0.35, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)}):Play()
				end


				task.delay(0.5, function()
					tab_busy = false
				end)
			end
		end)



		tabs += 1



		-- Functions

		local function hover(frame)
			frame.MouseEnter:Connect(function()
				if not frame:GetAttribute("hover_effect_locked") then
					tween_service:Create(frame, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {BackgroundColor3 = frame:GetAttribute("hover_color")}):Play()
				end
			end)


			frame.MouseLeave:Connect(function()
				if not frame:GetAttribute("hover_effect_locked") then
					tween_service:Create(frame, TweenInfo.new(0.1, Enum.EasingStyle.Sine), {BackgroundColor3 = frame:GetAttribute("color")}):Play()
				end
			end)
		end


		function tab_functions.new_section(section_name)
			-- Variables

			local section_functions = {}

			local auto_resize_enabled = false

			local section_busy = false



			-- Create instances

			local section_button = Instance.new("Frame")
			local UICorner = Instance.new("UICorner")
			local section_info = Instance.new("TextLabel")
			local ImageButton = Instance.new("ImageButton")

			local section_content = Instance.new("Frame")
			local UIListLayout = Instance.new("UIListLayout")
			local UIPadding = Instance.new("UIPadding")
			local UICorner_1 = Instance.new("UICorner")



			-- Properties

			section_button.BackgroundColor3 = getgenv().color_scheme.elements_color
			section_button.BorderSizePixel = 0
			section_button.Position = UDim2.new(0.0217391308, 0, 0, 0)
			section_button.Size = UDim2.new(0, 220, 0, 30)
			section_button.ZIndex = 1 + tabs
			section_button.Parent = ScrollingFrame
			section_button:SetAttribute("color", section_button.BackgroundColor3)
			section_button:SetAttribute("hover_color", getgenv().color_scheme.elements_hover_color)
			hover(section_button)

			UICorner.Parent = section_button

			section_info.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
			section_info.BackgroundTransparency = 1.000
			section_info.BorderSizePixel = 0
			section_info.Position = UDim2.new(0.0299999993, 0, 0.205999941, 0)
			section_info.Size = UDim2.new(0.730434775, 0, 0.600000024, 0)
			section_info.Font = Enum.Font.Gotham
			section_info.TextColor3 = getgenv().color_scheme.misc_elements_color
			section_info.TextScaled = true
			section_info.ZIndex = 1 + tabs
			section_info.TextSize = 14.000
			section_info.TextWrapped = true
			section_info.TextXAlignment = Enum.TextXAlignment.Left
			section_info.Text = section_name
			section_info.Parent = section_button

			ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			ImageButton.BackgroundTransparency = 1.000
			ImageButton.BorderSizePixel = 0
			ImageButton.Position = UDim2.new(0.870999992, 0, 0.0583333299, 0)
			ImageButton.Size = UDim2.new(0.119999997, 0, 0.879999995, 0)
			ImageButton.Image = "rbxassetid://3926305904"
			ImageButton.ZIndex = 1 + tabs
			ImageButton.ImageColor3 = getgenv().color_scheme.misc_elements_color
			ImageButton.ImageRectOffset = Vector2.new(404, 283)
			ImageButton.ImageRectSize = Vector2.new(36, 36)
			ImageButton.Parent = section_button



			section_content.BackgroundColor3 = getgenv().color_scheme.section_background_color
			section_content.BorderSizePixel = 0
			section_content.Position = UDim2.new(0.0217391308, 0, 0.120521173, 0)
			section_content.Size = UDim2.new(0, 220, 0, 0)
			section_content.Visible = false
			section_content.ZIndex = 1 + tabs
			section_content.ClipsDescendants = true
			section_content.Parent = ScrollingFrame

			UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			UIListLayout.Padding = UDim.new(0, 7)
			UIListLayout.Parent = section_content

			UIPadding.PaddingTop = UDim.new(0, 4)
			UIPadding.Parent = section_content

			UICorner_1.CornerRadius = UDim.new(0, 5)
			UICorner_1.Parent = section_content



			-- Connections

			UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				if auto_resize_enabled then
					section_content.Size = UDim2.fromOffset(section_content.Size.X.Offset, UIListLayout.AbsoluteContentSize.Y + 8)
				end
			end)


			for _, v in pairs({section_button, ImageButton}) do
				v.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputState == Enum.UserInputState.Begin and not section_busy then
						-- Variables

						local speed = 0.25 * math.clamp(UIListLayout.AbsoluteContentSize.Y / 266, 1, 1.5)


						-- Setup

						section_busy = true


						-- Tweening

						if not section_content.Visible then
							-- Setup

							section_content.BackgroundTransparency = 0

							for _, v in pairs(section_content:GetChildren()) do
								if v:IsA("Frame") and not v:GetAttribute("content") or v:IsA("Frame") and v:GetAttribute("content_open") then
									v.Visible = true
								end
							end

							section_content.Visible = true


							-- Animation

							tween_service:Create(ImageButton, TweenInfo.new(speed, Enum.EasingStyle.Sine), {Rotation = 180}):Play()

							tween_service:Create(section_content, TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(section_content.Size.X.Offset, UIListLayout.AbsoluteContentSize.Y + 8)}):Play()


							-- Enable auto resize

							task.delay(speed, function()
								auto_resize_enabled = true
							end)
						else
							-- Setup

							auto_resize_enabled = false


							-- Animation

							tween_service:Create(ImageButton, TweenInfo.new(speed, Enum.EasingStyle.Sine), {Rotation = 0}):Play()

							tween_service:Create(section_content, TweenInfo.new(speed, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.fromOffset(section_content.Size.X.Offset, -7)}):Play()


							-- Anti jitter

							local anti_jitter = section_content:GetPropertyChangedSignal("Size"):Connect(function()
								if section_content.Size.Y.Offset <= 0 then
									section_content.BackgroundTransparency = 1

									for _, v in pairs(section_content:GetChildren()) do
										if v:IsA("Frame") then
											v.Visible = false
										end
									end
								end
							end)


							-- Disable auto resize

							task.delay(speed, function()
								anti_jitter:Disconnect()

								section_content.Visible = false

								section_content.Size = UDim2.fromOffset(section_content.Size.X.Offset, 0)
							end)
						end


						task.delay(speed, function()
							section_busy = false
						end)
					end
				end)
			end



			-- Functions

			function section_functions.new_button(button_info, callback)
				-- Variables

				local button_busy = false


				-- Create instances

				local button = Instance.new("Frame")
				local TextLabel = Instance.new("TextLabel")
				local UICorner = Instance.new("UICorner")



				-- Properties

				button.BackgroundColor3 = getgenv().color_scheme.elements_color
				button.BorderColor3 = Color3.fromRGB(27, 42, 53)
				button.Size = UDim2.new(0, 212, 0, 23)
				button.BorderSizePixel = 0
				button.ClipsDescendants = true
				button.ZIndex = 1 + tabs
				button.Parent = section_content
				button:SetAttribute("color", button.BackgroundColor3)
				button:SetAttribute("hover_color", getgenv().color_scheme.elements_hover_color)
				hover(button)

				TextLabel.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
				TextLabel.BackgroundTransparency = 1.000
				TextLabel.Position = UDim2.new(0, 0, 0.150000006, 0)
				TextLabel.Size = UDim2.new(1, 0, 0.699999988, 0)
				TextLabel.Font = Enum.Font.Gotham
				TextLabel.TextColor3 = getgenv().color_scheme.misc_elements_color
				TextLabel.TextScaled = true
				TextLabel.TextSize = 14.000
				TextLabel.TextWrapped = true
				TextLabel.ZIndex = 1 + tabs
				TextLabel.Text = button_info
				TextLabel.Parent = button

				UICorner.CornerRadius = UDim.new(0, 5)
				UICorner.Parent = button



				-- Connections

				button.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputState == Enum.UserInputState.Begin and not button_busy and not section_busy and not tab_busy then
						button_busy = true


						callback()


						-- Button animation

						tween_service:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.fromOffset(0, 23)}):Play()

						tween_service:Create(TextLabel, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {TextTransparency = 1}):Play()

						task.delay(0.3, function()
							tween_service:Create(button, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(212, 23)}):Play()

							tween_service:Create(TextLabel, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()


							task.delay(0.3, function()
								button_busy = false
							end)
						end)
					end
				end)
			end


			function section_functions.new_toggle(toggle_info, callback)
				-- Variables

				local state = false

				local toggle_busy = false



				-- Create instances

				local toggle = Instance.new("Frame")
				local enabled = Instance.new("ImageButton")
				local disabled = Instance.new("ImageButton")
				local TextLabel = Instance.new("TextLabel")
				local UICorner = Instance.new("UICorner")



				-- Properties

				toggle.BackgroundColor3 = getgenv().color_scheme.elements_color
				toggle.BorderColor3 = Color3.fromRGB(27, 42, 53)
				toggle.BorderSizePixel = 0
				toggle.ZIndex = 1 + tabs
				toggle.Position = UDim2.new(0, 0, 0.854922295, 0)
				toggle.Size = UDim2.new(0, 212, 0, 26)
				toggle.Parent = section_content
				toggle:SetAttribute("color", toggle.BackgroundColor3)
				toggle:SetAttribute("hover_color", getgenv().color_scheme.elements_hover_color)
				hover(toggle)

				enabled.BackgroundTransparency = 1.000
				enabled.Position = UDim2.new(0.894999981, 0, 0.125, 0)
				enabled.Size = UDim2.new(0.0900000036, 0, 0.75, 0)
				enabled.ZIndex = 1 + tabs
				enabled.Image = "rbxassetid://3926309567"
				enabled.ImageColor3 = getgenv().color_scheme.enabled_color
				enabled.ImageRectOffset = Vector2.new(784, 420)
				enabled.ImageRectSize = Vector2.new(48, 48)
				enabled.ImageTransparency = 1.000
				enabled.Parent = toggle

				disabled.BackgroundColor3 = Color3.fromRGB(248, 249, 250)
				disabled.BackgroundTransparency = 1.000
				disabled.BorderSizePixel = 0
				disabled.Position = UDim2.new(0.889999986, 0, 0.125, 0)
				disabled.Size = UDim2.new(0.0939999968, 0, 0.75, 0)
				disabled.ZIndex = 1 + tabs
				disabled.Image = "rbxassetid://3926309567"
				disabled.ImageColor3 = getgenv().color_scheme.misc_elements_color
				disabled.ImageRectOffset = Vector2.new(628, 420)
				disabled.ImageRectSize = Vector2.new(48, 48)
				disabled.Parent = toggle

				TextLabel.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
				TextLabel.BackgroundTransparency = 1.000
				TextLabel.Position = UDim2.new(0.0333367847, 0, 0.182999834, 0)
				TextLabel.Size = UDim2.new(0.809493423, 0, 0.633000016, 0)
				TextLabel.ZIndex = 1 + tabs
				TextLabel.Font = Enum.Font.Gotham
				TextLabel.TextColor3 = getgenv().color_scheme.misc_elements_color
				TextLabel.TextScaled = true
				TextLabel.TextSize = 14.000
				TextLabel.TextWrapped = true
				TextLabel.Text = toggle_info
				TextLabel.TextXAlignment = Enum.TextXAlignment.Left
				TextLabel.Parent = toggle

				UICorner.CornerRadius = UDim.new(0, 5)
				UICorner.Parent = toggle



				-- Connections

				for _, v in pairs({toggle, disabled, enabled}) do
					v.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputState == Enum.UserInputState.Begin and not toggle_busy and not section_busy and not tab_busy then
							state = not state

							toggle_info = true


							callback(state)


							if state then
								tween_service:Create(disabled, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {ImageTransparency = 1}):Play()

								tween_service:Create(enabled, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {ImageTransparency = 0}):Play()
							else
								tween_service:Create(disabled, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {ImageTransparency = 0}):Play()

								tween_service:Create(enabled, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {ImageTransparency = 1}):Play()
							end
						end
					end)
				end
			end


			function section_functions.new_text_box(text_box_info, callback)
				-- Create instances

				local text_box = Instance.new("Frame")
				local TextLabel = Instance.new("TextLabel")
				local UICorner = Instance.new("UICorner")
				local Frame = Instance.new("Frame")
				local TextBox = Instance.new("TextBox")
				local UICorner_2 = Instance.new("UICorner")



				-- Properties

				text_box.BackgroundColor3 = getgenv().color_scheme.elements_color
				text_box.BorderColor3 = Color3.fromRGB(27, 42, 53)
				text_box.BorderSizePixel = 0
				text_box.ZIndex = 1 + tabs
				text_box.Position = UDim2.new(0, 0, 0.683937848, 0)
				text_box.Size = UDim2.new(0, 212, 0, 26)
				text_box.Parent = section_content

				TextLabel.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
				TextLabel.BackgroundTransparency = 1.000
				TextLabel.Position = UDim2.new(0.0333367772, 0, 0.182999834, 0)
				TextLabel.Size = UDim2.new(0.477663189, 0, 0.633000016, 0)
				TextLabel.ZIndex = 1 + tabs
				TextLabel.Font = Enum.Font.Gotham
				TextLabel.TextColor3 = getgenv().color_scheme.misc_elements_color
				TextLabel.TextScaled = true
				TextLabel.TextSize = 14.000
				TextLabel.Text = text_box_info
				TextLabel.TextWrapped = true
				TextLabel.TextXAlignment = Enum.TextXAlignment.Left
				TextLabel.Parent = text_box

				UICorner.CornerRadius = UDim.new(0, 5)
				UICorner.Parent = text_box

				Frame.BackgroundColor3 = getgenv().color_scheme.dark_color
				Frame.Position = UDim2.new(0.510999978, 0, 0.100000232, 0)
				Frame.Size = UDim2.new(0.478000015, 0, 0.819999993, 0)
				Frame.ZIndex = 1 + tabs
				Frame.Parent = text_box

				TextBox.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
				TextBox.BackgroundTransparency = 1.000
				TextBox.Position = UDim2.new(0.0323472507, 0, 0.150999993, 0)
				TextBox.Size = UDim2.new(0.936999977, 0, 0.698000014, 0)
				TextBox.ClearTextOnFocus = false
				TextBox.Font = Enum.Font.Gotham
				TextBox.PlaceholderColor3 = Color3.fromRGB(235, 235, 235)
				TextBox.Text = ""
				TextBox.TextColor3 = getgenv().color_scheme.misc_elements_color
				TextBox.TextScaled = true
				TextBox.TextSize = 14.000
				TextBox.ZIndex = 1 + tabs
				TextBox.TextWrapped = true
				TextBox.Parent = Frame

				UICorner_2.CornerRadius = UDim.new(0, 5)
				UICorner_2.Parent = Frame



				-- Connections

				TextBox.Focused:Connect(function()
					tween_service:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {BackgroundColor3 = getgenv().color_scheme.enabled_color}):Play()
				end)


				TextBox.FocusLost:Connect(function(enter_pressed)
					if enter_pressed then
						callback(TextBox.Text)


						tween_service:Create(Frame, TweenInfo.new(0.35, Enum.EasingStyle.Sine), {BackgroundColor3 = getgenv().color_scheme.dark_color}):Play()
					end
				end)
			end


			function section_functions.new_key_bind(key_bind_info, key, callback)
				-- Setup

				assert(key and type(key) == "string", "Incorrect key type")


				-- Variables

				local busy = false


				-- Create instances

				local key_bind = Instance.new("Frame")
				local enabled = Instance.new("ImageButton")
				local info_label = Instance.new("TextLabel")
				local UICorner = Instance.new("UICorner")
				local key_label = Instance.new("TextLabel")



				-- Properties

				key_bind.BackgroundColor3 = getgenv().color_scheme.elements_color
				key_bind.BorderColor3 = Color3.fromRGB(27, 42, 53)
				key_bind.BorderSizePixel = 0
				key_bind.ZIndex = 1 + tabs
				key_bind.Position = UDim2.new(0, 0, 0.15544042, 0)
				key_bind.Size = UDim2.new(0, 212, 0, 26)
				key_bind.Parent = section_content
				key_bind:SetAttribute("color", key_bind.BackgroundColor3)
				key_bind:SetAttribute("hover_color", getgenv().color_scheme.elements_hover_color)
				hover(key_bind)

				info_label.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
				info_label.BackgroundTransparency = 1.000
				info_label.Position = UDim2.new(0.0333367772, 0, 0.182999834, 0)
				info_label.Size = UDim2.new(0.477663189, 0, 0.633000016, 0)
				info_label.ZIndex = 1 + tabs
				info_label.Font = Enum.Font.Gotham
				info_label.Text = key_bind_info
				info_label.TextColor3 = getgenv().color_scheme.misc_elements_color
				info_label.TextScaled = true
				info_label.TextSize = 14.000
				info_label.TextWrapped = true
				info_label.TextXAlignment = Enum.TextXAlignment.Left
				info_label.Parent = key_bind

				UICorner.CornerRadius = UDim.new(0, 5)
				UICorner.Parent = key_bind

				key_label.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
				key_label.BackgroundTransparency = 1.000
				key_label.Position = UDim2.new(0.510999978, 0, 0.182999834, 0)
				key_label.Size = UDim2.new(0.460844964, 0, 0.633000016, 0)
				key_label.ZIndex = 1 + tabs
				key_label.Font = Enum.Font.Gotham
				key_label.TextColor3 = getgenv().color_scheme.misc_elements_color
				key_label.TextScaled = true
				key_label.TextSize = 14.000
				key_label.TextWrapped = true
				key_label.Text = key
				key_label.TextXAlignment = Enum.TextXAlignment.Right
				key_label.Parent = key_bind



				-- Connections

				key_bind.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputState == Enum.UserInputState.Begin and not busy and not section_busy and not tab_busy then
						key_bind:SetAttribute("hover_effect_locked", true)

						busy = true


						tween_service:Create(key_bind, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {BackgroundColor3 = getgenv().color_scheme.enabled_color}):Play()
					end
				end)


				user_input_service.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Keyboard then
						if not busy and input.KeyCode.Name == key_label.Text then
							callback(key_label.Text)
						elseif busy then
							-- Set new key

							key_label.Text = input.KeyCode.Name


							-- Tween color back to normal

							tween_service:Create(key_bind, TweenInfo.new(0.3, Enum.EasingStyle.Sine), {BackgroundColor3 = getgenv().color_scheme.elements_color}):Play()


							-- Debounce end

							busy = false

							key_bind:SetAttribute("hover_effect_locked", false)
						end
					end
				end)
			end


			function section_functions.new_slider(slider_info, min_value, max_value, callback)
				-- Setup

				assert(min_value and max_value and type(min_value) == "number" and type(max_value) == "number", "Incorrect min_value or max_value")


				-- Create instances

				local slider = Instance.new("Frame")
				local info_label = Instance.new("TextLabel")
				local UICorner = Instance.new("UICorner")
				local value_label = Instance.new("TextLabel")
				local bar = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local fill = Instance.new("Frame")
				local UICorner_3 = Instance.new("UICorner")



				-- Properties

				slider.BackgroundColor3 = getgenv().color_scheme.elements_color
				slider.BorderColor3 = Color3.fromRGB(27, 42, 53)
				slider.BorderSizePixel = 0
				slider.ZIndex = 1 + tabs
				slider.Position = UDim2.new(0, 0, 0.326424867, 0)
				slider.Size = UDim2.new(0, 212, 0, 32)
				slider.Parent = section_content
				slider:SetAttribute("color", slider.BackgroundColor3)
				slider:SetAttribute("hover_color", getgenv().color_scheme.elements_hover_color)
				hover(slider)

				info_label.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
				info_label.BackgroundTransparency = 1.000
				info_label.Position = UDim2.new(0.0333367772, 0, 0.15, 0)
				info_label.Size = UDim2.new(0.477663219, 0, 0.5169999, 0)
				info_label.ZIndex = 1 + tabs
				info_label.Font = Enum.Font.Gotham
				info_label.TextColor3 = getgenv().color_scheme.misc_elements_color
				info_label.TextScaled = true
				info_label.TextSize = 14.000
				info_label.Text = slider_info
				info_label.TextWrapped = true
				info_label.TextXAlignment = Enum.TextXAlignment.Left
				info_label.Parent = slider

				UICorner.CornerRadius = UDim.new(0, 5)
				UICorner.Parent = slider

				value_label.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
				value_label.BackgroundTransparency = 1.000
				value_label.Position = UDim2.new(0.510999978, 0, 0.15, 0)
				value_label.Size = UDim2.new(0.460844964, 0, 0.5169999, 0)
				value_label.ZIndex = 1 + tabs
				value_label.Font = Enum.Font.Gotham
				value_label.Text = min_value
				value_label.TextColor3 = getgenv().color_scheme.misc_elements_color
				value_label.TextScaled = true
				value_label.TextSize = 14.000
				value_label.TextWrapped = true
				value_label.TextXAlignment = Enum.TextXAlignment.Right
				value_label.Parent = slider

				bar.BackgroundColor3 = getgenv().color_scheme.dark_color
				bar.BorderColor3 = Color3.fromRGB(255, 255, 255)
				bar.BorderSizePixel = 0
				bar.Position = UDim2.new(0.0333369859, 0, 0.720000029, 0)
				bar.Size = UDim2.new(0.93963027, 0, 0.115000002, 0)
				bar.ZIndex = 1 + tabs
				bar.Parent = slider

				UICorner_2.CornerRadius = UDim.new(0, 100)
				UICorner_2.Parent = bar

				fill.BackgroundColor3 = getgenv().color_scheme.enabled_color
				fill.BorderColor3 = Color3.fromRGB(255, 255, 255)
				fill.BorderSizePixel = 0
				fill.Size = UDim2.new(0.581381083, 0, 1, 0)
				fill.ZIndex = 1 + tabs
				fill.Parent = bar

				UICorner_3.CornerRadius = UDim.new(0, 100)
				UICorner_3.Parent = fill



				-- Functions

				local function fill_1()
					-- Variables

					local delta = math.clamp((mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)


					-- Callback

					callback(math.clamp(delta * max_value, min_value, max_value))


					-- Change value

					value_label.Text = math.ceil(delta * max_value)


					-- Fill

					tween_service:Create(fill, TweenInfo.new(0.04, Enum.EasingStyle.Linear), {Size = UDim2.fromScale(delta, 1)}):Play()
				end



				-- Connections

				slider.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputState == Enum.UserInputState.Begin then
						-- Setup

						fill_1()


						-- Connections

						local move_connection = mouse.Move:Connect(function()
							fill_1()
						end)


						-- Disconnect

						input.Changed:Connect(function()
							if input.UserInputState == Enum.UserInputState.End then
								move_connection:Disconnect()
							end
						end)
					end
				end)
			end


			function section_functions.new_dropdown(dropdown_info, array, callback)
				-- Setup

				assert(type(array) == "table" and #array > 0 or type(array) == "function" and #array() > 0 and callback, "Incorrect table type")				


				-- Variables

				local busy = false

				local selected_element


				-- Create instances

				local dropdown = Instance.new("Frame")
				local UICorner = Instance.new("UICorner")
				local ImageButton = Instance.new("ImageButton")
				local TextLabel = Instance.new("TextLabel")

				local dropdown_content = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local UIListLayout = Instance.new("UIListLayout")



				-- Properties

				dropdown.BackgroundColor3 = getgenv().color_scheme.elements_color
				dropdown.BorderColor3 = Color3.fromRGB(27, 42, 53)
				dropdown.Position = UDim2.new(0, 0, 0.528497398, 0)
				dropdown.Size = UDim2.new(0, 212, 0, 23)
				dropdown.ZIndex = 1 + tabs
				dropdown.Parent = section_content
				dropdown:SetAttribute("color", dropdown.BackgroundColor3)
				dropdown:SetAttribute("hover_color", getgenv().color_scheme.elements_hover_color)
				hover(dropdown)

				UICorner.CornerRadius = UDim.new(0, 5)
				UICorner.Parent = dropdown

				ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ImageButton.BackgroundTransparency = 1.000
				ImageButton.BorderSizePixel = 0
				ImageButton.Position = UDim2.new(0.88499999, 0, 0, 0)
				ImageButton.Size = UDim2.new(0.109999992, 0, 1, 0)
				ImageButton.ZIndex = 1 + tabs
				ImageButton.Image = "rbxassetid://3926305904"
				ImageButton.ImageColor3 = getgenv().color_scheme.misc_elements_color
				ImageButton.ImageRectOffset = Vector2.new(404, 283)
				ImageButton.ImageRectSize = Vector2.new(36, 36)
				ImageButton.Parent = dropdown

				TextLabel.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
				TextLabel.BackgroundTransparency = 1.000
				TextLabel.Position = UDim2.new(0.0329999737, 0, 0.150000006, 0)
				TextLabel.Size = UDim2.new(0.772727251, 0, 0.699999988, 0)
				TextLabel.ZIndex = 1 + tabs
				TextLabel.Font = Enum.Font.Gotham
				TextLabel.TextColor3 = getgenv().color_scheme.misc_elements_color
				TextLabel.TextScaled = true
				TextLabel.TextSize = 14.000
				TextLabel.Text = dropdown_info
				TextLabel.TextWrapped = true
				TextLabel.TextXAlignment = Enum.TextXAlignment.Left
				TextLabel.Parent = dropdown



				dropdown_content.BackgroundColor3 = getgenv().color_scheme.elements_color
				dropdown_content.BorderColor3 = Color3.fromRGB(27, 42, 53)
				dropdown_content.Position = UDim2.new(0.0181818176, 0, 0.461538464, 0)
				dropdown_content.Size = UDim2.new(0, 212, 0, 0)
				dropdown_content.BorderSizePixel = 0
				dropdown_content.ZIndex = 1 + tabs
				dropdown_content.ClipsDescendants = true
				dropdown_content.Visible = false
				dropdown_content.Parent = section_content
				dropdown_content:SetAttribute("content", true)
				dropdown_content:SetAttribute("content_open", false)

				UICorner_1.CornerRadius = UDim.new(0, 5)
				UICorner_1.Parent = dropdown_content

				UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
				UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout.Padding = UDim.new(0, 5)
				UIListLayout.Parent = dropdown_content



				-- Functions

				local function change_state(state)
					-- Setup

					busy = true


					-- Variables

					local speed = math.clamp(0.25 * (UIListLayout.AbsoluteContentSize.Y / 72), 0, 0.75)


					-- Open or close			

					if not state then
						-- Animation

						tween_service:Create(ImageButton, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {Rotation = 0}):Play()

						if type(array) == "function" and #array() < 3 or type(array) == "table" and #array < 3 then
							tween_service:Create(dropdown_content, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(dropdown_content.Size.X.Offset, -7)}):Play()
						else
							tween_service:Create(dropdown_content, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.fromOffset(dropdown_content.Size.X.Offset, -7)}):Play()
						end


						-- Anti jitter

						local anti_jitter = dropdown_content:GetPropertyChangedSignal("Size"):Connect(function()
							if dropdown_content.Size.Y.Offset <= 0 then
								dropdown_content.BackgroundTransparency = 1

								for _, v in pairs(dropdown_content:GetChildren()) do
									if v:IsA("Frame") then
										v.Visible = false
									end
								end
							end
						end)


						-- Destroy all elements

						task.delay(speed, function()
							anti_jitter:Disconnect()

							dropdown_content:SetAttribute("content_open", false)

							dropdown_content.Visible = false

							dropdown_content.Size = UDim2.fromOffset(dropdown_content.Size.X.Offset, 0)
						end)
					else
						dropdown_content:SetAttribute("content_open", true)

						dropdown_content.BackgroundTransparency = 0

						dropdown_content.Visible = true


						tween_service:Create(ImageButton, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {Rotation = 180}):Play()

						tween_service:Create(dropdown_content, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(dropdown_content.Size.X.Offset, UIListLayout.AbsoluteContentSize.Y)}):Play()
					end



					-- Debounce end

					task.delay(speed, function()
						busy = false	
					end)
				end


				local function add_buttons(array)
					-- Delete all buttons

					for _, v in pairs(dropdown_content:GetChildren()) do
						if v:IsA("Frame") then
							v:Destroy()
						end
					end


					for _, v in pairs(array) do
						-- Create instances

						local button = Instance.new("Frame")
						local TextLabel = Instance.new("TextLabel")
						local UICorner = Instance.new("UICorner")


						-- Properties

						button.Name = v
						button.BackgroundColor3 = selected_element == v and getgenv().color_scheme.enabled_color or getgenv().color_scheme.dark_color
						button.BorderColor3 = Color3.fromRGB(27, 42, 53)
						button.Size = UDim2.new(0, 212, 0, 20)
						button.BorderSizePixel = 0
						button.ZIndex = 1 + tabs
						button.Parent = dropdown_content
						button:SetAttribute("color", button.BackgroundColor3)
						button:SetAttribute("hover_color", button.BackgroundColor3 == getgenv().color_scheme.dark_color and getgenv().color_scheme.dark_hover_color or getgenv().color_scheme.enabled_color)
						hover(button)

						TextLabel.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
						TextLabel.BackgroundTransparency = 1.000
						TextLabel.Position = UDim2.new(0, 0, 0.150000006, 0)
						TextLabel.Size = UDim2.new(1, 0, 0.699999988, 0)
						TextLabel.ZIndex = 1 + tabs
						TextLabel.Font = Enum.Font.Gotham
						TextLabel.TextColor3 = getgenv().color_scheme.misc_elements_color
						TextLabel.TextScaled = true
						TextLabel.Text = v
						TextLabel.TextSize = 14.000
						TextLabel.TextWrapped = true
						TextLabel.Parent = button

						UICorner.CornerRadius = UDim.new(0, 5)
						UICorner.Parent = button


						-- Connections

						button.InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputState == Enum.UserInputState.Begin and not busy then
								-- Variables

								local last_selected_element = selected_element


								-- Setup

								button:SetAttribute("hover_effect_locked", true)

								selected_element = v ~= selected_element and v or nil

								-- Animation

								if selected_element then
									tween_service:Create(button, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {BackgroundColor3 = getgenv().color_scheme.enabled_color}):Play()

									if last_selected_element then
										tween_service:Create(dropdown_content[last_selected_element], TweenInfo.new(0.25, Enum.EasingStyle.Sine), {BackgroundColor3 = getgenv().color_scheme.dark_color}):Play()
									end
								else
									tween_service:Create(button, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {BackgroundColor3 = getgenv().color_scheme.dark_color}):Play()
								end

								-- Callback and stuff

								callback(selected_element)

								change_state(false)
							end
						end)
					end
				end





				-- Connections

				for _, v in pairs({dropdown, ImageButton}) do
					v.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputState == Enum.UserInputState.Begin and not busy and not section_busy and not tab_busy then
							if not dropdown_content.Visible then
								add_buttons(type(array) == "function" and array() or array)
							end

							change_state(not dropdown_content.Visible)
						end
					end)
				end
			end


			function section_functions.new_dropdown2(dropdown_info, array, callback)
				-- Setup

				assert(type(array) == "table" and #array > 0 or type(array) == "function" and #array() > 0 and callback, "Incorrect table type")


				-- Variables

				local busy = false

				local selected_elements = {}


				-- Create instances

				local dropdown = Instance.new("Frame")
				local UICorner = Instance.new("UICorner")
				local ImageButton = Instance.new("ImageButton")
				local TextLabel = Instance.new("TextLabel")

				local dropdown_content = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local UIListLayout = Instance.new("UIListLayout")



				-- Properties

				dropdown.BackgroundColor3 = getgenv().color_scheme.elements_color
				dropdown.BorderColor3 = Color3.fromRGB(27, 42, 53)
				dropdown.Position = UDim2.new(0, 0, 0.528497398, 0)
				dropdown.Size = UDim2.new(0, 212, 0, 23)
				dropdown.ZIndex = 1 + tabs
				dropdown.Parent = section_content
				dropdown:SetAttribute("color", dropdown.BackgroundColor3)
				dropdown:SetAttribute("hover_color", getgenv().color_scheme.elements_hover_color)
				hover(dropdown)

				UICorner.CornerRadius = UDim.new(0, 5)
				UICorner.Parent = dropdown

				ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				ImageButton.BackgroundTransparency = 1.000
				ImageButton.BorderSizePixel = 0
				ImageButton.Position = UDim2.new(0.88499999, 0, 0, 0)
				ImageButton.Size = UDim2.new(0.109999992, 0, 1, 0)
				ImageButton.ZIndex = 1 + tabs
				ImageButton.Image = "rbxassetid://3926305904"
				ImageButton.ImageColor3 = getgenv().color_scheme.misc_elements_color
				ImageButton.ImageRectOffset = Vector2.new(404, 283)
				ImageButton.ImageRectSize = Vector2.new(36, 36)
				ImageButton.Parent = dropdown

				TextLabel.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
				TextLabel.BackgroundTransparency = 1.000
				TextLabel.Position = UDim2.new(0.0329999737, 0, 0.150000006, 0)
				TextLabel.Size = UDim2.new(0.772727251, 0, 0.699999988, 0)
				TextLabel.ZIndex = 1 + tabs
				TextLabel.Font = Enum.Font.Gotham
				TextLabel.TextColor3 = getgenv().color_scheme.misc_elements_color
				TextLabel.TextScaled = true
				TextLabel.TextSize = 14.000
				TextLabel.Text = dropdown_info
				TextLabel.TextWrapped = true
				TextLabel.TextXAlignment = Enum.TextXAlignment.Left
				TextLabel.Parent = dropdown



				dropdown_content.BackgroundColor3 = getgenv().color_scheme.elements_color
				dropdown_content.BorderColor3 = Color3.fromRGB(27, 42, 53)
				dropdown_content.Position = UDim2.new(0.0181818176, 0, 0.461538464, 0)
				dropdown_content.Size = UDim2.new(0, 212, 0, 0)
				dropdown_content.BorderSizePixel = 0
				dropdown_content.ZIndex = 1 + tabs
				dropdown_content.ClipsDescendants = true
				dropdown_content.Visible = false
				dropdown_content.Parent = section_content
				dropdown_content:SetAttribute("content", true)
				dropdown_content:SetAttribute("content_open", false)

				UICorner_1.CornerRadius = UDim.new(0, 5)
				UICorner_1.Parent = dropdown_content

				UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
				UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout.Padding = UDim.new(0, 5)
				UIListLayout.Parent = dropdown_content



				-- Functions

				local function change_state(state)
					-- Setup

					busy = true


					-- Variables

					local speed = math.clamp(0.25 * (UIListLayout.AbsoluteContentSize.Y / 72), 0, 0.75)


					-- Open or close			

					if not state then
						-- Animation

						tween_service:Create(ImageButton, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {Rotation = 0}):Play()

						if type(array) == "function" and #array() < 3 or type(array) == "table" and #array < 3 then
							tween_service:Create(dropdown_content, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(dropdown_content.Size.X.Offset, -7)}):Play()
						else
							tween_service:Create(dropdown_content, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.fromOffset(dropdown_content.Size.X.Offset, -7)}):Play()
						end


						-- Anti jitter

						local anti_jitter = dropdown_content:GetPropertyChangedSignal("Size"):Connect(function()
							if dropdown_content.Size.Y.Offset <= 0 then
								dropdown_content.BackgroundTransparency = 1

								for _, v in pairs(dropdown_content:GetChildren()) do
									if v:IsA("Frame") then
										v.Visible = false
									end
								end
							end
						end)


						-- Destroy all elements

						task.delay(speed, function()
							anti_jitter:Disconnect()

							dropdown_content:SetAttribute("content_open", false)

							dropdown_content.Visible = false

							dropdown_content.Size = UDim2.fromOffset(dropdown_content.Size.X.Offset, 0)
						end)
					else
						dropdown_content:SetAttribute("content_open", true)

						dropdown_content.BackgroundTransparency = 0

						dropdown_content.Visible = true


						tween_service:Create(ImageButton, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {Rotation = 180}):Play()

						tween_service:Create(dropdown_content, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.fromOffset(dropdown_content.Size.X.Offset, UIListLayout.AbsoluteContentSize.Y)}):Play()
					end



					-- Debounce end

					task.delay(speed, function()
						busy = false	
					end)
				end


				local function add_buttons(array)
					-- Delete all buttons

					for _, v in pairs(dropdown_content:GetChildren()) do
						if v:IsA("Frame") then
							v:Destroy()
						end
					end


					for _, v in pairs(array) do
						-- Create instances

						local button = Instance.new("Frame")
						local TextLabel = Instance.new("TextLabel")
						local UICorner = Instance.new("UICorner")


						-- Properties

						button.Name = v
						button.BackgroundColor3 = table.find(selected_elements, v) and getgenv().color_scheme.enabled_color or getgenv().color_scheme.dark_color
						button.BorderColor3 = Color3.fromRGB(27, 42, 53)
						button.Size = UDim2.new(0, 212, 0, 20)
						button.BorderSizePixel = 0
						button.ZIndex = 1 + tabs
						button.Parent = dropdown_content
						button:SetAttribute("color", button.BackgroundColor3)
						button:SetAttribute("hover_color", button.BackgroundColor3 == getgenv().color_scheme.dark_color and getgenv().color_scheme.dark_hover_color or getgenv().color_scheme.enabled_hover_color)
						hover(button)

						TextLabel.BackgroundColor3 = Color3.fromRGB(235, 235, 235)
						TextLabel.BackgroundTransparency = 1.000
						TextLabel.Position = UDim2.new(0, 0, 0.150000006, 0)
						TextLabel.Size = UDim2.new(1, 0, 0.699999988, 0)
						TextLabel.ZIndex = 1 + tabs
						TextLabel.Font = Enum.Font.Gotham
						TextLabel.TextColor3 = getgenv().color_scheme.misc_elements_color
						TextLabel.TextScaled = true
						TextLabel.Text = v
						TextLabel.TextSize = 14.000
						TextLabel.TextWrapped = true
						TextLabel.Parent = button

						UICorner.CornerRadius = UDim.new(0, 5)
						UICorner.Parent = button


						-- Connections

						button.InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputState == Enum.UserInputState.Begin and not busy then
								if table.find(selected_elements, v) then
									table.remove(selected_elements, table.find(selected_elements, v))


									button:SetAttribute("color", getgenv().color_scheme.dark_color)
									button:SetAttribute("hover_color", getgenv().color_scheme.dark_hover_color)

									tween_service:Create(button, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {BackgroundColor3 = getgenv().color_scheme.dark_color}):Play()
								else
									table.insert(selected_elements, v)


									button:SetAttribute("color", getgenv().color_scheme.enabled_color)
									button:SetAttribute("hover_color", getgenv().color_scheme.enabled_hover_color)

									tween_service:Create(button, TweenInfo.new(0.25, Enum.EasingStyle.Sine), {BackgroundColor3 = getgenv().color_scheme.enabled_color}):Play()
								end


								callback(selected_elements)
							end
						end)
					end
				end





				-- Connections

				for _, v in pairs({dropdown, ImageButton}) do
					v.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 and input.UserInputState == Enum.UserInputState.Begin and not busy and not section_busy and not tab_busy then
							if not dropdown_content.Visible then
								add_buttons(type(array) == "function" and array() or array)
							end

							change_state(not dropdown_content.Visible)
						end
					end)
				end
			end



			return section_functions
		end



		return tab_functions
	end



	return window_functions
end



return create_window()
