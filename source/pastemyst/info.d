module pastemyst.info;

public const string BASE_ENDPOINT = "https://paste.myst.rs/api/v2/";
public const string DATA_ENDPOINT = "https://paste.myst.rs/api/v2/data/";
public const string TIME_ENDPOINT = "https://paste.myst.rs/api/v2/time/";
public const string USER_ENDPOINT = "https://paste.myst.rs/api/v2/user/";

public const string DATA_LANGUAGE_BY_NAME = DATA_ENDPOINT ~ "language?name=";
public const string DATA_LANGUAGE_BY_EXT = DATA_ENDPOINT ~ "languageExt?extension=";

public const string TIME_EXPIRES_IN_TO_UNIX = TIME_ENDPOINT ~ "expiresInToUnixTime";
