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

library hfluid;
import 'dart:html';
import 'dart:scalarlist';

class HeightFieldFluid {
  final num columnWidth;
  final int columnsWide;
  static final int BoundaryNorth = 1;
  static final int BoundaryEast = 2;
  static final int BoundarySouth = 3;
  static final int BoundaryWest = 4;
  num _dt;
  num _dx;
  num _invDx;
  num _gravity;


  num _c;
  num _c2;
  num _h;
  num _h2;
  num _invH2;
  num _maxSlope;
  num _maxOffset;
  num _velocityDampen;


  Float32List _velocity;
  Float32List _height;
  Float32List _tempHeight;

  Float32List get columns => _height;

  int columnIndex(int i, int j) => i + (columnsWide * j);


  HeightFieldFluid(this.columnsWide, this.columnWidth) {
    final int numColumns = columnsWide * columnsWide;
    _velocityDampen = 0.99;
    _gravity = -10.0;
    _dt = 0.10;
    num domainSize = (numColumns)/2.0;
    _dx = domainSize / numColumns;
    _invDx = 1.0 / _dx;
    _h = columnWidth;
    _h2 = _h * _h;
    _invH2 = 1.0 / _h2;
    _c = 3.0;
    _c2 = _c * _c;
    _maxSlope = 4.0;
    _maxOffset = _maxSlope * _h;

    _velocity = new Float32List(numColumns);
    _height = new Float32List(numColumns);
    _tempHeight = new Float32List(numColumns);
  }

  void _simpleUpdate() {
    Stopwatch sw = new Stopwatch();
    sw.start();

    List<int> indexList = new List<int>();
    for (int i = 1; i < columnsWide-1; i++) {
      int index = i * columnsWide + 1;
      for (int j = 1; j < columnsWide-1; j++) {
        final int indexEast = index+1;
        final int indexWest = index-1;
        final int indexNorth = index+columnsWide;
        final int indexSouth = index-columnsWide;
        final num heightEast = _height[indexEast];
        final num heightWest = _height[indexWest];
        final num heightNorth = _height[indexNorth];
        final num heightSouth = _height[indexSouth];
        final num height = _height[index];
        num velocity = _velocity[index];
        num heightSum = heightEast+heightWest+heightNorth+heightSouth;
        heightSum = heightSum - 4 * height;
        num offset = heightSum;
        num f = _c2 * heightSum * _invH2;
        // v'
        velocity += f * _dt;
        velocity *= _velocityDampen;
        num newHeight = height + velocity * _dt;

        _velocity[index] = velocity;
        _tempHeight[index] = newHeight;
        index++;
      }
    }
    sw.stop();
    sw.reset();
    sw.start();
    for (int i = 1; i < columnsWide-1; i++) {
      int index = i * columnsWide + 1;
      for (int j = 1; j < columnsWide-1; j++) {
        _height[index] = _tempHeight[index];
        index++;
      }
    }
    sw.stop();
  }

  void update() {
    _simpleUpdate();
  }

  void _setReflectiveBoundaryNorth() {
    for (int i = 0; i < columnsWide; i++) {
      final int indexGhost = i + (columnsWide-1)*columnsWide;
      final int indexVisible = indexGhost-columnsWide;
      _height[indexGhost] = _height[indexVisible];
    }
  }

  void _setReflectiveBoundaryEast() {
    for (int j = 0; j < columnsWide; j++) {
      int indexGhost = columnsWide-1 + j*columnsWide;
      int indexVisible = indexGhost-1;
      _height[indexGhost] = _height[indexVisible];
    }
  }

  void _setReflectiveBoundarySouth() {
    for (int i = 0; i < columnsWide; i++) {
      final int indexGhost = i;
      final int indexVisible = indexGhost+columnsWide;
      _height[indexGhost] = _height[indexVisible];
    }
  }

  void _setReflectiveBoundaryWest() {
    for (int j = 0; j < columnsWide; j++) {
      int indexGhost = j*columnsWide;
      int indexVisible = indexGhost+1;
      _height[indexGhost] = _height[indexVisible];
    }
  }

  void setReflectiveBoundaryAll() {
    _setReflectiveBoundaryNorth();
    _setReflectiveBoundarySouth();
    _setReflectiveBoundaryEast();
    _setReflectiveBoundaryWest();
  }

