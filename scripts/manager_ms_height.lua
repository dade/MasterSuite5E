--[[
	Height management with distance calculations between targets
]]

OOB_MSGTYPE_UPDATETOKENHEIGHT = "UpdateTokenHeight";
local TokenManager_onWheelHelper;
local TokenManager_getWidgetList;

function onInit()
	DB.addHandler("combattracker.list.*.height", "onUpdate", update);

	TokenManager_onWheelHelper = TokenManager.onWheelHelper;
	TokenManager_onWheel = TokenManager.onWheel;
	TokenManager_getWidgetList = TokenManager.getWidgetList;

	Token.onWheel = onWheel;
	TokenManager.getWidgetList = getWidgetList;

	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_UPDATETOKENHEIGHT, updateTokenHeight);
end

function update(node)
	executeClientSync();
end

function updateHeight(token, notches)
	if not token then return; end

	local ctNode = CombatManager.getCTFromToken(token);
	if not ctNode then return; end

	local dbNode = DB.getChild(ctNode, "height");
	local nHeight = 0;

	if dbNode ~= nil and dbNode.getValue() ~= nil then
		nHeight = tonumber(dbNode.getValue());
	end

	nHeight = nHeight + (5 * notches);

	if ctNode.isOwner() or Session.IsHost then
		DB.setValue(ctNode, "height", "number", nHeight);
	end

	if Session.IsHost and token.getOwner then
		DB.setOwner(ctNode, token.getOwner());
	end

	executeClientSync();
end

function executeClientSync()
	local msgOOB = {};
	msgOOB.type = OOB_MSGTYPE_UPDATETOKENHEIGHT;
	Comm.deliverOOBMessage(msgOOB);
end

function updateTokenHeight()
	for _, ctNode in pairs(CombatManager.getCombatantNodes()) do
		updateHeightWidget(DB.getChild(ctNode, "height"));
	end
end

function updateHeightWidget(heightNode)
	if not heightNode then return; end

	local node = heightNode.getParent();
	local token = CombatManager.getTokenFromCT(node);
	if not token then return; end
	local nHeight = 0;
	if heightNode.getValue() ~= nil then
		nHeight = tonumber(heightNode.getValue());
	end
	local widget = token.findWidget("tokenheight");

	if widget == nil then
		widget = token.addTextWidget("height_medium", "");
	end

	widget.setName("tokenheight");
	widget.setFrame("tempmodsmall", 10, 10, 10, 4);
	widget.setPosition("bottom right", 0, 0);
	widget.setColor("#99999");
	widget.setText(nHeight .. " ft.");

	if nHeight == 0 or not nHeight then
		widget.setVisible(false);
		widget.destroy();
	else
		widget.bringToFront();
		widget.setVisible(true);
	end
end

function getWidgetList(tokenCT, sSet)
	updateHeight(tokenCT, 0);
	return TokenManager_getWidgetList(tokenCT, sSet);
end

function onWheel(tokenCT, notches)
	local stopProc = true;
	if Input.isAltPressed() then
		updateHeight(tokenCT, notches);
	elseif Input.isShiftPressed() then
		local oldOrientation = tokenCT.getOrientation();
		local newOrientation = (oldOrientation + notches) % 8;

		tokenCT.setOrientation(newOrientation);
	elseif Input.isControlPressed() then
		local w = 0;
		local h = 0;
		local rectScale = 0;

		w, h = tokenCT.getImageSize();

		if w > h then
			rectScale = w / h;
		elseif h > w then
			rectScale = h / w;
		else
			rectScale = 1;
		end

		local newscale = tokenCT.getScale();
		if UtilityManager.isClientFGU() then
			local adj = notches * 0.1;
			if adj < 9 then
				newscale = newscale * (1 + adj);
			else
				newscale = newscale + (1 / (1 - adj));
			end
		else
			newscale = newscale + (notches * 0.1);
			if newscale < 0.1 then
				newscale = 0.1;
			end
		end

		tokenCT.setScale(newscale * rectScale);
	end

	return true;
end

function getCTEntryHeight(ctEntry)
	local height = 0;

	if ctEntry then
		local heightNode = ctEntry.getChild("height");

		if heightNode then
			height = heightNode.getValue();
		else
			-- Debug.console("no height node");
		end
	end

	return height;
end

function getHeight(ctNode)
	local hNode = DB.getChild(ctNode, "height");
	local nHeight = 0;
	if hNode and hNode.getValue() then
		nHeight = tonumber(hNode.getValue());
	end

	return nHeight;
end

function getHeightDifferential(sourceNode, targetNode)
	if User.getRulesetName() == "5E" then
		local sourceSize = StringManager.trim(DB.getValue(sourceNode, "size", ""):lower());
		local targetSize = StringManager.trim(DB.getValue(targetNode, "size", ""):lower());

		local sSizeIndex = 1;
		local tSizeIndex = 1;
		if sourceSize == "large" then
			sSizeIndex = 2;
		elseif sourceSize == "huge" then
			sSizeIndex = 3;
		elseif sourceSize == "gargantuan" then
			sSizeIndex = 4;
		end

		if targetSize == "large" then
			tSizeIndex = 2;
		elseif targetSize == "huge" then
			tSizeIndex = 3;
		elseif targetSize == "gargantuan" then
			tSizeIndex = 4;
		end

		return sSizeIndex, tSizeIndex;
	end
end

function getHeightOrientation(ctNode)
	local heightOrientation = 0;

	return heightOrientation;
end