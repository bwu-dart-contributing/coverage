// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library coverage.src.util;

import 'dart:async';

/// Retries the specified function with the specified interval and returns
/// the result on successful completion.
Future retry(Future f(), Duration interval, {Duration timeout}) async {
  var keepGoing = true;

  Future _withTimeout(Future f(), {Duration duration}) {
    if (duration == null) {
      return f();
    }

    return f().timeout(duration, onTimeout: () {
      keepGoing = false;

      var msg;

      if (duration.inSeconds == 0) {
        msg = '${duration.inMilliseconds}ms';
      } else {
        msg = '${duration.inSeconds}s';
      }

      throw new StateError('Failed to complete within ${msg}');
    });
  }

  return _withTimeout(() async {
    while (keepGoing) {
      try {
        var result = await f();
        return result;
      } catch (_) {
        if (keepGoing) {
          await new Future.delayed(interval);
        }
      }
    }
  }, duration: timeout);
}