  void _setFlowBoundaryNorth(num dh) {
    for (int i = 0; i < columnsWide; i++) {
      final int indexGhost = i + (columnsWide-1)*columnsWide;
      final int indexVisible = indexGhost-columnsWide;
      _height[indexGhost] += dh;
    }
  }

  void _setFlowBoundaryEast(num dh) {
    for (int j = 0; j < columnsWide; j++) {
      int indexGhost = columnsWide-1 + j*columnsWide;
      int indexVisible = indexGhost-1;
      _height[indexGhost] += dh;
    }
  }

  void _setFlowBoundarySouth(num dh) {
    for (int i = 0; i < columnsWide; i++) {
      final int indexGhost = i;
      final int indexVisible = indexGhost+columnsWide;
      _height[indexGhost] += dh;
    }
  }

  void _setFlowBoundaryWest(num dh) {
    for (int j = 0; j < columnsWide; j++) {
      int indexGhost = j*columnsWide;
      int indexVisible = indexGhost+1;
      _height[indexGhost] += dh;
    }
  }

  void setFlowBoundary(int boundaryLabel, num dh) {
    if (boundaryLabel == BoundaryNorth) {
      _setFlowBoundaryNorth(dh);
    } else if (boundaryLabel == BoundaryEast) {
      _setFlowBoundaryEast(dh);
    } else if (boundaryLabel == BoundarySouth) {
      _setFlowBoundarySouth(dh);
    } else if (boundaryLabel == BoundaryWest) {
      _setFlowBoundaryWest(dh);
    }
  }

  void _setOpenBoundaryNorth() {
    num denom = 1.0 / (_h + _c * _dt);
    for (int i = 0; i < columnsWide; i++) {
      final int indexGhost = i + (columnsWide-1)*columnsWide;
      final int indexVisible = indexGhost-columnsWide;
      _height[indexGhost] = (_c * _dt * _height[indexVisible] + _height[indexGhost] * _h) * denom;
    }
  }

  void _setOpenBoundaryEast() {
    num denom = 1.0 / (_h + _c * _dt);
    for (int j = 0; j < columnsWide; j++) {
      int indexGhost = columnsWide-1 + j*columnsWide;
      int indexVisible = indexGhost-1;
      _height[indexGhost] = (_c * _dt * _height[indexVisible] + _height[indexGhost] * _h) * denom;
    }
  }

  void _setOpenBoundarySouth() {
    num denom = 1.0 / (_h + _c * _dt);
    for (int i = 0; i < columnsWide; i++) {
      final int indexGhost = i;
      final int indexVisible = indexGhost+columnsWide;
      _height[indexGhost] = (_c * _dt * _height[indexVisible] + _height[indexGhost] * _h) * denom;
    }
  }

  void _setOpenBoundaryWest() {
    num denom = 1.0 / (_h + _c * _dt);
    for (int j = 0; j < columnsWide; j++) {
      int indexGhost = j*columnsWide;
      int indexVisible = indexGhost+1;
      _height[indexGhost] = (_c * _dt * _height[indexVisible] + _height[indexGhost] * _h) * denom;
    }
  }

  void setReflectiveBoundary(int boundaryLabel) {
    if (boundaryLabel == BoundaryNorth) {
      _setReflectiveBoundaryNorth();
    } else if (boundaryLabel == BoundaryEast) {
      _setReflectiveBoundaryEast();
    } else if (boundaryLabel == BoundarySouth) {
      _setReflectiveBoundarySouth();
    } else if (boundaryLabel == BoundaryWest) {
      _setReflectiveBoundaryWest();
    }
  }

  void setOpenBoundaryAll() {
    _setOpenBoundaryNorth();
    _setOpenBoundaryEast();
    _setOpenBoundarySouth();
    _setOpenBoundaryWest();
  }
  void setOpenBoundary(int boundaryLabel) {
    if (boundaryLabel == BoundaryNorth) {
      _setOpenBoundaryNorth();
    } else if (boundaryLabel == BoundaryEast) {
      _setOpenBoundaryEast();
    } else if (boundaryLabel == BoundarySouth) {
      _setOpenBoundarySouth();
    } else if (boundaryLabel == BoundaryWest) {
      _setOpenBoundaryWest();
    }
  }
}