/obj/item/borg/upgrade/storageincreaser
	name = "storage increaser"
	desc = "Improves cyborg storage with bluespace technology to store more medicines"
	icon_state = "cyborg_upgrade2"
	origin_tech = "bluespace=4;materials=5;engineering=3"
	require_module = TRUE
	var/max_energy_multiplication = 3
	var/recharge_rate_multiplication = 2

/obj/item/borg/upgrade/storageincreaser/do_install(mob/living/silicon/robot/R)
	for(var/obj/item/borg/upgrade/storageincreaser/U in R.contents)
		to_chat(R, span_notice("A [name] unit is already installed!"))
		to_chat(usr, span_notice("There's no room for another [name] unit!"))
		return FALSE

	for(var/datum/robot_storage/energy/ES in R.module.storages)
		// ОФФы решили не делать деактиватор, поэтому против абуза сбрасываем.
		ES.max_amount = initial(ES.max_amount)
		ES.recharge_rate = initial(ES.recharge_rate)
		ES.amount = initial(ES.max_amount)

		// Modifier
		ES.max_amount *= max_energy_multiplication
		ES.recharge_rate *= recharge_rate_multiplication
		ES.amount = ES.max_amount

	return TRUE

/obj/item/borg/upgrade/hypospray
	name = "cyborg hypospray upgrade"
	desc = "Adds and replaces some reagents with better ones"
	icon_state = "cyborg_upgrade2"
	origin_tech = "biotech=6;materials=5"
	require_module = TRUE
	module_type = /obj/item/robot_module/medical
	items_to_replace = list(
		/obj/item/reagent_containers/borghypo/basic = /obj/item/reagent_containers/borghypo/basic/upgraded
	)

// Улучшения голопроектора //
/obj/item/borg/upgrade/atmos_holofan/better
	name = "Улучшение модульного ATMOS голопроектора"
	desc = "Повышает энергоэффективность проектора, позволяя создавать до 3 голопроекций."
	icon_state = "cyborg_upgrade2"
	origin_tech = "materials=4;engineering=4;magnets=4"
	require_module = TRUE
	module_type = /obj/item/robot_module/engineering

/obj/item/borg/upgrade/atmos_holofan/better/do_install(mob/living/silicon/robot/R)
	var/obj/item/holosign_creator/atmos/robot/T = locate() in R.module.modules
	T.name = "Улучшенный модульный ATMOS голопроектор"
	T.desc = "Улучшенный модуль ATMOS голопроектора, предназначенный для использования инженерными киборгами.\
		<br>Количество создаваемых голопроекций увеличено до 3 за счёт применения улучшенных материалов."
	T.icon = 'modular_ss220/silicons/icons/robot_tools.dmi'
	T.icon_state = "atmos_holofan_better"
	T.max_signs = 3
	clean_signs(T)

	return

/obj/item/borg/upgrade/atmos_holofan/best
	name = "Оптимизация модульного ATMOS голопроектора"
	desc = "Оптимизирует энергоэффективность проектора и заменяет микросхемы на продвинутые, позволяя создавать до 5 голопроекций."
	icon_state = "cyborg_upgrade5"
	origin_tech = "materials=6;engineering=6;magnets=6;programming=6"
	require_module = TRUE
	module_type = /obj/item/robot_module/engineering
	required_upgrades = list(/obj/item/borg/upgrade/atmos_holofan/better)

/obj/item/borg/upgrade/atmos_holofan/best/do_install(mob/living/silicon/robot/R)
	var/obj/item/holosign_creator/atmos/robot/T = locate() in R.module.modules
	T.name = "Продвинутый модульный ATMOS голопроектор"
	T.desc = "Продвинутый модуль ATMOS голопроектора, предназначенный для использования инженерными киборгами.\
		<br>Количество создаваемых голопроекций увеличено до 5 за счёт точечной оптимизации микросхем и применения редких материалов."
	T.icon = 'modular_ss220/silicons/icons/robot_tools.dmi'
	T.icon_state = "atmos_holofan_best"
	T.max_signs = 5
	clean_signs(T)

	return

// Очистка проекций при установке улучшений //
/obj/item/borg/upgrade/atmos_holofan/proc/clean_signs(mob/living/silicon/robot/R)
	var/obj/item/holosign_creator/atmos/robot/T = locate() in R.module.modules
	var/list/signs = T.signs
	if(length(signs) > 0)
		for(var/A in signs)
			qdel(A)
		to_chat(R, span_notice("Все активные голограммы были отключены."))
	return

// Проверка наличия необходимых улучшений //
/obj/item/borg/upgrade
	var/required_upgrades = list()

/obj/item/borg/upgrade/pre_install_checks(mob/user, mob/living/silicon/robot/R)
	. = ..()
	if(!.)
		return

	var/list/missing_upgrades = list()

	for(var/item in required_upgrades)
		var/atom/required_upgrade = item
		var/upgrade_found = FALSE

		for(var/obj/item/borg/upgrade/installed_upgrade in R)
			if(istype(installed_upgrade,required_upgrade))
				upgrade_found = TRUE
				break

		if(!upgrade_found)
			missing_upgrades += required_upgrade::name

	if(length(missing_upgrades) > 0)
		to_chat(user, span_notice("Ошибка: отсутствуют необходимые улучшения: [missing_upgrades.Join(", ")]."))
		return FALSE
