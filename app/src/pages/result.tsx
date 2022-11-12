import {GetServerSideProps} from "next";
import {LambdaResponse, QueryParams} from "~/core/types";
import {Calculations, Tweets} from "~/core/components";

const Result = ({query}: { query: QueryParams }) => {
    /* fetch from api gateway and get result */
    const result = getData();
    return (
        <div className="min-h-screen flex flex-col items-center text-center gap-y-10">
            <div className={"mt-20"}>
                <h1 className="font-bold text-6xl">
                    Results for {" "}
                    <span className={"text-indigo-500"}>{query.name}</span>
                </h1>
            </div>
            <div className={"border-t-2 border-gray-800 pt-10"}>
                <div>
                    <h2 className={"font-bold text-5xl"}>Calculated Sentiment</h2>
                </div>
                <div className="flex gap-x-32 mt-3">
                    <Calculations title={"Before Death"} data={result.Data.Frequency.Pre}/>
                    <Calculations title={"After Death"} data={result.Data.Frequency.Post}/>
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

const getData = (): LambdaResponse => {
    return {
        "Name": "QueenElizabethII",
        "Data": {
            "Frequency": {
                "Post": {
                    "MixedFrequency": 2,
                    "NegativeFrequency": 3,
                    "NeutralFrequency": 48,
                    "PositiveFrequency": 7
                },
                "Pre": {
                    "MixedFrequency": 0,
                    "NegativeFrequency": 1,
                    "NeutralFrequency": 47,
                    "PositiveFrequency": 13
                }
            },
            "Samples": {
                "Post": {
                    "1567931255060062208": {
                        "Mixed": "0.00022246403386816382",
                        "Negative": "0.35329583287239075",
                        "Neutral": "0.506397545337677",
                        "Positive": "0.14008411765098572",
                        "Sentiment": "NEUTRAL"
                    },
                    "1567939155119820801": {
                        "Mixed": "5.91033895034343e-05",
                        "Negative": "0.0013971611624583602",
                        "Neutral": "0.663402259349823",
                        "Positive": "0.33514150977134705",
                        "Sentiment": "NEUTRAL"
                    },
                    "1567966394825986048": {
                        "Mixed": "0.19604434072971344",
                        "Negative": "0.2504284083843231",
                        "Neutral": "0.5473015308380127",
                        "Positive": "0.006225655321031809",
                        "Sentiment": "NEUTRAL"
                    },
                    "1569785855786500100": {
                        "Mixed": "0.0005013758200220764",
                        "Negative": "0.0026199910789728165",
                        "Neutral": "0.4213942289352417",
                        "Positive": "0.5754843950271606",
                        "Sentiment": "POSITIVE"
                    },
                    "1590358470145896450": {
                        "Mixed": "8.05226227384992e-06",
                        "Negative": "0.001341549912467599",
                        "Neutral": "0.9852042198181152",
                        "Positive": "0.01344610657542944",
                        "Sentiment": "NEUTRAL"
                    }
                },
                "Pre": {
                    "1467131581605167106": {
                        "Mixed": "3.2644668408465805e-06",
                        "Negative": "0.003163931891322136",
                        "Neutral": "0.9923615455627441",
                        "Positive": "0.004471132066100836",
                        "Sentiment": "NEUTRAL"
                    },
                    "1531168553990250496": {
                        "Mixed": "3.036187081306707e-05",
                        "Negative": "0.0002953286748379469",
                        "Neutral": "0.7125144004821777",
                        "Positive": "0.28715991973876953",
                        "Sentiment": "NEUTRAL"
                    },
                    "1532452021273608205": {
                        "Mixed": "9.313548798672855e-05",
                        "Negative": "0.008329198695719242",
                        "Neutral": "0.857367217540741",
                        "Positive": "0.134210467338562",
                        "Sentiment": "NEUTRAL"
                    },
                    "1532678157865713666": {
                        "Mixed": "0.00014155141252558678",
                        "Negative": "0.0007471819408237934",
                        "Neutral": "0.7888252139091492",
                        "Positive": "0.21028609573841095",
                        "Sentiment": "NEUTRAL"
                    },
                    "1536779701829500928": {
                        "Mixed": "0.0004572782781906426",
                        "Negative": "0.08271685242652893",
                        "Neutral": "0.758970320224762",
                        "Positive": "0.15785560011863708",
                        "Sentiment": "NEUTRAL"
                    }
                }
            },
            "Score": {
                "Post": {
                    "MixedScore": "0.6659917898786565",
                    "NegativeScore": "0.14216994087643495",
                    "NeutralScore": "0.029117911539765375",
                    "PositiveScore": "0.16272035548560476"
                },
                "Pre": {
                    "MixedScore": "0.6765132008834177",
                    "NegativeScore": "0.058461436797978286",
                    "NeutralScore": "0.00047439424503834026",
                    "PositiveScore": "0.2645509668977046"
                }
            }
        }
    }
}

export default Result;
