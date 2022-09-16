pragma solidity >=0.8.0;

contract AssemblyTest {
    function _delegate(address impl) internal {
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())

            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)

            let size := returndatasize()
            returndatacopy(ptr, 0, size)

            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    // 일반적으로 사용하는 Proxy Pattern의 fallBack함수 입니다.
    // 패턴에 따라서 다양하게 적용이 가능하며, 저도 사용은 해봤지만 정확하게 어떠한 assembly를 가지고 있는지가 궁금하여 뜯어보았습니다.

    /*
        1. mload(0x40)

        일단 스택의 최상단 빈 메모리를 가져옵니다.

        2. calldatacopy(ptr, 0, calldatasize())

        data를 복사하는 코드로 calldatacopy(a,b,c)로 하였을떄 c의 bytes값 즉 Transcation데이터를 b의 position에서 ptr로 복사를 합니다.
        - 쉽게 말해 c의 Bytes를 a에 복사합니다.

        function test(address impl) public view returns(bytes memory size) {
            assembly {
                let ptr := mload(0x40)
                // size := calldatasize() 0x
                // calldatacopy(ptr, 0, calldatasize()) 0x0000000000000000000000000000000000000000000000000000000000000020

            }
        }

        따로 실행하는 Transaction데이터가 없기 떄문에 calldataSize()는 0x 즉 없다는 값으로 나오고.
        mload에 복사를 해봤자 없는 값이기 떄문에 똑같이 default값으로 나오는것을 확인해 볼 수 있습니다.
        
        3.  let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)

        그후 delegatecall을 합니다.
        delegatecall과 call의 차이점은 delegatecall같은 경우에는 msg.sender, msg.value가 유지된다는 특징이 있습니다.
        하지만 delegatecall 및 call은 모두 function selector에러가 발생 가능합니다.
        - 해당 에러는 실행하는 contract에서 실행하고자 하는 함수가 없을때에 발생을 합니다.

        그러기 때문에 proxy를 사용할 떄에는 반드시 abi = 실행하고자 하는 contract , address = proxyContract Address로 설정을 해주어야 합니다.

        delegatecall의 인자값은 다음과 같습니다. delegatecall(a,b,c,d,e,f)
        a : gas비를 의미합니다.
        b : 호출 하고자 하는 contract주소를 의미합니다.
        c : 보낼 데이터의 시작 메모리 주소
        d : 데이터 사이즈
        e : output결과를 가져오는 항목 -> 결과로 어떤값이 올지 모르기 때문에 0
        f : output의 가지으를 가져오는 항목 -> 마찬가지로 결과값을 모르기 떄문에 0

        4. 나머지 코드

        나머지 코드는 return값이 있는지 없는지를 확인하면서 끝이 납니다.

    */
}
