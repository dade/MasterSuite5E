--[[
	Code HEAVILY inspired by Theogeek's Improved Criticals, except we don't need all of its functionality
	so we're simply going to jack out most of the code and just maximize the critical damage dice if the
	extension is enabled.
]]
local rOriginalRoll = {};
local onDamage = nil;
local onDamageRoll = nil;

function onInit()
	onDamageRoll = ActionDamage.onDamageRoll;
	ActionDamage.onDamageRoll = onDamageRollWrapper;
	ActionsManager.registerPostRollHandler("damage", ActionDamage.onDamageRoll);

	onDamage = ActionDamage.onDamage;
	ActionDamage.onDamage = onDamageWrapper;
	ActionsManager.registerResultHandler("damage", ActionDamage.onDamage);
end

function critEnabled()
	return OptionsManager.isOption("MS_Crit", "option_val_enabled");
end

function calculateDamage(aClauses, rRoll)
	local endDie = 0;
	local startDie = 1;
	local nOriginalDamage = 0;
	local vDie;
	local nSides;
	local sSign, sColor, sSides;
	local tempDie;
	local bIsCritClause = false;
	local bDieOverride = false;

	for _, aClause in ipairs(aClauses) do
		endDie = startDie + #aClause.dice - 1;
		bIsCritClause = aClause.dmgtype:match("critical") ~= nil;
		tempDie = rRoll.aDice[startDie];

		if tempDie ~= nil then
			sSign, sColor, sSides = tempDie.type:match("^([%-%+]?)([dDrRgGbBpP])([%dF]+)");
			if sColor == "g" then
				bDieOverride = true;
			end

			for i = startDie, endDie do
				vDie = rRoll.aDice[i];
				nOriginalDamage = vDie.result;
				nSides = tonumber(sSides) or 0;

				if bDieOverride then
					if nSides > 0 then
						if sSign == "-" then
							vDie.result = 0 - nSides;
						else
							vDie.result = nSides;
						end
					end
				end

				vDie.value = vDie.result;
			end

			startDie = endDie + 1;
		end
	end
end

function onDamageRollWrapper(rSource, rRoll)
	rOriginalRoll = UtilityManager.copyDeep(rRoll);
	onDamageRoll(rSource, rRoll);
end

function onDamagePreWrapper(rSource, rTarget, rRoll)
	local aClauses = {};
	if critEnabled() and rRoll.sDesc:match("%[CRITICAL%]") then
		aClauses = UtilityManager.copyDeep(rRoll.clauses);
		rRoll = UtilityManager.copyDeep(rOriginalRoll);
		calculateDamage(aClauses, rRoll);
		ActionDamage.decodeDamageTypes(rRoll, true);
	end
	return rRoll;
end

function onDamageWrapper(rSource, rTarget, rRoll)
	rRoll = onDamagePreWrapper(rSource, rTarget, rRoll);
	onDamage(rSource, rTarget, rRoll);
end