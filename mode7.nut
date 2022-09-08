setFPS(60)
setResolution(480, 240)
::sprFont <- newSprite("res/font.png", 6, 8, 0, 0, 0, 0)
::font <- newFont(sprFont, 0, 0, true, 0)
local landHeight = 800, landWidth = 800;
local land = newSprite("res/terrain.png", 1, 1, 0, 0, 0, 0)
local sprTree = newSprite("res/big tree.png", 1, 1, 0, 0, 0, 0)

local fWorldX = 1.0;
local fWorldY = 1.0;
local fWorldA = 0.0;
local fNear = 0.005;
local fFar = 0.03;
local fFoVHalf = 3.14159 / 4.0;
local fDepth = 32.0;


local listObjects = [
    {x = 8.5, y = 8.5, spr = sprTree},
    {x = 7.5, y = 7.5, spr = sprTree},
    {x = 10.5, y = 3.5, spr = sprTree}
]

while(!getQuit()) {

	if(keyDown(k_q)) fNear += 1.0
	if(keyDown(k_a)) fNear -= 1.0
	if(keyDown(k_space)) fFar += 1.0
	if(keyDown(k_lshift)) fFar -= 1.0
    if(keyDown(k_z)) fFoVHalf += 1.0
	if(keyDown(k_x)) fFoVHalf -= 1.0

    local fFarX1 = fWorldX + cos(fWorldA - fFoVHalf) * fFar;
    local fFarY1 = fWorldY + sin(fWorldA - fFoVHalf) * fFar;

    local fNearX1 = fWorldX + cos(fWorldA - fFoVHalf) * fNear;
    local fNearY1 = fWorldY + sin(fWorldA - fFoVHalf) * fNear;

    local fFarX2 = fWorldX + cos(fWorldA + fFoVHalf) * fFar;
    local fFarY2 = fWorldY + sin(fWorldA + fFoVHalf) * fFar;

    local fNearX2 = fWorldX + cos(fWorldA + fFoVHalf) * fNear;
    local fNearY2 = fWorldY + sin(fWorldA + fFoVHalf) * fNear;

    //percentage times fNearX2-fNearX1 or screenW()?

    for (local y = 0; y < screenH() / 2; y++)
    {
        local fSampleDepth = y / (screenH().tofloat() / 2.0); // we get the depth from where the tree is drawn at?
        local fStartX = (fFarX1 - fNearX1) / (fSampleDepth) + fNearX1;
        local fStartY = (fFarY1 - fNearY1) / (fSampleDepth) + fNearY1;
        local fEndX = (fFarX2 - fNearX2) / (fSampleDepth) + fNearX2;
        local fEndY = (fFarY2 - fNearY2) / (fSampleDepth) + fNearY2;
        for (local x = 0; x < screenW(); x++)
        {
            local fSampleWidth = x.tofloat() / screenW().tofloat();
            local fSampleX = (fEndX - fStartX) * fSampleWidth + fStartX;
            local fSampleY = (fEndY - fStartY) * fSampleWidth + fStartY;

            if(fSampleX >= 0 && fSampleX < landWidth && fSampleY >= 0 && fSampleY < landHeight){
                drawSprite(land, floor(fSampleX) + (floor(fSampleY))*landWidth, x, screenH()/2 + y)
            }
        }
    }

    foreach(object in listObjects)
    {
        local fVecX = object.x - fWorldX;
		local fVecY = object.y - fWorldY;
		local fDistanceFromPlayer = sqrt(fVecX*fVecX + fVecY*fVecY);

        local fEyeX = sin(fWorldA);
        local fEyeY = cos(fWorldA);

        // Calculate angle between lamp and players feet, and players looking direction
        // to determine if the lamp is in the players field of view
        local fObjectAngle = atan2(fEyeY, fEyeX) - atan2(fVecY, fVecX);
        if (fObjectAngle < -3.14159)
            fObjectAngle += 2.0 * 3.14159;
        if (fObjectAngle > 3.14159)
            fObjectAngle -= 2.0 * 3.14159;

        local bInPlayerFOV = fabs(fObjectAngle) < fFoVHalf / 2.0;

        if (bInPlayerFOV && fDistanceFromPlayer >= 0.5 && fDistanceFromPlayer < fDepth)
        {
            local fObjectCeiling = (screenH() / 2.0).tofloat() - screenH() / fDistanceFromPlayer.tofloat();
            local fObjectFloor = screenH() - fObjectCeiling;
            local fObjectHeight = fObjectFloor - fObjectCeiling;
            local fObjectAspectRatio = 59.0 / 46.0; //I don't know what this line means
            local fObjectWidth = fObjectHeight / fObjectAspectRatio;
            local fMiddleOfObject = (0.5 * (fObjectAngle / (fFoVHalf / 2.0)) + 0.5) * screenW().tofloat();

            #Not fixed yet

            for (local lx = 0; lx < fObjectWidth; lx++)
            {
                for (local ly = 0; ly < fObjectHeight; ly++)
                {
                    local fSampleX = lx / fObjectWidth;
                    local fSampleY = ly / fObjectHeight;
                    local nObjectColumn = (fMiddleOfObject + lx - (fObjectWidth / 2.0)).tofloat();
                    if (nObjectColumn >= 0 && nObjectColumn < screenW())
                        #drawSprite(land, floor(fSampleX) + (floor(fSampleY))*landWidth, x, screenH()/2 + y)
                        if(fSampleX >= 0 && fSampleX < 46 && fSampleY >= 0 && fSampleY < 59){
                            drawSprite(object.spr, floor(fSampleX*46) + (floor(fSampleY*59))*46, nObjectColumn, fObjectCeiling + ly);
                        }
                }
            }

            #Not fixed yet
        }
    }

    if (keyDown(k_left))
    {
        fWorldA -= 0.1;
    }
    if (keyDown(k_right))
    {
        fWorldA += 0.1;
    }
    if (keyDown(k_up))
    {
        fWorldX += cos(fWorldA) * 1;
        fWorldY += sin(fWorldA) * 1;
    }

    if (keyDown(k_down))
    {
        fWorldX -= cos(fWorldA) * 1;
        fWorldY -= sin(fWorldA) * 1;
    }

    setDrawColor(0xFFFFFFFF)

    #drawRec(screenW()/2-16, screenH()-32, 32, 32, true)

    drawText(font, 20, 20, getFPS().tostring())

	update()
}