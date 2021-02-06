module pastemyst.info;

public const string BASE_ENDPOINT = "https://paste.myst.rs/api/v2/";
public const string DATA_ENDPOINT = BASE_ENDPOINT ~ "data/";
public const string TIME_ENDPOINT = BASE_ENDPOINT ~ "time/";
public const string USER_ENDPOINT = BASE_ENDPOINT ~ "user/";
public const string PASTE_ENDPOINT = BASE_ENDPOINT ~ "paste/";

public const string DATA_LANGUAGE_BY_NAME = DATA_ENDPOINT ~ "language?name=";
public const string DATA_LANGUAGE_BY_EXT = DATA_ENDPOINT ~ "languageExt?extension=";

public const string TIME_EXPIRES_IN_TO_UNIX = TIME_ENDPOINT ~ "expiresInToUnixTime";
