function onInit()
	local node = getDatabaseNode();
	local nodeItem = DB.getChild(node, "...");
	local sName = DB.getValue(nodeItem, "name", "");
	name.setValue(sName);

	DB.addHandler(DB.getPath(node, ".effect"), "onUpdate", update);
	DB.addHandler(DB.getPath(node, ".durdice"), "onUpdate", update);
	DB.addHandler(DB.getPath(node, ".durmod"), "onUpdate", update);
	DB.addHandler(DB.getPath(node, ".durunit"), "onUpdate", update);
	DB.addHandler(DB.getPath(node, ".visibility"), "onUpdate", update);
	DB.addHandler(DB.getPath(node, ".actiononly"), "onUpdate", update);
	update();
end

function onClose()
	DB.removeHandler(DB.getPath(node, ".effect"), "onUpdate", update);
	DB.removeHandler(DB.getPath(node, ".durdice"), "onUpdate", update);
	DB.removeHandler(DB.getPath(node, ".durmod"), "onUpdate", update);
	DB.removeHandler(DB.getPath(node, ".durunit"), "onUpdate", update);
	DB.removeHandler(DB.getPath(node, ".visibility"), "onUpdate", update);
	DB.removeHandler(DB.getPath(node, ".actiononly"), "onUpdate", update);
end

function update()
	local node = getDatabaseNode();
	local sDuration = "";
	local dDurDice = DB.getValue(node, "durdice");
	local nDurMod = DB.getValue(node, "durmod", 0);
	local sDurDice = StringManager.convertDiceToString(dDurDice);

	if sDurDice ~= "" then
		sDuration = sDuration .. sDurDice;
	end

	if nDurMod ~= 0 and sDurDice ~= "" then
		local sSign = "+";
		if nDurMod < 0 then
			sSign = "";
		end
		sDuration = sDuration .. sSign .. nDurMod;
	elseif nDurMod ~= 0 then
		sDuration = sDuration .. nDurMod;
	end

	local sUnits = DB.getValue(node, "durunit", "");
	if sDuration ~= "" then
		local bMultiple = (sDurDice ~= "") or (nDurMod > 1);

		if sUnits == "minute" then
			sDuration = sDuration .. " minute";
		elseif sUnits == "hour" then
			sDuration = sDuration .. " hour";
		elseif sUnits == "day" then
			sDuration = sDuration .. " day";
		else
			sDuration = sDuration .. " rnd";
		end

		if bMultiple then
			sDuration = sDuration .. "s";
		end
	end

	local sActionOnly = "[ActionOnly]";
	local bActionOnly = DB.getValue(node, "actiononly", 0) ~= 0;
	if not bActionOnly then sActionOnly = ""; end

	local sEffect = DB.getValue(node, "effect", "");
	local sVis = DB.getValue(node, "visibility", "");
	if sVis ~= "" then
		sVis = " visibility [" .. sVis .. "]";
	end
	if sDuration ~= "" then
		sDuration = " for [" .. sDuration .. "]";
	end
	local sFinal = "[" .. sEffect .. "]" .. sDuration .. sVis .. sActionOnly;
	effect_description.setValue(sFinal);
end