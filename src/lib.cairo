#[starknet::interface]
trait ISimpleStorage<TContractState> {
    fn set(ref self: TContractState, x: u128);
    fn get(self: @TContractState) -> u128;
}

#[starknet::contract]
mod SimpleStorage {
    use starknet::{get_caller_address, contract_address_const};

    #[storage]
    struct Storage {
        stored_data: u128
    }

    #[abi(embed_v0)]
    impl SimpleStorage of super::ISimpleStorage<ContractState> {
        fn set(ref self: ContractState, x: u128) {
            let caller_felt: felt252 = get_caller_address().into();
            println!("Caller : {}", caller_felt);
            assert!(get_caller_address() != contract_address_const::<0>(), "Caller is 0");
            self.stored_data.write(x);
        }

        fn get(self: @ContractState) -> u128 {
            self.stored_data.read()
        }
    }
}
#[cfg(test)]
mod test {
    use result::ResultTrait;
    use core::traits::TryInto;
    use starknet::testing::set_caller_address;
    use starknet::contract_address_const;
    use super::{ISimpleStorageDispatcher, ISimpleStorageDispatcherTrait};

    #[test]
    fn test_fail() {
        let (address, _) = starknet::deploy_syscall(
            super::SimpleStorage::TEST_CLASS_HASH.try_into().unwrap(), 0, array![].span(), true
        )
            .unwrap();
        let hello_dispatcher = ISimpleStorageDispatcher { contract_address: address };
        let one_address = contract_address_const::<1>();
        set_caller_address(one_address);
        hello_dispatcher.set(1);
    }
}
