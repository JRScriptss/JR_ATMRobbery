# JR ATMRobbery

A customizable ATM robbery script for FiveM with **ESX** or **QBCore** support.  
Includes **ox_target / qb-target integration**, police alerts, mini-games, and item requirements.

---

## Features

- Supports **ESX** and **QBCore** frameworks.
- Target system support:
  - `ox_target`  
  - `qb-target`
- Requires a **specific item** (e.g., hacker device) to start the robbery. Can be set in `config.lua`
- Checks **minimum police online** before robbery.
- Mini-games for robbery hacking: These can be changed
  - Digital fingerprint (`utk_fingerprint`)
  - Thermite (`ps-ui`)
  - Number maze (`ps-ui`)
- Police notifications and alerts with multiple dispatch system support:
  - Default
  - CD Dispatch
  - QS-Dispatch
  - RCore Dispatch
  - PS-Dispatch
- Money grab animation and progress bar during the robbery.

---

## Installation

1. Configure the `config.lua` to your preference.
2. Place the script folder in your `resources` directory.  
3. Add to `server.cfg`:

```cfg
ensure JR_ATM
