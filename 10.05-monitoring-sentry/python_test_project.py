import sentry_sdk
sentry_sdk.init(
    "https://aceec2d4ae0b472188c670b94176ee32@o1133118.ingest.sentry.io/6179365",

    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    # We recommend adjusting this value in production.
    traces_sample_rate=1.0
)


division_by_zero = 1 / 0