package result;

import result.Result;
import error.Error;

class SafeTools {

	inline public static function resolve<T>(result : Result<T,Error>) : T {
		return switch (result) {
			case Error(e): tui.Script.instance.error(e); null;
			case Ok(res): res;
		}
	}

}
