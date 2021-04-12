--[[
	Advanced Effects, the MasterSuite Edition
]]

function onInit()
	if Session.IsHost then
		-- Listeners for combattracker/NPC inv list
		DB.addHandler("combattracker.list.*.inventorylist.*.carried", "onUpdate", inventoryUpdateItemEffects);
		DB.addHandler("combattracker.list.*.inventorylist.*.effectlist.*.effect", "onUpdate", updateItemEffectsForEdit);
		DB.addHandler("combattracker.list.*.inventorylist.*.effectlist.*.durdice", "onUpdate", updateItemEffectsForEdit);
		DB.addHandler("combattracker.list.*.inventorylist.*.effectlist.*.durmod", "onUpdate", updateItemEffectsForEdit);
		DB.addHandler("combattracker.list.*.inventorylist.*.effectlist.*.name", "onUpdate", updateItemEffectsForEdit);
		DB.addHandler("combattracker.list.*.inventorylist.*.effectlist.*.durunit", "onUpdate", updateItemEffectsForEdit);
		DB.addHandler("combattracker.list.*.inventorylist.*.effectlist.*.visibility", "onUpdate", updateItemEffectsForEdit);
		DB.addHandler("combattracker.list.*.inventorylist.*.effectlist.*.actiononly", "onUpdate", updateItemEffectsForEdit);
		DB.addHandler("combattracker.list.*.inventorylist.*.isidentified", "onUpdate", updateItemEffectsForEdit);
		DB.addHandler("combattracker.list.*.inventorylist", "onChildDeleted", updateFromDeletedInventory);

		-- Listeners for character/PC inv list
		DB.addHandler("charsheet.*.inventorylist.*.carried", "onUpdate", inventoryUpdateItemEffects);
		DB.addHandler("charsheet.*.inventorylist.*.effectlist.*.effect", "onUpdate", updateItemEffectsForEdit);
		DB.addHandler("charsheet.*.inventorylist.*.effectlist.*.durdice", "onUpdate", updateItemEffectsForEdit);
		DB.addHandler("charsheet.*.inventorylist.*.effectlist.*.durmod", "onUpdate", updateItemEffectsForEdit);
		DB.addHandler("charsheet.*.inventorylist.*.effectlist.*.name", "onUpdate", updateItemEffectsForEdit);
		DB.addHandler("charsheet.*.inventorylist.*.effectlist.*.durunit", "onUpdate", updateItemEffectsForEdit);
		DB.addHandler("charsheet.*.inventorylist.*.effectlist.*.visibility", "onUpdate", updateItemEffectsForEdit);
		DB.addHandler("charsheet.*.inventorylist.*.effectlist.*.actiononly", "onUpdate", updateItemEffectsForEdit);
		DB.addHandler("charsheet.*.inventorylist.*.isidentified", "onUpdate", updateItemEffectsForEdit);
		DB.addHandler("charsheet.*.inventorylist", "onChildDeleted", updateFromDeletedInventory);
	end

	CombatManager.setCustomAddPC(addPC);
	CombatManager.setCustomAddNPC(addNPC);

	-- CoreRPG replacements
	ActionsManager_decodeActors = ActionsManager.decodeActors;
	ActionsManager.decodeActors = MS_decodeActors;

	-- 5E Action/Roll Overrides
	ActionAttack_performRoll = ActionAttack.performRoll;
	ActionAttack.performRoll = MS_attackPerformRoll;

	ActionDamage_performRoll = ActionDamage.performRoll;
	ActionDamage.performRoll = MS_damagePerformRoll;

	PowerManager_performAction = PowerManager.performAction;
	PowerManager.performAction = MS_powerPerformAction;

	-- 5E Effects Manager Overrides
	EffectManager5E_checkConditionalHelper = EffectManager5E.checkConditionalHelper;
	EffectManager5E.checkConditionalHelper = MS_checkConditionalHelper;

	EffectManager5E_getEffectsByType = EffectManager5E.getEffectsByType;
	EffectManager5E.getEffectsByType = MS_getEffectsByType;

	EffectManager5E_hasEffect = EffectManager5E.hasEffect;
	EffectManager5E.hasEffect = MS_hasEffect;
end

function inventoryUpdateItemEffects(nodeField)
	updateItemEffects(DB.getChild(nodeField, ".."));
end

function updateItemEffectsForEdit(nodeField)
	checkEffectsAfterEdit(nodeField.getChild(".."));
end

