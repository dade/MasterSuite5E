function onInit()
	local node = getDatabaseNode();
	if node.getPath():match("^npc%.id%-%d+") then
		local sVisibility = DB.getValue(node, "visibility");
		local sEffectString = DB.getValue(node, "effect");
		if sVisiblity == "" and sEffectString == "" then
			DB.setValue(node, "visibility", "string", "hide");
		end
	end

	DB.addHandler(DB.getPath(node, ".type"), "onUpdate", update);
	DB.addHandler(DB.getPath(node, ".save_type"), "onUpdate", updateSaveEffects);
	DB.addHandler(DB.getPath(node, ".save"), "onUpdate", updateSaveEffects);
	DB.addHandler(DB.getPath(node, ".save_modifier"), "onUpdate", updateSaveEffects);
	DB.addHandler(DB.getPath(node, ".ability_type"), "onUpdate", updateAbilityEffects);
	DB.addHandler(DB.getPath(node, ".ability"), "onUpdate", updateAbilityEffects);
	DB.addHandler(DB.getPath(node, ".ability_modifier"), "onUpdate", updateAbilityEffects);
	DB.addHandler(DB.getPath(node, ".susceptibility_type"), "onUpdate", updateSusceptibilityEffects);
	DB.addHandler(DB.getPath(node, ".susceptibility"), "onUpdate", updateSusceptibilityEffects);
	DB.addHandler(DB.getPath(node, ".susceptibility_modifier"), "onUpdate", updateSusceptibilityEffects);
	DB.addHandler(DB.getPath(node, ".misc_type"), "onUpdate", updateMiscEffects);
	DB.addHandler(DB.getPath(node, ".misc_modifier"), "onUpdate", updateMiscEffects);
	update();
end

function onClose()
	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, ".type"), "onUpdate", update);
	DB.removeHandler(DB.getPath(node, ".save_type"), "onUpdate", updateSaveEffects);
	DB.removeHandler(DB.getPath(node, ".save"), "onUpdate", updateSaveEffects);
	DB.removeHandler(DB.getPath(node, ".save_modifier"), "onUpdate", updateSaveEffects);
	DB.removeHandler(DB.getPath(node, ".ability_type"), "onUpdate", updateAbilityEffects);
	DB.removeHandler(DB.getPath(node, ".ability"), "onUpdate", updateAbilityEffects);
	DB.removeHandler(DB.getPath(node, ".ability_modifier"), "onUpdate", updateAbilityEffects);
	DB.removeHandler(DB.getPath(node, ".susceptibility_type"), "onUpdate", updateSusceptibilityEffects);
	DB.removeHandler(DB.getPath(node, ".susceptibility"), "onUpdate", updateSusceptibilityEffects);
	DB.removeHandler(DB.getPath(node, ".susceptibility_modifier"), "onUpdate", updateSusceptibilityEffects);
	DB.removeHandler(DB.getPath(node, ".misc_type"), "onUpdate", updateMiscEffects);
	DB.removeHandler(DB.getPath(node, ".misc_modifier"), "onUpdate", updateMiscEffects);
end

function update()
	local node = getDatabaseNode();
	local sType = DB.getValue(node, "type", "");
	local bCustom = sType == "";
	local bSave = sType == "save";
	local bAbility = sType == "ability";
	local bSusceptibility = sType == "susceptibility";
	local bMisc = sType == "misc";
	local w = Interface.findWindow("master_effect_editor", "");

	if bSave then
		save_type.setVisible(true);
		save.setComboBoxVisible(true);
		save_modifier.setVisible(true);
		updateSaveEffects();
	else
		save_type.setVisible(false);
		save.setComboBoxVisible(false);
		save_modifier.setVisible(false);
	end

	if bAbility then
		ability_type.setVisible(true);
		ability.setVisible(true);
		ability_modifier.setVisible(true);
		updateAbilityEffects();
	else
		ability_type.setVisible(false);
		ability.setVisible(false);
		ability_modifier.setVisible(false);
	end

	if bSusceptibility then
		susceptibility_type.setVisible(true);
		susceptibility.setComboBoxVisible(true);
		susceptibility_modifier.setVisible(false);
		updateSusceptibilityEffects();
	else
		susceptibility_type.setVisible(false);
		susceptibility.setComboBoxVisible(false);
		susceptibility_modifier.setVisible(false);
	end

	if bMisc then
		misc_type.setVisible(true);
		misc_modifier.setVisible(true);
		updateMiscEffects();
	else
		misc_type.setVisible(false);
		misc_modifier.setVisible(false);
	end

	if bCustom then
		effect.setVisible(true);
	else
		effect.setVisible(false);
	end
