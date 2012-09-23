-----------------------------------------------------------------------------------------
--
-- Collisions.lua
--
-----------------------------------------------------------------------------------------

local class = {}
local mathAbs = math.abs

function class.pointInRect( pointX, pointY, left, top, width, height )
	return pointX >= left and pointX <= left + width and pointY >= top and pointY <= top + height
end

function class.pointInCircle( pointX, pointY, centerX, centerY, radius )
	local dX, dY = pointX - centerX, pointY - centerY
	return dX * dX + dY * dY <= radius * radius 
end

function class.pointInDiamond( pointX, pointY, centerX, centerY, radius )
	return mathAbs( pointX - centerX ) + mathAbs( pointY - centerY ) <= radius
end

function class.rectInRect( left1, top1, width1, height1, left2, top2, width2, height2 )
	return left1 >= left2 and left1 + width1 <= left2 + width2 and top1 >= top2 and top1 + height1 <= top2 + height2
end

function class.circleInCircle( centerX1, centerY1, radius1, centerX2, centerY2, radius2 )
	if radius1 > radius2 then
		return false
	end

	local dX, dY, radii = centerX1 - centerX2, centerY1 - centerY2, radius2 - radius1
	return dX * dX + dY * dY <= radii * radii
end

function class.diamondInDiamond( centerX1, centerY1, radius1, centerX2, centerY2, radius2 )
	if radius1 > radius2 then
		return false
	end
	
	return mathAbs( centerX1 - centerX2 ) + mathAbs( centerY1 - centerY2 ) <= radius2 - radius1
end

function class.intersectRects( left1, top1, width1, height1, left2, top2, width2, height2 )
	return left1 + width1 >= left2 and left1 <= left2 + width2 and top1 + height1 >= top2 and top1 <= top2 + height2
end

function class.intersectCircles( centerX1, centerY1, radius1, centerX2, centerY2, radius2 )
	local dX, dY, radii = centerX1 - centerX2, centerY1 - centerY2, radius1 + radius2

	return dX * dX + dY * dY <= radii * radii
end

function class.intersectDiamonds( centerX1, centerY1, radius1, centerX2, centerY2, radius2 )
	return mathAbs( centerX1 - centerX2 ) + mathAbs( centerY1 - centerY2 ) <= radius1 + radius2
end

function class.intersectRectWithCircle( left, top, width, height, centerX, centerY, radius )
	if left <= centerX and left + width >= centerX then
		return top + height >= centerY - radius and top <= centerY + radius
	elseif top <= centerY and top + height >= centerY then
		return left + width >= centerX - radius and left <= centerX + radius
	elseif left < centerX then
		if top < centerY then
			return class.pointInCircle( left + width, top + height, centerX, centerY, radius )
		else
			return class.pointInCircle( left + width, top, centerX, centerY, radius )
		end
	else
		if top < centerY then
			return class.pointInCircle( left, top + height, centerX, centerY, radius )
		else
			return class.pointInCircle( left, top, centerX, centerY, radius )
		end
	end
end

function class.intersectRectWithDiamond( left, top, width, height, centerX, centerY, radius )
	if left <= centerX and left + width >= centerX then
		return top + height >= centerY - radius and top <= centerY + radius
	elseif top <= centerY and top + height >= centerY then
		return left + width >= centerX - radius and left <= centerX + radius
	elseif left < centerX then
		if top < centerY then
			return class.pointInDiamond( left + width, top + height, centerX, centerY, radius )
		else
			return class.pointInDiamond( left + width, top, centerX, centerY, radius )
		end
	else
		if top < centerY then
			return class.pointInDiamond( left, top + height, centerX, centerY, radius )
		else
			return class.pointInDiamond( left, top, centerX, centerY, radius )
		end
	end
end

--------------------------------------------------------------
 
return class
