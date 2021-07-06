//Cleanbot assembly
/obj/item/weapon/bucket_sensor
	desc = "It's a bucket. With a sensor attached."
	name = "proxy bucket"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "bucket_proxy"
	force = 3.0
	throwforce = 5.0
	throw_speed = 2
	throw_range = 5
	w_class = 3.0
	var/created_name = "Cleanbot"


//Cleanbot
/obj/machinery/bot/cleanbot
	name = "\improper Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "cleanbot0"
	layer = 5.0
	density = 0
	anchored = 0
	//weight = 1.0E7
	health = 25
	maxhealth = 25
	var/blood = 1
	var/list/target_types = list()
	var/obj/effect/decal/cleanable/target
	var/obj/effect/decal/cleanable/oldtarget
	var/list/cleanbottargets = list() //Targets that the cleanbot cannot reach and will thus ignore.
	var/max_targets = 50 //Maximum number of targets a cleanbot can ignore.
	var/oldloc = null
	req_one_access = list(access_janitor, access_robotics)
//	var/patrol_path[] = null
//	var/beacon_freq = 1445		// navigation beacon frequency
	var/closest_dist
	var/closest_loc
	var/failed_steps
	var/next_dest
	var/next_dest_loc
	bot_type = CLEAN_BOT
	bot_filter = "10"

/obj/machinery/bot/cleanbot/New()
	..()
	get_targets()
	icon_state = "cleanbot[on]"

	var/datum/job/janitor/J = new/datum/job/janitor
	botcard.access = J.get_access()
	prev_access = botcard.access

	spawn(5)
		add_to_beacons(bot_filter)

/obj/machinery/bot/cleanbot/turn_on()
	. = ..()
	icon_state = "cleanbot[on]"
	updateUsrDialog()

/obj/machinery/bot/cleanbot/turn_off()
	..()
	icon_state = "cleanbot[on]"
	updateUsrDialog()

/obj/machinery/bot/cleanbot/bot_reset()
	..()
	cleanbottargets = list() //Allows the bot to clean targets it previously ignored due to being unreachable.
	target = null
	oldtarget = null
	oldloc = null

/obj/machinery/bot/cleanbot/set_custom_texts()
	text_hack = "You corrupt [name]'s cleaning software."
	text_dehack = "[name]'s software has been reset!"
	text_dehack_fail = "[name] does not seem to respond to your repair code!"

/obj/machinery/bot/cleanbot/attack_hand(mob/user as mob)
	. = ..()
	if (.)
		return
	usr.set_machine(src)
	interact(user)

