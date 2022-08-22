%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (get_block_timestamp)

struct Wallet:
    member wallet_address_low: felt
    member wallet_address_high: felt
end

struct Applicant:
    member applicant_id: felt
    member registration_date: felt
    member evidence_hash: felt
    # uint256[] associatedGrantedApplicationIds;
end

struct Certifier:
    member certifier_id: felt
    member registration_date: felt
    member evidence_hash: felt
    # uint256[] associatedGrantedApplicationIds;
end

@storage_var
func approved_applicants(wallet: Wallet) -> (applicant: Applicant):
end

@storage_var
func approved_applicants_accounts(index: felt) -> (wallet: Wallet):
end

@storage_var
func approved_applicants_accounts_length() -> (res: felt):
end

@storage_var
func certifiers(wallet: Wallet) -> (certifier: Certifier):
end

@storage_var
func certifiers_accounts(index: felt) -> (wallet: Wallet):
end

@storage_var
func certifiers_accounts_length() -> (res: felt):
end

@external
func add_approved_applicant{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
} (wallet: Wallet, firstname: felt, lastname: felt, database_id: felt):
    let (approved_applicant) = approved_applicants.read(wallet)
    # Applicant's wallet is not already registered
    assert approved_applicant = Applicant(0, 0, 0)
    # TODO: calculate evidence hash
    let (block_timestamp) = get_block_timestamp()
    approved_applicants.write(wallet, Applicant(database_id, block_timestamp, 1234))
    let (current_index) = approved_applicants_accounts_length.read()
    approved_applicants_accounts.write(current_index, wallet)
    approved_applicants_accounts_length.write(current_index + 1)
    return ()
end

@view 
func get_approved_applicant{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
} (wallet: Wallet) -> (applicant: Applicant): 
    let (approved_applicant) = approved_applicants.read(wallet)
    return (applicant=approved_applicant)
end

@view
func get_approved_applicant_wallet{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
} (position: felt) -> (wallet: Wallet):
    let (approved_applicant_wallet) = approved_applicants_accounts.read(position)
    return (wallet=approved_applicant_wallet)
end

@view
func get_approved_applicants_length{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
} () -> (length: felt):
    let (length) = approved_applicants_accounts_length.read()
    return (length)
end

@external
func add_certifier{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
} (wallet: Wallet, firstname: felt, lastname: felt, database_id: felt):
    let (registered_certifier) = certifiers.read(wallet)
    # Certifier's wallet is not already registered
    assert registered_certifier = Certifier(0, 0, 0)
    # TODO: calculate evidence hash
    let (block_timestamp) = get_block_timestamp()
    certifiers.write(wallet, Certifier(database_id, block_timestamp, 5678))
    let (current_index) = certifiers_accounts_length.read()
    certifiers_accounts.write(current_index, wallet)
    certifiers_accounts_length.write(current_index + 1)
    return ()
end

@view 
func get_certifier{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
} (wallet: Wallet) -> (certifier: Certifier): 
    let (registered_certifier) = certifiers.read(wallet)
    return (certifier=registered_certifier)
end

@view
func get_certifier_wallet{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
} (position: felt) -> (wallet: Wallet):
    let (certifier_wallet) = certifiers_accounts.read(position)
    return (wallet=certifier_wallet)
end

@view
func get_certifiers_length{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
} () -> (length: felt):
    let (length) = certifiers_accounts_length.read()
    return (length)
end
