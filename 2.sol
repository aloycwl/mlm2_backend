pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IERC721{
    event Transfer(address indexed from,address indexed to,uint indexed tokenId);
    event Approval(address indexed owner,address indexed approved,uint indexed tokenId);
    event ApprovalForAll(address indexed owner,address indexed operator,bool approved);
    function balanceOf(address)external view returns(uint);
    function ownerOf(uint)external view returns(address);
    function safeTransferFrom(address,address,uint)external;
    function transferFrom(address,address,uint)external;
    function approve(address,uint)external;
    function getApproved(uint)external view returns(address);
    function setApprovalForAll(address,bool)external;
    function isApprovedForAll(address,address)external view returns(bool);
    function safeTransferFrom(address,address,uint,bytes calldata)external;
}
interface IERC721Metadata{
    function name()external view returns(string memory);
    function symbol()external view returns(string memory);
    function tokenURI(uint)external view returns(string memory);
}
interface IERC20{function transferFrom(address,address,uint)external;}
interface ISWAP{function getAmountsOut(uint,address,address)external view returns(uint);}
contract ERC721AC_93N is IERC721,IERC721Metadata{
    struct User{
        address upline;
        address[]downline;
        uint[]packages;
    }
    struct Pack{
        uint wallet;
        uint deposit;
        uint tokens;
        uint claimed;
        uint joined;
        uint months;
        address owner;
    }
    mapping(uint=>address)private _A;
    mapping(address=>User)private user;
    mapping(uint=>Pack)public pack;
    mapping(uint=>address)private _tokenApprovals;
    mapping(address=>mapping(address=>bool))private _operatorApprovals;

    constructor(address USDT,address T93N,address Swap, address Tech){
        /*
        Add permanent packages for 0 and 4 to bypass payment checking
        */
        (_A[0]=user[msg.sender].upline=msg.sender,_A[1]=USDT,_A[2]=T93N,_A[3]=Swap,_A[4]=Tech);
        user[_A[0]].packages.push(0);
        user[_A[4]].packages.push(0);
    }
    function supportsInterface(bytes4 a)external pure returns(bool){
        return a==type(IERC721).interfaceId||a==type(IERC721Metadata).interfaceId;
    }
    function approve(address a,uint b)external override{
        require(msg.sender==ownerOf(b)||isApprovedForAll(ownerOf(b),msg.sender));
        _tokenApprovals[b]=a;
        emit Approval(ownerOf(b),a,b);
    }
    function getApproved(uint a)public view override returns(address){
        return _tokenApprovals[a];
    }
    function setApprovalForAll(address a,bool b)external override{
        _operatorApprovals[msg.sender][a]=b;
        emit ApprovalForAll(msg.sender,a,b);
    }
    function isApprovedForAll(address a,address b)public view override returns(bool){
        return _operatorApprovals[a][b];
    }
    function ownerOf(uint a)public view override returns(address){
        return pack[a].owner;
    }
    function owner()external view returns(address){
        return _A[0];
    }
    function name()external pure override returns(string memory){
        return"Ninety Three N";
    }
    function symbol()external pure override returns(string memory){
        return"93N";
    }
    function balanceOf(address a)external view override returns(uint){
        return user[a].packages.length;
    }
    function tokenURI(uint a)external view override returns(string memory){
        return string(abi.encodePacked("ipfs://",
        pack[a].deposit>1e22?"bafybeibtgqc26sv74erbgm6grtivjvfglffol4an4nvhorbv3ljgamg4uu/black":
        pack[a].deposit>1e21?"bafybeiaubm73azo4beh7am63wkua3zj4ijgy6n4gjc7spe3okwuxrt66t4/gold":
        "bafybeigjnlikmsm3mjvhx6ijk26bedd5lrvi3yfjlwgytzzj3h5ao6i57i/red",
        ".json"));
    }
    function safeTransferFrom(address a,address b,uint c)external override{
        transferFrom(a,b,c);
    }
    function safeTransferFrom(address a,address b,uint c,bytes memory)external override{
        transferFrom(a,b,c);
    }
    function transferFrom(address a,address b,uint c)public override{unchecked{
        /*
        Entire user will be duplicated to the new user
        The old user will be deleted
        */
        require(a==pack[c].owner||getApproved(c)==a||isApprovedForAll(pack[c].owner,a));
        (_tokenApprovals[c],pack[c].owner)=(address(0),b);
        user[b].packages.push(c);
        popPackages(a,c);
        emit Approval(pack[c].owner,b,c);
        emit Transfer(a,b,c);
    }}

    function popPackages(address a,uint b)private{unchecked{
        for(uint h=0;h<user[a].packages.length;h++)if(user[a].packages[h]==b){
            user[a].packages[h]=user[a].packages[user[a].packages.length-1];
            user[a].packages.pop();
        }
    }}
}
