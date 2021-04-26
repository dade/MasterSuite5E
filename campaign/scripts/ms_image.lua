local getDistanceBetweenOriginal;

function onInit()
	if super and super.onInit() then
		super.onInit();
	end
	
	getDistanceBetweenOriginal = Token.getDistanceBetween;
	Token.getDistanceBetween = getDistanceBetween;
end

function onMeasurePointer(pixellength, type, startx, starty, endx, endy)
	if not (getGridSize and getDistanceBaseUnits and getDistanceSuffix and Interface.getDistanceDiagMult and getDistanceDiagMult) then
		return "";
	end

	local gridSize = getGridSize();
	local units = getDistanceBaseUnits();
	local suffix = getDistanceSuffix();
	local diagMult = Interface.getDistanceDiagMult();
	if getDistanceDiagMult() == 0 then diagMult = 0; end
	local startz = 0;
	local endz = 0;
	local ctNodeOrigin = getCTNodeAt(startx, starty, gridSize);

	if ctNodeOrigin then
		local ctNodeTarget = getCTNodeAt(endx, endy, gridSize);

		if ctNodeTarget then
			startz = HeightManager.getHeight(ctNodeOrigin) * gridSize / units;
			endz = HeightManager.getHeight(ctNodeTarget) * gridSize / units;
		end
	end

	local distance = getDistanceBetween3D(startx, starty, startz, endx, endy, endz);

	if distance == 0 then
		return "";
	else
		local stringDistance = nil;
		if diagMult == 0 then
			stringDistance = string.format("%.1f", distance);
		else
			stringDistance = string.format("%.0f", distance);
		end

		return stringDistance .. suffix;
	end
end

function getCTNodeAt(sx, sy, gridSize)
	local tokens = getTokens();

	for _, token in pairs(tokens) do
		local x, y = token.getPosition();
		local ctNode = CombatManager.getCTFromToken(token);
		local bExact = true;
		local sizeMult = 0;

		if User.getRulesetName() == "5E" then
			local sSize = StringManager.trim(DB.getValue(ctNode, "size", ""):lower());

			if sSize == "large" then
				sizeMult = 0.5;
			elseif sSize == "huge" then
				sizeMult = 1;
			elseif sSize == "gargantuan" then
				sizeMult = 1.5;
				bExact = false;
			end
		end

		local bFound = false;
		if bExact then
			bFound = exactMatch(sx, sy, x, y, sizeMult, gridSize);
		else
			bFound = matchWithin(sx, sy, x, y, sizeMult, gridSize);
		end

		if bFound then
			return ctNode;
		end
	end
end

-- Incorporating GKEnialb's work here (reformatted slightly, same functionality)
function exactMatch(sx, sy, ex, ey, sizeMult, gridSize)
	local eq = false;

	if ex > sx then
		ex = ex - gridSize * sizeMult;
	elseif ex < sx then
		ex = ex + gridSize * sizeMult;
	end

	if ey > sy then
		ey = ey - gridSize * sizeMult;
	elseif ey < sy then
		ey = ey + gridSize * sizeMult;
	end

	if ex == sx and ey == sy then
		eq = true;
	end

	return eq;
end

function matchWithin(sx, sy, ex, ey, sizeMult, gridSize)
	local eq = false;
	local lbx = ex;
	local lby = ey;
	local ubx = ex;
	local eby = ey;

	if ex > sx then
		lbx = ex - gridSize * sizeMult;
	elseif ex < sx then
		ubx = ex + gridSize * sizeMult;
	end

	if ey > sy then
		lby = ey - gridSize * sizeMult;
	elseif ey < sy then
		uby = ey + gridSize * sizeMult;
	end

	if sx >= lbx and sx <= ubx and sy >= lby and sy <= uby then
		eq = true;
	end

	return eq;
end

-- Custom Override
local function getDistanceBetween(sourceToken, targetToken)
	if not sourceToken and not targetToken then
		return;
	end

	local gridSize = getGridSize();
	local units = getDistanceBaseUnits();
	local startz = 0;
	local endz = 0;
	local ctNodeOrigin = CombatManager.getCTFromToken(sourceToken);
	if ctNodeOrigin then
		startz = HeightManager.getHeight(ctNodeOrigin) * gridSize / units;
		local ctNodeTarget = CombatManager.getCTFromToken(targetToken);

		if ctNodeTarget then
			endz = HeightManager.getHeight(ctNodeTarget) * gridSize / units;
		end
	end

	local startx, starty = sourceToken.getPosition();
	local endx, endy = targetToken.getPosition();
	local nDistance = getDistanceBetween3D(startx, starty, startz, endx, endy, endz);
	return nDistance;
end

function getDistanceBetween3D(startx, starty, startz, endx, endy, endz)
	local diagMult = Interface.getDistanceDiagMult();
	if getDistanceDiagMult() == 0 then diagMult = 0; end

	local units = getDistanceBaseUnits();
	local gridSize = getGridSize();
	local distance = 0;
	local dx = math.abs(endx - startx);
	local dy = math.abs(endy - starty);
	local dz = math.abs(endz - startz);

	if diagMult == 1 then
		local longestLeg = math.max(dx, dy, dz);
		distance = math.floor(longestLeg / gridSize + 0.5) * units;
	elseif diagMult == 0 then
		local hypotenuse = math.sqrt((dx ^ 2) + (dy ^ 2) + (dz ^ 2));
		distance = (hypotenuse / gridSize) * units;
	else
		local straight = math.max(dx, dy, dz);
		local diagonal = 0;

		if straight == dx then
			diagonal = math.floor((math.ceil(dy / gridSize) + math.ceil(dz / gridSize)) / 2) * gridSize;
		elseif straight == dy then
			diagonal = math.floor((math.ceil(dx / gridSize) + math.ceil(dz / gridSize)) / 2) * gridSize;
		else
			diagonal = math.floor((math.ceil(dx / gridSize) + math.ceil(dy / gridSize)) / 2) * gridSize;
		end

		distance = math.floor((straight + diagonal) / gridSize);
		distance = distance * units;
	end

	return distance;
end