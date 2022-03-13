// constants
import Web3EthContract from "web3-eth-contract";
import Web3 from "web3";
import Web3Modal from "web3modal";
import CoinbaseWalletSDK from "@coinbase/wallet-sdk";
import WalletConnectProvider from "@walletconnect/web3-provider";
import { fetchData } from "../data/dataActions";

 const  INFURA_ID = "116174764d354240a64cecda70ce8399"
 const providerOptions = {
  walletlink: {
    package: CoinbaseWalletSDK, //coinbase wallet
    options: {
      appName: "Timepiece Ape",
      infuraId: INFURA_ID
    }
  },
  walletconnect: {
    package: WalletConnectProvider, // walletconnect
    options: {
      infuraId: INFURA_ID
    }
  }
}
const connectRequest = () => {
  return {
    type: "CONNECTION_REQUEST",
  };
};

const connectSuccess = (payload) => {
  return {
    type: "CONNECTION_SUCCESS",
    payload: payload,
  };
};

const connectFailed = (payload) => {
  return {
    type: "CONNECTION_FAILED",
    payload: payload,
  };
};

const updateAccountRequest = (payload) => {
  return {
    type: "UPDATE_ACCOUNT",
    payload: payload,
  };
};

export const connect = () => {
  return async (dispatch) => {
    dispatch(connectRequest());
    const abiResponse = await fetch("/config/abi.json", {
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
      },
    });
    const abi = await abiResponse.json();
    const configResponse = await fetch("/config/config.json", {
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
      },
    });
    const CONFIG = await configResponse.json();
      try {
        // const { ethereum } = window;
        const web3Modal = new Web3Modal({
          network: "mainnet", // optional
          cacheProvider: true, // optional
          providerOptions // required
        });
        
        const provider = await web3Modal.connect();
        
        const web3 = new Web3(provider);
        Web3EthContract.setProvider(provider);
        
        let networkId;
        let accounts;
      

        if (provider.isCoinbaseWallet) {
          networkId = await provider.getChainId()
          accounts = await provider._addresses
        } 
        else if (provider.connected) {
          networkId = await provider.chainId
          accounts = await provider.accounts
        }
        else {
          accounts = await provider.request({
            method: "eth_requestAccounts",
          });
          networkId = await provider.request({
            method: "net_version",
          });
        }
             
        if (networkId == CONFIG.NETWORK.ID) {
          const SmartContractObj = new Web3EthContract(
            abi,
            CONFIG.CONTRACT_ADDRESS
          );
          dispatch(
            connectSuccess({
              account: accounts[0],
              smartContract: SmartContractObj,
              web3: web3
            })
          );
          // Add listeners start
          provider.on("accountsChanged", (accounts) => {
            dispatch(updateAccount(accounts[0]));
          });
          // provider.on("chainChanged", () => {
          //   window.location.reload();
          // });
          // Add listeners end
        } else {
          dispatch(connectFailed(`Change network to ${CONFIG.NETWORK.NAME}.`));
        }
      } catch (err) {
        dispatch(connectFailed("Something went wrong."));
        console.log(err)
      } 
  };
};

export const updateAccount = (account) => {
  return async (dispatch) => {
    dispatch(updateAccountRequest({ account: account }));
    dispatch(fetchData(account));
  };
};
