//Common

/obj/machinery/abductor
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/team = 0

/obj/machinery/abductor/Initialize(mapload)
	. = ..()
	GLOB.abductor_equipment.Add(src)

/obj/machinery/abductor/Destroy()
	GLOB.abductor_equipment.Remove(src)
	return ..()

//Console

/obj/machinery/abductor/console
	name = "Abductor console"
	desc = "Ship command center."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "console"
	density = TRUE
	anchored = TRUE
	var/obj/item/abductor/gizmo/gizmo
	var/obj/item/clothing/suit/armor/abductor/vest/vest
	var/obj/machinery/abductor/experiment/experiment
	var/obj/machinery/abductor/pad/pad
	var/obj/machinery/computer/camera_advanced/abductor/camera
	var/list/datum/icon_snapshot/disguises = list()

/obj/machinery/abductor/console/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/abductor/console/LateInitialize()
	..()
	// GLOB.abductor_equipment is populated in Initialize;
	// delaying linkage until after.
	Link_Abduction_Equipment()

/obj/machinery/abductor/console/Destroy()
	gizmo = null
	vest = null
	experiment = null
	pad = null
	camera = null
	disguises.Cut()
	return ..()

/obj/machinery/abductor/console/attack_hand(mob/user)
	if(..())
		return
	if(!isabductor(user))
		to_chat(user, "<span class='warning'>You start mashing alien buttons at random!</span>")
		if(do_after(user, 100, target = src))
			TeleporterSend()
		return
	user.set_machine(src)
	var/dat = ""
	dat += "<H3> Abductsoft 3000 </H3>"

	if(experiment != null)
		var/points = experiment.points
		var/credits = experiment.credits
		dat += "Collected Samples : [points] <br>"
		dat += "Gear Credits: [credits] <br>"
		dat += "<b>Transfer data in exchange for supplies:</b><br>"
		dat += "<a href='byond://?src=[UID()];dispense=baton'>Advanced Baton (2)</a><br>"
		dat += "<a href='byond://?src=[UID()];dispense=helmet'>Agent Helmet</a><br>"
		dat += "<a href='byond://?src=[UID()];dispense=vest'>Agent Vest</a><br>"
		dat += "<a href='byond://?src=[UID()];dispense=silencer'>Radio Silencer</a><br>"
		dat += "<a href='byond://?src=[UID()];dispense=tool'>Science Tool</a><br>"
		dat += "<a href='byond://?src=[UID()];dispense=mind_device'>Mental Interface Device (2)</a><br>"
		dat += "<a href='byond://?src=[UID()];dispense=organ_extractor'>Organ Extractor (2)</a><br>"
	else
		dat += "<span class='bad'>NO EXPERIMENT MACHINE DETECTED</span> <br>"

	if(pad)
		dat += "<span class='bad'>Emergency Teleporter System.</span>"
		dat += "<span class='bad'>Consider using primary observation console first.</span>"
		dat += "<a href='byond://?src=[UID()];teleporter_send=1'>Activate Teleporter</A><br>"
		if(gizmo && gizmo.marked)
			dat += "<a href='byond://?src=[UID()];teleporter_retrieve=1'>Retrieve Mark</A><br>"
		else
			dat += "<span class='linkOff'>Retrieve Mark</span><br>"
	else
		dat += "<span class='bad'>NO TELEPAD DETECTED</span></br>"

	if(vest)
		dat += "<h4> Agent Vest Mode </h4><br>"
		var/mode = vest.mode
		if(mode == ABDUCTOR_VEST_STEALTH)
			dat += "<a href='byond://?src=[UID()];flip_vest=1'>Combat</A>"
			dat += "<span class='linkOff'>Stealth</span>"
		else
			dat += "<span class='linkOff'>Combat</span>"
			dat += "<a href='byond://?src=[UID()];flip_vest=1'>Stealth</A>"

		dat+="<br>"
		dat += "<a href='byond://?src=[UID()];select_disguise=1'>Select Agent Vest Disguise</a><br>"
		dat += "<a href='byond://?src=[UID()];toggle_vest=1'>[vest.flags & NODROP ? "Unlock" : "Lock"] Vest</a><br>"
	else
		dat += "<span class='bad'>NO AGENT VEST DETECTED</span>"
	var/datum/browser/popup = new(user, "computer", "Abductor Console", 400, 500)
	popup.set_content(dat)
	popup.open()

