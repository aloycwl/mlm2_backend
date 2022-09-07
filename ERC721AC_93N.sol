/***
[DEPLOYMENT] CHANGE TOKEN ADDRESSES
Remove slow down process
Change withdraw to individual
Change tokenuri
Change %
Change to 180 days
Add mergeable

IPFS IMAGE
bafybeignocrxxvzeytqvwyirsqlmhap73bnljwhjue3h7q7l6pjv4notba
bafybeibfq6g54krudacqhkpj77vkmpjgu6geeysnj6mbk24duippgvfjq4
bafybeibraambmefp6l3uzjb7hq7qp75ixvrefrbggnezzmmq3pzckm77xa
bafybeidcipg6rpcochekmgvd7ilibbl3o73qmtkhohzwvh2b5gdrnqk6xi
bafybeigkfxele4tlfqynuz6sqq75mv2zgckxv6vmlrqeuba2ocazvb7t34
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
    function name()external view returns(string memory);
    function symbol()external view returns(string memory);
    function tokenURI(uint)external view returns(string memory);
}
interface IERC20{function transferFrom(address,address,uint)external;}
interface ISWAP{function getAmountsOut(uint,address,address)external view returns(uint);}
contract ERC721AC_93N is IERC721,IERC721Metadata{
    /*
    Emit status: 0-in USDT, 1-stake, 2-out
    mapping _A: 0-owner, 1-usdt, 2-93n, 3-swap, 4-tech
    Require all the addresses to get live price from PanCakeSwap
    */
    modifier onlyOwner(){require(msg.sender==_A[0]);_;}
    event Payout(address indexed from,address indexed to,uint amount,uint indexed status);
    struct User{
        address upline;
        address[]downline;
        uint[]packages;
    }
    struct Packages{
        uint wallet;
        uint deposit;
        uint tokens;
        uint claimed;
        uint joined;
        uint months;
        address owner;
    }
    uint public Split=1;
    uint private _count;
    uint[]public _counts;
    mapping(uint=>Packages)public Pack;
    mapping(uint=>address)private _A;
    mapping(uint=>address)private _tokenApprovals;
    mapping(address=>User)private user;
    mapping(address=>mapping(address=>bool))private _operatorApprovals;
    constructor(address USDT,address T93N,address Swap, address Tech){
        (_A[0]=user[msg.sender].upline=msg.sender,_A[1]=USDT,_A[2]=T93N,_A[3]=Swap,_A[4]=Tech);
        /*
        Add permanent packages for 0 and 4 to bypass payment checking
        */
        user[_A[0]].packages.push(0);
        user[_A[4]].packages.push(0);
    }
    function supportsInterface(bytes4 a)external pure returns(bool){
        return a==type(IERC721).interfaceId||a==type(IERC721Metadata).interfaceId;
    }
    function ownerOf(uint a)public view override returns(address){
        return Pack[a].owner;
    }
    function owner()external view returns(address){
        return _A[0];
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
    function safeTransferFrom(address a,address b,uint c)external override{
        transferFrom(a,b,c);
    }
    function safeTransferFrom(address a,address b,uint c,bytes memory)external override{
        transferFrom(a,b,c);
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
        Pack[a].deposit>1e22?"bafybeibtgqc26sv74erbgm6grtivjvfglffol4an4nvhorbv3ljgamg4uu/black":
        Pack[a].deposit>1e21?"bafybeiaubm73azo4beh7am63wkua3zj4ijgy6n4gjc7spe3okwuxrt66t4/gold":
        "bafybeigjnlikmsm3mjvhx6ijk26bedd5lrvi3yfjlwgytzzj3h5ao6i57i/red",
        ".json"));
    }
    function transferFrom(address a,address b,uint c)public override{unchecked{
        /*
        Entire user will be duplicated to the new user
        The old user will be deleted
        */
        require(a==Pack[c].owner||getApproved(c)==a||isApprovedForAll(Pack[c].owner,a));
        (_tokenApprovals[c],Pack[c].owner)=(address(0),b);
        user[b].packages.push(c);
        popPackages(a,c);
        emit Approval(Pack[c].owner,b,c);
        emit Transfer(a,b,c);
    }}

    function getUplines(address d0)private view returns(address d1,address d2,address d3){
        (d1=user[d0].upline,d2=user[d1].upline,d3=user[d2].upline);
    }
    function popPackages(address a,uint b)private{unchecked{
        for(uint h=0;h<user[a].packages.length;h++)if(user[a].packages[h]==b){
            user[a].packages[h]=user[a].packages[user[a].packages.length-1];
            user[a].packages.pop();
        }
    }}
    function _payment(address con,address from,address usr,address to,uint amt,uint status)private{
        /*
        Custom connection to the various token address
        Emit events for history
        */
        IERC20(con).transferFrom(from,to,amt);
        emit Payout(usr,to,amt,status);
    }
    function _payment4(address con,address from,address usr,address[4]memory to,uint[4]memory amt,uint status)private{unchecked{
        /*
        Payout loop of 4 iterations
        Exit fuction (for payment of USDT) if no address found
        */
        for(uint i=0;i<4;i++){
            if(to[i]==address(0))return;
            if(user[to[i]].packages.length>0)_payment(con,from,usr,to[i],amt[i],status);
        }
    }}
    function Deposit(address referral,uint amount,uint months)external{unchecked{
        require(months==3||months==6||months==9);
        require(amount>=1e20);
        /*
        Get price from our own swap
        Issue the number of tokens in equivalent to USDT
        Initiate new user
        */
        _count++;
        (uint tokens,Packages storage p)=(ISWAP(_A[3]).getAmountsOut(amount,_A[1],_A[2]),Pack[_count]);
        (p.months=months,p.wallet=p.tokens=tokens,p.deposit=amount,
            p.owner=msg.sender,p.joined=p.claimed=block.timestamp);
        _counts.push(_count);
        user[msg.sender].packages.push(_count);
        emit Transfer(address(0),msg.sender,_count);
        /*
        Only set upline and downline when user is new
        If no address, referral is not existing member or referral is ownself, set referral as admin
        */
        if(user[msg.sender].upline==address(0)){
            referral=referral==address(0)||user[referral].upline==address(0)||referral==msg.sender?_A[0]:referral;
            user[msg.sender].upline=referral;
            user[referral].downline.push(msg.sender);
        }
        /*
        Uplines & tech to get USDT 5%, 3%, 2% & tech 1%
        USDT to be prorated according to months
        Getting uplines for payout
        */
        (address d1,address d2,address d3)=getUplines(msg.sender); 
        _payment(_A[1],msg.sender,msg.sender,address(this),amount,0);
        uint a2=amount*months/9;
        _payment4(_A[1],address(this),msg.sender,[d1,d2,d3,_A[4]],[a2/20,a2*3/100,a2/50,amount/100],0);
    }}
    function Staking()external{unchecked{
        /*
        Go through every contract and pay them and their upline accordingly
        2628e3 seconds a month
        */
        for(uint j=0;j<_counts.length;j++){
            (uint i,uint s)=(_counts[j],1);
            Packages memory p=Pack[i];
            if(p.wallet>0){
                (address d0,uint expiry,uint amt,uint prm)=(p.owner,p.joined+p.months*2628e3,0,1);
                (address d1,address d2,address d3)=getUplines(msg.sender); 
                /*
                Token payment direct to wallet in term of 15%, 10%, 5%
                Update user's last claim if claimed
                */
                if(expiry>p.claimed)(amt=((expiry>block.timestamp?block.timestamp:expiry)-p.claimed)*
                    p.wallet*(p.months/3+1)/2628e5,Pack[i].claimed=block.timestamp);
                else{
                    /*
                    Contract auto expire upon due, getting amount from deposit x rate
                    Release 34%,34%,32% and split if set
                    Delete the contract upon last payment
                    */
                    (amt,prm,s)=(p.tokens*17/50/Split,p.months/9,2);
                    if(amt>=p.wallet){
                        amt=p.wallet;
                        delete Pack[i];
                        popPackages(p.owner,i);
                        emit Transfer(p.owner,address(0),i); 
                    }else Pack[i].wallet-=amt;
                }
                _payment4(_A[2],address(this),d0,[d0,d1,d2,d3],[amt,amt/20*prm,amt/10*prm,amt*3/20*prm],s);
            }
        }
    }}
    function Cleanup()external{unchecked{
        uint len=_counts.length;
        for(uint i=0;i<_counts.length;i++)if(Pack[_counts[i]].wallet==0){
            (_counts[i]=_counts[len-1],len--,i--);
            _counts.pop();
        }
    }}
    function SetSplit(uint num)external onlyOwner{
        /*
        Modifying the split to slow down the withdrawal
        */
        Split=num;
    } 
    function SetSWAPAddress(address a)external onlyOwner{
        /*
        Update live price address when listed
        */
        _A[3]=a;
    }
    function getDownlines(address a)external view returns(address[]memory lv1,uint lv2,uint lv3){unchecked{
        lv1=user[a].downline;
        /*
        Loop through all level 2 and level 3 downlines
        Create new array counts
        Set length and reset variables for later use
        */
        for(uint i=0;i<lv1.length;i++){
            address[]memory c1=user[lv1[i]].downline;
            lv2+=c1.length;
            for(uint j=0;j<c1.length;j++)lv3+=user[c1[j]].downline.length;
        }
    }}
    function getUserPackages(address a)external view returns(uint[]memory){
        return user[a].packages;
    }
}

//0x0000000000000000000000000000000000000000
//1000000000000000000000
