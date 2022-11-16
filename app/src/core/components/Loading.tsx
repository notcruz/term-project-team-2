import {useEffect, useState} from "react";

type props = {
    name: string,
    count: string
}

const Loading = ({name, count}: props) => {
    const [dots, setDots] = useState("");

    useEffect(() => {
        setTimeout(() => {
            if (dots.length === 3)
                setDots(() => "");
            else
                setDots(() => dots + ".");
        }, 1000);

    }, [dots])

    return (
        <div className="min-h-screen flex flex-col items-center justify-center">
            <h1 className={"text-indigo-500 font-bold text-5xl"}>Loading{dots}</h1>
            <h2 className={"text-lg"}>
                Querying and Analyzing {count} Tweets about {name}
            </h2>
        </div>
    );
};

export {Loading};