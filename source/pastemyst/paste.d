module pastemyst.paste;

import std.typecons;
import std.uri;
import vibe.d;
import pastemyst.info;
import pastemyst.expires;

/++
 + holds information about a single paste edit
 +/
public struct Edit
{
    /++
     + unique id of the edit
     +/
    @name("_id")
    public string uniqueId;

    /++
     + edit id, multiple edits can share the same id to show that multiple properties were edited at the same time
     +/
    public ulong editId;

    /++
     + type of edit
     +/
    public EditType editType;

    /++
     + various metadata, most used case is for storing which pasty was edited
     +/
    public string[] metadata;

    /++
     + actual edit, usually stores the old data
     +/
    public string edit;

    /++
     + unix time of when the edit was done
     +/
    public ulong editedAt;
}

/++
 + type of paste edit
 +/
public enum EditType
{
    title,
    pastyTitle,
    pastyLanguage,
    pastyContent,
    pastyAdded,
    pastyRemoved,
}

/++
 + struct for a single pasty. a pasty is a part of a paste and represents a single "file", contains a title, language and code.
 +/
public struct Pasty
{
    /++
     + id of the pasty
     +/
    @name("_id")
    @optional
    public string id;

    /++
     + title of the pasty.
     +/
    public string title;

    /++
     + language of the pasty. this stores the name of the language, not the mode or MIME type.
     +/
    public string language;

    /++
     + code of the pasty.
     +/
    public string code;
}

/++
 + struct representing a paste.
 +/
public struct Paste
{
    /++
     + paste id
     +/
    @name("_id")
    public string id;

    /++
     + when the paste is created, using unix time.
     +/
    public ulong createdAt;

    /++
     + when the paste expires.
     +/
    public ExpiresIn expiresIn;

    /++
     + when the paste will get deleted, if `expiresIn` is set to never, this value is set to 0;
     +/
    public ulong deletesAt;

    /++
     + owner of the paste. if no owner then this value should be an empty string.
     +/
    public string ownerId;

    /++
     + if the paste is private.
     +/
    public bool isPrivate;

    /++
     + does the paste show up on the user's public profile?
     +/
    public bool isPublic;

    /++
     + array of all tags for this paste
     +/
    public string[] tags;

    /++
     + number of stars
     +/
    public ulong stars;

    /++
     + is the paste encrytped?
     +/
    public bool encrypted;

    /++
     + title of the paste.
     +/
    public string title;

    /++
     + pasties of the paste. a paste can have multiple pasties which are sort of like "files".
     +/
    public Pasty[] pasties;

    /++
     + array of paste edits
     +/
    public Edit[] edits;
}

/++
 + struct containing info needed to create a pasty
 +/
public struct PastyCreateInfo
{
    /++
     + title of the pasty.
     +/
    public string title;

    /++
     + language of the pasty. this stores the name of the language, not the mode or MIME type.
     +/
    public string language;

    /++
     + code of the pasty.
     +/
    public string code;
}

/++
 + struct containing info needed to create a paste
 +/
public struct PasteCreateInfo
{
    /++
     + title -- optional
     +/
    public string title;

    /++
     + expires in -- optional
     +/
    public ExpiresIn expiresIn;

    /++
     + is it only accessible by the owner -- optional
     +/
    public bool isPrivate;

    /++
     + is it displayed on the owners public profile -- optional
     +/
    public bool isPublic;

    /++
     + tags, comma separated -- optional
     +/
    public string tags;

    /++
     + list of pasties -- mandatory
     +/
    public PastyCreateInfo[] pasties;
}

