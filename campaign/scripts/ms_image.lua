function onInit()
	if super and super.onInit() then
		super.onInit();
	end

	DB.addHandler("combattracker.list.*.height", "onUpdate", updateMeasure);
end

function updateMeasure(node)
	
end

function onMeasurePointer(pixellength, type, startx, starty, endx, endy)
	local gridSize = self.getGridSize();
	local snapSX, snapSY = snapToGrid(startx, starty);
	local snapEX, snapEY = snapToGrid(endx, endy);
	local ctNodeStart, ctNodeEnd = getCTNodesAt(startx, starty, endx, endy);
	local nHeightDistance = 0;
	local diagMult = Interface.getDistanceDiagMult();
	local suffix = getDistanceSuffix() or "";

	if HeightManager ~= nil then
		local sh = HeightManager.getCTEntryHeight(ctNodeStart);
		local eh = HeightManager.getCTEntryHeight(ctNodeEnd);
		nHeightDistance = math.abs(eh - sh) / 5;
	end

	local lenx = math.floor(math.abs(snapSX - snapEX) / gridSize);
	local leny = math.floor(math.abs(snapSY - snapEY) / gridSize);
	local baseDistance = math.max(lenx, leny) + math.floor(math.min(lenx, leny) / 2);
	local distance = baseDistance;

	if nHeightDistance > 0 then
		distance = math.floor((math.sqrt((baseDistance ^ 2) + (nHeightDistance ^ 2)) * 10) + 1) / 10;
	end

	if distance == 0 then
		return "";
	else
		if diagMult > 0 then
			distance = string.format("%.0f", distance);
		else
			distance = string.format("%.1f", distance);
		end
	end

	return ("" .. (distance * 5) .. suffix);
end

function getCTNodesAt(posSX, posSY, posEX, posEY)
	local startNodeCT, endNodeCT = nil;

	if not listCT then
		listCT = DB.findNode("combattracker.list");
	end

	local ctEntries = listCT.getChildren();

	for _, v in pairs(ctEntries) do
		token = CombatManager.getTokenFromCT(v);

		if token then
			local posX, posY = token.getPosition();

			if posX == posSX and posY == posSY then
				startNodeCT = v;
			elseif posX == posEX and posY == posEY then
			endNodeCT = v;
			end

			if startNodeCT ~= nil and endNodeCT ~= nil then
				break;
			end
		end
	end

	return startNodeCT, endNodeCT;
end