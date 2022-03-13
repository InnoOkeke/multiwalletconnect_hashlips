// SPDX-License-Identifier: GPL-3.0

//Developer : FazelPejmanfar , Twitter :@Pejmanfarfazel



pragma solidity >=0.7.0 <0.9.0;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract TimepieceApeSociety is ERC721A, Ownable {
  using Strings for uint256;

  string public baseURI;
  string public baseExtension = ".json";
  string public notRevealedUri;
  uint256 public cost = 0.2 ether;
  uint256 public maxSupply = 7777;
  uint256 public MaxperWallet = 10;
  uint256 public MaxperWalletWl = 1;
  uint256 public MaxperTxWl = 1;
  uint256 public maxpertx = 10 ; // max mint per tx
  bool public paused = false;
  bool public revealed = false;
  bool public preSale = true;
  bool public publicSale = false;
  bytes32 public merkleRoot = 0x7d47dd9d8fd212164c3a9e8d23f89077455d468a3e287590d7f66b9c5ed8dcfd;

  constructor(
    string memory _initBaseURI,
    string memory _initNotRevealedUri
  ) ERC721A("Timepiece Ape Society", "TAS") {
    setBaseURI(_initBaseURI);
    setNotRevealedURI(_initNotRevealedUri);
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }
      function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }

  // public
  function mint(uint256 tokens) public payable {
    require(!paused, "TAS: oops contract is paused");
    require(publicSale, "TAS: Sale Hasn't started yet");
    uint256 supply = totalSupply();
    uint256 ownerTokenCount = balanceOf(_msgSender());
    require(tokens > 0, "TAS: need to mint at least 1 NFT");
    require(tokens <= maxpertx, "TAS: max mint amount per tx exceeded");
    require(supply + tokens <= maxSupply, "TAS: We Soldout");
    require(ownerTokenCount + tokens <= MaxperWallet, "TAS: Max NFT Per Wallet exceeded");
    require(msg.value >= cost * tokens, "TAS: insufficient funds");

      _safeMint(_msgSender(), tokens);
    
  }
/// @dev presale mint for whitelisted
    function presalemint(uint256 tokens, bytes32[] calldata merkleProof) public payable  {
    require(!paused, "TAS: oops contract is paused");
    require(preSale, "TAS: Presale Hasn't started yet");
    require(MerkleProof.verify(merkleProof, merkleRoot, keccak256(abi.encodePacked(msg.sender))), "TAS: You are not Whitelisted");
    uint256 supply = totalSupply();
    uint256 ownerTokenCount = balanceOf(_msgSender());
    require(ownerTokenCount + tokens <= MaxperWalletWl, "TAS: Max NFT Per Wallet exceeded");
    require(tokens > 0, "TAS: need to mint at least 1 NFT");
    require(tokens <= MaxperTxWl, "TAS: max mint per Tx exceeded");
    require(supply + tokens <= maxSupply, "TAS: Whitelist MaxSupply exceeded");
    require(msg.value >= cost * tokens, "TAS: insufficient funds");

      _safeMint(_msgSender(), tokens);
    
  }




  /// @dev use it for giveaway and mint for yourself
     function gift(uint256 _mintAmount, address destination) public onlyOwner {
    require(_mintAmount > 0, "need to mint at least 1 NFT");
    uint256 supply = totalSupply();
    require(supply + _mintAmount <= maxSupply, "max NFT limit exceeded");

      _safeMint(destination, _mintAmount);
    
  }

  


  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721AMetadata: URI query for nonexistent token"
    );
    
    if(revealed == false) {
        return notRevealedUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  //only owner
  function reveal(bool _state) public onlyOwner {
      revealed = _state;
  }

  function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }
  
  function setMaxPerWallet(uint256 _limit) public onlyOwner {
    MaxperWallet = _limit;
  }

    function setWlMaxPerWallet(uint256 _limit) public onlyOwner {
    MaxperWalletWl = _limit;
  }

  function setmaxpertx(uint256 _maxpertx) public onlyOwner {
    maxpertx = _maxpertx;
  }

    function setWLMaxpertx(uint256 _wlmaxpertx) public onlyOwner {
    MaxperTxWl = _wlmaxpertx;
  }
  
  function setCost(uint256 _newCost) public onlyOwner {
    cost = _newCost;
  }

    function setMaxsupply(uint256 _newsupply) public onlyOwner {
    maxSupply = _newsupply;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }
  
  function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
    notRevealedUri = _notRevealedURI;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }

    function togglepreSale(bool _state) external onlyOwner {
        preSale = _state;
    }

    function togglepublicSale(bool _state) external onlyOwner {
        publicSale = _state;
    }
  
 
  function withdraw() public payable onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success);
  }
}