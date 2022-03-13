//Merkle
const [accounts, setAccounts] = useState([]);

useEffect(() => {
  requestAccount();
}, [])


const { MerkleTree } = require('merkletreejs');
const keccak256 = require('keccak256');

useEffect(() => {
  requestAccount();
}, [])

async function requestAccount() {
  if(typeof window.ethereum !== 'undefined') {
    let accounts = await window.ethereum.request({ method: 'eth_requestAccounts' })
    setAccounts(accounts);
  }
}

let Whitelist = require('./Accounts.json');
const leafNodes = Whitelist.map(addr => keccak256(addr));
const merkleTree = new MerkleTree(leafNodes, keccak256, { sortPairs: true});
const rootHash = merkleTree.getRoot();
const claimingAddress = keccak256(accounts[0]);
const hexProof = merkleTree.getHexProof(claimingAddress);
//Merkle