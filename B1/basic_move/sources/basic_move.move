module basic_move::basic_move;

use std::string::{String, utf8};
use sui::test_scenario::{begin, end};
use sui::test_utils::destroy;

// EXPECTION CODES

const EAlreadyCarriesWeapon: u64 = 0;
const ENoWeaponEquipped: u64 = 1;

// STRUCTS
public struct Hero has key {
    id: UID,
    name: String,
    stamina: u64,
    weapon: Option<Weapon>,
}

public struct Weapon has key, store {
    id: UID,
    name: String,
    power: u64,
}

// INIT

// PUBLIC FUNCTIONS

// MINT
public fun mint_hero(name_param: String, stamina_param: u64, ctx: &mut TxContext): Hero {
    // Much cleaner than the previous implementation (Creating local variable and returning it)
    Hero {
        id: object::new(ctx),
        name: name_param,
        stamina: stamina_param,
        weapon: option::none(),
    }
}

public fun mint_weapon(name_param: String, power_param: u64, ctx: &mut TxContext): Weapon {
    Weapon {
        id: object::new(ctx),
        name: name_param,
        power: power_param,
    }
}

// EQUIP & UNEQUIP
public fun equip_weapon(hero: &mut Hero, weapon: Weapon) {
    assert!(hero.weapon.is_none(), EAlreadyCarriesWeapon);
    hero.weapon.fill(weapon);
}

public fun unequip_weapon(hero: &mut Hero): Weapon {
    assert!(hero.weapon.is_some(), ENoWeaponEquipped);
    hero.weapon.extract()
}

#[test]
fun test_mint() {
    let mut test = begin(@0xCAFE);

    let hero_name: String = utf8(b"Hero");
    let hero_stamina: u64 = 100;
    let hero = mint_hero(hero_name, hero_stamina, test.ctx());

    assert!(hero.name == hero_name, 1);
    assert!(hero.stamina == hero_stamina, 2);
    destroy(hero);
    test.end();
}

#[test]
fun test_equip_weapon() {
    let mut test = begin(@0xCAFE);

    let hero_name: String = utf8(b"Hero");
    let hero_stamina: u64 = 100;
    let mut hero = mint_hero(hero_name, hero_stamina, test.ctx());

    let weapon_name: String = utf8(b"Weapon");
    let weapon_power: u64 = 10;
    let weapon = mint_weapon(weapon_name, weapon_power, test.ctx());

    hero.equip_weapon(weapon);
    assert!(hero.weapon.is_some(), 1);
    let w = hero.weapon.borrow();
    assert!(w.name == weapon_name, 999);

    destroy_for_testing(hero);
    test.end();
}

#[test]
#[expected_failure(abort_code = EAlreadyCarriesWeapon)]
fun test_equip_weapon_with_existing_weapon() {
    let mut test = begin(@0xCAFE);

    let mut hero = mint_hero(b"Hero".to_string(), 100, test.ctx());

    let weapon = mint_weapon(b"Weapon".to_string(), 10, test.ctx());

    hero.equip_weapon(weapon);
    assert!(hero.weapon.is_some(), 1);
    let w = hero.weapon.borrow();
    assert!(w.name == b"Weapon".to_string(), 999);

    let weapon_2 = mint_weapon(b"Weapon2".to_string(), 33, test.ctx());

    hero.equip_weapon(weapon_2);

    destroy_for_testing(hero);
    test.end();
}

#[test]
fun test_unequip_weapon() {
    let mut test = begin(@0xCAFE);

    let hero_name: String = utf8(b"Hero");
    let hero_stamina: u64 = 100;
    let mut hero = mint_hero(hero_name, hero_stamina, test.ctx());

    let weapon_name: String = utf8(b"Weapon");
    let weapon_power: u64 = 10;
    let weapon = mint_weapon(weapon_name, weapon_power, test.ctx());

    hero.equip_weapon(weapon);

    assert!(hero.weapon.is_some(), 1);

    let unequipped_weapon = hero.unequip_weapon();
    assert!(hero.weapon.is_none(), 2);

    hero.destroy_for_testing();
    destroy(unequipped_weapon);
    test.end();
}

#[test]
#[expected_failure(abort_code = ENoWeaponEquipped)]
fun test_unequip_weapon_with_no_weapon() {
    let mut test = begin(@0xCAFE);

    let mut hero = mint_hero(b"Hero".to_string(), 100, test.ctx());
    let unequipped_weapon = hero.unequip_weapon();

    hero.destroy_for_testing();
    destroy(unequipped_weapon);
    test.end();
}

#[test_only]
fun destroy_for_testing(hero: Hero) {
    let Hero {
        id,
        name: _,
        stamina: _,
        weapon: _w,
    } = hero;
    object::delete(id);

    if (_w.is_some()) {
        let Weapon {
            id: _wid,
            name: _,
            power: _,
        } = _w.destroy_some();
        object::delete(_wid);
    } else {
        _w.destroy_none();
    }
}
