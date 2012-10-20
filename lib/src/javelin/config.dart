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

abstract class JavelinConfigType {
  abstract String serialize(Dynamic o);
  abstract Dynamic deserialize(String data);
  bool istype(Dynamic o) => false;
}

class JavelinConfigType_bool extends JavelinConfigType {
  String serialize(Dynamic o) {
    assert(o is bool);
    return JSON.stringify(o);
  }
  Dynamic deserialize(String data) {
    bool o = JSON.parse(data);
    return o;
  }
  bool istype(Dynamic o) => o is bool;
}

class JavelinConfigType_num extends JavelinConfigType {
  String serialize(Dynamic o) {
    assert(o is num);
    return JSON.stringify(o);
  }
  Dynamic deserialize(String data) {
    num o = JSON.parse(data);
    return o;
  }
  bool istype(Dynamic o) => o is num;
}

class JavelinConfigType_String extends JavelinConfigType {
  String serialize(Dynamic o) {
    return o;
  }
  Dynamic deserialize(Dynamic o) {
    return o;
  }
  bool istype(Dynamic o) => o is String;
}

class JavelinConfigType_vec3 extends JavelinConfigType {
  String serialize(Dynamic o) {
    assert(o is vec3);
    Map<String, num> target = new Map<String, num>();
    target['x'] = o.x;
    target['y'] = o.y;
    target['z'] = o.z;
    return JSON.stringify(target);
  }
  Dynamic deserialize(String data) {
    Map<String, num> src = JSON.parse(data);
    vec3 o = new vec3.zero();
    o.x = src['x'];
    o.y = src['y'];
    o.z = src['z'];
    return o;
  }
  bool istype(Dynamic o) => o is vec3;
}

class JavelinConfigTypes {
  static Map<String, JavelinConfigType> types;
  static init() {
    types = new Map<String, JavelinConfigType>();
    types['vec3'] = new JavelinConfigType_vec3();
    types['bool'] = new JavelinConfigType_bool();
    types['num'] = new JavelinConfigType_num();
    types['String'] = new JavelinConfigType_String();
  }
  static JavelinConfigType find(String name) {
    return JavelinConfigTypes.types[name];
  }
}

typedef Dynamic CreateDefault();

class JavelinConfigVariable {
  String name;
  String type;
  CreateDefault defaultValue;
  Dynamic value;
  JavelinConfigVariable(this.name, this.type, this.defaultValue) {
    value = defaultValue();
  }
  void reset() {
    value = defaultValue();
  }
}

typedef ConfigVariableChanged(JavelinConfigVariable variable);

class JavelinConfigStorage {
  static Map<String, JavelinConfigVariable> variables;
  static ConfigVariableChanged notification;
  static void init() {
    notification = null;
    JavelinConfigTypes.init();
    variables = new Map<String, JavelinConfigVariable>();
    variables['camera.position'] = new JavelinConfigVariable('camera.position', 'vec3', () => new vec3(0.0, 2.0, 0.0));
    variables['camera.focusPosition'] = new JavelinConfigVariable('camera.focusPosition', 'vec3', () => new vec3(0.0, 2.0, 2.0));
    variables['drawlist.update'] = new JavelinConfigVariable('drawlist.update', 'bool', () => true);
    variables['Javelin.demo'] = new JavelinConfigVariable('Javelin.demo', 'String', () => 'Empty');
    variables['demo.hfluid.waveheight'] = new JavelinConfigVariable('demo.hfluid.waveheight', 'num', () => 0.8);
    variables['demo.hfluid.dropheight'] = new JavelinConfigVariable('demo.hfluid.dropheight', 'num', () => 0.3);
    variables['demo.postprocess'] = new JavelinConfigVariable('demo.postprocess', 'String', () => 'blit');
    variables['demo.normalmap.style'] = new JavelinConfigVariable('demo.normalmap.style', 'String', () => 'basic');
  }

  static void loadVariable(String name) {
    JavelinConfigVariable variable = JavelinConfigStorage.variables[name];
    if (variable == null) {
      return;
    }
    JavelinConfigType type = JavelinConfigTypes.types[variable.type];
    if (type == null) {
      return;
    }
    String json = window.localStorage[name];
    if (json != null) {
      variable.value = type.deserialize(json);
    } else {
      print('First time seeing $name');
      storeVariable(name);
    }
  }

  static void storeVariable(String name) {
    JavelinConfigVariable variable = JavelinConfigStorage.variables[name];
    if (variable == null) {
      return;
    }
    JavelinConfigType type = JavelinConfigTypes.types[variable.type];
    if (type == null) {
      return;
    }
    String json = type.serialize(variable.value);
    window.localStorage[name] = json;
  }

  static void load() {
    variables.forEach((k,v) {
      loadVariable(k);
    });
  }

  static void store() {
    variables.forEach((k,v) {
      storeVariable(k);
    });
  }

  static Dynamic set(String name, Dynamic o,[bool commit=true]) {
    JavelinConfigVariable variable;
    variable = JavelinConfigStorage.variables[name];
    if (variable == null) {
      return;
    }
    variable.value = o;
    if (commit) {
      storeVariable(name);
    }
    return o;
  }

  static Dynamic get(String name) {
    JavelinConfigVariable variable;
    variable = JavelinConfigStorage.variables[name];
    if (variable == null) {
      return null;
    }
    return variable.value;
  }
}