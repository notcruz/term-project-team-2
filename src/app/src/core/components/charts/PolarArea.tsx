import {AWSComprehendFrequency, AWSComprehendScore} from "~/core/types";
import {PolarArea as P} from "react-chartjs-2";

const PolarArea = (data: AWSComprehendFrequency | AWSComprehendScore) => {
    return (
        <>
            <P
                data={{
                    labels: Object.keys(data),
                    datasets: [
                        {
                            data: Object.values(data),
                            backgroundColor: [
                                "rgba(255, 99, 132, 0.5)",
                                "rgba(54, 162, 235, 0.5)",
                                "rgba(255, 206, 86, 0.5)",
                                "rgba(75, 192, 192, 0.5)",
                                "rgba(153, 102, 255, 0.5)",
                                "rgba(255, 159, 64, 0.5)",
                            ],
                            borderWidth: 1,
                        },
                    ],
                }}
            />
        </>
    );
};

export {PolarArea};