/obj/machinery/bot/cleanbot/interact(mob/user as mob)
	var/dat
	dat += hack(user)
	dat += text({"
<TT><B>Cleaner v1.1 controls</B></TT><BR><BR>
Status: []<BR>
Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
Maintenance panel panel is [open ? "opened" : "closed"]"},
text("<A href='?src=\ref[src];power=1'>[on ? "On" : "Off"]</A>"))
	if(!locked || issilicon(user))
		dat += text({"<BR>Cleans Blood: []<BR>"}, text("<A href='?src=\ref[src];operation=blood'>[blood ? "Yes" : "No"]</A>"))
		dat += text({"<BR>Patrol station: []<BR>"}, text("<A href='?src=\ref[src];operation=patrol'>[auto_patrol ? "Yes" : "No"]</A>"))
	//	dat += text({"<BR>Beacon frequency: []<BR>"}, text("<A href='?src=\ref[src];operation=freq'>[beacon_freq]</A>"))
/*	if(open && !locked)
		dat += text({"
Odd looking screw twiddled: []<BR>
Weird button pressed: []"},
text("<A href='?src=\ref[src];operation=screw'>[screwloose ? "Yes" : "No"]</A>"),
text("<A href='?src=\ref[src];operation=oddbutton'>[oddbutton ? "Yes" : "No"]</A>"))*/

	var/datum/browser/popup = new(user, "autoclean", "Automatic Station Cleaner v1.1")
	popup.set_content(dat)
	popup.open()
	return

/obj/machinery/bot/cleanbot/Topic(href, href_list)

	..()
	switch(href_list["operation"])
		if("blood")
			blood =!blood
			get_targets()
			updateUsrDialog()
		if("freq")
			var/freq = text2num(input("Select frequency for  navigation beacons", "Frequency", num2text(beacon_freq / 10))) * 10
			if (freq > 0)
				beacon_freq = freq
			updateUsrDialog()

/*		if("screw")
			screwloose = !screwloose
			usr << "<span class='notice>You twiddle the screw.</span>"
			updateUsrDialog()
		if("oddbutton")
			oddbutton = !oddbutton
			usr << "<span class='notice'>You press the weird button.</span>"
			updateUsrDialog() */

/obj/machinery/bot/cleanbot/attackby(obj/item/weapon/W, mob/user as mob)
	if (istype(W, /obj/item/weapon/card/id)||istype(W, /obj/item/device/pda))
		if(allowed(usr) && !open && !emagged)
			locked = !locked
			user << "<span class='notice'>You [ locked ? "lock" : "unlock"] the [src] behaviour controls.</span>"
		else
			if(emagged)
				user << "<span class='warning'>ERROR</span>"
			if(open)
				user << "<span class='warning'>Please close the access panel before locking it.</span>"
			else
				user << "<span class='notice'>This [src] doesn't seem to respect your authority.</span>"
	else
		return ..()

/obj/machinery/bot/cleanbot/Emag(mob/user as mob)
	..()
	if(emagged == 2)
		if(user) user << "<span class='danger'>[src] buzzes and beeps.</span>"

/obj/machinery/bot/cleanbot/process()
	set background = BACKGROUND_ENABLED

	if(!on)
		return
	if(mode == BOT_CLEANING)
		return
	if(call_path)
		call_mode()
		return

	if(!emagged && prob(5))
		visible_message("[src] makes an excited beeping booping sound!")

	if(emagged == 2 && prob(10)) //Wets floors randomly
		if(istype(loc,/turf/simulated))
			var/turf/simulated/T = loc
			T.MakeSlippery()

	if(emagged == 2 && prob(5)) //Spawns foam!
		visible_message("<span class='danger'>[src] whirs and bubbles violently, before releasing a plume of froth!</span>")
		new /obj/effect/effect/foam(loc)

	if(mode == BOT_SUMMON)
		bot_summon()
		return

	if(!target || target == null) //Search for cleanables it can see.
		for (var/obj/effect/decal/cleanable/D in view(7,src))
			for(var/T in target_types)
				if(!(D in cleanbottargets) && (D.type == T || D.parent_type == T) && D != oldtarget)
					oldtarget = D
					target = D
					break

	if(!target || target == null)
		if(loc != oldloc)
			oldtarget = null

		if(auto_patrol)
			if(mode == BOT_IDLE || mode == BOT_START_PATROL)
				start_patrol()

			if(mode == BOT_PATROL)
				bot_patrol()



		return

	if(target && path.len == 0)
		spawn(0)
			if(!src || !target)
				return
			//Try to produce a path to the target, and ignore airlocks to which it has access.
			path = AStar(loc, target.loc, /turf/proc/CardinalTurfsWithAccess, /turf/proc/Distance_cardinal, 0, 30, id=botcard)
			if(!path)
				path = list()
			if(path.len == 0) //Target is unreachable, so add it to ignore list and prepare to find another target or remain idle/patrol.
				add_to_ignore(target)
				oldtarget = target
				target = null
				mode = BOT_IDLE
		return
	if(path.len > 0 && target && (target != null))
		mode = BOT_MOVING
		step_to(src, path[1])
		path -= path[1]
	else if(path.len == 1)
		step_to(src, target)

	if(target && (target != null))
		if(loc == target.loc)
			clean(target)
			path = new()
			target = null
			return

	oldloc = loc

/*
/obj/machinery/bot/cleanbot/proc/patrol_move()
	if (patrol_path.len <= 0)
		return

	var/next = patrol_path[1]
	patrol_path -= next
	if (next == loc)
		return

	var/moved = step_towards(src, next)
	if (!moved)
		failed_steps++
	if (failed_steps > 4)
		patrol_path = null
		next_dest = null
		failed_steps = 0
	else
		failed_steps = 0

/obj/machinery/bot/cleanbot/receive_signal(datum/signal/signal)
	var/recv = signal.data["beacon"]
	var/valid = signal.data["patrol"]
	if(!recv || !valid)
		return

	var/dist = get_dist(src, signal.source.loc)
	if (dist < closest_dist && signal.source.loc != loc)
		closest_dist = dist
		closest_loc = signal.source.loc
		next_dest = signal.data["next_patrol"]

	if (recv == next_dest)
		next_dest_loc = signal.source.loc
		next_dest = signal.data["next_patrol"]
		*/

/obj/machinery/bot/cleanbot/proc/add_to_ignore(target)
	if(cleanbottargets.len < max_targets && !(target in cleanbottargets)) //Add the target to the ignore list if it is not full or already inside.
		cleanbottargets += target
	else if (cleanbottargets.len >= max_targets)
		cleanbottargets -= cleanbottargets[1] // ignore list is full, so remove the oldest target.
		cleanbottargets += target // then add the newest one.

/obj/machinery/bot/cleanbot/proc/get_targets()
	target_types = new/list()

	target_types += /obj/effect/decal/cleanable/oil
	target_types += /obj/effect/decal/cleanable/vomit
	target_types += /obj/effect/decal/cleanable/robot_debris
	target_types += /obj/effect/decal/cleanable/crayon
	target_types += /obj/effect/decal/cleanable/molten_item
	target_types += /obj/effect/decal/cleanable/tomato_smudge
	target_types += /obj/effect/decal/cleanable/egg_smudge
	target_types += /obj/effect/decal/cleanable/pie_smudge
	target_types += /obj/effect/decal/cleanable/flour
	target_types += /obj/effect/decal/cleanable/ash
	target_types += /obj/effect/decal/cleanable/greenglow
	target_types += /obj/effect/decal/cleanable/dirt

	if(blood)
		target_types += /obj/effect/decal/cleanable/xenoblood/
		target_types += /obj/effect/decal/cleanable/xenoblood/xgibs
		target_types += /obj/effect/decal/cleanable/blood/
		target_types += /obj/effect/decal/cleanable/blood/gibs/
		target_types += /obj/effect/decal/cleanable/trail_holder

/obj/machinery/bot/cleanbot/proc/clean(var/obj/effect/decal/cleanable/target)
	anchored = 1
	icon_state = "cleanbot-c"
	visible_message("<span class='danger'>[src] begins to clean up [target]</span>")
	mode = BOT_CLEANING
	spawn(50)
		if(mode == BOT_CLEANING)
			mode = BOT_IDLE
			qdel(target)
			icon_state = "cleanbot[on]"
			anchored = 0
			target = null

/obj/machinery/bot/cleanbot/explode()
	on = 0
	visible_message("<span class='danger'><B>[src] blows apart!</B></span>", 1)
	var/turf/Tsec = get_turf(src)

	new /obj/item/weapon/reagent_containers/glass/bucket(Tsec)

	new /obj/item/device/assembly/prox_sensor(Tsec)

	if (prob(50))
		new /obj/item/robot_parts/l_arm(Tsec)

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	qdel(src)
	return

/obj/item/weapon/bucket_sensor/attackby(var/obj/item/W, mob/user as mob)
	..()
	if(istype(W, /obj/item/robot_parts/l_arm) || istype(W, /obj/item/robot_parts/r_arm))
		user.drop_item()
		qdel(W)
		var/turf/T = get_turf(loc)
		var/obj/machinery/bot/cleanbot/A = new /obj/machinery/bot/cleanbot(T)
		A.name = created_name
		user << "<span class='notice'>You add the robot arm to the bucket and sensor assembly. Beep boop!</span>"
		user.unEquip(src, 1)
		qdel(src)

	else if (istype(W, /obj/item/weapon/pen))
		var/t = copytext(stripped_input(user, "Enter new robot name", name, created_name),1,MAX_NAME_LEN)
		if (!t)
			return
		if (!in_range(src, usr) && loc != usr)
			return
		created_name = t
