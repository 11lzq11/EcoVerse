class PerlinNoise {
  final List<int> perm;

  PerlinNoise([int seed = 0]) : perm = _generatePerm(seed);

  static List<int> _generatePerm(int seed) {
    final p = List<int>.generate(256, (i) => i);
    final rng = Random(seed);
    for (int i = 255; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final temp = p[i];
      p[i] = p[j];
      p[j] = temp;
    }
    return p + p;
  }

  double fade(double t) => t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
  double lerp(double a, double b, double t) => a + t * (b - a);

  double grad(int hash, double x, double y) {
    final h = hash & 3;
    final u = h < 2 ? x : y;
    final v = h < 2 ? y : x;
    return ((h & 1) != 0 ? -u : u) + ((h & 2) != 0 ? -v : v);
  }

  double noise(double x, double y) {
    final int X = x.floor() & 255;
    final int Y = y.floor() & 255;
    x -= x.floor();
    y -= y.floor();
    final u = fade(x);
    final v = fade(y);
    final A = perm[X] + Y;
    final B = perm[X + 1] + Y;
    return lerp(
      lerp(grad(perm[A], x, y), grad(perm[B], x - 1, y), u),
      lerp(grad(perm[A + 1], x, y - 1), grad(perm[B + 1], x - 1, y - 1), u),
      v,
    );
  }

  double octaveNoise(double x, double y, {int octaves = 4, double persistence = 0.5}) {
    double total = 0;
    double frequency = 1;
    double amplitude = 1;
    double maxValue = 0;
    for (int i = 0; i < octaves; i++) {
      total += noise(x * frequency, y * frequency) * amplitude;
      maxValue += amplitude;
      amplitude *= persistence;
      frequency *= 2;
    }
    return total / maxValue;
  }
}