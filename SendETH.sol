pragma solidity >=0.8.0;

contract AssemblyTest {
    address[2] owners = [
        0x5B38Da6a701c568545dCfcB03FcB875f56beddC4,
        0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
    ];

    function sendEth(address _to, uint256 _amount) external payable {
        bool success;
        uint256 value = msg.value;

        assembly {
            for {
                let i := 0
            } lt(i, 2) {
                i := add(i, 1)
            } {
                let owner := sload(i)
                if eq(_to, owner) {
                    success := call(gas(), _to, _amount, 0, 0, 0, 0)
                }
            }
        }

        require(success, "Error : fail");
    }

    // 먼저 for문을 정의한 코드부터 설명을 해보자면
    // assembly에서 변수를 선언하는 것은 메모리를 선언하는 것과 유사하다고 생각을 하여 진행을 하였다.
    // Golang을 아주 살짝만 맛만보았을때에도 Golang에서도 변수를 선언하면 메모리를 할당하고 메모리를 가르키는 주소가 만들어 진다고 한다.
    // Solidity에서도 assembly를 사용하면 이러한 방식으로 동작하는 것이 아닌가 싶다.
    // 왜냐하면 add라는 코드안에는 0x40, 0x20 등등 메모리 주소가 들어가게 되는데 for문에서 add안에 새로운 변수를 할당해도 에러가 발생을 하지 않는 모습을 보아하니
    // 변수 또한 메모리로 생성이 되는 것이 아닌가라는 생각을 하면서 공부를 하였다.

    // lt는 굉장히 쉽다.
    // lt(a,b) == a<b 라는 조건이다.

    function verifyAddress() external view returns (address i) {
        assembly {
            let temp := 0 // 0x0000000000000000000000000000000000000000
            i := sload(temp) // 0x0000000000000000000000000000000000000004
        }
    }

    // 실제로 test를 해보았는데 메모리 주소같은 형태는 아니더라도 빈 address가 할당이 되었다.

    function verifyAddress2(address _to) external payable returns (bool) {
        bool success;
        uint256 value = msg.value;

        assembly {
            let temp := 0 // 0x0000000000000000000000000000000000000000
            let owner := sload(temp) // 0x0000000000000000000000000000000000000004

            if eq(owner, _to) {
                success := call(gas(), _to, value, 0, 0, 0, 0)
            }
        }

        return success;
    }

    // 하지만 어떠한 값으로 돌아오는지 보고 싶어서 test해본 결과 실패를 하였다.
    // 참고하였던 자료에서는 성공을 하였지만 나는 실패를 하였다.
    // 원인은 애초에 if문을 타지 않는다. 그러기 때문에 require문에서 false가 동작을 하고 있다.
    // if문을 타지 않는 이유는 간단하고 sload값을 0, 1에서도 따왔지만 default Address 값만 나오고 있기 떄문에 인자로 들어가는 _to Address와는 맞지 않기 떄문이다.

    function mySendEth(address _to) external payable {
        bool success;
        uint256 value = msg.value;

        address[2] memory tempOwner = owners;

        assembly {
            for {
                let i := 0
            } lt(i, 2) {
                i := add(i, 1)
            } {
                let owner := mload(add(tempOwner, mul(0x20, i)))
                if eq(_to, owner) {
                    success := call(gas(), _to, value, 0, 0, 0, 0)
                }
            }
        }

        require(success, "Error : fail");
    }

    // 그래서 내가 배운 부분을 활용을 하였다.
    // 그냥 0,1을 통해서 sload 하게 되면 default Address가 나오기 떄문에 전역에 선언하여 잡은 정적 배열을 할당하엿다.

    // 그후 sload를 통해서 할당한 값을 가져왔다.
    // 이떄 molad를 사용해도 된다. 왜냐하면 tempOwner라는 변수는 지역변수로 선언이 되어 있기 떄문에 메모리값으로 잡히게 된다.
}
