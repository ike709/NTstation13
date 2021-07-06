//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

#define access_security 1 // Security equipment
#define access_brig 2 // Brig timers and permabrig
#define access_armory 3
#define access_forensics_lockers 4
#define access_medical 5
#define access_morgue 6
#define access_tox 7
#define access_tox_storage 8
#define access_genetics 9
#define access_engine 10
#define access_engine_equip 11
#define access_maint_tunnels 12
#define access_external_airlocks 13
#define access_emergency_storage 14
#define access_change_ids 15
#define access_ai_upload 16
#define access_teleporter 17
#define access_eva 18
#define access_heads 19
#define access_captain 20
#define access_all_personal_lockers 21
#define access_chapel_office 22
#define access_tech_storage 23
#define access_atmospherics 24
#define access_bar 25
#define access_janitor 26
#define access_crematorium 27
#define access_kitchen 28
#define access_robotics 29
#define access_rd 30
#define access_cargo 31
#define access_construction 32
#define access_chemistry 33
#define access_cargo_bot 34
#define access_hydroponics 35
#define access_manufacturing 36
#define access_library 37
#define access_lawyer 38
#define access_virology 39
#define access_cmo 40
#define access_qm 41
#define access_court 42
#define access_surgery 45
#define access_theatre 46
#define access_research 47
#define access_mining 48
#define access_mining_office 49 //not in use
#define access_mailsorting 50
#define access_mint 51
#define access_mint_vault 52
#define access_heads_vault 53
#define access_mining_station 54
#define access_xenobiology 55
#define access_ce 56
#define access_hop 57
#define access_hos 58
#define access_RC_announce 59 //Request console announcements
#define access_keycard_auth 60 //Used for events which require at least two people to confirm them
#define access_tcomsat 61 // has access to the entire telecomms satellite / machinery
#define access_gateway 62
#define access_sec_doors 63 // Security front doors
#define access_mineral_storeroom 64
#define access_minisat 65
#define access_weapons 66 //Weapon authorization for secbots

	//BEGIN CENTCOM ACCESS
	/*Should leave plenty of room if we need to add more access levels.
#define Mostly for admin fun times.*/
#define access_cent_general 101//Minimum access.
#define access_cent_thunder 102//Thunderdome.
#define access_cent_specops 103//Special Ops.
#define access_cent_medsci 104//Medical/Research
#define access_cent_living 105//Living quarters.
#define access_cent_engineering 106//Engineering (formally 'teleporter')
#define access_cent_secret 107//Agents(spies, assassins, secrets, etc) (formally 'storage')
#define access_cent_captain 109//Captain's office/ID comp/AI.

	//The Syndicate
#define access_syndicate 150//General Syndicate Access

/obj/var/list/req_access = null
/obj/var/req_access_txt = "0"
/obj/var/list/req_one_access = null
/obj/var/req_one_access_txt = "0"

//returns 1 if this mob has sufficient access to use this object
/obj/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(src.check_access(null))
		return 1
	if(istype(M, /mob/living/silicon))
		//AI can do whatever he wants
		return 1
	else if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(src.check_access(H.get_active_hand()) || src.check_access(H.wear_id))
			return 1
	else if(istype(M, /mob/living/carbon/monkey) || istype(M, /mob/living/carbon/alien/humanoid))
		var/mob/living/carbon/george = M
		//they can only hold things :(
		if(src.check_access(george.get_active_hand()))
			return 1
	else if(isanimal(M))
		var/mob/living/simple_animal/A = M
		if(check_access(A.access_card))
			return 1
	return 0

/obj/item/proc/GetAccess()
	return list()

/obj/item/proc/GetID()
	return null

/obj/proc/check_access(obj/item/I)
	//These generations have been moved out of /obj/New() because they were slowing down the creation of objects that never even used the access system.
	if(!src.req_access)
		src.req_access = list()
		if(src.req_access_txt)
			var/list/req_access_str = text2list(req_access_txt,";")
			for(var/x in req_access_str)
				var/n = text2num(x)
				if(n)
					req_access += n

	if(!src.req_one_access)
		src.req_one_access = list()
		if(src.req_one_access_txt)
			var/list/req_one_access_str = text2list(req_one_access_txt,";")
			for(var/x in req_one_access_str)
				var/n = text2num(x)
				if(n)
					req_one_access += n

	if(!istype(src.req_access, /list)) //something's very wrong
		return 1

	var/list/L = src.req_access
	if(!L.len && (!src.req_one_access || !src.req_one_access.len)) //no requirements
		return 1
	if(!I)
		return 0
	for(var/req in src.req_access)
		if(!(req in I.GetAccess())) //doesn't have this access
			return 0
	if(src.req_one_access && src.req_one_access.len)
		for(var/req in src.req_one_access)
			if(req in I.GetAccess()) //has an access from the single access list
				return 1
		return 0
	return 1


