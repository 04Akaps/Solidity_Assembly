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

    function sendEth(address _to, uint256 _amount) external payable {}

    address[] owners = [
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
        0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    ];
}
