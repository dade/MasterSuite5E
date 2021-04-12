function onInit()
	DB.addHandler("charsheet.*.attune.count", "onUpdate", update);
	DB.addHandler("charsheet.*.attune", "onChildUpdate", update);
	DB.addHandler("charsheet.*.inventorylist.*.rarity", "onUpdate", update);
	DB.addHandler("charsheet.*.classes.*.level", "onUpdate", update);
	OptionsManager.registerCallback("AT_max_attunement", update);
	update();
end

function onClose()
	DB.removeHandler("charsheet.*.attune.count", "onUpdate", update);
	DB.removeHandler("charsheet.*.attune", "onChildUpdate", update);
	DB.removeHandler("charsheet.*.inventorylist.*.rarity", "onUpdate", update);
	DB.removeHandler("charsheet.*.classes.*.level", "onUpdate", update);
	OptionsManager.unregisterCallback("AT_max_attunement", update);
end

function update()
	local nodeChar = window.getDatabaseNode().getChild("...");
	local itemRarity = DB.getValue(window.getDatabaseNode(), "rarity");
	local matchString = "([rR]equire)(.*)([aA]ttunement)";
	local bNotApplicable = false;
	local nCount, nDef, nMisc, nTot;

	nCount, nDef, nMisc, nTot = AttunementTracker.resolveAttunementSlots(nodeChar);

	if itemRarity ~= nil then
		if itemRarity:match(matchString) then
			setVisible(getValue() == 1 or nCount < nTot);
		else
			setVisible(false);
			bNotApplicable = true;
		end
	else
		setVisible(false);
		bNotApplicable = true;
	end

	if DB.getValue(window.getDatabaseNode(), "attune") == 1 then
		setVisible(getValue() == 1);
	end

	window.na_attunement.setVisible(not isVisible() and bNotApplicable);
	window.no_attunement.setVisible(not isVisible() and not window.na_attunement.isVisible());

	-- AttunementTracker.forceUpdateAttunement(nodeChar);
end

function onValueChanged()
	if getValue() == 1 then
		modifyAttunedCount(1);
	else
		modifyAttunedCount(-1);
	end
end

function modifyAttunedCount(mod)
	local nodeChar = window.getDatabaseNode();
	local path = nodeChar.getChild("...");
	local value;

	value = DB.getValue(path, "attune.count", 0);
	value = value + mod;

	if value < 0 then value = 0; end

	DB.setValue(path, "attune.count", "number", value);
end