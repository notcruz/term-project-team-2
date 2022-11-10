import type {NextPage} from "next";
import {useRouter} from "next/router";
import {useState} from "react";
import {InputField} from "~/core/components";

const Home: NextPage = () => {
    const [input, setInput] = useState<string>();
    const [count, setCount] = useState<string>("50");
    const [date, setDate] = useState<string>();

    const router = useRouter();

    const handleClick = () => {
        router.push(`/result?name=${input}&count=${count}&date=${date}`);
    };

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
                <div className="mt-6 flex flex-wrap flex-col space-y-3 items-center justify-center">
                    <div className="flex flex-col gap-y-3">
                        <div className="flex flex-col items-start">
                            <InputField className={"w-96"} title={"Celebrity Name"} type={"text"}
                                        placeholder={"Queen Elizabeth II"}
                                        onChange={(e) => setInput(e?.target?.value)} value={input}/>
                        </div>
                        <div className="flex justify-center gap-x-9">
                            <div className="flex flex-col items-start">
                                <InputField className={"w-44"} title={"Tweet Count"} type={"number"} placeholder={"100"}
                                            onChange={(e) => setCount(e?.target?.value)} value={count}/>
                            </div>
                            <div className="flex flex-col items-start">
                                <InputField className={"w-44"} title={"Date of Death"} type={"date"}
                                            placeholder={"09/08/2022"}
                                            onChange={(e) => setDate(e?.target?.value)} value={date}/>
                            </div>
                        </div>
                        <div className="flex mt-3">
                            <button
                                type={"submit"}
                                disabled={!isEnabledEnabled()}
                                onClick={handleClick}
                                className="w-full text-white rounded-md bg-indigo-500 font-bold px-4 py-1.5 hover:scale-105 duration-300 transition disabled:opacity-50 disabled:hover:scale-100 disabled:hover:cursor-not-allowed"
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

export default Home;
