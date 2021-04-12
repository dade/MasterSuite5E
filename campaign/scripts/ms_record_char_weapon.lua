function onInit()
	super.onInit();
end

function onAttackAction(draginfo)
	local nodeWeapon = getDatabaseNode();
	local nodeChar = nodeWeapon.getChild("...")

	-- Build basic attack action record
	local rAction = CharWeaponManager.buildAttackAction(nodeChar, nodeWeapon);

	-- Decrement ammo
	CharWeaponManager.decrementAmmo(nodeChar, nodeWeapon);

	-- Perform action
	local rActor = ActorManager.resolveActor(nodeChar);
	local _, sRecord = DB.getValue(nodeWeapon, "shortcut", "", "");

	rActor.itemPath = sRecord;
	ActionAttack.performRoll(draginfo, rActor, rAction);
	return true;
end

function onDamageAction(draginfo)
	local nodeWeapon = getDatabaseNode();
	local nodeChar = nodeWeapon.getChild("...")

	-- Build basic damage action record
	local rAction = CharWeaponManager.buildDamageAction(nodeChar, nodeWeapon);

	-- Perform damage action
	local rActor = ActorManager.resolveActor(nodeChar);
	local _, sRecord = DB.getValue(nodeWeapon, "shortcut", "", "");

	rActor.itemPath = sRecord;
	ActionDamage.performRoll(draginfo, rActor, rAction);
	return true;
end