local tankIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:%d:64:64:0:19:22:41|t";
local healerIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:%d:64:64:20:39:1:20|t";
local damageIcon = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES.blp:16:16:0:%d:64:64:20:39:22:41|t";

function LFGEventFrame_OnEvent(self, event, ...)
	if ( event == "LFG_UPDATE" ) then
		LFRStatus = C_ezAPI.getBucketData("LFR_STATUS")
		LFG_UpdateQueuedList();
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		LFG_UpdateQueuedList();
		LFG_UpdateRoleCheckboxes();
	elseif ( event == "LFG_LOCK_INFO_RECEIVED" ) then
		LFGLockList = GetLFDChoiceLockedState();
		LFG_UpdateFramesIfShown();
	elseif ( event == "PARTY_MEMBERS_CHANGED" ) then
		LFG_UpdateQueuedList();
		LFG_UpdateFramesIfShown();

		local canBackfill = CanPartyLFGBackfill()
		if LFRStatus then
			local numMembers = GetNumRaidMembers()
			-- for some reason LFG_UPDATE with STATUS_NONE doesn't invoke event? may be we do it wrong on server side?
			if numMembers == 0 then
				LFRStatus = nil
			else
				canBackfill = numMembers < LFRStatus.tankSlots + LFRStatus.healerSlots + LFRStatus.damageSlots
			end
		end
		if not canBackfill then
			StaticPopup_Hide("LFG_OFFER_CONTINUE");
		end
	elseif ( event == "LFG_OFFER_CONTINUE" ) then
		local displayName, lfgID, typeID = ...;
		local dialog = StaticPopup_Show("LFG_OFFER_CONTINUE", NORMAL_FONT_COLOR_CODE..displayName.."|r");
		if ( dialog ) then
			dialog.data = lfgID;
			dialog.data2 = typeID;
		end
	elseif ( event == "LFG_ROLE_CHECK_ROLE_CHOSEN" ) then
		local player, isTank, isHealer, isDamage = ...;

		--Yes, consecutive string concatenation == bad for garbage collection. But the alternative is either extremely unslightly or localization unfriendly. (Also, this happens fairly rarely)
		local roleList;
		
		--Horrible hack to deal with a bug in embedded font strings. FIXME
		--The more icons with absolute sizes in a certain fontstring, the higher up the text goes. This offsets it to make the icons be in line with the text.
		local numRoles = (isTank and 1 or 0) + (isHealer and 1 or 0) + (isDamage and 1 or 0);
		local yOffset = 2*(numRoles-1)-2;	--Formula derived through testing.
		
		local tankIcon = format(tankIcon, yOffset);
		local healerIcon = format(healerIcon, yOffset);
		local damageIcon = format(damageIcon, yOffset);
		
		if ( isTank ) then
			roleList = tankIcon.." "..TANK;
		end
		if ( isHealer ) then
			if ( roleList ) then
				roleList = roleList..PLAYER_LIST_DELIMITER.." "..healerIcon.." "..HEALER;
			else
				roleList = healerIcon.." "..HEALER;
			end
		end
		if ( isDamage ) then
			if ( roleList ) then
				roleList = roleList..PLAYER_LIST_DELIMITER.." "..damageIcon.." "..DAMAGER;
			else
				roleList = damageIcon.." "..DAMAGER;
			end
		end
		assert(roleList);
		ChatFrame_DisplayUsageError(string.format(LFG_ROLE_CHECK_ROLE_CHOSEN, player, roleList));
	end
	
	LFG_UpdateRolesChangeable();
	LFG_UpdateFindGroupButtons();
	LFG_UpdateLockedOutPanels();
	LFDFrame_UpdateBackfill();
end

LFGEventFrame:SetScript("OnEvent", LFGEventFrame_OnEvent)