pragma solidity>0.8.0;//SPDX-License-Identifier:None
interface IERC721{event Transfer(address indexed from,address indexed to,uint indexed tokenId);event Approval(address indexed owner,address indexed approved,uint indexed tokenId);event ApprovalForAll(address indexed owner,address indexed operator,bool approved);function balanceOf(address)external view returns(uint);function ownerOf(uint)external view returns(address);function safeTransferFrom(address,address,uint)external;function transferFrom(address,address,uint)external;function approve(address,uint)external;function getApproved(uint)external view returns(address);function setApprovalForAll(address,bool)external;function isApprovedForAll(address,address)external view returns(bool);function safeTransferFrom(address,address,uint,bytes calldata)external;}
interface IERC721Metadata{function name()external view returns(string calldata);function symbol()external view returns(string calldata);function tokenURI(uint)external view returns(string calldata);}
interface IERC20{function transferFrom(address,address,uint)external;function balanceOf(address)external view returns(uint256);}
interface ISWAP{function getAmountsOut(uint,address,address)external view returns(uint);}
contract ERC721AC_93N is IERC721,IERC721Metadata{
    struct User{
        address upline;
        address[]downline;
        uint[]pack;
    }
    struct Pack{
        uint node;
        uint t93n;
        uint claimed;
        uint joined;
        address owner;
    }
    struct Node{
        uint price;
        uint count;
        uint factor; //1-3: shares, 4-5: staking %
        uint period;
        string uri;
    }
    mapping(uint=>address)private _A;
    mapping(address=>User)private user;
    mapping(uint=>Node)private node;
    mapping(uint=>Pack)public pack;
    mapping(uint=>address)private _tokenApprovals;
    mapping(address=>mapping(address=>bool))private _operatorApprovals;
    uint constant private P=10000; //Percentage
    uint[3]private refA=[500,300,200];
    uint[3]private refB=[500,500,1000];
    uint public Share;
    uint private _count; //For unique NFT

    constructor(address USDT,address T93N,address Swap, address Tech){
        /*
        Add permanent packages for 0 and 4 to bypass payment checking
        Initialise node: 0- Red Lion, 1- Green Lion, 2- Blue Lion, 3-Super Unicorn, 4-Asset Eagle
        */
        (_A[0]=user[msg.sender].upline=msg.sender,_A[1]=USDT,_A[2]=T93N,_A[3]=Swap,_A[4]=Tech);
        user[_A[0]].pack.push(0);
        user[_A[4]].pack.push(0);
        node[0].price=node[1].price=node[2].price=1e20;
        (node[0].count,node[0].factor,node[0].uri)=(25e4,1,"bAXSCgPa1KkU9AABScYju6VxVy8F9NdPfUJxM3NsMWQt");
        (node[1].count,node[1].factor,node[1].uri)=(15e4,2,"XC9ZBbRaKSVqx6bqvpBtCRgySWju2hnbT5x9sRZhheZw");
        (node[2].count,node[2].factor,node[2].uri)=(1e5,3,"Z1vRU2Yf6BfZCdpTVRPzXUtoxAsxtPVjFk9aK2JxTtP2");
        (node[3].count,node[3].price,node[3].period,node[3].factor,node[3].uri)=(3e4,1e21,180,1,"cUpTRu4AehAoGLGcYCEaCz9hR6bdB8shVmnmk5nNenyy");
        (node[4].count,node[4].price,node[4].period,node[4].factor,node[4].uri)=(1e4,5e21,360,7,"bLKzHK2fCe4T8mdZ3NMk9yY4JwwNgS8gJeCfCEUmpkh7");
    }
    function supportsInterface(bytes4 a)external pure returns(bool){return a==type(IERC721).interfaceId||a==type(IERC721Metadata).interfaceId;}
    function approve(address a,uint b)external override{require(msg.sender==ownerOf(b)||isApprovedForAll(ownerOf(b),msg.sender));_tokenApprovals[b]=a;emit Approval(ownerOf(b),a,b);}
    function getApproved(uint a)public view override returns(address){return _tokenApprovals[a];}
    function setApprovalForAll(address a,bool b)external override{_operatorApprovals[msg.sender][a]=b;emit ApprovalForAll(msg.sender,a,b);}
    function isApprovedForAll(address a,address b)public view override returns(bool){return _operatorApprovals[a][b];}
    function ownerOf(uint a)public view override returns(address){return pack[a].owner;}
    function owner()external view returns(address){return _A[0];}
    function name()external pure override returns(string memory){return"Ninety Three N";}
    function symbol()external pure override returns(string memory){return"93N";}
    function balanceOf(address a)external view override returns(uint){return user[a].pack.length;}
    function tokenURI(uint a)external view override returns(string memory){return string(abi.encodePacked("ipfs://Qm",node[a].uri));}
    function safeTransferFrom(address a,address b,uint c)external override{transferFrom(a,b,c);}
    function safeTransferFrom(address a,address b,uint c,bytes calldata)external override{transferFrom(a,b,c);}
    function transferFrom(address a,address b,uint c)public override{unchecked{
        /*
        Entire user will be duplicated to the new user
        The old user will be deleted
        */
        require(a==pack[c].owner||getApproved(c)==a||isApprovedForAll(pack[c].owner,a));
        (_tokenApprovals[c],pack[c].owner)=(address(0),b);
        //user[b].pack.push(c);
        popPackages(a,c);
        emit Approval(pack[c].owner,b,c);
        emit Transfer(a,b,c);
    }}

    function popPackages(address a,uint b)private{unchecked{
        for(uint h=0;h<user[a].pack.length;h++)if(user[a].pack[h]==b){
            user[a].pack[h]=user[a].pack[user[a].pack.length-1];
            user[a].pack.pop();
        }
    }}
    function getUplines(address d0)private view returns(address d1,address d2,address d3){
        (d1=user[d0].upline,d2=user[d1].upline,d3=user[d2].upline);
    }
    function Purchase(address referral,uint n,uint c)external{unchecked{
        require((n<3?node[0].count+node[1].count+node[2].count:node[n].count)>=c,"Insufficient nodes");
        /*
        Tabulate total and fetch pricing
        Set upline if non-existence and if no referral set to admin 
        */
        uint amt=node[n].price*c;
        uint t93n=ISWAP(_A[3]).getAmountsOut(amt,_A[1],_A[2])/c;
        if(user[msg.sender].upline==address(0)){
            user[msg.sender].upline=referral==address(0)||referral==msg.sender?_A[0]:referral;
            user[referral].downline.push(msg.sender);
        }
        /*
        Transfer USDT to this contract as checking and redistribution (roll back if insufficient amount)
        Transfer to uplines and admin
        */
        address[3]memory d;
        (d[0],d[1],d[2])=getUplines(msg.sender); 
        IERC20(_A[1]).transferFrom(msg.sender,address(this),amt);
        for(uint i;i<3;i++)IERC20(_A[1]).transferFrom(address(this),d[i],amt*refA[i]/P);
        /*
        Loop to generate nodes (random if <3)
        Check if node supply is valid and deduct after allocated
        Add shares if <3
        */
        for(uint i;i<c;i++){
            uint num;
            if(n<3){
                num=uint(keccak256(abi.encodePacked(block.timestamp+i)))%3;
                if(node[num].count<1){
                    i++;
                    continue;
                }else Share+=node[num].factor;
            }else num=n;
            _count++;
            Pack storage p=pack[_count];
            (p.node,p.owner,p.t93n)=(num,msg.sender,t93n);
            p.joined=p.claimed=block.timestamp;
            user[msg.sender].pack.push(_count);
            emit Transfer(address(0),msg.sender,_count);
        }
    }}
}
