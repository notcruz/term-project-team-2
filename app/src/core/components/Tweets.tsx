import {TwitterTweetEmbed} from "react-twitter-embed";
import {useState} from "react";
import {twMerge} from "tailwind-merge";

type props = {
    title: string,
    range?: string,
    ids: string[]
};

const Tweets = (props: props) => {
    const [count, setCount] = useState(0);

    return (
        /* width of the embeds is reduced when items-center is set at the parent level before they load */
        /* little setup to wait until all tweets load and update parent to center items to prevent width reduction */
        <div className={twMerge("flex flex-col w-[40rem]", count === 5 && "items-center")}>
            <div>
                <h3 className={"font-semibold text-3xl"}>{props.title}</h3>
            </div>
            <div>
                {props.ids.map((id) => {
                    return (
                        /* handle race condition when incrementing state */
                        <TwitterTweetEmbed onLoad={() => setCount((prev) => prev + 1)} tweetId={id}/>
                    )
                })}
            </div>
        </div>
    )
};

export {Tweets};