end

function updateAbilityEffects()
	if not Session.IsHost then return; end

	local nodeRecord = getDatabaseNode();
	local sEffectString = "";
	local sType = DB.getValue(nodeRecord, "ability_type", "");
	local sAbility = DB.getValue(nodeRecord, "abilitiy", "str");
	local nModifier = DB.getValue(nodeRecord, "ability_modifier", 0);
	local sTypeChar = "";

	if sType == "modifier" or sType == "" then
		sTypeChar = "";
	elseif sType == "percent_modifier" then
		sTypeChar = "P";
	elseif sType == "base" then
		sTypeChar = "B";
	elseif sType == "base_percent" then
		sTypeChar = "BP";
	end

	if sAbility == "" then sAbility = "str"; end
	if sAbility ~= "" then
		sEffectString = sEffectString .. sTypeChar .. sAbility:upper() .. ": " .. nModifier .. ";";
	end
	DB.setValue(nodeRecord, "effect", "string", sEffectString);
end

function updateSaveEffects()
	if not Session.IsHost then return; end

	local nodeRecord = getDatabaseNode();
	local sEffectString = "";
	local sType = DB.getValue(nodeRecord, "save_type", "");
	local sSave = DB.getValue(nodeRecord, "save", "");
	local nModifier = DB.getValue(nodeRecord, "save_modifier", 0);
	local sTypeChar = "";

	if sType == "modifier" or sType == "" then
		sTypeChar = "";
	elseif sType == "base" then
		sTypeChar = "B";
	end

	if sSave ~= "" then
		sEffectString = sEffectString .. sTypeChar .. sSave:upper() .. ": " .. nModifier .. ";";
	end
	DB.setValue(nodeRecord, "effect", "string", sEffectString);
end

function updateSusceptibilityEffects()
	if not Session.IsHost then return; end

	local nodeRecord = getDatabaseNode();
	local sEffectString = "";
	local sType = DB.getValue(nodeRecord, "susceptibility_type", "");
	local sSusc = DB.getValue(nodeRecord, "susceptibility", "");
	local nModifier = DB.getValue(nodeRecord, "susceptibility_modifier", 0);
	local sTypeChar = "";

	if sType == "" then
		sType = "immune";
	end
	if sSusc == "" then
		sSusc = "acid";
	end
	if sSusc ~= "" then
		sEffectString = sEffectString .. sType:upper() .. ": " .. sSusc .. ";";
	end
	DB.setValue(nodeRecord, "effect", "string", sEffectString);
end

function updateMiscEffects()
	if not Session.IsHost then return; end

	local nodeRecord = getDatabaseNode();
	local sEffectString = "";
	local sType = DB.getValue(nodeRecord, "misc_type", "");
	local nModifier = DB.getValue(nodeRecord, "misc_modifier", 0);
	local sTypeChar = "";

	if sType == "" then sType = "ac"; end
	if nModifier ~= 0 then
		sEffectString = sEffectString .. sType:upper() .. ": " .. nModifier .. ";";
	end
	DB.setValue(nodeRecord, "effect", "string", sEffectString);
end