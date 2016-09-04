package;

// Haxe build macro converting a JSON file into strongly typed, inline/dce friendly, properties
// usage example: https://gist.github.com/anissen/134e64b67c4101d62ac694623ce1f086

#if macro
import haxe.Json;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.io.File;
import sys.FileSystem;

/**
	Using macros to generate types (recursively) from a JSON file.
	The resulting type is dce-friendly, which means unused or inlined properties
	will completely disappear in the compiled code.

	File path (.json is optional) will be resolved:
	1. relative to class
	2. under /res
	3. under /resource

	Usage:

		@:build(JSONBuilder.build("resource.json"))
		class R { }

	Example:

		{
			"list": [1,2,3],
			"obj": {
				"foo": "hello",
				"bar": 42
			},
			"value": "world"
		}

	Generates:

		class R {
			static public var list = [1,2,3];
			inline static public var obj = R_obj;
			inline static public var value = "world";
		}
		class R_obj {
			inline static public var foo = "hello";
			inline static public var bar = 42;
		}

**/
class JSONBuilder {
	static var inClass :ClassType;
	static var pos :Position;

	macro static public function build(resName :String) :Array<Field>	{
		inClass = Context.getLocalClass().get();
		pos = Context.currentPos();

		var obj = loadResource(resName);
		var path = [inClass.name];
		return makeFields(obj, path);
	}

	/* AST BUILDING */

	static function makeFields(obj :Dynamic, path :Array<String>) :Array<Field> {
		return [
			for (prop in Reflect.fields(obj))
				makeField(prop, Reflect.getProperty(obj, prop), path)
		];
	}

	static function makeField(prop :String, value :Dynamic, path :Array<String>) :Field {
		prop = safeFieldName(prop);

		var valueExpr = makeExpr(value, path.concat([prop]));

		var isConst = switch (valueExpr.expr) {
			case EConst(_): true;
			default: false;
		};

		var flags = [Access.APublic, Access.AStatic];
		if (isConst) flags.push(Access.AInline);

		return {
			name: prop,
			access: flags,
			kind: FVar(null, valueExpr),
			pos: pos
		}
	}

	static function makeExpr(value :Dynamic, path :Array<String>) :Expr {
		if (value == null
			|| Std.is(value, String)
			|| Std.is(value, Int)
			|| Std.is(value, Float)
			|| Std.is(value, Bool)
			|| Std.is(value, Array)) {
			return macro $v{value};
		} else {
			return makeType(value, path);
		}
	}

	static function makeType(value :Dynamic, path :Array<String>) {
		var cname = path.join("_");
		var cdef = macro class Tmp { }
		cdef.pack = inClass.pack.copy();
		cdef.name = cname;
		cdef.fields = makeFields(value, path);

		haxe.macro.Context.defineType(cdef);

		return macro $i{cname};
	}

	static function safeFieldName(prop :String) {
		var c = prop.charCodeAt(0);
		if (c >= "0".code && c <= "9".code) return "_" + prop;
		return prop;
	}

	/* RESOURCE LOADING */

	static function loadResource(resName :String) {
		var fileName = getFileName(resName);
		var module = inClass.pack.concat([inClass.name]).join(".");
		Context.registerModuleDependency(module, fileName);

		try {
			return Json.parse(File.getContent(fileName));
		} catch (err:Dynamic) {
			Context.error('Unable to load resource "$fileName": $err', Context.currentPos());
			return {};
		}
	}

	static function getFileName(resName:String)	{
		if (resName.indexOf('.') < 0) resName += '.json';

		try {
		    return Context.resolvePath(resName);
		} catch (err:Dynamic) {}
		if (FileSystem.exists('res/$resName')) return 'res/$resName';
		if (FileSystem.exists('resource/$resName')) return 'resource/$resName';
		return resName;
	}
}
#end