/++
 + returns a paste if it can find it by its id
 +
 + if the paste is private you need to provide the token (found on your profile's settings page)
 +/
public Nullable!Paste getPaste(string id, string token = "")
{
    Nullable!Paste paste = Nullable!Paste.init;

    requestHTTP(PASTE_ENDPOINT ~ id,
        (scope req)
        {
            req.method = HTTPMethod.GET;

            if (token != "")
            {
                req.headers.addField("Authorization", token);
            }
        },
        (scope res)
        {
            if (res.statusCode != HTTPStatus.notFound)
            {
                try
                {
                    paste = nullable(deserializeJson!Paste(res.bodyReader.readAllUTF8()));
                } catch (Exception) {}
            }
        }
    );

    return paste;
}

/++
 + creates a paste and returns the full paste info
 +
 + if you want the paste to be tied to your account or to create a private/public paste, or use other account specific features you have to provide the token.
 +/
public Nullable!Paste createPaste(const PasteCreateInfo createInfo, string token = "")
{
    Nullable!Paste result = Nullable!Paste.init;

    requestHTTP(BASE_ENDPOINT ~ "paste",
        (scope req)
        {
            req.method = HTTPMethod.POST;
            req.headers.addField("Content-Type", "application/json");

            if ((createInfo.isPrivate || createInfo.isPublic || createInfo.tags != "") && token == "")
            {
                throw new Exception("using account features but the token isnt provided");
            }

            if (token != "")
            {
                req.headers.addField("Authorization", token);
            }

            req.writeJsonBody(createInfo);
        },
        (scope res)
        {
            try
            {
                result = nullable(deserializeJson!Paste(res.bodyReader.readAllUTF8()));
            } catch (Exception) {}
        }
    );

    return result;
}

/++
 + deletes a paste
 +
 + you can only delete pastes on your account so you must provide the token
 +
 + this action is irreversible
 +/
public void deletePaste(string id, string token)
{
    requestHTTP(PASTE_ENDPOINT ~ id,
        (scope req)
        {
            req.method = HTTPMethod.DELETE;
            req.headers.addField("Content-Type", "application/json");

            req.headers.addField("Authorization", token);
        }, (scope res) {}
    );
}

/++
 + edits a paste
 +
 + you can only edit pastes on your account so you must provide the token
 +
 + returns the new edited paste
 +
 + to edit values you need to send the exact same paste, except values you want edited should be changed
 +
 + you cant edit the expires in value, changing it will have no effect
 +/
public Nullable!Paste editPaste(Paste paste, string token)
{
    Nullable!Paste result = Nullable!Paste.init;

    requestHTTP(PASTE_ENDPOINT ~ paste.id,
        (scope req)
        {
            req.method = HTTPMethod.PATCH;
            req.headers.addField("Content-Type", "application/json");

            req.headers.addField("Authorization", token);

            req.writeJsonBody(paste);
        },
        (scope res)
        {
            try
            {
                result = nullable(deserializeJson!Paste(res.bodyReader.readAllUTF8()));
            } catch (Exception) {}
        }
    );

    return result;
}

@("getting a paste")
unittest
{
    const paste = getPaste("cwy615yg").get();

    assert(paste.title == "DONT DELETE - api example");
}

@("creating a paste")
unittest
{
    const pastyCreateInfo = PastyCreateInfo("pasty1", "plain text", "asd asd asd");

    const createInfo = PasteCreateInfo("api test paste",
            ExpiresIn.never,
            false,
            false,
            "",
            [pastyCreateInfo]);

    const paste = createPaste(createInfo);

    assert(!paste.isNull());

    assert(paste.get().title == createInfo.title);
}

@("creating a private paste")
unittest
{
    import std.process : environment;

    const token = environment.get("TOKEN");

    const pastyCreateInfo = PastyCreateInfo("pasty1", "plain text", "asd asd asd");

    const createInfo = PasteCreateInfo("api test paste",
            ExpiresIn.never,
            true,
            false,
            "",
            [pastyCreateInfo]);

    const paste = createPaste(createInfo, token);

    assert(!paste.isNull());

    assert(paste.get().isPrivate);
}

@("deleting a paste")
unittest
{
    import std.process : environment;

    const token = environment.get("TOKEN");

    const pastyCreateInfo = PastyCreateInfo("pasty1", "plain text", "asd asd asd");

    const createInfo = PasteCreateInfo("api test paste",
            ExpiresIn.never,
            false,
            false,
            "",
            [pastyCreateInfo]);

    const paste = createPaste(createInfo, token);

    assert(!paste.isNull());

    deletePaste(paste.get().id, token);

    assert(getPaste(paste.get().id, token).isNull());
}

@("editing a paste")
unittest
{
    import std.process : environment;

    const token = environment.get("TOKEN");

    const pastyCreateInfo = PastyCreateInfo("pasty1", "plain text", "asd asd asd");

    const createInfo = PasteCreateInfo("api test paste",
            ExpiresIn.never,
            false,
            false,
            "",
            [pastyCreateInfo]);

    auto paste = createPaste(createInfo, token);

    assert(!paste.isNull());

    paste.get().title = "edited title";

    editPaste(paste.get(), token);
}