/obj/proc/check_access_list(var/list/L)
	if(!src.req_access  && !src.req_one_access)	return 1
	if(!islist(src.req_access))	return 1
	if(!src.req_access.len && (!src.req_one_access || !src.req_one_access.len))	return 1
	if(!L)	return 0
	if(!islist(L))	return 0
	for(var/req in src.req_access)
		if(!(req in L)) //doesn't have this access
			return 0
	if(src.req_one_access && src.req_one_access.len)
		for(var/req in src.req_one_access)
			if(req in L) //has an access from the single access list
				return 1
		return 0
	return 1

/proc/get_centcom_access(job)
	switch(job)
		if("Guest")
			return list(access_cent_general)
		if("Employee")
			return list(access_cent_general, access_cent_living)
		if("Thunderdome Overseer")
			return list(access_cent_general, access_cent_living, access_cent_thunder)
		if("Med-Sci")
			return list(access_cent_general, access_cent_living, access_cent_medsci)
		if("Engineer")
			return list(access_cent_general, access_cent_living, access_cent_engineering)
		if("Spec Ops")
			return list(access_cent_general, access_cent_living, access_cent_specops)
		if("Special Ops Officer")
			return list(access_cent_general, access_cent_living, access_cent_thunder, access_cent_specops, access_cent_medsci, access_cent_secret)
		if("Agent")
			return list(access_cent_general, access_cent_living, access_cent_secret)
		if("Vice-Admiral")
			return get_all_centcom_access()
		if("Admiral")
			return get_all_centcom_access()

/proc/get_all_accesses()
	return list(access_security, access_sec_doors, access_brig, access_armory, access_forensics_lockers, access_court,
	            access_medical, access_genetics, access_morgue, access_rd,
	            access_tox, access_tox_storage, access_chemistry, access_engine, access_engine_equip, access_maint_tunnels,
	            access_external_airlocks, access_change_ids, access_ai_upload,
	            access_teleporter, access_eva, access_heads, access_captain, access_all_personal_lockers,
	            access_tech_storage, access_chapel_office, access_atmospherics, access_kitchen,
	            access_bar, access_janitor, access_crematorium, access_robotics, access_cargo, access_construction,
	            access_hydroponics, access_library, access_lawyer, access_virology, access_cmo, access_qm, access_surgery,
	            access_theatre, access_research, access_mining, access_mailsorting, access_weapons,
	            access_heads_vault, access_mining_station, access_xenobiology, access_ce, access_hop, access_hos, access_RC_announce,
	            access_keycard_auth, access_tcomsat, access_gateway, access_mineral_storeroom)

/proc/get_all_centcom_access()
	return list(access_cent_general, access_cent_thunder, access_cent_specops, access_cent_medsci, access_cent_engineering, access_cent_living, access_cent_secret, access_cent_captain)

/proc/get_all_syndicate_access()
	return list(access_syndicate)

/proc/get_region_accesses(var/code)
	switch(code)
		if(0)
			return get_all_accesses()
		if(1) //station general
			return list(access_kitchen,access_bar, access_hydroponics, access_janitor, access_chapel_office, access_crematorium, access_library, access_theatre, access_lawyer)
		if(2) //security
			return list(access_sec_doors, access_weapons, access_security, access_brig, access_armory, access_forensics_lockers, access_court, access_hos)
		if(3) //medbay
			return list(access_medical, access_genetics, access_morgue, access_chemistry, access_virology, access_surgery, access_cmo)
		if(4) //research
			return list(access_research, access_tox, access_tox_storage, access_robotics, access_xenobiology, access_genetics, access_rd)
		if(5) //engineering and maintenance
			return list(access_construction, access_maint_tunnels, access_engine, access_engine_equip, access_external_airlocks, access_tech_storage, access_atmospherics, access_tcomsat, access_ce)
		if(6) //supply
			return list(access_mailsorting, access_mining, access_mining_station, access_mineral_storeroom, access_cargo, access_qm)
		if(7) //command
			return list(access_heads, access_RC_announce, access_keycard_auth, access_change_ids, access_ai_upload, access_teleporter, access_eva, access_gateway, access_all_personal_lockers, access_heads_vault, access_hop, access_captain)

/proc/get_region_accesses_name(var/code)
	switch(code)
		if(0)
			return "All"
		if(1)
			return "Station General"
		if(2)
			return "Security"
		if(3)
			return "Medbay"
		if(4)
			return "Research"
		if(5)
			return "Engineering"
		if(6)
			return "Supply"
		if(7)
			return "Command"


