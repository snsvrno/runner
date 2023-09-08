package;

import ansi.colors.Color.BRIGHT_BG;
import error.Error;
import ansi.Paint.paint;
import ansi.Paint.paintPreserve;
import ansi.colors.Style;
import hxml.Hxml;

import tui.errors.*;
 
using result.SafeTools;
using hxml.tools.BuildSetTools;

class Main extends tui.Script {
	public static function main() new Main();

	inline private static var CACHEPATH : String = ".runner";

	override function init() {
		name = "runner";
		version = "0.0.0";
		description = "builds haxe projects, runs outputs, and some extra things too!";
		addSwitches(... Switches.switches);
	}

	private function run() {
		ansi.Command.hideCursor();

		if (params.length != 1 || haxe.io.Path.extension(params[0]) != "hxml")
			error(new EValue("the first parameter", "an hxml file", params[0]));

		debug('using hxml file ${paint(params[0], Green, null, Underline)}');

		var hxml = Hxml.load(params[0]).resolve(); 
		var runnerRoot = haxe.io.Path.join([Sys.getCwd(), CACHEPATH]);

		if (!sys.FileSystem.exists(runnerRoot))
			sys.FileSystem.createDirectory(runnerRoot);

		for (buildset in hxml.sets) {
			Sys.print(paint(" job " + buildset.index + "/" + hxml.sets.length + " ", null, Cyan, Bold) + " ");

			var pos = ansi.Command.cursorPosition();
			var text = "build";
			var step = 0;
			var direction = 1;

			var options : hxml.ds.BuildOptions = {
				endFunc: function(result : Null<hxml.ds.BuildResult>) {
					if (result == null) {
						ansi.Command.write(pos.r, pos.c, paint(text, Red));
					} else {
						ansi.Command.write(pos.r, pos.c, paint(text, Green));
						Sys.println(" " + Math.floor(result.duration*10)/10 + paint(" seconds", White, Dim));
					}

				},

				updateFunc: function() {
					var ptext = paint(text.substring(0,step), White, Dim) + paint(text.substring(step, step+1), Green, FGBright) + paint(text.substring(step+1), White, Dim);
					ansi.Command.write(pos.r, pos.c, ptext);
					step = step + direction;
					if (direction > 0 && step > text.length) {
						direction = -1;
						step = text.length-2;
					} else if (direction < 0 && step < 0) {
						direction = 1;
						step = 1;
					}
				},

				updateTick: 0.1,
			};
	
			switch(buildset.run(options)) {
				case Ok(result):

				case Error(e):
					Sys.println(paint(" failed",Red));
					error(e);
			}
		}
	}

	override function exit(code:Int) {
		ansi.Command.showCursor();
		super.exit(code);
	}

	override function error(e:Error) {
		Sys.println(paint(" e ", White, Red, FGBright | Bold) + " " + paintPreserve(e.msg(), Red, BGBright));
		exit(1);
	}

	override function debug(text:String) {
		Sys.println(paint(" d ", White, Blue, FGBright | Bold) + " " + paintPreserve(text, Blue, BGBright));
	}

}