function updateFromDeletedInventory(node)
	local nodeChar = DB.getChild(node, "..");
	local bIsNPC = not ActorManager.isPC(nodeChar);
	local nodeCT = getCTNodeByNodeChar(nodeChar);

	if bIsNPC and string.match(nodeChar.getPath(), "^combattracker") then
		nodeCT = nodeChar;
	end

	if nodeCT then
		checkEffectsAfterDelete(nodeCT);
	end
end

function checkEffectsAfterEdit(itemNode)
	local nodeChar = nil;
	local bIDUpdated = false;

	if itemNode.getPath():match("%.effectlist%.") then
		nodeChar = DB.getChild(itemNode, ".....");
	else
		nodeChar = DB.getChild(itemNode, "...");
		bIDUpdated = true;
	end

	local nodeCT = getCTNodeByNodeChar(nodeChar);

	if nodeCT then
		for _, nodeEffect in pairs(DB.getChildren(nodeCT, "effects")) do
			local sLabel = DB.getValue(nodeEffect, "label", "");
			local sEffSource = DB.getValue(nodeEffect, "source_name", "");
			local nodeEffectFound = DB.findNode(sEffSource);

			if nodeEffectFound and string.match(sEffSource, "inventorylist") then
				local nodeEffectItem = nodeEffectFound.getChild("...");
				if nodeEffectFound == itemNode then
					nodeEffect.delete();
					updateItemEffects(DB.getChild(itemNode, "..."));
				elseif nodeEffectItem == itemNode then
					nodeEffect.delete();
					updateItemEffects(nodeEffectItem);
				end
			end
		end
	end
end

function checkEffectsAfterDelete(nodeChar)
	local sUser = User.getUsername();

	for _, nodeEffect in pairs(DB.getChildren(nodeChar, "effects")) do
		local sLabel = DB.getValue(nodeEffect, "label", "");
		local sEffSource = DB.getValue(nodeEffect, "source_name", "");
		local nodeFound = DB.findNode(sEffSource);
		local bDeleted = nodeFound == nil and string.match(sEffSource, "inventorylist");

		if bDeleted then
			local msg = {font = "msgfont", icon = "roll_effect"};
			msg.text = "Effect ['" .. sLabel .. "'] ";
			msg.text = msg.text .. "removed [from " .. DB.getValue(nodeChar, "name", "") .. "]";

			if sEffSource and sEffSource ~= "" then
				msg.text = msg.text .. " [by deleteion]";
			end

			if EffectManager.isGMEffect(nodeChar, nodeEffect) then
				if sUser == "" then
					msg.secret = true;
					Comm.addChatMessage(msg);
				elseif sUser ~= "" then
					Comm.addChatMessage(msg);
					Comm.deliverChatMessage(msg, sUser);
				end
			else
				Comm.deliverChatMessage(msg);
			end

			nodeEffect.delete();
		end
	end
end

function updateItemEffects(nodeItem)
	local nodeChar = DB.getChild(nodeItem, "...");
	if not nodeChar then return; end
	local sUser = User.getUsername();
	local sName = DB.getValue(nodeItem, "name", "");
	if not string.match(nodeChar.getPath(), "^combattracker") then
		nodeChar = getCTNodeByNodeChar(nodeChar);
	end
	if not nodeChar then return; end

	local nCarried = DB.getValue(nodeItem, "carried", 0);
	local bEquipped = nCarried == 2;
	local nIdentified = DB.getValue(nodeItem, "isidentified", 1);

	for _, nodeItemEffect in pairs(DB.getChildren(nodeItem, "effectlist")) do
		updateItemEffect(nodeItemEffect, sName, nodeChar, nil, bEquipped, nIdentified);
	end
end

