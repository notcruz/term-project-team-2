import type {NextPage} from "next";
import {useRouter} from "next/router";
import {useEffect, useState} from "react";
import {InputField} from "~/core/components";
import {WikipediaResult} from "~/core/types";

const Home: NextPage = () => {
    const [suggested, setSuggested] = useState<WikipediaResult>();
    const [input, setInput] = useState<string>("");
    const [count, setCount] = useState<string>("50");
    const [date, setDate] = useState<string>();

    const [result, setResult] = useState<WikipediaResult[]>([]);

    /* refreshes components, should probably fix */
    useEffect(() => {
        const delayDebounceFn = setTimeout(() => {
            fetch(getQueryURL(input), {
                headers: {"accept": "application/sparql-results+json"},
            })
                .then((response) => response.json())
                .then((json) =>
                    setResult((json.results.bindings as WikipediaResult[])
                        .filter((r) => (r.RIP && r.RIP.value >= "2006-3-21") || (!r.RIP && r.DR))
                    )
                );
        }, 750)

        return () => clearTimeout(delayDebounceFn)
    }, [input])

    useEffect(() => {
        if (suggested !== undefined) {
            setInput(suggested.itemLabel.value);
            if (suggested.RIP?.value) {
                setDate(parseDate(suggested.RIP.value));
            }
        }
    }, [suggested])

    const router = useRouter();

    const handleClick = () => {
        router.push(`/result?name=${input}&count=${count}&date=${date}`);
    };

    const handleChange = () => {

    }

    const isEnabledEnabled = () => {
        return input && count && date;
    };

    return (
        <div className="min-h-screen flex flex-col items-center justify-center text-center">
            <div>
                <div>
                    <h1 className="font-bold text-5xl text-indigo-500">
                        Sentimental Analysis v2
                    </h1>
                </div>
                <div>
                    <p className="text-lg">
                        Check how people feel about a celebrity before and after their
                        passing!
                    </p>
                </div>
                <div className="mt-6 flex gap-x-6">
                    <div className={"flex flex-col border border-gray-300 shadow-md drop-shadow rounded-md w-80 h-96"}>
                        <div className={"py-3 border-b border-gray-300"}>
                            <h2 className={"font-bold text-xl"}>Suggested Individuals</h2>
                        </div>
                        <div className={"overflow-y-auto flex flex-col flex-1"}>
                            {
                                (!result || result.length == 0) && (
                                    <div className={"mt-32"}>
                                        <p>No results found!</p>
                                    </div>
                                )
                            }
                            {
                                result.map((result: WikipediaResult) => {
                                    return (
                                        <button key={result.item.value} onClick={() => setSuggested(result)}
                                                className={"py-3 px-5 w-full transition duration-300 hover:bg-indigo-500 hover:text-white"}>
                                            <div>
                                                <p className={"font-semibold"}>{result.itemLabel.value}</p>
                                            </div>
                                            <div>
                                                <p className={"leading-none"}>{result.itemDescription.value}</p>
                                            </div>
                                        </button>
                                    )
                                })
                            }
                        </div>
                    </div>
                    <div className="flex flex-col gap-y-3 flex-1 w-64">
                        <div className="flex flex-col items-start">
                            <InputField className={"w-full"} title={"Celebrity Name"} type={"text"}
                                        placeholder={"Queen Elizabeth II"}
                                        onChange={(e) => setInput(e?.target?.value)} value={input}/>
                        </div>
                        <div className="flex flex-col items-start">
                            <InputField className={"w-full"} title={"Tweet Count"} type={"number"}
                                        placeholder={"100"}
                                        onChange={(e) => setCount(e?.target?.value)} value={count}/>
                        </div>
                        <div className="flex flex-col items-start">
                            <InputField className={"w-full"} title={"Date of Death"} type={"date"}
                                        placeholder={"09/08/2022"}
                                        onChange={(e) => setDate(e?.target?.value)} value={date}/>
                        </div>
                        <div className="flex mt-3">
                            <button
                                type={"submit"}
                                disabled={!isEnabledEnabled()}
                                onClick={handleClick}
                                className="w-full shadow-md drop-shadow text-white rounded-md bg-indigo-500 font-bold px-4 py-1.5 hover:scale-105 duration-300 transition disabled:opacity-50 disabled:hover:scale-100 disabled:hover:cursor-not-allowed"
                            >
                                Search
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
};

const parseDate = (s: string) => {
    const parsed = Date.parse(s);
    return new Date(parsed).toISOString().slice(0, 10);
}

const getQueryURL = (query: string) => {
    return `https://query.wikidata.org/sparql?query=SELECT%20distinct%20%3Fitem%20%3FitemLabel%20%3FitemDescription%20(SAMPLE(%3FDR)%20as%20%3FDR)%20(SAMPLE(%3FRIP)%20as%20%3FRIP)%20(SAMPLE(%3Fimage)as%20%3Fimage)%20(SAMPLE(%3Farticle)as%20%3Farticle)%20WHERE%20%7B%0A%20%20%3Fitem%20wdt%3AP31%20wd%3AQ5.%0A%20%20%3Fitem%20%3Flabel%20%22${encodeURIComponent(query)}%22%40en.%20%20%0A%20%20%3Farticle%20schema%3Aabout%20%3Fitem%20.%0A%20%20%3Farticle%20schema%3AinLanguage%20%22en%22%20.%0A%20%20%3Farticle%20schema%3AisPartOf%20%3Chttps%3A%2F%2Fen.wikipedia.org%2F%3E.%20%20%0A%20%20OPTIONAL%7B%3Fitem%20wdt%3AP569%20%3FDR%20.%7D%20%23%20P569%20%3A%20Date%20of%20birth%0A%20%20OPTIONAL%7B%3Fitem%20wdt%3AP570%20%3FRIP%20.%7D%20%20%20%20%20%23%20P570%20%3A%20Date%20of%20death%0A%20%20OPTIONAL%7B%3Fitem%20wdt%3AP18%20%3Fimage%20.%7D%20%20%20%20%20%23%20P18%20%3A%20image%20%20%0A%0A%20%20SERVICE%20wikibase%3Alabel%20%7B%20bd%3AserviceParam%20wikibase%3Alanguage%20%22en%22.%20%7D%20%20%20%20%0A%7D%0AGROUP%20BY%20%3Fitem%20%3FitemLabel%20%3FitemDescription`;
}
export default Home;
