import {PolarArea} from "~/core/components/charts";
import {ComponentProps} from "react";

type props = {
    title: string,
    data: ComponentProps<typeof PolarArea>;
}

const Calculations = (props: props) => {
    return (
        <div className="rounded-md w-[30rem]">
            <div>
                <h3 className={"font-semibold text-4xl"}>{props.title}</h3>
            </div>
            <div className={"mt-3"}>
                <PolarArea {...props.data} />
            </div>
        </div>
    )
};

export {Calculations};