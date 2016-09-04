package;

// Import JSON in Haxe at compile time
// usage example: https://gist.github.com/anissen/999e2ef0ee057319e99e

#if macro
import haxe.macro.Context;
#end

class JSONImporter {
    macro static public function import_json(file :String) {
        var data = sys.io.File.getContent(file);
        var json = try {
            haxe.Json.parse(data);
        } catch (e :Dynamic) {
            trace('Could not import JSON file "$file". Error: $e');
            {};
        }
        return Context.makeExpr(json, Context.currentPos());
    }
}