function updateItemEffect(nodeItemEffect, sName, nodeChar, sUser, bEquipped, nIdentified)
	local sCharName = DB.getValue(nodeChar, "name", "");
	local sItemSource = nodeItemEffect.getPath();
	local sLabel = DB.getValue(nodeItemEffect, "effect", "");

	if sLabel and sLabel ~= "" then
		local bFound = false;
		for _, nodeEffect in pairs(DB.getChildren(nodeChar, "effects")) do
			local nActive = DB.getValue(nodeEffect, "isactive", 0);
			local nGMOnly = DB.getValue(nodeEffect, "isgmonly", 0);

			if nActive ~= 0 then
				local sEffSource = DB.getValue(nodeEffect, "source_name", "");
				if sEffSource == sItemSource then
					bFound = true;
					if not bEquipped then
						sendEffectRemovedMessage(nodeChar, nodeEffect, sLabel, nGMOnly, sUser);
						nodeEffect.delete();
						break;
					end
				end
			end
		end

		if not bFound and bEquipped then
			local rEffect = {};
			local nRollDur = 0;
			local dDurDice = DB.getValue(nodeItemEffect, "durdice");
			local nModDice = DB.getValue(nodeItemEffect, "durdice", 0);
			local nGMOnly = 0;
			local sVisiblity = DB.getValue(nodeItemEffect, "visibility", "");

			if dDurDice and dDurDice ~= "" then
				nRollDur = StringManager.evalDice(dDurDice, nModDice);
			else
				nRollDur = nModDice;
			end

			if sVisiblity == "hide" then
				nGMOnly = 1;
			elseif sVisiblity == "show" then
				nGMOnly = 0;
			elseif nIdentified == 0 then
				nGMOnly = 1;
			elseif nIdentified > 0 then
				nGMOnly = 0;
			end

			local isNPC = isCTNodeNPC(nodeChar);

			if isNPC then
				local bTokenVis = DB.getValue(nodeChar, "tokenvis", 1) == 1;
				if not bTokenVis then nGMOnly = 1; end
			end

			rEffect.nDuration = nRollDur;
			rEffect.sName = sName .. ";" .. sLabel;
			rEffect.sLabel = sLabel;
			rEffect.sUnits = DB.getValue(nodeItemEffect, "durunit", "");
			rEffect.nInit = 0;
			rEffect.sSource = sItemSource;
			rEffect.nGMOnly = nGMOnly;
			rEffect.sApply = "";

			sendEffectAddedMessage(nodeChar, rEffect, sLabel, nGMOnly, sUser);
			EffectManager.addEffect("", "", nodeChar, rEffect, false);
		end
	end
end

function getCTNodeByNodeChar(nodeChar)
	local nodeCT = nil;
	for _, node in pairs(DB.getChildren("combattracker.list")) do
		local _, sRecord = DB.getValue(node, "link", "", "");
		if sRecord ~= "" and sRecord == nodeChar.getPath() then
			nodeCT = node;
			break;
		end
	end

	return nodeCT;
end

function updateCharEffects(nodeChar, nodeEntry)
	for _, nodeCharEffect in pairs(DB.getChildren(nodeChar, "effectlist")) do
		updateCharEffect(nodeCharEffect, nodeEntry);
	end
end

function updateCharEffect(nodeCharEffect, nodeEntry)
	local sUser = User.getUsername();
	local sName = DB.getValue(nodeEntry, "name", "");
	local sLabel = DB.getValue(nodeCharEffect, "effect", "");
	local nRollDur = 0;
	local dDurDice = DB.getValue(nodeCharEffect, "durdice");
	local nModDice = DB.getValue(nodeCharEffect, "durmod", 0);
	local nGMOnly = 0;
	local sVisiblity = DB.getValue(nodeCharEffect, "visibility", "");

	if dDurDice and dDurDice ~= "" then
		nRollDur = StringManager.evalDice(dDurDice, nModDice);
	else
		nRollDur = nModDice;
	end

	if sVisiblity == "show" then
		nGMOnly = 0;
	else
		nGMOnly = 1;
	end

	local bIsPC = ActorManager.getType(nodeEntry) == "pc";
	if not bIsPC then nGMOnly = 1; end

	local rEffect = {};
	rEffect.nDuration = nRollDur;
	rEffect.sName = sLabel;
	rEffect.sLabel = sLabel;
	rEffect.sUnits = DB.getValue(nodeCharEffect, "durunit", "");
	rEffect.nInit = 0;
	rEffect.nGMOnly = nGMOnly;
	rEffect.sApply = "";

	sendEffectAddedMessage(nodeEntry, rEffect, sLabel, nGMOnly, sUser);
	EffectManager.addEffect("", "", nodeEntry, rEffect, false);
end

function isCTNodeNPC(nodeCT)
	local isPC = false;
	local sClassLink, sRecordLink = DB.getValue(nodeCT, "link", "", "");
	if sClassLink == "npc" then
		isPC = true;
	end
	return isPC;
end

