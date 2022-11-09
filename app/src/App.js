import { Input } from "@mui/material";
import { useState } from "react";

function App() {
  const [input, setInput] = useState();

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
            Check the how people feel about a celebrity before and after their
            passing!
          </p>
        </div>
        <div className="mt-3">
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e?.target?.value)}
            className="bg-transparent border border-gray-300 px-3 py-1"
          />
        </div>
      </body>
    </div>
  );
}

/**
  <nav className="bg-gray-600 flex justify-center py-3">
        <a href="/" className="font-bold text-xl hover:scale-105 duration-300">
          Sentimental Analysis v2
        </a>
      </nav>
 */
export default App;
