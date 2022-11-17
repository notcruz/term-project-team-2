import '../styles/globals.css'
import type {AppProps} from 'next/app'
import {ArcElement, Chart, Legend, RadialLinearScale, Tooltip} from "chart.js";

Chart.register(RadialLinearScale, ArcElement, Tooltip, Legend);

function MyApp({Component, pageProps}: AppProps) {
    return <Component {...pageProps} />
}

export default MyApp
