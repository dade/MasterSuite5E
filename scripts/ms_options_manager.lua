--[[
	We want to handle all of our options in this file. This will also allow us to enable/disable extensions
]]

function onInit()
	registerOptions();
end

function registerOptions()
	OptionsManager.registerOption2("MS_Crit", false, "option_header_ms", "option_label_ms_crit", "option_entry_cycler", {
		labels = "option_label_enabled",
		values = "option_val_enabled",
		baselabel = "option_label_disabled",
		baseval = "option_val_disabled",
		default = "option_val_enabled"
	});
	
	OptionsManager.registerOption2("MS_AE_EDIT", false, "option_header_ms", "option_label_ms_aeedit", "option_entry_cycler", {
		labels = "option_label_enabled",
		values = "option_val_enabled",
		baselabel = "option_label_disabled",
		baseval = "option_val_disabled",
		default = "option_val_enabled"
	});
end