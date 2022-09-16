pragma solidity 0.4.24;

contract AssemblyTest {
    uint256[] d = [1, 2, 3, 4];
    uint256[3] s = [1, 2, 3];

    function d_1() public view returns (uint256 r) {
        uint256[] memory arr = d;
        assembly {
            r := arr
        }
    }

    function d_2() public view returns (uint256 r) {
        uint256[] memory arr = d;
        assembly {
            r := mload(arr)
        }
    }

    function s_2() public view returns (uint256 r) {
        uint256[3] memory arr = s;

        assembly {
            r := mload(arr)
        }
    }

    function s_3() public view returns (uint256 r) {
        uint256[3] memory arr = s;

        assembly {
            r := mload(add(arr, mul(0x20, 2)))
        }
    }

    // 동적, 정적 배열의 차이점을 이해 해야 한다.
    // 동적 배열의 경우Length값을 첫 32바이트에 저장을 한다고 하니 d_2의 경우에는 배열의 Length값이 나오고
    // 정적 배열의 경우에는 Length값이 있기 떄문에 0번쨰 값을 반환한다고 한다.

    // 만약 배열의 특정 인덱스 값에 접근을 하고자 한다면 동적 배열의 경우에는
    // => molad(add(arr, add(0x20, mul(0x20 * i))))로 접근을 해야한다.
    // => 이는 mul을 통해서 index를 정하고 있는데 0x20을 넣은 이유는 byte의 가장 단위이기 떄문에 0x20으로 활용하는 것이다.

    // 정적 배열의 경우에는 이렇게 활용한다.,
    // => molad(add(arr,mul( 0x20 * i)));

    function fii() external view returns (uint256 v) {
        uint256 a;
        uint256 b;
        uint256 c;

        c = a + b;

        assembly {
            a := mload(0x40)
            mstore(a, 2)

            v := mload(a)
        }
    }

    function setDate(uint256 newvalue) public {
        assembly {
            sstore(0, newvalue)
        }
    }

    function getDate() public view returns (uint256 r) {
        assembly {
            let v := sload(0)
            mstore(0x40, v)

            r := mload(0x40)
            // return mload(0x40)
            // r:= sload(0)
        }
    }

    // 데이터를 저장하고 불러오는 방식을 다루어 보았다.
    // sload, sstore는 Contract의 Storage에 저장하고 불러오는 코드이다.
    // => 그러기 때문에 비싸다.

    // 하지만 mload, mstore는 메모리 단계에서 관리를 하기 떄문에 저렴하다??는 장점이 있다.

    function sendEth(address _to, uint256 _amount) external payable {}

    address[] owners = [
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
        0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    ];
}
