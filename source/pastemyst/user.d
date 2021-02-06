module pastemyst.user;

import std.typecons;
import std.uri;
import vibe.d;
import pastemyst.info;

/++
 + represents a single pastemyst user
 +/
public struct User
{
    /++
     + id of the user
     +/
    @name("_id")
    public string id;

    /++
     + username of the user
     +/
    public string username;

    /++
     + url of their avatar image
     +/
    public string avatarUrl;

    /++
     + their default language
     +/
    public string defaultLang;

    /++
     + if they have a public profile
     +/
    public bool publicProfile;

    /++
     + how long has the user been a supporter for, 0 if not a supporter
     +/
    public uint supporterLength;

    /++
     + if the user is a contributor to pastemyst
     +/
    public bool contributor;
}

/++
 + checks if a user exists
 +/
public bool userExists(string username)
{
    bool exists = false;

    const reqstring = USER_ENDPOINT ~ encodeComponent(username) ~ "/exists";

    requestHTTP(reqstring,
        (scope req)
        {
            req.method = HTTPMethod.GET;
        },
        (scope res)
        {
            if (res.statusCode == HTTPStatus.ok)
            {
                exists = true;
            }
        }
    );

    return exists;
}

/++
 + finds a user by their username, returns null if not found or if the user doesnt have a public profile set.
 +/
public Nullable!User getUser(string username)
{
    Nullable!User user = Nullable!User.init;

    const reqstring = USER_ENDPOINT ~ encodeComponent(username);

    requestHTTP(reqstring,
        (scope req)
        {
            req.method = HTTPMethod.GET;
        },
        (scope res)
        {
            if (res.statusCode != HTTPStatus.notFound)
            {
                user = nullable(deserializeJson!User(res.bodyReader.readAllUTF8()));
            }
        }
    );

    return user;
}

@("user exists")
unittest
{
    assert(userExists("codemyst"));
}

@("getting a user")
unittest
{
    assert(getUser("codemyst").get().publicProfile);
}
