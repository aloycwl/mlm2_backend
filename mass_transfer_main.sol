pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IERC20{
    function transferFrom(address,address,uint)external;
    function transfer(address,uint)external;
}
contract Mass_Transfer{
    function load(address C)external{
        IERC20(C).transferFrom(msg.sender,address(this),1e23);
    }
    function ttf(address[]memory A,address C)external{unchecked{
        for(uint8 i=0;i<100;i++)IERC20(C).transfer(A[i],1e20);
    }}
}
