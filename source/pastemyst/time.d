module pastemyst.time;

import std.conv;
import vibe.d;
import pastemyst.info;
import pastemyst.expires;

/++
 + converts an expiresIn value to a specific unix timestamp when a paste should expire
 +/
public ulong getExpiresInToUnixTime(ulong createdAt, ExpiresIn expiresIn)
{
    ulong time = 0;

    const reqstring = TIME_EXPIRES_IN_TO_UNIX ~ "?createdAt=" ~ createdAt.to!string() ~
                      "&expiresIn=" ~ expiresIn;

    requestHTTP(reqstring,
        (scope req)
        {
            req.method = HTTPMethod.GET;
        },
        (scope res)
        {
            time = parseJsonString(res.bodyReader.readAllUTF8())["result"].get!ulong();
        }
    );

    return time;
}

@("converting expires in value")
unittest
{
    assert(getExpiresInToUnixTime(1_588_441_258, ExpiresIn.oneWeek) == 1_589_046_058);
}
