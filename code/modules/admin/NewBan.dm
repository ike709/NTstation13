var/CMinutes = null
var/list/Banlist = list()

/*
/proc/CheckBan(var/ckey, var/id, var/address)
	if(!Banlist)		// if Banlist cannot be located for some reason
		LoadBans()		// try to load the bans
		if(!Banlist)	// uh oh, can't find bans!
			return 0	// ABORT ABORT ABORT

	. = list()
	var/appeal
	if(config && config.banappeals)
		appeal = "\nFor more information on your ban, or to appeal, head to <a href='[config.banappeals]'>[config.banappeals]</a>"
	//banlist.cd = "/base"
	if( "[ckey][id]" in banlist["dor"])
		//banlist.cd = "[ckey][id]"
		if (Banlist["temp"])
			if (!GetExp(Banlist["minutes"]))
				ClearTempbans()
				return 0
			else
				.["desc"] = "\nReason: [Banlist["reason"]]\nExpires: [GetExp(Banlist["minutes"])]\nBy: [Banlist["bannedby"]][appeal]"
		else
			//banlist.cd	= "/base/[ckey][id]"
			.["desc"]	= "\nReason: [Banlist["reason"]]\nExpires: <B>PERMENANT</B>\nBy: [Banlist["bannedby"]][appeal]"
		.["reason"]	= "ckey/id"
		return .
	else
		for (var/A in banlist.dir)
			//banlist.cd = "/base/[A]"
			var/matches
			if( ckey == Banlist["key"] )
				matches += "ckey"
			if( id == Banlist["id"] )
				if(matches)
					matches += "/"
				matches += "id"
			if( address == Banlist["ip"] )
				if(matches)
					matches += "/"
				matches += "ip"

			if(matches)
				if(Banlist["temp"])
					if (!GetExp(Banlist["minutes"]))
						ClearTempbans()
						return 0
					else
						.["desc"] = "\nReason: [Banlist["reason"]]\nExpires: [GetExp(Banlist["minutes"])]\nBy: [Banlist["bannedby"]][appeal]"
				else
					.["desc"] = "\nReason: [Banlist["reason"]]\nExpires: <B>PERMENANT</B>\nBy: [Banlist["bannedby"]][appeal]"
				.["reason"] = matches
				return .
	return 0*/

/proc/UpdateTime() //No idea why i made this a proc.
	CMinutes = (world.realtime / 10) / 60
	return 1

/proc/LoadBans()

	//Banlist = new("data///banlist.bdb")
	log_admin("Loading Banlist")

//	if (!length(banlist["dir"])) log_admin("Banlist is empty.")

	//if (!//banlist.dir.Find("base"))
	//	log_admin("Banlist missing base dir.")
		//banlist.dir.Add("base")
		//banlist.cd = "/base"
	//else if (//banlist.dir.Find("base"))
		//banlist.cd = "/base"

	ClearTempbans()
	return 1

/proc/ClearTempbans()
	UpdateTime()

	//banlist.cd = "/base"
	/*for (var/A in banlist["dir"])
		//banlist.cd = "/base/[A]"
		if (!Banlist["key"] || !Banlist["id"])
			RemoveBan(A)
			log_admin("Invalid Ban.")
			message_admins("Invalid Ban.")
			continue

		if (!Banlist["temp"]) continue
		if (CMinutes >= Banlist["minutes"]) RemoveBan(A)*/

	return 1


/proc/AddBan(ckey, computerid, reason, bannedby, temp, minutes, address)

	/*var/bantimestamp

	if (temp)
		UpdateTime()
		bantimestamp = CMinutes + minutes

	//banlist.cd = "/base"
	if (1)
		usr << text("\red Ban already exists.")
		return 0
	else
		//banlist.dir.Add("[ckey][computerid]")
		//banlist.cd = "/base/[ckey][computerid]"
		Banlist["key"] << ckey
		Banlist["id"] << computerid
		Banlist["ip"] << address
		Banlist["reason"] << reason
		Banlist["bannedby"] << bannedby
		Banlist["temp"] << temp
		if (temp)
			Banlist["minutes"] << bantimestamp
		notes_add(ckey, "Banned for [minutes] minutes - [reason]")*/
	return 1

/proc/RemoveBan(foldername)
	return 1

/proc/GetExp(minutes as num)
	UpdateTime()
	var/exp = minutes - CMinutes
	if (exp <= 0)
		return 0
	else
		var/timeleftstring
		if (exp >= 1440) //1440 = 1 day in minutes
			timeleftstring = "[round(exp / 1440, 0.1)] Days"
		else if (exp >= 60) //60 = 1 hour in minutes
			timeleftstring = "[round(exp / 60, 0.1)] Hours"
		else
			timeleftstring = "[exp] Minutes"
		return timeleftstring

/datum/admins/proc/unbanpanel()
	var/count = 0
	var/dat
	return
	

//////////////////////////////////// DEBUG ////////////////////////////////////

/proc/CreateBans()

	return

/proc/ClearAllBans()
	return
	//banlist.cd = "/base"
	//or (var/A in banlist["dir"])
//		RemoveBan(A)

