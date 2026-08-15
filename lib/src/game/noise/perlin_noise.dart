import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';

/// Perlin noise implementation for procedural terrain generation
class PerlinNoise {
  final List<int> _perm;
  
  PerlinNoise([int seed = 0]) : _perm = _generatePermutation(seed) {
  }
  
  static List<int> _generatePermutation(int seed) {
    final perm = List<int>.generate(512, (i) => i % 256);
    final random = math.Random(seed);
    
    // Fisher-Yates shuffle
    for (var i = 255; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = perm[i];
      perm[i] = perm[j];
      perm[j] = temp;
    }
    
    // Duplicate for overflow handling
    for (var i = 0; i < 256; i++) {
      perm[256 + i] = perm[i];
    }
    
    return perm;
  }
  
  /// 1D noise
  double noise1D(double x) {
    final xi = x.floor();
    final xf = x - xi;
    
    final u = fade(xf);
    final g0 = grad(xi);
    final g1 = grad(xi + 1);
    
    return lerp(g0, g1, u);
  }
  
  /// 2D noise
  double noise2D(double x, double y) {
    final xi = x.floor();
    final yi = y.floor();
    final xf = x - xi;
    final yf = y - yi;
    
    final u = fade(xf);
    final v = fade(yf);
    
    final aa = _perm[_perm[xi & 255] + yi & 255] & 3;
    final ab = _perm[_perm[xi & 255] + (yi + 1) & 255] & 3;
    final ba = _perm[_perm[xi + 1] + yi & 255] & 3;
    final bb = _perm[_perm[xi + 1] + (yi + 1) & 255] & 3;
    
    final x1 = lerp(grad(aa, xf, yf), grad(ba, xf - 1, yf), u);
    final x2 = lerp(grad(ab, xf, yf - 1), grad(bb, xf - 1, yf - 1), u);
    
    return lerp(x1, x2, v);
  }
  
  /// 3D noise
  double noise3D(double x, double y, double z) {
    final xi = x.floor();
    final yi = y.floor();
    final zi = z.floor();
    final xf = x - xi;
    final yf = y - yi;
    final zf = z - zi;
    
    final u = fade(xf);
    final v = fade(yf);
    final w = fade(zf);
    
    final n = xi + yi * 57 + zi * 113;
    
    final aaa = _perm[_perm[_perm[n & 255] + yi & 255] + zi & 255] & 3;
    final aba = _perm[_perm[_perm[n + 1] + yi & 255] + zi & 255] & 3;
    final baa = _perm[_perm[_perm[n + 57] + yi & 255] + zi & 255] & 3;
    final bba = _perm[_perm[_perm[n + 58] + yi & 255] + zi & 255] & 3;
    final aab = _perm[_perm[_perm[n + 113] + yi & 255] + (zi + 1) & 255] & 3;
    final abb = _perm[_perm[_perm[n + 114] + yi & 255] + (zi + 1) & 255] & 3;
    final bab = _perm[_perm[_perm[n + 170] + yi & 255] + (zi + 1) & 255] & 3;
    final bbb = _perm[_perm[_perm[n + 171] + yi & 255] + (zi + 1) & 255] & 3;
    
    final x1 = lerp3(
      grad(aaa, xf, yf, zf),
      grad(baa, xf - 1, yf, zf),
      grad(aba, xf, yf - 1, zf),
      grad(bba, xf - 1, yf - 1, zf),
      u, v, w
    );
    
    final x2 = lerp3(
      grad(aab, xf, yf, zf - 1),
      grad(bab, xf - 1, yf, zf - 1),
      grad(abb, xf, yf - 1, zf - 1),
      grad(bbb, xf - 1, yf - 1, zf - 1),
      u, v, w
    );
    
    return lerp(x1, x2, w);
  }
  
  double fade(double t) => t * t * t * (t * (t * 6 - 15) + 10);
  
  double lerp(double a, double b, double t) => a + t * (b - a);
  
  double grad(int hash, [double x = 0, double y = 0, double z = 0]) {
    double result = 0;
    if ((hash & 1) != 0) result += x; else result -= x;
    if ((hash & 2) != 0) result += y; else result -= y;
    if ((hash & 4) != 0) result += z; else result -= z;
    return result;
  }
  
  double lerp3(double a, double b, double c, double d, double x, double y, double z) {
    return lerp(
      lerp(lerp(a, b, x), lerp(c, d, x), y),
      lerp(lerp(a, b, x), lerp(c, d, x), y),
      z
    );
  }
}
