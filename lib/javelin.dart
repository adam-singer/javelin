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

library javelin;
import 'dart:math' as Math;
import 'dart:html';
import 'dart:json' as JSON;
import 'dart:async';
import 'package:vector_math/vector_math_browser.dart';
import 'package:spectre/spectre.dart';
import 'package:game_loop/game_loop.dart';
import 'package:javelin/javelin_render.dart';
import 'package:asset_pack/asset_pack.dart';

part 'src/javelin/config.dart';
part 'src/javelin/config_ui.dart';
part 'src/javelin/keyboard.dart';
part 'src/javelin/mouse.dart';
part 'src/javelin/base_demo.dart';
part 'src/javelin/render_config.dart';
part 'src/javelin/application.dart';
part 'src/javelin/launcher.dart';