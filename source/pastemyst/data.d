module pastemyst.data;

import std.typecons;
import std.uri;
import vibe.d;
import pastemyst.info;

/++
 + a struct representing a single language
 +/
public struct Language
{
    /++
     + language name
     +/
    public string name;

    /++
     + language mode (used for the online editor - codemirror)
     +/
    public string mode;

    /++
     + all supported mimes
     +/
    public string[] mimes;

    /++
     + all supported extensions
     +/
    public string[] ext;

    /++
     + color of the language, not guaranteed that every language has it
     + will be #ffffff if the language doesnt have a color
     +/
    @optional
    public string color = "#ffffff";
}

/++
 + returns language information for a specific language, searched languages by name. if the language couldn't be found it returns null
 +/
public Nullable!Language getLanguageByName(string name)
{
    return getLanguage(DATA_LANGUAGE_BY_NAME, name);
}

/++
 + returns language information for a specific language, searched languages by extension. if the language couldn't be found it returns null
 +
 + dont include the . in the extension
 +/
public Nullable!Language getLanguageByExtension(string extension)
{
    return getLanguage(DATA_LANGUAGE_BY_EXT, extension);
}

/++
 + there are 2 endpoints that return languages, one by name and one by extension, they return same data
 +
 + this function just does a GET request on the provided endpoint with the provided value and returns a language
 +/
private Nullable!Language getLanguage(string endpoint, string value)
{
    Nullable!Language lang = Nullable!Language.init;

    requestHTTP(endpoint ~ encodeComponent(value),
        (scope req)
        {
            req.method = HTTPMethod.GET;
        },
        (scope res)
        {
            if (res.statusCode != HTTPStatus.notFound)
            {
                lang = nullable(deserializeJson!Language(res.bodyReader.readAllUTF8()));
            }
        }
    );

    return lang;
}

unittest
{
    assert(getLanguageByName("non existing lang").isNull());
    assert(getLanguageByName("asdasdasd").isNull());

    const lang = getLanguageByName("d").get();

    assert(lang.name == "D");
}

unittest
{
    assert(getLanguageByExtension("brokey").isNull());

    const lang = getLanguageByExtension("d").get();

    assert(lang.name == "D");
}
