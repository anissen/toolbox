package;

// Import JSON in Haxe at compile time
// usage example: https://gist.github.com/anissen/999e2ef0ee057319e99e

#if macro
import haxe.macro.Context;
#end

class JSONImporter {
    macro static public function import_json(file :String) {
        if (!sys.FileSystem.exists(file)) {
            Context.error(file + " does not exist", Context.currentPos());
        }

        var data = sys.io.File.getContent(file);
        var json = try {
            haxe.Json.parse(data);
        } catch (error :String) {
            var position = Std.parseInt(error.split("position").pop());
            var pos = Context.makePosition({
                min: position,
                max: position + 1,
                file: file
            });
            haxe.macro.Context.error(file + " is not valid JSON. " + error, pos);
        }
        return Context.makeExpr(json, Context.currentPos());
    }
}
