import React, {useState} from 'react';
import './App.css';
import NFTCarousel from './components/NFTCarousel'


function App() {
    const [index, setIndex] = useState(0);
    return (
        <div>
        <NFTCarousel index={index} setIndex={setIndex}/>
        </div>
    );
}

export default App;