rulesetAttunementDef = 3;

function getDefaultAttunementSlots(node)
	return tonumber(DB.getValue(node, "attune.default", 0));
end

function getMiscAttunementModifier(node)
	return tonumber(DB.getValue(node, "attune.misc", 0));
end

function getAttunementCount(node)
	return tonumber(DB.getValue(node, "attune.count", 0));
end

function getMaxAttunementSlots(node)
	return tonumber(DB.getValue(node, "attune.total", 0));
end

function resolveAttunementSlots(node)
	local nDef, nTot;
	local nMisc = getMiscAttunementModifier(node);
	local nCount = getAttunementCount(node);

	nDef = rulesetAttunementDef;

	if DB.getChild(node, "classes") ~= nil then
		local aClasses = DB.getChild(node, "classes");
		local aCList = aClasses.getChildren();

		for _, v in pairs(aCList) do
			local vName = DB.getValue(v, "name");
			local vLvl = DB.getValue(v, "level");

			if vName == "Artificer" then
				if vLvl >= 9 and vLvl < 14 then
					nDef = nDef + 1;
				elseif vLvl >= 14 and vLvl < 18 then
					nDef = nDef + 2;
				elseif vLvl >= 18 then
					nDef = nDef + 3;
				end
			end
		end
	end

	if nMisc > 0 then
		nTot = nDef + nMisc;
	else
		nTot = nDef;
	end

	return nCount, nDef, nMisc, nTot;
end

function forceUpdateAttunement(node)
	local nCount, nDef, nMisc, nTot = resolveAttunementSlots(node);

	if nCount ~= getAttunementCount(node) then
		DB.setValue(node, "attune.count", "number", nCount);
	end

	if nDef ~= getDefaultAttunementSlots(node) then
		DB.setValue(node, "attune.default", "number", nDef);
	end

	if nMisc ~= getMiscAttunementModifier(node) then
		DB.setValue(node, "attune.misc", "number", nMisc);
	end

	if nTot ~= getMaxAttunementSlots(node) then
		DB.setValue(node, "attune.total", "number", nTot);
	end
end

function registerDefaults(node)
	local nCount, nDef, nMisc, nTot = resolveAttunementSlots(node);
	DB.setValue(node, "attune.count", "number", nCount);
	DB.setValue(node, "attune.default", "number", nDef);
	DB.setValue(node, "attune.misc", "number", nMisc);
	DB.setValue(node, "attune.total", "number", nTot);
end