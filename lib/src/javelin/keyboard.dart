part of javelin;

/*

  Copyright (C) 2012 John McCutchan <john@johnmccutchan.com>

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

*/

class JavelinKeyCodes {
  static final int KeyTab = 9;

  static final int KeyShift = 16;
  static final int KeyControl = 17;
  static final int KeyAlt = 18;

  static final int KeySpace = 32;
  static final int KeyPageUp = 33;
  static final int KeyPageDown = 34;
  static final int KeyEnd = 35;
  static final int KeyHome = 36;
  static final int KeyLeft = 37;
  static final int KeyUp = 38;
  static final int KeyRight = 39;
  static final int KeyDown = 40;

  static final int Key0 = 48;
  static final int Key1 = 49;
  static final int Key2 = 50;
  static final int Key3 = 51;
  static final int Key4 = 52;
  static final int Key5 = 53;
  static final int Key6 = 54;
  static final int Key7 = 55;
  static final int Key8 = 56;
  static final int Key9 = 57;

  static final int KeyA = 65;
  static final int KeyB = 66;
  static final int KeyC = 67;
  static final int KeyD = 68;
  static final int KeyE = 69;
  static final int KeyF = 70;
  static final int KeyG = 71;
  static final int KeyH = 72;
  static final int KeyI = 73;
  static final int KeyJ = 74;
  static final int KeyK = 75;
  static final int KeyL = 76;
  static final int KeyM = 77;
  static final int KeyN = 78;
  static final int KeyO = 79;
  static final int KeyP = 80;
  static final int KeyQ = 81;
  static final int KeyR = 82;
  static final int KeyS = 83;
  static final int KeyT = 84;
  static final int KeyU = 85;
  static final int KeyV = 86;
  static final int KeyW = 87;
  static final int KeyX = 88;
  static final int KeyY = 89;
  static final int KeyZ = 90;
}

/** Keyboard state manager. Supports temporal keyboard queries, for example,
 * was the key pressed in the previous frame and released this frame?
 */
class JavelinKeyboard {
  final List<Map<int, bool>> _keyboardStates = [new Map<int, bool>(),
                                                new Map<int, bool>()];
  int _currentIndex = 0;
  int _previousIndex = 1;

  bool _isDown(Map<int, bool> keyboardState, int keyCode) {
    bool r = keyboardState[keyCode];
    if (r == null) {
      // Never seen
      return false;
    }
    return r;
  }

  /** Is [keyCode] up this frame? */
  bool isUp(int keyCode) {
    return !_isDown(_keyboardStates[_currentIndex], keyCode);
  }

  /** Was [keyCode] up in the previous frame? */
  bool wasUp(int keyCode) {
    return !_isDown(_keyboardStates[_previousIndex], keyCode);
  }

  /** Is [keyCode] down this frame? */
  bool isDown(int keyCode) {
    return _isDown(_keyboardStates[_currentIndex], keyCode);
  }

  /** Was [keyCode] down in the previous frame? */
  bool wasDown(int keyCode) {
    return _isDown(_keyboardStates[_previousIndex], keyCode);
  }

  /** Was [keyCode] down in the previous frame and up in this frame? */
  bool wasReleased(int keyCode) {
    return wasDown(keyCode) && isUp(keyCode);
  }

  /** Was [keyCode] up in the previous frame and down in this frame? */
  bool wasPressed(int keyCode) {
    return wasUp(keyCode) && isDown(keyCode);
  }

  /** Is [keyCode] being held down? */
  bool isHeld(int keyCode) {
    return wasDown(keyCode) && isDown(keyCode);
  }

  /** This function must be called once and only once per logical game
   * frame. After calling this function all keyboard events for the current
   * frame should be processed.
   *
   * NOTE: This function should be thought of as internal.
   */
  void frame() {
    // Swap map indices.
    int temp = _currentIndex;
    _currentIndex = _previousIndex;
    _previousIndex = temp;
    // Clear current frame state.
    _keyboardStates[_currentIndex].clear();
    // Start current frame state at same point as previous frame.
    _keyboardStates[_previousIndex].forEach((k, v) {
      _keyboardStates[_currentIndex][k] = v;
    });
  }

  /** Process a keyboard event for the current frame.
   *
   * NOTE: This function should be thought of as internal.
   * */
  void keyboardEvent(KeyboardEvent event, bool down) {
    _keyboardStates[_currentIndex][event.keyCode] = down;
  }
}