/obj/machinery/abductor/console/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	if(href_list["teleporter_send"])
		TeleporterSend()
	else if(href_list["teleporter_retrieve"])
		TeleporterRetrieve()
	else if(href_list["flip_vest"])
		FlipVest()
	else if(href_list["toggle_vest"])
		if(vest)
			vest.toggle_nodrop()
	else if(href_list["select_disguise"])
		SelectDisguise(FALSE, usr)
	else if(href_list["dispense"])
		switch(href_list["dispense"])
			if("baton")
				Dispense(/obj/item/abductor_baton, cost = 2)
			if("helmet")
				Dispense(/obj/item/clothing/head/helmet/abductor)
			if("silencer")
				Dispense(/obj/item/abductor/silencer)
			if("tool")
				Dispense(/obj/item/abductor/gizmo)
			if("vest")
				Dispense(/obj/item/clothing/suit/armor/abductor/vest)
			if("mind_device")
				Dispense(/obj/item/abductor/mind_device, cost = 2)
			if("organ_extractor")
				Dispense(/obj/item/organ_extractor/abductor, cost = 2)
	updateUsrDialog()


/obj/machinery/abductor/console/proc/TeleporterRetrieve()
	if(pad && gizmo && gizmo.marked)
		return pad.Retrieve(gizmo.marked)

/obj/machinery/abductor/console/proc/TeleporterSend()
	if(pad)
		pad.Send()

/obj/machinery/abductor/console/proc/FlipVest()
	if(vest)
		vest.flip_mode()

/obj/machinery/abductor/console/proc/SelectDisguise(remote, mob/user)
	var/entry_name = tgui_input_list(user, "Choose Disguise", "Abductor Disguises", disguises)
	var/datum/icon_snapshot/chosen = disguises[entry_name]
	if(chosen && (remote || in_range(user, src)))
		vest.SetDisguise(chosen)

/obj/machinery/abductor/console/proc/SetDroppoint(turf/location,user)
	if(!istype(location))
		to_chat(user, "<span class='warning'>That place is not safe for the specimen.</span>")
		return

	if(pad)
		pad.teleport_target = location
		to_chat(user, "<span class='notice'>Location marked as test subject release point.</span>")

/obj/machinery/abductor/console/proc/Link_Abduction_Equipment() // these must all be explicitly `in machines` or they will not properly link.
	for(var/obj/machinery/abductor/pad/p in GLOB.abductor_equipment)
		if(p.team == team)
			pad = p
			break

	for(var/obj/machinery/abductor/experiment/e in GLOB.abductor_equipment)
		if(e.team == team)
			experiment = e
			e.console = src

	for(var/obj/machinery/computer/camera_advanced/abductor/c in GLOB.abductor_equipment)
		if(c.team == team)
			camera = c
			c.console = src

/obj/machinery/abductor/console/proc/AddSnapshot(mob/living/carbon/human/target)
	var/datum/icon_snapshot/entry = new
	entry.name = target.name
	entry.icon = target.icon
	entry.icon_state = target.icon_state
	entry.overlays = target.get_overlays_copy(list(L_HAND_LAYER,R_HAND_LAYER))
	//Update old disguise instead of adding new one
	if(disguises[entry.name])
		disguises[entry.name] = entry
		return
	disguises[entry.name] = entry

/obj/machinery/abductor/console/proc/AddGizmo(obj/item/abductor/gizmo/G)
	if(G == gizmo && G.console == src)
		return FALSE

	if(G.console)
		G.console.gizmo = null

	gizmo = G
	G.console = src
	return TRUE

/obj/machinery/abductor/console/proc/AddVest(obj/item/clothing/suit/armor/abductor/vest/V)
	if(vest == V)
		return FALSE

	for(var/obj/machinery/abductor/console/C in SSmachines.get_by_type(/obj/machinery/abductor/console))
		if(C.vest == V)
			C.vest = null
			break

	vest = V
	return TRUE

/obj/machinery/abductor/console/item_interaction(mob/living/user, obj/item/used, list/modifiers)
	if(istype(used, /obj/item/abductor/gizmo) && AddGizmo(used))
		to_chat(user, "<span class='notice'>You link the tool to the console.</span>")
		return ITEM_INTERACT_COMPLETE
	if(istype(used, /obj/item/clothing/suit/armor/abductor/vest) && AddVest(used))
		to_chat(user, "<span class='notice'>You link the vest to the console.</span>")
		return ITEM_INTERACT_COMPLETE

	return ..()

/obj/machinery/abductor/console/proc/Dispense(item,cost=1)
	if(experiment && experiment.credits >= cost)
		experiment.credits -=cost
		atom_say("Поступление средств!")
		if(pad)
			flick("alien-pad", pad)
			new item(pad.loc)
		else
			new item(src.loc)
	else
		atom_say("Недостаточно средств!")