function addPC(nodePC)
	if not nodePC then return; end
	local nodeEntry = DB.createChild("combattracker.list");
	if not nodeEntry then return; end

	DB.setValue(nodeEntry, "ct.visible", "number", 1);
	DB.setValue(nodeEntry, "link", "windowreference", "charsheet", nodePC.getNodeName());
	DB.setValue(nodeEntry, "friendfoe", "string", "friend");
	local sToken = DB.getValue(nodePC, "token", nil);
	if not sToken or sToken == "" then
		sToken = "portrait_" .. nodePC.getName() .. "_token";
	end
	DB.setValue(nodeEntry, "token", "token", sToken);

	for _, nodeItem in pairs(DB.getChildren(nodePC, "inventorylist")) do
		updateItemEffects(nodeItem, true);
	end
	updateCharEffects(nodePC, nodeEntry);
end

function addNPC(aClass, nodeNPC, sName)
	local nodeEntry, nodeLastMatch = CombatManager.addNPCHelper(nodeNPC, sName);
	DB.setValue(nodeEntry, "ct.visible", "number", 1);
	CampaignDataManager2.updateNPCSpells(nodeEntry);
	CampaignDataManager2.resetNPCSpellcastingSlots(nodeEntry);
	local sSize = StringManager.trim(DB.getValue(nodeEntry, "size", ""):lower());

	if sSize == "large" then
		DB.setValue(nodeEntry, "space", "number", 10);
	elseif sSize == "huge" then
		DB.setValue(nodeEntry, "space", "number", 15);
	elseif sSize == "gargantuan" then
		DB.setValue(nodeEntry, "space", "number", 20);
	end

	local sOptHRNH = OptionsManager.getOption("HRNH");
	local nHP = DB.getValue(nodeNPC, "hp", 0);
	local sHD = StringManager.trim(DB.getValue(nodeNPC, "hd", ""));
	if sOptHRNH == "max" and sHD ~= "" then
		nHP = StringManager.evalDiceString(sHD, true, true);
	elseif sOptHRNH == "random" and sHD ~= "" then
		nHP = math.max(StringManager.evalDiceString(sHD, true), 1);
	end
	DB.setValue(nodeEntry, "hptotal", "number", nHP);
	local nDex = DB.getValue(nodeNPC, "abilities.dexterity.score", 10);
	local nDexMod = math.floor((nDex - 10) / 2);
	DB.setValue(nodeEntry, "init", "number", nDexMod);

	local aEffects = {};

	-- Vulnerabilities
	local aVulnTypes = CombatManager2.parseResistances(DB.getValue(nodeEntry, "damagevulnerabilities", ""));
	if #aVulnTypes > 0 then
		for _,v in ipairs(aVulnTypes) do
			if v ~= "" then
				table.insert(aEffects, "VULN: " .. v);
			end
		end
	end
			
	-- Damage Resistances
	local aResistTypes = CombatManager2.parseResistances(DB.getValue(nodeEntry, "damageresistances", ""));
	if #aResistTypes > 0 then
		for _,v in ipairs(aResistTypes) do
			if v ~= "" then
				table.insert(aEffects, "RESIST: " .. v);
			end
		end
	end

	-- Damage immunities
	local aImmuneTypes = CombatManager2.parseResistances(DB.getValue(nodeEntry, "damageimmunities", ""));
	if #aImmuneTypes > 0 then
		for _,v in ipairs(aImmuneTypes) do
			if v ~= "" then
				table.insert(aEffects, "IMMUNE: " .. v);
			end
		end
	end

	-- Condition immunities
	local aImmuneCondTypes = {};
	local sCondImmune = DB.getValue(nodeEntry, "conditionimmunities", ""):lower();
	for _,v in ipairs(StringManager.split(sCondImmune, ",;\r", true)) do
		if StringManager.isWord(v, DataCommon.conditions) then
			table.insert(aImmuneCondTypes, v);
		end
	end
	if #aImmuneCondTypes > 0 then
		table.insert(aEffects, "IMMUNE: " .. table.concat(aImmuneCondTypes, ", "));
	end

	-- Decode traits and actions
	local rActor = ActorManager.getActor("", nodeNPC);
	for _,v in pairs(DB.getChildren(nodeEntry, "actions")) do
		CombatManager2.parseNPCPower(rActor, v, aEffects);
	end
	for _,v in pairs(DB.getChildren(nodeEntry, "legendaryactions")) do
		CombatManager2.parseNPCPower(rActor, v, aEffects);
	end
	for _,v in pairs(DB.getChildren(nodeEntry, "lairactions")) do
		CombatManager2.parseNPCPower(rActor, v, aEffects);
	end
	for _,v in pairs(DB.getChildren(nodeEntry, "reactions")) do
		CombatManager2.parseNPCPower(rActor, v, aEffects);
	end
	for _,v in pairs(DB.getChildren(nodeEntry, "traits")) do
		CombatManager2.parseNPCPower(rActor, v, aEffects);
	end
	for _,v in pairs(DB.getChildren(nodeEntry, "innatespells")) do
		CombatManager2.parseNPCPower(rActor, v, aEffects, true);
	end
	for _,v in pairs(DB.getChildren(nodeEntry, "spells")) do
		CombatManager2.parseNPCPower(rActor, v, aEffects, true);
	end

	-- Add special effects
	if #aEffects > 0 then
		EffectManager.addEffect("", "", nodeEntry, { sName = table.concat(aEffects, "; "), nDuration = 0, nGMOnly = 1 }, false);
	end

	updateCharEffects(nodeNPC, nodeEntry);

	local sOptINIT = OptionsManager.getOption("INIT");
	if sOptINIT == "group" then
		if nodeLastMatch then
			local nLastInit = DB.getValue(nodeLastMatch, "initresult", 0);
			DB.setValue(nodeEntry, "initresult", "number", nLastInit);
		else
			DB.setValue(nodeEntry, "initresult", "number", math.random(20) + DB.getValue(nodeEntry, "init", 0));
		end
	elseif sOptINIT == "on" then
		DB.setValue(nodeEntry, "initresult", "number", math.random(20) + DB.getValue(nodeEntry, "init", 0));
	end

	return nodeEntry;
