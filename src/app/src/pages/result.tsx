import {GetServerSideProps} from "next";
import {LambdaResponse, QueryParams} from "~/core/types";
import {Calculations, Error, Loading, Tweets} from "~/core/components";
import {useEffect, useState} from "react";
import {useRouter} from "next/router";
import {twMerge} from "tailwind-merge";

const ENDPOINT = process.env.NEXT_PUBLIC_ENDPOINT;

const Result = ({query}: { query: QueryParams }) => {
    const [result, setResult] = useState<LambdaResponse>();
    const [type, setType] = useState<"frequency" | "score">("frequency");
    const router = useRouter();

    console.log(process.env)

    /* fetch from api gateway and get result */
    useEffect(() => {
        const fetchData = async () => {
            const response = await fetch(`${ENDPOINT}/?name=${query.name}&count=${query.count}&death=${query.date}`)
                .then((r) => r.json());
            if (response.data)
                setResult(response.data);
            else
                setResult(JSON.parse(response.body));
        };
        if (router.isReady)
            fetchData();
    }, []);

    if (!query || !query.name || !query.count)
        return <Error/>;

    if (!result) return <Loading name={query.name} count={query.count}/>;

    return (
        <div className="min-h-screen flex flex-col items-center text-center gap-y-10">
            <div className={"bg-indigo-500 w-full"}>
                <div className={"py-3"}>
                    <a href={"/"} className={"font-bold text-white text-3xl hover:underline"}>Sentimental Analysis</a>
                </div>
            </div>
            <div>
                <h1 className="font-bold text-6xl">
                    Results for {" "}
                    <span className={"text-indigo-500"}>{query.name}</span>
                </h1>
            </div>
            <div className={"border-t-2 border-gray-800 pt-10"}>
                <div>
                    <h2 className={"font-bold text-5xl"}>Calculated Sentiment</h2>
                </div>
                <div className={"my-5 space-x-6"}>
                    <button disabled={type === "frequency"} onClick={() => setType("frequency")}
                            className={twMerge("font-bold text-white bg-indigo-500 rounded-md px-4 py-2 w-32 transition duration-300 disabled:cursor-not-allowed", type === "frequency" && "opacity-90 bg-indigo-400")}>Frequency
                    </button>
                    <button disabled={type === "score"} onClick={() => setType("score")}
                            className={twMerge("font-bold text-white bg-indigo-500 rounded-md px-4 py-2 w-32 transition duration-300 disabled:cursor-not-allowed", type === "score" && "opacity-90 bg-indigo-400")}>Score
                    </button>
                </div>
                <div className="flex gap-x-32 mt-3">
                    <Calculations title={"Before Death"}
                                  data={type === "score" ? result.Data.Score.Pre : result.Data.Frequency.Pre}/>
                    <Calculations title={"After Death"}
                                  data={type === "score" ? result.Data.Score.Post : result.Data.Frequency.Post}/>
                </div>
            </div>
            <div className={"border-t-2 border-gray-800 pt-10"}>
                <div>
                    <h2 className={"font-bold text-5xl"}>Processed Tweets</h2>
                </div>
                <div className={"flex gap-x-32 mt-3"}>
                    <Tweets title={"Before Death"} ids={Object.keys(result.Data.Samples.Pre)}/>
                    <Tweets title={"After Death"} ids={Object.keys(result.Data.Samples.Post)}/>
                </div>
            </div>
        </div>
    );
};

export const getServerSideProps: GetServerSideProps = async (context) => {
    return {
        props: {query: context.query},
    };
};

export default Result;
