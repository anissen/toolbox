package;

class Test {
    static public function main() {
        test_json_compile_time_import();
        test_json_compile_time_strongly_typed_import();
        test_map_iterator();
        test_asset_paths();
    }

    static function test_json_compile_time_import() {
        trace('***** test_json_compile_time_import *****');
        trace(JSONImporter.import_json('test.json'));
        trace('');
    }

    static function test_json_compile_time_strongly_typed_import() {
        trace('***** test_json_compile_time_strongly_typed_import *****');
        for (f in Type.getClassFields(R)) {
            trace('Field: $f');
        }
        // trace(R);
        trace('');
    }

    static function test_map_iterator() {
        trace('***** test_map_iterator *****');
        var map = [ 42 => 'hello', 666 => 'world' ];
        for (pair in KeyValueIterator.pairs(map) /* or using KeyValueIterator */) {
            trace('key: ${pair.key}, value: ${pair.value}');
        }
        trace('');
    }

    static function test_asset_paths() {
        trace('***** test_asset_paths *****');
        for (f in Type.getClassFields(AssetPaths)) {
            trace('Field: $f');
        }
        trace('');
    }
}