end

function getUserFromNode(node)
	local sNodePath = node.getPath();
	local _, sRecord = DB.getValue(node, "link", "", "");
	local sUser = nil;
	
	for _, vUser in ipairs(User.getActiveUsers()) do
		for _, vIdentity in ipairs(User.getActiveIndentities(vUser)) do
			if sRecord == "charsheet." .. vIdentity then
				sUser = vUser;
				break;
			end
		end
	end

	return sUser;
end

function sendEffectAddedMessage(nodeCT, rNewEffect, sLabel, nGMOnly)
	local sUser = getUserFromNode(nodeCT);
	local msg = ChatManager.createBaseMessage(ActorManager.getActorFromCT(nodeCT), sUser);
	msg.text = "Advanced Effect ['" .. rNewEffect.sName .. "'] ";
	msg.text = msg.text .. "-> [to " .. DB.getValue(nodeCT, "name", "") .. "]";
	if rNewEffect.sSource and rNewEffect.sSource ~= "" then
	msg.text = msg.text .. " [by " .. DB.getValue(DB.findNode(rNewEffect.sSource), "name", "") .. "]";
	end
	sendRawMessage(sUser,nDMOnly,msg);
end

function sendEffectRemovedMessage(nodeChar, nodeEffect, sLabel, nGMOnly)
	local sUser = getUserFromNode(nodeChar);
	local sCharName = DB.getValue(nodeChar, "name", "");
	local msg = ChatManager.createBaseMessage(ActorManager.getActorFromCT(nodeChar), sUser);

	msg.text = "Advanced Effect ['" .. sLabel .. "'] " .. "removed [from " .. sCharName .. "]";
	local sEffSource = DB.getValue(nodeEffect, "source_name", "");
	if sEffSource and sEffSource ~= "" then
		msg.text = msg.text .. " [by " .. DB.getValue(DB.findNode(sEffSource), "name", "") .. "]";
	end
	sendRawMessage(sUser, nGMOnly, msg);
end

function sendRawMessage(sUser, nGMOnly, msg)
	local sIdentity = nil;
	if sUser and sUser ~=  "" then
		sIdentity = User.getCurrentIdentity(sUser) or nil;
	end

	if sIdentity then
		msg.icon = "portrait_" .. User.getCurrentIdentity(sUser) .. "_chat";
	else
		msg.font = "msgfont";
		msg.icon = "roll_effect";
	end

	if nGMOnly == 1 then
		msg.secret = true;
		Comm.addChatMessage(msg);
	elseif nGMOnly ~= 1 then
		Comm.deliverChatMessage(msg);
	end
end

