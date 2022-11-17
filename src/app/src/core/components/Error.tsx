const Error = () => {
    return (
        <div className="min-h-screen flex flex-col items-center justify-center">
            <h1 className={"font-bold text-5xl text-indigo-500"}>
                Missing a name and/or count
            </h1>
            <h2 className={"text-lg"}>
                Go back to <a href={"/"} className={"font-bold text-indigo-500 underline"}>Landing Page</a>
            </h2>
        </div>
    )
};

export {Error};