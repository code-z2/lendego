# Lendego

borrow.sol = here a user can interact with the liquidVault.sol and can place borrow orders
// all the associated borrow only method move here
lend.sol = here a user can interact with the stableVault.sol and can place position orders
// all khe associated lenders only method move here

vaults/liquidVault = used to manage borrowers collateral
vaults/stableVault = used to manage lenders fund

// interaction happens between lend.sol and borrow.sol

however no external interaction can happen betwen vaults and contracts. as vaults will be implicitly deployed.
