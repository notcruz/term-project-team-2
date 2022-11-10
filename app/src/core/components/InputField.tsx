import {ChangeEventHandler, HTMLInputTypeAttribute} from "react";
import {twMerge} from "tailwind-merge";

type props = {
    title: string,
    className?: string
    type?: HTMLInputTypeAttribute,
    placeholder?: string,
    value?: string,
    onChange?: ChangeEventHandler<HTMLInputElement>
}

const InputField = (props: props) => {
    return (
        <>
            <div className={"mb-0.5"}>
                <h3 className="font-bold">{props.title}</h3>
            </div>
            <div>
                <input type={props.type} value={props.value} placeholder={props.placeholder} onChange={props.onChange}
                       className={twMerge("rounded-md bg-transparent border w-44 border-gray-300 px-4 py-1.5 duration-300 outline-indigo-500 ring-0", props.className)}/>
            </div>
        </>
    )
};

export {InputField};