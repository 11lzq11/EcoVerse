import 'dart:math' as math;

class PerlinNoise {
  final List<double> _perm;
  PerlinNoise([int seed = 0]) : _perm = _makePerm(seed);

  static List<double> _makePerm(int seed) {
    final p = List<double>.generate(256, (i) => i.toDouble());
    final r = math.Random(seed);
    for (int i = 255; i > 0; i--) {
      final j = r.nextInt(i + 1);
      final t = p[i]; p[i] = p[j]; p[j] = t;
    }
    return p + p;
  }

  double fade(double t) => t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
  double lerp(double a, double b, double t) => a + t * (b - a);
  double grad(int hash, double x) => (hash & 1) == 0 ? x : -x;

  double noise(double x) {
    final int X = x.floor() & 255;
    x -= x.floor();
    final double u = fade(x);
    return lerp(grad(_perm[X], x), grad(_perm[X + 1], x - 1), u);
  }

  double octaveNoise(double x, {int octaves = 4, double persistence = 0.5}) {
    double total = 0, frequency = 1, amplitude = 1, maxValue = 0;
    for (int i = 0; i < octaves; i++) {
      total += noise(x * frequency) * amplitude;
      maxValue += amplitude;
      amplitude *= persistence;
      frequency *= 2;
    }
    return total / maxValue;
  }
}