function isValidEffect(rActor, nodeEffect)
	local bResult = false;
	local nActive = DB.getValue(nodeEffect, "isactive", 0);
	local bItem = false;
	local bActionItemUsed = false;
	local bActionOnly = false;
	local nodeItem = nil;
	local sSource = DB.getValue(nodeEffect, "source_name", "");
	local node = DB.findNode(sSource);

	if node and node ~= nil then
		nodeItem = node.getChild("...");
		if nodeItem and nodeItem ~= nil then
			bActionOnly = DB.getValue(node, "actiononly", 0) ~= 0;
		end
	end

	if rActor.itemPath and rActor.itemPath ~= nil then
		if DB.findNode(rActor.itemPath) ~= nil then
			if node and node ~= nil and nodeItem and nodeItem ~= nil then
				local sNodePath = nodeItem.getPath();
				if bActionOnly and sNodePath ~= "" and sNodePath == rActor.itemPath then
					bActionItemUsed = true;
					bItem = true;
				else
					bActionItemUsed = false;
					bItem = true; -- is item, but doesn't match source path for this effect
				end
			end
		end
	end

	if nActive ~= 0 and bActionOnly and bActionItemUsed then
		bResult = true;
	elseif nActive ~= 0 and not bActionOnly and bActionItemUsed then
		bResult = true;
	elseif nActive ~= 0 and bActionOnly and not bActionItemUsed then
		bResult = false;
	else
		bResult = true;
	end

	return bResult;
end

-------------------------------------------------
-- Override Functions (updated)
-------------------------------------------------

-- Overriding checkConditionalHelper() from manager_effect_5E
function MS_checkConditionalHelper(rActor, sEffect, rTarget, aIgnore)
	if not rActor then return false; end

	for _, v in pairs(DB.getChildren(ActorManager.getCTNode(rActor), "effects")) do
		local nActive = DB.getValue(v, "isactive", 0);

		if not isValidEffect(rActor, v) then
			return false;
		end
	end

	return EffectManager5E_checkConditionalHelper(rActor, sEffect, rTarget, aIgnore);
end

-- Overriding getEffectsByType() from manager_effect_5E
function MS_getEffectsByType(rActor, sEffectType, aFilter, rFilterActor, bTargetedOnly)
	if not rActor then return {}; end

	for _, v in pairs(DB.getChildren(ActorManager.getCTNode(rActor), "effects")) do
		if not isValidEffect(rActor, v) then
			return {};
		end
	end

	return EffectManager5E_getEffectsByType(rActor, sEffectType, aFilter, rFilterActor, bTargetedOnly);
end

-- Overriding hasEffect() from manager_effect_5E
function MS_hasEffect(rActor, sEffect, rTarget, bTargetedOnly, bIgnoreEffectTargets)
	if not sEffect or not rActor then return false; end

	for _, v in pairs(DB.getChildren(ActorManager.getCTNode(rActor), "effects")) do
		if not isValidEffect(rActor, v) then
			return false;
		end
	end

	return EffectManager5E_hasEffect(rActor, sEffect, rTarget, bTargetedOnly, bIgnoreEffectTargets);
end

-- Overriding decodeActors() from CoreRPG's manager_actions
function MS_decodeActors(draginfo)
	local sItemPath = draginfo.getMetaData("itemPath");

	local rSource, aTargets = ActionsManager_decodeActors(draginfo);

	if sItemPath and sItemPath ~= "" then
		rSource.itemPath = sItemPath;
	end

	return rSource, aTargets;
end

-- Overriding PowerManager.performAction() from manager_power
function MS_powerPerformAction(draginfo, rActor, rAction, nodePower)
	if not rActor or not rAction then return false; end

	local nodeWeapon = nodePower.getChild("...");
	local _, sRecord = DB.getValue(nodeWeapon, "shortcut", "", "");
	rActor.itemPath = sRecord;
	if draginfo and rActor.itemPath and rActor.itemPath ~= "" then
		draginfo.setMetaData("itemPath", rActor.itemPath);
	end

	PowerManager_performAction(draginfo, rActor, rAction, nodePower);
end

-- Overriding ActionDamage.performRoll() from manager_action_damage
function MS_damagePerformRoll(draginfo, rActor, rAction)
	local rRoll = ActionDamage.getRoll(rActor, rAction);

	if draginfo and rActor.itemPath and rActor.itemPath ~= "" then
		draginfo.setMetaData("itemPath", rActor.itemPath);
	end

	ActionsManager.performAction(draginfo, rActor, rRoll);
end

-- Overriding ActionAttack.performRoll() from manager_action_attack
function MS_attackPerformRoll(draginfo, rActor, rAction)
	local rRoll = ActionAttack.getRoll(rActor, rAction);

	if draginfo and rActor.itemPath and rActor.itemPath ~= "" then
		draginfo.setMetaData("itemPath", rActor.itemPath);
	end

	ActionsManager.performAction(draginfo, rActor, rRoll);
end