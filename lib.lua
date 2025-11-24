local export = {}

local container_list = {"container", "infinity-container", "logistic-container", "temporary-container"}

local function generate_icon_set(sub_icon_set)
	if type(sub_icon_set) ~= "table" then
		return nil
	end
	local icon_set = {
		{
			icon = data.raw["deconstruction-item"]["deconstruction-planner"].icon
		},
		{
			icon = data.raw["item"]["steel-chest"].icon,
			scale = 0.3125,
			shift = {-4, -4}
		}
	}
	for _, value in ipairs(sub_icon_set) do
		if type(value) ~= "table" or type(value.icon) == "nil" then
			return nil
		end
		icon_set[#icon_set + 1] = {
			icon = value.icon,
			scale = 0.3125,
			shift = {6, 6}
		}
	end
	return icon_set
end

local function generate_select_mode(border_color, common_mode)
	if type(border_color) ~= "table" then
		return nil
	end
	if type(border_color.r) ~= "number" or type(border_color.g) ~= "number" or  type(border_color.b) ~= "number" then
		return nil
	end
	local r = border_color.r
	local g = border_color.g
	local b = border_color.b
	if r < 0 or r > 1 or g < 0 or g > 1 or b < 0 or b > 1 then
		return nil
	end
	local select_mode = export.deepcopy(common_mode or {
		mode = {"any-entity"},
		cursor_box_type = "pair",
		entity_type_filters = container_list,
		ended_sound = data.raw["deconstruction-item"]["deconstruction-planner"].select.ended_sound
	})
	select_mode.border_color = {r = r, g = g, b = b}
	return select_mode
end

local function generate_selector(name, icon_set, select_mode, select_mode_alt, reverse_mode, reverse_mode_alt)
	if not name or not icon_set or not select_mode then
		return nil
	end
	return {
		type = "selection-tool",
		select             = select_mode,
		alt_select         = select_mode_alt or select_mode,
		reverse_select     = reverse_mode or select_mode,
		alt_reverse_select = reverse_mode_alt or reverse_mode or select_mode_alt or select_mode,
		name = name,
		icons = icon_set,
		flags = {"only-in-cursor", "spawnable"},
		subgroup = "tool",
		order = "c[automated-construction]-b["..name.."]",
		stack_size = 1,
		stackable = false
	}
end

local function register_selector_all(callback)
	if type(callback) ~= "function" then
		return nil
	end
	script.on_event(defines.events.on_player_selected_area,             callback)
	script.on_event(defines.events.on_player_alt_selected_area,         callback)
	script.on_event(defines.events.on_player_reverse_selected_area,     callback)
	script.on_event(defines.events.on_player_alt_reverse_selected_area, callback)
	return true
end

local function generate_item_request_proxy(entity, player, insert_plan, removal_plan)
	if not entity or not entity.valid or not player then
		return nil
	end
	return {
		name = "item-request-proxy",
		target = entity,
		position = entity.position,
		force = player.force,
		-- player = player,		-- DO NOT USE THIS, IT can CAUSE A CRASH. Undoing an item-request-proxy will cause a crash. This is what allows an undo. THIS IS ONLY HERE TO SERVE AS A WARNING.
		modules = insert_plan or {},
		insert_plan = insert_plan or {},
		removal_plan = removal_plan or {}
	}
end

local function get_current_item_request(entity)
	if not entity or not entity.valid then
		return nil
	end
	return (entity.type == "entity-ghost" and entity) or entity.item_request_proxy
end

local function get_current_insert_plan(entity)
	local item_request_proxy = get_current_item_request(entity)
	if item_request_proxy then
		return item_request_proxy.insert_plan or (entity.type ~= "entity-ghost" and item_request_proxy.modules) or {}
	end
	return {}
end

local function get_shortcut(selector, icons)
	return {
		type = "shortcut",
		name = selector.name.."-shortcut",
		order = "b[blueprints]-s["..selector.name.."]",
		action = "spawn-item",
		item_to_spawn = selector.name,
		style = "default",
		icons = icons or selector.icons,
		small_icons = icons or selector.icons
	}
end
local function get_key_sequence(selector, key_sequence)
	if type(key_sequence) ~= "string" then
		return nil
	end
	local shortcut = get_shortcut(selector)
	return {
		type = "custom-input",
		name = "give-"..selector.name,
		order = shortcut.order,
		action = shortcut.action,
		item_to_spawn = shortcut.item_to_spawn,
		key_sequence = key_sequence,
		consuming = "none",
	}
end

export.container_list = container_list
---@diagnostic disable-next-line: undefined-field
export.deepcopy                    = table.deepcopy
export.generate_select_mode        = generate_select_mode
export.generate_icon_set           = generate_icon_set
export.generate_selector           = generate_selector
export.register_selector_all       = register_selector_all
export.generate_item_request_proxy = generate_item_request_proxy
export.get_current_item_request    = get_current_item_request
export.get_current_insert_plan     = get_current_insert_plan
export.get_shortcut                = get_shortcut
export.get_key_sequence            = get_key_sequence

return export