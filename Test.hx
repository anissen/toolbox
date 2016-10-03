package;

class Test {
    static public function main() {
        test_json_compile_time_import();
        test_json_compile_time_strongly_typed_import();
        test_map_iterator();
    }

    static function test_json_compile_time_import() {
        trace(JSONImporter.import_json('test.json'));
    }

    static function test_json_compile_time_strongly_typed_import() {
        trace(R);
    }

    static function test_map_iterator() {
        var map = [ 42 => 'hello', 666 => 'world' ];
        for (pair in KeyValueIterator.pairs(map) /* or using KeyValueIterator */) {
            trace('key: ${pair.key}, value: ${pair.value}');
        }
    }
}