/proc/get_access_desc(A)
	switch(A)
		if(access_cargo)
			return "Cargo Bay"
		if(access_cargo_bot)
			return "Delivery Chutes"
		if(access_security)
			return "Security"
		if(access_brig)
			return "Holding Cells"
		if(access_court)
			return "Courtroom"
		if(access_forensics_lockers)
			return "Forensics"
		if(access_medical)
			return "Medical"
		if(access_genetics)
			return "Genetics Lab"
		if(access_morgue)
			return "Morgue"
		if(access_tox)
			return "R&D Lab"
		if(access_tox_storage)
			return "Toxins Lab"
		if(access_chemistry)
			return "Chemistry Lab"
		if(access_rd)
			return "RD Office"
		if(access_bar)
			return "Bar"
		if(access_janitor)
			return "Custodial Closet"
		if(access_engine)
			return "Engineering"
		if(access_engine_equip)
			return "Power Equipment"
		if(access_maint_tunnels)
			return "Maintenance"
		if(access_external_airlocks)
			return "External Airlocks"
		if(access_emergency_storage)
			return "Emergency Storage"
		if(access_change_ids)
			return "ID Console"
		if(access_ai_upload)
			return "AI Upload"
		if(access_teleporter)
			return "Teleporter"
		if(access_eva)
			return "EVA"
		if(access_heads)
			return "Bridge"
		if(access_captain)
			return "Captain"
		if(access_all_personal_lockers)
			return "Personal Lockers"
		if(access_chapel_office)
			return "Chapel Office"
		if(access_tech_storage)
			return "Technical Storage"
		if(access_atmospherics)
			return "Atmospherics"
		if(access_crematorium)
			return "Crematorium"
		if(access_armory)
			return "Armory"
		if(access_construction)
			return "Construction"
		if(access_kitchen)
			return "Kitchen"
		if(access_hydroponics)
			return "Hydroponics"
		if(access_library)
			return "Library"
		if(access_lawyer)
			return "Law Office"
		if(access_robotics)
			return "Robotics"
		if(access_virology)
			return "Virology"
		if(access_cmo)
			return "CMO Office"
		if(access_qm)
			return "Quartermaster"
		if(access_surgery)
			return "Surgery"
		if(access_theatre)
			return "Theatre"
		if(access_manufacturing)
			return "Manufacturing"
		if(access_research)
			return "Science"
		if(access_mining)
			return "Mining"
		if(access_mining_office)
			return "Mining Office"
		if(access_mailsorting)
			return "Cargo Office"
		if(access_mint)
			return "Mint"
		if(access_mint_vault)
			return "Mint Vault"
		if(access_heads_vault)
			return "Main Vault"
		if(access_mining_station)
			return "Mining EVA"
		if(access_xenobiology)
			return "Xenobiology Lab"
		if(access_hop)
			return "HoP Office"
		if(access_hos)
			return "HoS Office"
		if(access_ce)
			return "CE Office"
		if(access_RC_announce)
			return "RC Announcements"
		if(access_keycard_auth)
			return "Keycode Auth."
		if(access_tcomsat)
			return "Telecommunications"
		if(access_gateway)
			return "Gateway"
		if(access_sec_doors)
			return "Brig"
		if(access_mineral_storeroom)
			return "Mineral Storage"
		if(access_weapons)
			return "Weapon Permit"

/proc/get_centcom_access_desc(A) //Changing this to reflect the new sprites
	switch(A)
		if(access_cent_general)
			return "Code Green"
		if(access_cent_thunder)
			return "Code Blue"
		if(access_cent_engineering)
			return "Code Yellow"
		if(access_cent_living)
			return "Code Grey"
		if(access_cent_medsci)
			return "Code Purple"
		if(access_cent_secret)
			return "Code Black"
		if(access_cent_specops)
			return "Code Red"
		if(access_cent_captain)
			return "Code Gold"

/proc/get_all_jobs()
	return list("Assistant", "Captain", "Head of Personnel", "Bartender", "Chef", "Botanist", "Quartermaster", "Cargo Technician",
				"Shaft Miner", "Clown", "Mime", "Janitor", "Librarian", "Lawyer", "Chaplain", "Chief Engineer", "Station Engineer",
				"Atmospheric Technician", "Chief Medical Officer", "Medical Doctor", "Chemist", "Geneticist", "Virologist",
				"Research Director", "Scientist", "Roboticist", "Head of Security", "Warden", "Detective", "Security Officer")

proc/get_all_job_icons() //For all existing HUD icons
	return get_all_jobs() + list("Prisoner")

/proc/get_all_centcom_jobs()
	return list("Guest","Thunderdome Overseer","Employee","Med-Sci","Spec Ops", "Engineer","Agent", "Vice-Admiral","Admiral")

/obj/item/proc/GetJobName() //Used in secHUD icon generation
	var/obj/item/weapon/card/id/I = GetID()
	if(!I)	return
	var/jobName = I.assignment
	if(jobName in get_all_job_icons()) //Check if the job has a hud icon
		return jobName
	if(jobName in get_all_centcom_jobs()) //Return with the NT logo if it is a Centcom job
		return "Centcom"
	return "Unknown" //Return unknown if none of the above apply
