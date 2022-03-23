pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

//Ropsten address:
//0xfCE80acB325de68E3FA3b383B81C8255A6E7F379

contract TShirtFactory is ERC721 {
    constructor() ERC721("NFTee", "NFT") {}

    event NewTShirt(uint256 tShirtId, string name, string imgUrl);

    struct TShirt {
        string name;
        string imgUrl;
    }

    TShirt[] public tShirts;

    mapping(uint256 => address) public tShirtToOwner;
    mapping(address => uint256) ownerTShirtCount;

    modifier onlyOwnerOf(uint256 _tShirtId) {
        require(msg.sender == tShirtToOwner[_tShirtId]);
        _;
    }

    function _createTShirt(string memory _name) internal {
        string memory imgUrl = _generateRandomImgUrl(4000);
        tShirts.push(TShirt(_name, imgUrl));
        uint256 id = tShirts.length - 1;
        tShirtToOwner[id] = msg.sender;
        ownerTShirtCount[msg.sender] = ownerTShirtCount[msg.sender]++;
        _mint(msg.sender, id);
        emit NewTShirt(id, _name, imgUrl);
        emit Transfer(address(0x0), msg.sender, id);
    }

    function _generateRandomImgUrl(uint256 res)
        private
        view
        returns (string memory)
    {
        uint256 rand = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp +
                        block.difficulty +
                        ((
                            uint256(keccak256(abi.encodePacked(block.coinbase)))
                        ) / (block.timestamp)) +
                        block.gaslimit +
                        ((uint256(keccak256(abi.encodePacked(msg.sender)))) /
                            (block.timestamp)) +
                        block.number
                )
            )
        );

        return
            string(
                abi.encodePacked(
                    "https://picsum.photos/seed/picsum/",
                    rand,
                    "/",
                    res
                )
            );
    }

    function createRandomTShirt(string memory _name) public {
        require(
            ownerTShirtCount[msg.sender] < 10,
            "You are only allowed to create T-shirts if you have less than 10."
        );
        _createTShirt(_name);
    }

    function getTShirtsByOwner(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        uint256[] memory result = new uint256[](ownerTShirtCount[_owner]);
        uint256 index = 0;
        for (uint256 i = 0; i < tShirts.length; i++) {
            if (tShirtToOwner[i] == _owner) {
                result[index] = i;
                index++;
            }
        }
        return result;
    }

    //ERC721 functions
    mapping(uint256 => address) tShirtApprovals;

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override {
        require(
            ERC721.ownerOf(tokenId) == from,
            "ERC721: transfer from incorrect owner"
        );
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        ownerTShirtCount[from] -= 1;
        ownerTShirtCount[to] += 1;
        tShirtToOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);

        _afterTokenTransfer(from, to, tokenId);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public override {
        require(
            tShirtToOwner[_tokenId] == msg.sender ||
                tShirtApprovals[_tokenId] == msg.sender
        );
        _transfer(_from, _to, _tokenId);
    }

    function approve(address _approved, uint256 _tokenId)
        public
        override
        onlyOwnerOf(_tokenId)
    {
        tShirtApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }
}
