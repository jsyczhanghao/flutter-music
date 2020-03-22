class Listener {
  Map<dynamic, List<Function>> _listeners = Map();
  
  on(dynamic event, Function callback) {
    if (_listeners[event] == null) {
      _listeners[event] = List<Function>();
    }

    _listeners[event].add(callback);
  }

  off(dynamic event, [Function callback]) {
    try {
      if (callback != null) {
        _listeners[event].remove(callback);
      } else {
        _listeners[event] = null;
      }
    } catch (e) {}
  }

  fire(dynamic event, [dynamic data]) {
    if (_listeners[event] != null) {
      for (Function callback in _listeners[event]) {
        if (data == null) {
          callback();
        } else {
          callback(data);
        }
      }
    }
  }
}