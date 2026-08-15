import 'dart:math' as math;

class PerlinNoise {
  final List<double> permutation;
  
  PerlinNoise([int seed = 0]) : permutation = _generatePermutation(seed) {
  }
  
  static List<double> _generatePermutation(int seed) {
    final List<double> p = List<double>.generate(256, (i) => i.toDouble());
    final math.Random rand = math.Random(seed);
    
    for (int i = 255; i > 0; i--) {
      final int j = rand.nextInt(i + 1);
      final double temp = p[i];
      p[i] = p[j];
      p[j] = temp;
    }
    
    return p + p;
  }
  
  double noise(double x) {
    final int X = x.floor() & 255;
    x -= x.floor();
    final double u = fade(x);
    
    final double y0 = lerp(grad(X, x), grad(X + 1, x - 1), u);
    final double y1 = lerp(grad(X + 256, x), grad(X + 257, x - 1), u);
    
    return lerp(y0, y1, ease(u));
  }
  
  double noise2D(double x, double y) {
    return (noise(x) + noise(y)) / 2;
  }
  
  double octaveNoise(double x, {int octaves = 4, double persistence = 0.5}) {
    double total = 0;
    double frequency = 1;
    double amplitude = 1;
    double maxValue = 0;
    
    for (int i = 0; i < octaves; i++) {
      total += noise(x * frequency) * amplitude;
      maxValue += amplitude;
      amplitude *= persistence;
      frequency *= 2;
    }
    
    return total / maxValue;
  }
  
  double grad(int hash, double x) {
    return (hash & 1) == 0 ? x : -x;
  }
  
  double fade(double t) => t * t * t * (t * (t * 6 - 15) + 10);
  
  double lerp(double a, double b, double t) => a + t * (b - a);
  
  double ease(double t) => t * t * (3 - 2 * t);
}
