function onInit()
	DB.addHandler("charsheet.*.inventorylist", "onChildDeleted", onInventoryItemDeleted);
end

function onClose()
	DB.removeHandler("charsheet.*.inventorylist", "onChildDeleted", onInventoryItemDeleted);
end

function onInventoryItemDeleted()
	local invList = getInventoryList();

	if invList == nil then return; end

	local attunedCount = 0;
	local list_items = invList.getWindows(false);

	for _, item in ipairs(list_items) do
		local attune_checkbox = getAttunedCheckbox(item);

		if attune_checkbox ~= nil then
			local isChecked = attune_checkbox.getValue();
			if isChecked >= 1 then
				attunedCount = attunedCount + 1;
			end
		end
	end

	local node = window.getDatabaseNode();
	DB.setValue(node, "attune.count", "number", attunedCount);
end

function getInventoryList()
	local controls = window.getControls();

	if controls == nil then return nil; end

	for _, ctrl in ipairs(controls) do
		if ctrl.getName() == "inventorylist" then
			return ctrl;
		end
	end

	return nil;
end

function getAttunedCheckbox(item)
	local controls = item.getControls();

	if controls == nil then return nil; end

	for _, ctrl in ipairs(controls) do
		if ctrl.getName() == "attune" then
			return ctrl;
		end
	end
end