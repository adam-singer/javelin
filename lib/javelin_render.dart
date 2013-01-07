/*
  Copyright (C) 2013 John McCutchan <john@johnmccutchan.com>

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

library javelin_render;

import 'dart:html';
import 'package:vector_math/vector_math_browser.dart';
import 'package:spectre/spectre.dart';
import 'package:spectre/spectre_post.dart';

part 'src/javelin_render/global_resources.dart';
part 'src/javelin_render/material.dart';
part 'src/javelin_render/material_constant.dart';
part 'src/javelin_render/texture.dart';
part 'src/javelin_render/renderable.dart';
part 'src/javelin_render/layer.dart';
part 'src/javelin_render/renderer.dart';