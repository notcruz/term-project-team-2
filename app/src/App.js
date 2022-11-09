import { Input } from "@mui/material";
import { useState } from "react";

function App() {
  const [input, setInput] = useState();
  const [count, setCount] = useState(50);
  const [date, setDate] = useState();

  return (
    <div className="min-h-screen flex flex-col items-center justify-center text-center">
      <body>
        <div>
          <h1 className="font-bold text-5xl text-indigo-400">
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
              <div className={"mb-0.5"}>
                <h3 className="font-bold">Celebrity Name</h3>
              </div>
              <div>
                <input
                  type="text"
                  value={input}
                  placeholder="Queen Elizabeth II"
                  onChange={(e) => setInput(e?.target?.value)}
                  className="rounded-md bg-transparent border w-96 border-gray-300 px-4 py-1.5 duration-300 outline-indigo-400 ring-0"
                />
              </div>
            </div>
            <div className="flex justify-center gap-x-9">
              <div className="flex flex-col items-start">
                <div className={"mb-0.5"}>
                  <h3 className="font-bold">Tweet Count</h3>
                </div>
                <div>
                  <input
                    type={"number"}
                    value={count}
                    placeholder={50}
                    onChange={(e) => setCount(e?.target?.value)}
                    className="rounded-md bg-transparent border w-44 border-gray-300 px-4 py-1.5 duration-300 outline-indigo-400 ring-0"
                  />
                </div>
              </div>
              <div className="flex flex-col items-start">
                <div className={"mb-0.5"}>
                  <h3 className="font-bold">Date of Death</h3>
                </div>
                <div>
                  <input
                    type={"date"}
                    value={date}
                    placeholder="09/08/2022"
                    onChange={(e) => setDate(e?.target?.value)}
                    className="rounded-md bg-transparent border border-gray-300 px-4 py-1.5 duration-300 outline-indigo-400 ring-0"
                  />
                </div>
              </div>
            </div>
            <div className="flex mt-3">
              <button className="w-full rounded-md bg-indigo-400 font-bold px-4 py-1.5 hover:scale-105 duration-300">
                Search
              </button>
            </div>
          </div>
        </div>
      </body>
    </div>
  );
}
export default App;
