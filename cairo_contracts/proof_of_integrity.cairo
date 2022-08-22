%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (get_block_timestamp)

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
func approved_applicants(wallet_address_low: felt, wallet_address_high: felt) -> (applicant: Applicant):
end

@storage_var
func certifiers(wallet_address_low: felt, wallet_address_high: felt) -> (certifier: Certifier):
end

@external
func add_approved_applicant{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
} (wallet_address_low: felt, wallet_address_high: felt, firstname: felt, lastname: felt, database_id: felt):
    let (approved_applicant) = approved_applicants.read(wallet_address_low, wallet_address_high)
    # Applicant's wallet is not already registered
    assert approved_applicant = Applicant(0, 0, 0)
    # TODO: calculate evidence hash
    let (block_timestamp) = get_block_timestamp()
    approved_applicants.write(wallet_address_low, wallet_address_high, Applicant(database_id, block_timestamp, 1234))
    return ()
end

@view 
func get_approved_applicant{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
} (wallet_address_low: felt, wallet_address_high: felt) -> (applicant: Applicant): 
    let (approved_applicant) = approved_applicants.read(wallet_address_low, wallet_address_high)
    return (applicant=approved_applicant)
end

@external
func add_certifier{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
} (wallet_address_low: felt, wallet_address_high: felt, firstname: felt, lastname: felt, database_id: felt):
    let (registered_certifier) = certifiers.read(wallet_address_low, wallet_address_high)
    # Certifier's wallet is not already registered
    assert registered_certifier = Certifier(0, 0, 0)
    # TODO: calculate evidence hash
    let (block_timestamp) = get_block_timestamp()
    certifiers.write(wallet_address_low, wallet_address_high, Certifier(database_id, block_timestamp, 5678))
    return ()
end

@view 
func get_certifier{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr
} (wallet_address_low: felt, wallet_address_high: felt) -> (certifier: Certifier): 
    let (registered_certifier) = certifiers.read(wallet_address_low, wallet_address_high)
    return (certifier=registered_certifier)
end