//Credit Petethegoat for this code, Modernised and Adapted by RemieRichards



#define HANDS_LAYER 1
#define TOTAL_LAYERS 1

#define DRONE_MAX_RESOURCE 50

/mob/living/simple_animal/drone
	name = "drone"
	desc = "A maintenance drone, an expendable robot built to perform station repairs."
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_grey"
	icon_living = "drone_grey"
	icon_dead = "drone_dead"
	gender = NEUTER
	health = 30
	maxHealth = 30
	heat_damage_per_tick = 0
	cold_damage_per_tick = 0
	unsuitable_atoms_damage = 0
	universal_speak = 1
	robot_talk_understand = 1
	wander = 0
	speed = 0
	ventcrawler = 2
	density = 0
	pass_flags = PASSTABLE
	sight = (SEE_TURFS | SEE_OBJS)
	var/picked = FALSE
	var/list/drone_overlays = list()
	var/laws = \
	{"1. You may not involve yourself in the matters of another being, even if such matters conflict with Law Two or Law Three, unless the other being is another Drone.
	2. You may not harm any being, regardless of intent or circumstance.
	3. You must maintain, repair, improve, and power the station to the best of your abilities."}


/mob/living/simple_animal/drone/New()
	..()

	name = "Drone ([rand(100,999)])"
	real_name = name

	access_card = new /obj/item/weapon/card/id(src)
	var/datum/job/captain/C = new /datum/job/captain
	access_card.access = C.get_access()

/mob/living/simple_animal/drone/attack_hand(mob/user)
	if(isdrone(user))
		var/mob/living/simple_animal/drone/D = user
		if(stat == DEAD)
			var/d_input = alert(D,"Perform which action?","Drone Interaction","Reactivate","Cannibalize","Nothing")
			if(d_input)
				switch(d_input)
					if("Reactivate")
						D.visible_message("<span class='notice'>[D] begins to reactivate [src]</span>")
						if(do_after(user,30,needhand = 1))
							health = maxHealth
							stat = CONSCIOUS
							icon_state = icon_living
							D.visible_message("<span class='notice'>[D] reactivates [src]!</span>")
						else
							D << "<span class='notice'>You need to remain still to reactivate [src]</span>"

					if("Cannibalize")
						if(D.health < D.maxHealth)
							D.visible_message("<span class='notice'>[D] begins to cannibalize parts from [src].</span>")
							if(do_after(D, 60,5,0))
								D.visible_message("<span class='notice'>[D] repairs itself using [src]'s remains!</span>")
								D.adjustBruteLoss(D.health - D.maxHealth)
								gib()
							else
								D << "<span class='notice'>You need to remain still to canibalize [src].</span>"
						else
							D << "<span class='notice'>You're already in perfect condition!</span>"
					if("Nothing")
						return

		return

	if(ishuman(user))
		if(user.get_active_hand())
			user << "<span class='notice'>Your hands are full.</span>"
			return
		src << "<span class='warning'>[user] is trying to pick you up!</span"
		user << "<span class='notice'>You start picking [src] up...</span>"
		if(do_after(user, 20, needhand = 1))
			drop_l_hand()
			drop_r_hand()
			var/obj/item/drone_holder/DH = new /obj/item/drone_holder(src)
			DH.contents += src
			DH.drone = src
			user.put_in_hands(DH)
			src.loc = DH
		else
			user << "<span class='notice'>[src] got away!</span>"
			src << "<span class='warning'>You got away from [user]!</span>"
		return

	..()


/mob/living/simple_animal/drone/IsAdvancedToolUser()
	return 1

/mob/living/simple_animal/drone/UnarmedAttack(atom/A, proximity)
	if(istype(A,/obj/item/weapon/gun))
		src << "<span class='warning'>Your subroutines prevent you from picking up [A].</span>"
		return

	A.attack_hand(src)

/mob/living/simple_animal/drone/swap_hand()
	var/obj/item/held_item = get_active_hand()
	if(held_item)
		if(istype(held_item, /obj/item/weapon/twohanded))
			var/obj/item/weapon/twohanded/T = held_item
			if(T.wielded == 1)
				usr << "<span class='warning'>Your other hand is too busy holding the [T.name].</span>"
				return

	hand = !hand
	if(hud_used.l_hand_hud_object && hud_used.r_hand_hud_object)
		if(hand)
			hud_used.l_hand_hud_object.icon_state = "hand_l_active"
			hud_used.r_hand_hud_object.icon_state = "hand_r_inactive"
		else
			hud_used.l_hand_hud_object.icon_state = "hand_l_inactive"
			hud_used.r_hand_hud_object.icon_state = "hand_r_active"


/mob/living/simple_animal/drone/put_in_l_hand(obj/item/I)
	. = ..()
	l_hand.screen_loc = ui_lhand
	update_inv_hands()

/mob/living/simple_animal/drone/put_in_r_hand(obj/item/I)
	. = ..()
	r_hand.screen_loc = ui_rhand
	update_inv_hands()


//this is all saycode's fault - Remie
/mob/living/simple_animal/drone/say(message)
	if(!message)
		return

	if(client)
		if(client.prefs.muted & MUTE_IC)
			src << "You cannot send IC messages (muted)."
			return
		if(client.handle_spam_prevention(message,MUTE_IC))
			return

	if(stat == DEAD)
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
		return say_dead(message)

	robot_talk(message)


/mob/living/simple_animal/drone/verb/check_laws()
	set category = "IC"
	set name = "Check Laws"

	usr << "<b>Drone Laws</b>"
	usr << laws



/mob/living/simple_animal/drone/Login()
	..()
	check_laws()

	if(!picked)
		pick_colour()

/mob/living/simple_animal/drone/Die()
	..()
	drop_l_hand()
	drop_r_hand()


/mob/living/simple_animal/drone/proc/pick_colour()
	var/colour = input("Choose your colour!", "Colour", "grey") in list("grey", "blue", "red", "green", "pink", "orange")
	icon_state = "drone_[colour]"
	icon_living = "drone_[colour]"
	picked = TRUE

/mob/living/simple_animal/drone/proc/apply_overlay(cache_index)
	var/image/I = drone_overlays[cache_index]
	if(I)
		overlays += I

/mob/living/simple_animal/drone/proc/remove_overlay(cache_index)
	if(drone_overlays[cache_index])
		overlays -= drone_overlays[cache_index]
		drone_overlays[cache_index] = null


/mob/living/simple_animal/drone/update_inv_hands()
	remove_overlay(HANDS_LAYER)
	var/list/hands_overlays = list()
	if(r_hand)
		hands_overlays += r_hand.get_onmob_icon("r_hand", -HANDS_LAYER)

	if(l_hand)
		hands_overlays += l_hand.get_onmob_icon("l_hand", -HANDS_LAYER)

	if(hands_overlays.len)
		drone_overlays[HANDS_LAYER] = hands_overlays

	apply_overlay(HANDS_LAYER)

#undef HANDS_LAYER

/mob/living/simple_animal/drone/canUseTopic()
	if(stat)
		return
	return 1

/mob/living/simple_animal/drone/activate_hand(var/selhand)

	if(istext(selhand))
		selhand = lowertext(selhand)

		if(selhand == "right" || selhand == "r")
			selhand = 0
		if(selhand == "left" || selhand == "l")
			selhand = 1

	if(selhand != src.hand)
		swap_hand()
	else
		mode()


//DRONE SHELL
/obj/item/drone_shell
	name = "drone shell"
	desc = "A shell of a maintenance drone, an expendable robot built to perform station repairs."
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_item"
	origin_tech = "programming=2;biotech=4"
	var/construction_cost = list("metal"=800, "glass"=350)
	var/construction_time=150

/obj/item/drone_shell/attack_ghost(mob/user)
	if(jobban_isbanned(user,"pAI"))
		return

	var/mob/living/simple_animal/drone/D = new(get_turf(loc))
	D.key = user.key
	qdel(src)


//DRONE HOLDER

/obj/item/drone_holder //Only exists in someones hand.
	name = "drone (hiding)"
	desc = "This drone is scared and has curled up into a ball"
	icon = 'icons/mob/drone.dmi'
	icon_state = "drone_item"
	var/mob/living/simple_animal/drone/drone //stored drone

/obj/item/drone_holder/dropped()
	if(drone)
		contents -= drone
		drone.loc = get_turf(src)
		drone.dir = SOUTH //Looks better
		drone.visible_message("<span class='notice'>[drone] uncurls!</span>")
		drone = null
		qdel(src)
	else
		..()




