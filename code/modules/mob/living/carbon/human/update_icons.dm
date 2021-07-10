	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/* Keep these comments up-to-date if you -insist- on hurting my code-baby ;_;
This system allows you to update individual mob-overlays, without regenerating them all each time.
When we generate overlays we generate the standing version and then rotate the mob as necessary..

As of the time of writing there are 20 layers within this list. Please try to keep this from increasing. //21 Total, Keeping things simple
	var/overlays_standing[20]		//For the standing stance

Most of the time we only wish to update one overlay:
	e.g. - we dropped the fireaxe out of our left hand and need to remove its icon from our mob
	e.g.2 - our hair colour has changed, so we need to update our hair icons on our mob
In these cases, instead of updating every overlay using the old behaviour (regenerate_icons), we instead call
the appropriate update_X proc.
	e.g. - update_inv_hands()
	e.g.2 - update_hair()

Note: Recent changes by aranclanos+carn:
	update_icons() no longer needs to be called.
	the system is easier to use. update_icons() should not be called unless you absolutely -know- you need it.
	IN ALL OTHER CASES it's better to just call the specific update_X procs.

All of this means that this code is more maintainable, faster and still fairly easy to use.

There are several things that need to be remembered:
>	Whenever we do something that should cause an overlay to update (which doesn't use standard procs
	( i.e. you do something like l_hand = /obj/item/something new(src), rather than using the helper procs)
	You will need to call the relevant update_inv_* proc

	All of these are named after the variable they update from. They are defined at the mob/ level like
	update_clothing was, so you won't cause undefined proc runtimes with usr.update_inv_wear_id() if the usr is a
	slime etc. Instead, it'll just return without doing any work. So no harm in calling it for slimes and such.


>	There are also these special cases:
		update_mutations()			//handles updating your appearance for certain mutations.  e.g TK head-glows
		update_damage_overlays()	//handles damage overlays for brute/burn damage

		update_body()				//Handles sprite-accessories that didn't really fit elsewhere (underwear, undershirts, socks, lips, eyes)


		update_hair()				//Handles updating your hair overlay (used to be update_face, but mouth and
									eyes were merged into update_body())

		update_body_parts()			//Handles human body parts and augments + mutations using the human icon cache system

>	I repurposed an old unused variable which was in the code called (coincidentally) var/update_icon
	It can be used as another method of triggering regenerate_icons(). It's basically a flag that when set to non-zero
	will call regenerate_icons() at the next life() call and then reset itself to 0.
	The idea behind it is icons are regenerated only once, even if multiple events requested it.
	//NOTE: fairly unused, maybe this could be removed?

If you have any questions/constructive-comments/bugs-to-report
Please contact me on #coderbus IRC. ~Carnie x
//Carn can sometimes be hard to reach now. However IRC is still your best bet for getting help.
*/

//Human Overlays Indexes/////////
#define BODYPARTS_LAYER			21		//Limbs
#define BODY_LAYER				20		//underwear, undershirts, socks, eyes, lips(makeup)
#define MUTATIONS_LAYER			19		//Tk headglows etc.
#define DAMAGE_LAYER			18		//damage indicators (cuts and burns)
#define UNIFORM_LAYER			17
#define ID_LAYER				16
#define SHOES_LAYER				15
#define GLOVES_LAYER			14
#define EARS_LAYER				13
#define SUIT_LAYER				12
#define BELT_LAYER				11		//Possible make this an overlay of somethign required to wear a belt?
#define SUIT_STORE_LAYER		10
#define BACK_LAYER				9
#define HAIR_LAYER				8		//Seperate layer so head items can overlay Hair and Hair underlay head items
#define GLASSES_LAYER			7		//Seperate layer to head so Eye wear is below helmets, but above hair
#define FACEMASK_LAYER			6
#define HEAD_LAYER				5
#define HANDCUFF_LAYER			4
#define LEGCUFF_LAYER			3
#define HANDS_LAYER				2
#define FIRE_LAYER				1		//If you're on fire
#define TOTAL_LAYERS			21		//KEEP THIS UP-TO-DATE OR SHIT WILL BREAK ;_;
//////////////////////////////////
/mob/living/carbon/human
	var/list/overlays_standing = list(1=null,2=null,3=null,4=null,5=null,6=null,7=null,8=null,9=null,10=null,11=null,12=null,13=null,14=null,15=null,16=null,17=null,18=null,19=null,20=null,21=null,)


/mob/living/carbon/human/proc/apply_overlay(cache_index)
	if(length(overlays_standing) >= cache_index)
		var/image/I = overlays_standing[cache_index]
		if(I)
			overlays += I

