import React, {useState, useEffect} from 'react';
import 'bootstrap/dist/css/bootstrap.css';
import Carousel from 'react-bootstrap/Carousel';
import contract from '../TShirtFactory.json';
import { ethers } from 'ethers';



const contractAddress = "0xfCE80acB325de68E3FA3b383B81C8255A6E7F379";
const abi = contract.abi;

export default function NFTCarousel({index,setIndex}) {

    const handleSelect = (selectedIndex, e) => {
      setIndex(selectedIndex);
    };

    const [currentAccount, setCurrentAccount] = useState(null);

  const checkWalletIsConnected = async () => {
    const { ethereum } = window;

    if (!ethereum) {
      console.log("Make sure you have Metamask installed!");
      return;
    } else {
      console.log("Wallet exists! We're ready to go!")
    }

    const accounts = await ethereum.request({ method: 'eth_accounts' });

    if (accounts.length !== 0) {
      const account = accounts[0];
      console.log("Found an authorized account: ", account);
      setCurrentAccount(account);
    } else {
      console.log("No authorized account found");
    }
  }

  const connectWalletHandler = async () => {
    const { ethereum } = window;

    if (!ethereum) {
      alert("Please install Metamask!");
    }

    try {
      const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
      console.log("Found an account! Address: ", accounts[0]);
      setCurrentAccount(accounts[0]);
    } catch (err) {
      console.log(err)
    }
  }

  const mintNftHandler = async () => {
    try {
      const { ethereum } = window;

      if (ethereum) {
        const provider = new ethers.providers.Web3Provider(ethereum);
        const signer = provider.getSigner();
        const nftContract = new ethers.Contract(contractAddress, abi, signer);

        alert("Initialize payment");
        let nftTxn = await nftContract.createRandomTShirt("Mid");

        alert("Mining... please wait");
        await nftTxn.wait();

        alert(`Mined, see transaction: https://rinkeby.etherscan.io/tx/${nftTxn.hash}`);

      } else {
        alert("Ethereum object does not exist");
      }

    } catch (err) {
      alert("error" +err);
    }
  }

  const connectWalletButton = () => {
    return (
      <button onClick={connectWalletHandler} className='cta-button connect-wallet-button'>
        Connect Wallet
      </button>
    )
  }

  const mintNftButton = () => {
    return (
      <button onClick={mintNftHandler} className='cta-button mint-nft-button'>
        Mint NFT
      </button>
    )
  }

  useEffect(() => {
    checkWalletIsConnected();
  }, [])


  
    return (
        <div style={{ display: 'block', width: "100%", padding: 30 }}>
        {currentAccount ? mintNftButton() : connectWalletButton()}
      <Carousel activeIndex={index} onSelect={handleSelect}>
        <Carousel.Item>
          <img
            className="d-block w-100"
            src="https://media.geeksforgeeks.org/wp-content/uploads/20210425122739/2-300x115.png"
            alt="First slide"
          />
          <Carousel.Caption>
            <p>Nulla vitae elit libero, a pharetra augue mollis interdum.</p>
          </Carousel.Caption>
        </Carousel.Item>
        <Carousel.Item>
          <img
            className="d-block w-100"
            src="https://media.geeksforgeeks.org/wp-content/uploads/20210425122739/2-300x115.png"
            alt="First slide"
          />
          <Carousel.Caption>
            <h3>First slide label</h3>
            <p>Nulla vitae elit libero, a pharetra augue mollis interdum.</p>
          </Carousel.Caption>
        </Carousel.Item>
      </Carousel>
      </div>
    );
  }