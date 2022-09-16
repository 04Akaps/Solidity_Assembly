pragma solidity >=0.8.0;

contract AssemblyTest {
    function _createClone(address target) public returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            result := create(0, clone, 0x40) // 0x4Dcb95A07672dEe1e50c4E6790bB4F527b0BCBb0
        }
    }

    // 제가 Factory에서 New대신에 사용하는 코드 입니다.
    // 이떄까지는 단순히 그냥 사용했었는데 assembly를 공부해가면서 한번 다루어 보고 싶었습니다.

    // -> 가스비가 더 줄어들기 떄문에 사용을 합니다.
    // -> 왜냐하면 new를 사용하면 Solidity에서 코드를 정리한 bytes코드가 만들어지는 Contract에 보관이 됩니다.
    // -> 그러기 때문에 더 많은 가스비가 소모가 되지만, clone Contract같은 경우에는 이미 만들어진 저장소에 보관을 하기 때문에
    // -> new 키워드를 통한 factory보다 더 효율적으로 가스 사용이 가능합니다.

    // Clone은 Proxy와 유사하게 동작을 합니다.
    // --> 저장공간을 따로 둔다는 의미에서

    /* 

    -- assembly 코드 설명 --

    1. mload(0x40)

    일단 기본적으로 빈 메모리를 할당하는 코드 입니다.
    Solidity 같은 경우에는 스택 구조로 동작을 하며 mload(0x40)같은 경우에는 항상 스택의 최상단 => 즉 비여있는 공간의 메모리를 가르킵니다.
    비어있는 메모리이기 때문에 어떠한 값을 넣어도 문제가 발생하지 않습니다.

    function mload() public view returns(bytes memory b){
        assembly{
            b:= mload(0x40) // 0x0000000000000000000000000000000000000000000000000000000000000020
        }
    }

    2. mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)

    이후 빈 메모리 값에 32bytes값을 할당하는 코드 입니다.
    - clone을 할 위치를 잡아주는 것 입니다.

    function mstoreOne(address target) public returns(address result){
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40) // 0x0000000000000000000000000000000000000000000000000000000000000020
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            result := mload(clone) // 0x3D373d3d3d363D73000000000000000000000000
        }
    }

    3.  mstore(add(clone, 0x14), targetBytes)

    이후 기존의 빈 메모리에 저장된 값에 20bytes를 붙여 줍니다.
    - 0x14는 hexadecimal로 16진법을 의미합니다.

    function mstoreTwo(address target) public returns(address result){
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            ) 
            mstore(add(clone, 0x14), targetBytes)
            result := mload(clone) // 0x3D373d3d3D363d735b38Da6a701c568545DcfCb0
        }
    }

    - 0x14는 특이합니다. (애만 특이한것은 아닙니다).

    단순히 바로 mload(add(clone,0x14))를 통해서 저장이 되지마자 불러오면 0x0000000000000000000000000000000000000000와 같은 값이 나옵니다.
    이러한 이유는 mstore에 애초에 0x0000000000000000000000000000000000000000000000000000000000000020과 같이 default같이 저장되어 있기 때문에 나오는 현상입니다.
    - 위에서 볼 수 있듯이 기존에 값이 추가되어 있는 상태라면 무리없이 동작합니다.

    4.   mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)

    이는 이제 40 bytes를 더해주기 위해서 수정되는 코드 입니다
    - 0x28은 40bytes를 의미합니다.

    function _createClone(address target) public returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            result := mload(clone) 0x3D373d3d3D363d735b38Da6a701c568545DcfCb0
        }
    }

    5. create(0,clone, 0x37)

    이제 우리가 원하는 주소가 나왔으니 해당 주소를 생성해 주면 됩니다.

    clone는 new키워드와 동일하다 생각을 하면 되고, 인자로는 create(gas, 메모리 주소, bytes길이)값이 들어가게 됩니다.
    - 0x37은 55bytes 입니다.
    - 이떄 gas는 새로 생성되는 Contract에 전송이 됩니다.
      
    function _createClone(address target) public returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            result := create(0, clone, 0x37) // 0x4Dcb95A07672dEe1e50c4E6790bB4F527b0BCBb0
        }
    }
    */

    /*
        -- 의문점 --

        아무래도 혼자서 공부를 하다보니 몇가지 의문점이 남고 이걸 바로바로 해소할 수 없습니다.
        
        굳이 왜 0x37, 0x14 등등을 사용하는지가 의문입니다.

        0x37말고도 0x14를 넣어도 동작을 하게 되는데 굳이 0x37을 사용을 하는 이유가 먼지가 궁금합니다.
        
        이러한 이유는 후에 좀 더 알아보고 해결이 되면 추가 작성을 하도록 하겠습니다.

    */
}