/mob/living/carbon/human/proc/remove_overlay(cache_index)
	if(length(overlays_standing) >= cache_index && overlays_standing[cache_index])
		overlays -= overlays_standing[cache_index]
		overlays_standing[cache_index] = null

//UPDATES OVERLAYS FROM OVERLAYS_STANDING
//TODO: Remove all instances where this proc is called. It used to be the fastest way to swap between standing/lying.
/mob/living/carbon/human/update_icons()

	return


//DAMAGE OVERLAYS
//constructs damage icon for each organ from mask * damage field and saves it in our overlays_ lists
/mob/living/carbon/human/update_damage_overlays()
	return


//HAIR OVERLAY
/mob/living/carbon/human/proc/update_hair()
	return


/mob/living/carbon/human/update_mutations()
	return


/mob/living/carbon/human/proc/update_body()
	return

/mob/living/carbon/human/proc/update_body_parts()
	return




/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/human/regenerate_icons()
	..()
	if(notransform)		return
	update_body()
	update_body_parts()
	update_hair()
	update_mutations()
	update_inv_w_uniform()
	update_inv_wear_id()
	update_inv_gloves()
	update_inv_glasses()
	update_inv_ears()
	update_inv_shoes()
	update_inv_s_store()
	update_inv_wear_mask()
	update_inv_head()
	update_inv_belt()
	update_inv_back()
	update_inv_wear_suit()
	update_inv_hands()
	update_inv_handcuffed()
	update_inv_legcuffed()
	update_inv_pockets()
	update_fire()
	update_transform()
	//Hud Stuff
	update_hud()

/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv



///////////////////////
// Human icon cache! //
// By Remie Richards //
///////////////////////

/*
	Called from update_body_parts() these procs handle the human icon cache the human icon cache uses a human mob's
	icon_render_key to either load an icon matching the key	or create one and add it to the cache.
	at present icon_render_key stores the following:
	- skin_tone
	- mutant_type (a local variable to these procs which simplifies mutantraces for the procs)
	- gender
	- limbs (these are stored as the limb's name, and whether it is REMOVED, ORGANIC or ROBOTIC)
	These procs do NOT extend to hair or sprite accesories or clothing as that would reduce the number of "matches" in the cache
	effectively negating the entire existance of the cache

	The cache essentially causes human icon operations involving limbs to get faster as a round progresses
	this progress is lost at the start of the next round

	The cache's original inspiration is based on the estimated cost of generating human overlays of limbs, the cache means
	that a new icon is only created where needed.
*/


var/global/list/human_icon_cache = list()


/mob/living/carbon/human
	var/icon_render_key = ""


///////////////////////
// get_mutant_type() //
///////////////////////
//simplifies dna.mutantraces and non mutantraces and husks and hulks into one var

/mob/living/carbon/human/proc/get_mutant_type()
	var/mutant_type = null
	var/race = dna ? dna.mutantrace : null


	if(has_organic_effect(/datum/organic_effect/husk))
		mutant_type = "husk"
	else if(has_organic_effect(/datum/organic_effect/hulk))
		mutant_type = "hulk"
	else if(race)
		if(race == "adamantine")
			mutant_type = "golem"
		else
			mutant_type = race
	else
		mutant_type = "normal"

	if(mutant_type)
		return mutant_type


////////////////////////////////
// generate_icon_render_key() //
////////////////////////////////
//produces a key based on a human's state

/mob/living/carbon/human/proc/generate_icon_render_key()
	var/mutant_type = get_mutant_type()

	icon_render_key = "" //Reset render_key

	if(mutant_type == "normal")
		icon_render_key += "|[skin_tone]" //Skin tone

	else
		icon_render_key += "|[mutant_type]" //Mutantrace/Normal human

	icon_render_key += "|[gender]" //Gender

	for(var/obj/item/organ/limb/L in organs) //Limb status
		icon_render_key += "|[initial(L.name)]="
		if(L.state == ORGAN_REMOVED)
			icon_render_key += "removed"
		else
			if(L.status == ORGAN_ORGANIC)
				icon_render_key += "organic"
			else
				icon_render_key += "robotic"

	icon_render_key += "|" //Make it look neat on the end



///////////////////////
// load_from_cache() //
///////////////////////
//change the human's icon to the one matching it's key

/mob/living/carbon/human/proc/load_from_cache()
	if(human_icon_cache[icon_render_key])
		remove_overlay(BODYPARTS_LAYER)
		overlays_standing[BODYPARTS_LAYER] = human_icon_cache[icon_render_key]
		apply_overlay(BODYPARTS_LAYER)


