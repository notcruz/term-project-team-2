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
