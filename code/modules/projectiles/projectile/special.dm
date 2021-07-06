/obj/item/projectile/ion
	name = "ion bolt"
	icon_state = "ion"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	trace_residue = "Minor electrical discolouration."


	on_hit(var/atom/target, var/blocked = 0)
		empulse(target, 1, 1)
		return 1


/obj/item/projectile/bullet/gyro
	name ="explosive bolt"
	icon_state= "bolter"
	damage = 50
	flag = "bullet"
	trace_residue = "Airburst explosive patterning."


	on_hit(var/atom/target, var/blocked = 0)
		explosion(target, -1, 0, 2)
		return 1

/obj/item/projectile/temp
	name = "freeze beam"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = 1
	flag = "energy"
	trace_residue = null
	var/temperature = 100


	on_hit(var/atom/target, var/blocked = 0)//These two could likely check temp protection on the mob
		if(istype(target, /mob/living))
			var/mob/M = target
			M.bodytemperature = temperature
		return 1

/obj/item/projectile/temp/hot
	name = "heat beam"
	temperature = 400
	trace_residue = "Unfocused charring patterns."

/obj/item/projectile/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "small1"
	damage = 0
	damage_type = BRUTE
	nodamage = 1
	flag = "bullet"
	trace_residue = null

	Bump(atom/A as mob|obj|turf|area)
		if(A == firer)
			loc = A.loc
			return

		sleep(-1) //Might not be important enough for a sleep(-1) but the sleep/spawn itself is necessary thanks to explosions and metoerhits

		if(src)//Do not add to this if() statement, otherwise the meteor won't delete them
			if(A)

				A.ex_act(2)
				playsound(src.loc, 'sound/effects/meteorimpact.ogg', 40, 1)

				for(var/mob/M in range(10, src))
					if(!M.stat && !istype(M, /mob/living/silicon/ai))\
						shake_camera(M, 3, 1)
				delete()
				return 1
		else
			return 0

/obj/item/projectile/energy/floramut
	name = "alpha somatoray"
	icon_state = "energy"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"
	trace_residue = null

	on_hit(var/atom/target, var/blocked = 0)
		if(iscarbon(target))
			var/mob/living/carbon/M = target
			if(check_dna_integrity(M) && M.dna.mutantrace == "plant") //Plantmen possibly get mutated and damaged by the rays.
				if(prob(15))
					M.apply_effect((rand(30,80)),IRRADIATE)
					M.Weaken(5)
					for (var/mob/V in viewers(src))
						V.show_message("\red [M] writhes in pain as \his vacuoles boil.", 3, "\red You hear the crunching of leaves.", 2)
				if(prob(35))
				//	for (var/mob/V in viewers(src)) //Public messages commented out to prevent possible metaish genetics experimentation and stuff. - Cheridan
				//		V.show_message("\red [M] is mutated by the radiation beam.", 3, "\red You hear the snapping of twigs.", 2)
					if(prob(80))
						randmutb(M)
						domutcheck(M,null)
					else
						randmutg(M)
						domutcheck(M,null)
				else
					M.adjustFireLoss(rand(5,15))
					M.show_message("\red The radiation beam singes you!")
				//	for (var/mob/V in viewers(src))
				//		V.show_message("\red [M] is singed by the radiation beam.", 3, "\red You hear the crackle of burning leaves.", 2)
			else
			//	for (var/mob/V in viewers(src))
			//		V.show_message("The radiation beam dissipates harmlessly through [M]", 3)
				M.show_message("lue The radiation beam dissipates harmlessly through your body.")

/obj/item/projectile/energy/florayield
	name = "beta somatoray"
	icon_state = "energy2"
	damage = 0
	damage_type = TOX
	nodamage = 1
	flag = "energy"
	trace_residue = null

	on_hit(mob/living/carbon/target, var/blocked = 0)
		if(iscarbon(target))
			if(ishuman(target) && target.dna && target.dna.mutantrace == "plant")	//These rays make plantmen fat.
				target.nutrition = min(target.nutrition+30, 500)
			else
				target.show_message("lue The radiation beam dissipates harmlessly through your body.")
		else
			return 1


/obj/item/projectile/beam/mindflayer
	name = "flayer ray"
	trace_residue = null

	on_hit(var/atom/target, var/blocked = 0)
		if(ishuman(target))
			var/mob/living/carbon/human/M = target
			M.adjustBrainLoss(20)
			M.hallucination += 20

/obj/item/projectile/kinetic
	name = "kinetic force"
	icon_state = null
	damage = 15
	damage_type = BRUTE
	flag = "bomb"
	trace_residue = null
	range = 2

obj/item/projectile/kinetic/New()
	var/turf/proj_turf = get_turf(src)
	if(!istype(proj_turf, /turf))
		return
	var/datum/gas_mixture/environment = proj_turf.return_air()
	var/pressure = environment.return_pressure()
	if(pressure < 50)
		name = "full strength kinetic force"
		damage *= 2
	..()

/obj/item/projectile/kinetic/Range(var/remove=1)
	if(range <= 0)
		return

	range -= remove
	if(range <= 0)
		new /obj/effect/kinetic_blast(src.loc)

		for(var/turf/T in range(1, src.loc))
			if(!istype(T, /turf/simulated/wall))
				T.ex_act(3)

		for(var/obj/structure/S in range(1, src.loc))
			S.ex_act(3)
		delete()


/obj/item/projectile/kinetic/on_hit(var/atom/target)
	var/turf/target_turf= get_turf(target)
	if(istype(target_turf, /turf/simulated/mineral))
		var/turf/simulated/mineral/M = target_turf
		M.gets_drilled()
	new /obj/effect/kinetic_blast(target_turf)

	if(isturf(target) || istype(target, /obj/structure))
		for(var/turf/T in range(1, target_turf))
			if(!istype(T, /turf/simulated/wall))
				T.ex_act(3)

		for(var/obj/structure/S in range(1, target_turf))
			S.ex_act(3)
	..()


/obj/effect/kinetic_blast
	name = "kinetic explosion"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "kinetic_blast"
	layer = 4.1

/obj/effect/kinetic_blast/New()
	spawn(4)
		qdel(src)



/obj/item/projectile/plasma
	name = "plasma blast"
	icon_state = "plasmacutter"
	damage_type = BURN
	damage = 10
	range = 6
	var/power = 9
	trace_residue = null

/obj/item/projectile/plasma/on_hit(var/atom/target)
	if(istype(target, /turf/simulated/mineral))
		while(target && target.density && range > 0 && power > 0)
			power -= 1
			var/turf/simulated/mineral/M = target
			M.gets_drilled()
		if(range > 0 && power > 0)
			return -1
	return ..()

/obj/item/projectile/plasma/adv
	range = 9
	power = 12
	damage = 15

/obj/item/projectile/plasma/adv/on_hit(var/atom/target)
	if(!ismob(target) && !istype(target, /turf/simulated/mineral))
		target.ex_act(3)
		power -= 10
		if(range > 0 && power > 0 && (!target || !target.density))
			return -1
	return ..()


/obj/item/projectile/plasma/adv/mech
	range = 12
	power = 18