/////////////////////
// generate_icon() //
/////////////////////
//builds an icon of the limb

/mob/living/carbon/human/proc/generate_icon(var/obj/item/organ/limb/affecting)
	var/image/I
	var/icon_gender = (gender == FEMALE) ? "f" : "m"

	var/icon/human_parts = 'icons/mob/human_parts.dmi'
	var/icon/augment_parts = 'icons/mob/augments.dmi'

	var/mutant_type = get_mutant_type()


	if(affecting.state == ORGAN_REMOVED && affecting.visibly_dismembers)
		return 0

	var/limb_name = initial(affecting.name)
	if(affecting.body_part == HEAD || affecting.body_part == CHEST) //these have gender and use it in their icons
		if(affecting.status == ORGAN_ORGANIC) //Heads bypass this due to the icon
			if(mutant_type != "normal")//Skin tone is irrelevant in Mutant races
				if(stat == DEAD)
					if(mutant_type == "plant")
						I						= image("icon"=human_parts, "icon_state"="[mutant_type]_[limb_name]_[icon_gender]_dead_s", "layer"=-BODYPARTS_LAYER)


					else if(mutant_type == "husk")
						I						= image("icon"=human_parts, "icon_state"="[mutant_type]_[limb_name]_s","layer"=-BODYPARTS_LAYER)

				else
					I							= image("icon"=human_parts, "icon_state"="[mutant_type]_[limb_name]_[icon_gender]_s","layer"=-BODYPARTS_LAYER)


			if(mutant_type == "normal") //Skin tone IS Relevant in "Normal" race humans
				I								= image("icon"=human_parts,"icon_state"="[skin_tone]_[limb_name]_[icon_gender]_s","layer"=-BODYPARTS_LAYER)

		else if(affecting.status == ORGAN_ROBOTIC)
			I									= image("icon"=augment_parts,"icon_state"="[limb_name]_[icon_gender]_s","layer"=-BODYPARTS_LAYER)

	else
		if(affecting.status == ORGAN_ORGANIC)
			if(mutant_type != "normal")
				if(stat == DEAD)
					if(mutant_type == "plant")
						I					= image("icon"=human_parts, "icon_state"="[mutant_type]_[limb_name]_dead_s", "layer"=-BODYPARTS_LAYER)
					else
						I					= image("icon"=human_parts,"icon_state"="[mutant_type]_[limb_name]_s", "layer"=-BODYPARTS_LAYER)
				else
					I						= image("icon"=human_parts,"icon_state"="[mutant_type]_[limb_name]_s", "layer"=-BODYPARTS_LAYER)
			else if(mutant_type == "normal")
				I							= image("icon"=human_parts,"icon_state"="[skin_tone]_[limb_name]_s", "layer"=-BODYPARTS_LAYER)
		else if(affecting.status == ORGAN_ROBOTIC)
			I								= image("icon"=augment_parts,"icon_state"="[limb_name]_s","layer"=-BODYPARTS_LAYER)

	if(I)
		return I
	return 0

////////////////////////////////////
// update_body_parts() debug text //
////////////////////////////////////
//when the world is in debug mode (Debug = 1) update_body_parts() prints it's work as it goes along

/mob/living/carbon/human/proc/human_icon_debug_text(var/mode)
	if(!Debug2) //Yes Debug2 is the var
		return

	message_admins("Human mob: [name]")

	switch(mode)
		if(1)
			message_admins("No icon update was needed!")
		if(2)
			message_admins("An icon was retrieved from the icon cache!")
		if(3)
			message_admins("A new list of images were created and cached!")

	message_admins("Icon Render Key is ")
	message_admins("[icon_render_key]")


//Human Overlays Indexes/////////
#undef BODYPARTS_LAYER
#undef BODY_LAYER
#undef MUTATIONS_LAYER
#undef DAMAGE_LAYER
#undef UNIFORM_LAYER
#undef ID_LAYER
#undef SHOES_LAYER
#undef GLOVES_LAYER
#undef EARS_LAYER
#undef SUIT_LAYER
#undef GLASSES_LAYER
#undef FACEMASK_LAYER
#undef BELT_LAYER
#undef SUIT_STORE_LAYER
#undef BACK_LAYER
//#undef HAIR_LAYER //Keeping these defined, for easy Head dismemberment
//#undef HEAD_LAYER
#undef HANDCUFF_LAYER
#undef LEGCUFF_LAYER
#undef HANDS_LAYER
#undef FIRE_LAYER
#undef TOTAL_LAYERS
