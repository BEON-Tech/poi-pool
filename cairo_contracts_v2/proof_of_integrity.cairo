%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

struct StudentWallet {
    wallet_address_low: felt,
    wallet_address_high: felt,
}

@storage_var
func student_wallets(program: felt, index: felt) -> (student: StudentWallet) {
}

@storage_var
func program_students_number(program: felt) -> (number: felt) {
}

// @storage_var
// func existing_programs(program: felt) -> (existing_program: felt) {
// }

// @storage_var
// func ordered_programs(index: felt) -> (program: felt) {
// }

// @storage_var
// func programs_length() -> (length: felt) {
// }

@external
func register_student{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (program: felt, wallet: StudentWallet) {
    // Add program if necessary
    // let (program_number) = existing_programs.read(program);

    // if (program_number == 0) {
    //     existing_programs.write(program, program);
    //     let (index) = programs_length.read();
    //     ordered_programs.write(index, program);
    //     programs_length.write(index + 1);
    // } 

    let (number) = program_students_number.read(program);

    student_wallets.write(program, number, wallet);
    program_students_number.write(program, number + 1);

    return ();
}

// @view 
// func get_programs_count{
//     syscall_ptr: felt*,
//     pedersen_ptr: HashBuiltin*,
//     range_check_ptr,
// } () -> (count: felt) {
//     let (length) = programs_length.read();
//     return (count=length);
// }

// @view 
// func get_programs_at_index{
//     syscall_ptr: felt*,
//     pedersen_ptr: HashBuiltin*,
//     range_check_ptr,
// } (index: felt) -> (program: felt) {
//     let (program) = ordered_programs.read(index);
//     return (program=program);
// }

@view 
func get_students_count_by_program{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (program: felt) -> (count: felt) {
    let (length) = program_students_number.read(program);
    return (count=length);
}

@view 
func get_student_wallet{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
} (program: felt, index: felt) -> (wallet: StudentWallet) {
    let (wallet) = student_wallets.read(program, index);
    return (wallet=wallet);
}
