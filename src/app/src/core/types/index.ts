export type QueryParams = {
    name?: string;
    count?: string;
    date?: string;
};

export type AWSComprehendScore = {
    PositiveScore: string;
    NegativeScore: string;
    NeutralScore: string;
    MixedScore: string;
};

export type AWSComprehendFrequency = {
    PositiveFrequency: number;
    NegativeFrequency: number;
    NeutralFrequency: number;
    MixedFrequency: number;
};

export type Post = {
    Mixed: string,
    Negative: string,
    Neutral: string,
    Positive: string,
    Sentiment: string
}

export type WikipediaResult = {
    item: {
        "type": "uri",
        "value": string
    },
    itemLabel: {
        "xml:lang": "en",
        "type": "literal",
        "value": string
    },
    itemDescription: {
        "xml:lang": "en",
        "type": "literal",
        "value": string
    },
    DR: {
        "datatype": "http://www.w3.org/2001/XMLSchema#dateTime",
        "type": "literal",
        "value": string
    },
    RIP?: {
        "datatype": "http://www.w3.org/2001/XMLSchema#dateTime",
        "type": "literal",
        value: string
    }
    article: {
        "type": "uri",
        "value": string
    },
    image?: {
        type: "uri",
        value: string
    }
}

export type LambdaResponse = {
    Name: string;
    Data: {
        Frequency: {
            Pre: AWSComprehendFrequency;
            Post: AWSComprehendFrequency;
        },
        Score: {
            Pre: AWSComprehendScore;
            Post: AWSComprehendScore;
        },
        Samples: {
            Post: {
                [key: string]: Post
            },
            Pre: {
                [key: string]: Post
            }
        }
    };
};
