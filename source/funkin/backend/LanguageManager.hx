package funkin.backend;

import haxe.Json;
import sys.io.File;
import sys.FileSystem;

class LanguageManager
{
    public static var current:Dynamic;
    public static var fallback:Dynamic;

    public static function init()
    {
        fallback = Json.parse(
            File.getContent("assets/lang/pt-BR.json")
        );

        load(ClientPrefs.language);
    }

    public static function load(lang:String)
    {
        trace("LOADING: " + lang);

        var path = 'assets/lang/$lang.json';

        if(!FileSystem.exists(path))
           path = "assets/lang/pt-BR.json";

        current = Json.parse(
           File.getContent(path)
        );
    }

    public static function get(key:String):String
    {
        var text = Reflect.field(current.lang, key);

        if(text != null)
            return text;

        text = Reflect.field(fallback.lang, key);

        if(text != null)
            return text;

        return key;
    }

    public static function image(path:String):String
    {
        if(ClientPrefs.language == "pt-BR")
        {
            var translated = 'lang/pt-BR/' + path;
            if(Paths.fileExists('images/' + translated + '.png'))
                return translated;
        }
        return path;
    }
}