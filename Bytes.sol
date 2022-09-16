pragma solidity >=0.8.0;

contract AssemblyTest {
    function add(uint256 _a, uint256 _b) public view returns (uint256 result) {
        assembly {
            let a := mload(0x40)
            let b := add(a, 32)
            calldatacopy(a, 4, 32)
            calldatacopy(b, add(4, 32), 32)
            result := add(mload(a), mload(b))
        }
    }

    // 단순한 calldata테스트 입니다.
    // -> 사실 많은 부분을 배웟기는 합니다..

    /*
        일단 이 부분에서 byte, bytes에 대해서 조금은 알아가야 합니다.

        bit는 가장 최소 단위로써 1byte는 8bit를 담을 수 있습니다.
        - 일반적인 0000 0000 과 같은 형태가 1byte고 0을 1bit라고 합니다.

        bytes는 byte의 단위 집합체로 char형태의 값을 담을 수 있습니다.

        function add(uint256 _a, uint256 _b) public view returns(address a, address  b) {
            assembly {
                a := mload(0x40) 0x0000000000000000000000000000000000000080
                b := add(a, 32) 0x00000000000000000000000000000000000000a0
            }
        }

        function add(uint256 _a, uint256 _b) public view returns(uint256 a, uint256  b) {
            assembly {
                a := mload(0x40) 128
                b := add(a, 32) 160
            }
        }

        이와 같은 코드에서 return값만 바뀌었는데 완전히 다른 값이 나오는 것을 볼 수 있습니다.

        쉽게 말해 uint256으로 반환했을떄에는 bytes의 총 길이값이 리턴이 되는 것이고, address값으로 변환하면 bytes값이 변환되어서 나오는 것입니다.

        function add(uint256 _a, uint256 _b) public view returns(bytes memory a, bytes memory  b) {
            assembly {
                a := mload(0x40) 128 
                b := add(a, 32) 160
            }
        }
        a : 0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000040
        b : 0x00000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000a00000000000000000000000000000000000000000000000000000000000000040

        직접 bytes값으로 변환하면 이와 같습니다.

        신기한점은 address값으로 반환하였을떄 마지막의 글자 조금만 달라진다는 것을 알 수 있습니다.

        왜냐하면 bytes값 같은 경우에는 char로 표현을하면 문자이기 떄문에 문자값만을 변경하여 값을 맞추는 것으로 이해하였습니다.
    */
}
