/***
Purchase: check upline eligible to matching
Purchase: issue tokens to upline?
Withdrawal: stacking give to upline too?
***/
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
    function name()external view returns(string calldata);
    function symbol()external view returns(string calldata);
    function tokenURI(uint)external view returns(string calldata);
}
interface IERC20{
    function transferFrom(address,address,uint)external;
    function balanceOf(address)external view returns(uint256);
}
interface ISWAP{
    function getAmountsOut(uint,address,address)external view returns(uint);
}
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
        uint minted;
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
    mapping(address=>User)public user;
    mapping(uint=>Node)private node;
    mapping(uint=>Pack)public pack;
    mapping(uint=>address)private _tokenApprovals;
    mapping(address=>mapping(address=>bool))private _operatorApprovals;
    uint constant private P=10000; //Percentage
    uint[3]private refA=[500,300,200];
    uint[3]private refB=[500,500,1e3];
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
        (node[0].count,node[0].price,node[0].factor,node[0].uri)=
            (25e4,node[1].price=node[2].price=1e20,1,"bAXSCgPa1KkU9AABScYju6VxVy8F9NdPfUJxM3NsMWQt");
        (node[1].count,node[1].factor,node[1].uri)=(15e4,2,"XC9ZBbRaKSVqx6bqvpBtCRgySWju2hnbT5x9sRZhheZw");
        (node[2].count,node[2].factor,node[2].uri)=(1e5,3,"Z1vRU2Yf6BfZCdpTVRPzXUtoxAsxtPVjFk9aK2JxTtP2");
        (node[3].count,node[3].price,node[3].period,node[3].factor,node[3].uri)=
            (3e4,1e21,15552e3,1,"cUpTRu4AehAoGLGcYCEaCz9hR6bdB8shVmnmk5nNenyy");
        (node[4].count,node[4].price,node[4].period,node[4].factor,node[4].uri)=
            (1e4,5e21,31104e3,7,"bLKzHK2fCe4T8mdZ3NMk9yY4JwwNgS8gJeCfCEUmpkh7");
    }
    function supportsInterface(bytes4 a)external pure returns(bool){
        return a==type(IERC721).interfaceId||a==type(IERC721Metadata).interfaceId;
    }
    function approve(address a,uint b)external override{
        require(msg.sender==ownerOf(b)||isApprovedForAll(ownerOf(b),msg.sender));
        _tokenApprovals[b]=a;emit Approval(ownerOf(b),a,b);
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
        return user[a].pack.length;
    }
    function tokenURI(uint a)external view override returns(string memory){
        return string(abi.encodePacked("ipfs://Qm",node[a].uri));
    }
    function safeTransferFrom(address a,address b,uint c)external override{
        transferFrom(a,b,c);
    }
    function safeTransferFrom(address a,address b,uint c,bytes calldata)external override{
        transferFrom(a,b,c);
    }
    function transferFrom(address a,address b,uint c)public override{unchecked{
        /*
        Entire user will be duplicated to the new user
        The old user will be deleted
        */
        require(a==pack[c].owner||getApproved(c)==a||isApprovedForAll(pack[c].owner,a));
        (_tokenApprovals[c],pack[c].owner)=(address(0),b);
        user[b].pack.push(c);
        popPackages(a,c);
        emit Approval(pack[c].owner,b,c);
        emit Transfer(a,b,c);
    }}

    function popPackages(address a,uint p)private{unchecked{
        /*
        To remove a package from user
        Can be used for transfer, merging or expiry
        */
        for(uint i;i<user[a].pack.length;i++)if(user[a].pack[i]==p){
            user[a].pack[i]=user[a].pack[user[a].pack.length-1];
            user[a].pack.pop();
        }
    }}
    function mintNFT(uint n)private{unchecked{
        _count++;
        node[n].count--;
        emit Transfer(address(0),msg.sender,_count);
    }}
    function getUplines(address d0)private view returns(address d1,address d2,address d3){
        /*
        Returns the upline for the address
        d1 being the direct and d3 is the furthest
        If there is no d2 or d3, the upline is the last available one
        */
        (d1=user[d0].upline,d2=user[d1].upline,d3=user[d2].upline);
    }
    function getDownlines(address a)external view returns(address[]memory lv1,uint lv2,uint lv3){unchecked{
        /*
        Loop through all level 2 and level 3 downlines
        Create new array counts
        Set length and reset variables 
        */
        lv1=user[a].downline;
        for(uint i=0;i<lv1.length;i++){
            address[]memory c1=user[lv1[i]].downline;
            lv2+=c1.length;
            for(uint j=0;j<c1.length;j++)lv3+=user[c1[j]].downline.length;
        }
    }}
    function checkMatchable(address a)private view returns(uint){unchecked{
        /*
        Loop through the user's entire pack
        Select check if there is any Super or Asset node
        Return 1 if found and 0 if isn't
        */
        for(uint i;i<user[a].pack.length;i++)if(pack[user[a].pack[i]].node>2)return 1;
        return 0;
    }}
    function Withdraw()external{
        /*
        Calculate how much tbe sender should be getting
        Loop through all existing nodes and calculate since last claimed
        Get the expiry and issue percentage when expired
        */
        uint x;
        uint[]memory p=user[msg.sender].pack;
        for(uint i;i<p.length;i++){
            uint z;
            if(pack[user[msg.sender].pack[i]].node>2){
                uint expiry=pack[p[i]].minted+node[p[i]].period;
                if(expiry<block.timestamp)
                    x+=pack[p[i]].t93n*node[p[i]].factor/P*(block.timestamp-pack[p[i]].claimed)/86400;
                else{
                    if(expiry+2628e3>block.timestamp&&expiry+2628e3>pack[p[i]].claimed)x+=pack[p[i]].t93n*2/5;
                    if(expiry+5256e3>block.timestamp&&expiry+5256e3>pack[p[i]].claimed)x+=pack[p[i]].t93n*3/10;
                    if(expiry+7884e3>block.timestamp&&expiry+5256e3>pack[p[i]].claimed){
                        x+=pack[p[i]].t93n*3/10;
                        popPackages(msg.sender,p[i]);
                        emit Transfer(msg.sender,address(0),p[i]);
                        z=1;
                    }
                }
            }
            if(z<1)pack[p[i]].claimed=block.timestamp;
        }
        IERC20(_A[2]).transferFrom(address(this),msg.sender,x);
    }
    function getNodes()external view returns(uint[]memory n){unchecked{
        /*
        Return the current user nodes for selection to merge
        */
        n=user[msg.sender].pack;
    }}
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
            mintNFT(num);
            Pack storage p=pack[_count];
            (p.node,p.owner,p.t93n,p.minted)=(num,msg.sender,t93n,p.claimed=block.timestamp);
            user[msg.sender].pack.push(_count);
        }
    }}
    function Merging(uint[]calldata nfts)external{
        require(nfts.length==10||nfts.length==50,"Incorrect nodes count");
        /*
        Combines nodes to Super or Asset
        Loop through user's club - pop it and remove shares
        Mint new nodes and update
        */
        for(uint i;i<nfts.length;i++){
            require(pack[nfts[i]].node<3,"Only club nodes can merge");
            popPackages(msg.sender,nfts[i]);
            Share-=node[nfts[i]].factor;
            emit Transfer(msg.sender,address(0),nfts[i]);
        }
        mintNFT(nfts.length==10?3:4);
    }
} 
