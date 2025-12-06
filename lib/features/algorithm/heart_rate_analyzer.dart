// import 'dart:math';

// class HeartRateAnalyzer {
//   final void Function(int bpm) onBpmCalculated;
//   final int windowMs;
//   final int minPeakDistMs;
//   final int smoothMs;
//   final int
//   bpmUpdateIntervalMs; // khoảng thời gian tối thiểu giữa 2 lần update BPM

//   final List<_Sample> _buffer = [];
//   int _lastBpmTimeMs = 0; // lưu thời điểm lần cuối tính BPM

//   HeartRateAnalyzer({
//     required this.onBpmCalculated,
//     this.windowMs = 12000,
//     this.minPeakDistMs = 350,
//     this.smoothMs = 180,
//     this.bpmUpdateIntervalMs = 2000, // mặc định 2s mới cập nhật BPM một lần
//   });

//   void addSample(double intensity, int timestampMs) {
//     _buffer.add(_Sample(intensity, timestampMs));

//     // chỉ giữ dữ liệu trong 12s gần nhất
//     _buffer.removeWhere((s) => timestampMs - s.t > windowMs);

//     if (_buffer.length < 10) return;

//     // nếu chưa đủ 2s kể từ lần cập nhật BPM cuối => bỏ qua
//     if (timestampMs - _lastBpmTimeMs < bpmUpdateIntervalMs) return;

//     // làm mượt tín hiệu (moving average)
//     final smooth = _smooth(_buffer.map((e) => e.v).toList(), 5);

//     // tìm peaks
//     final peaks = _detectPeaks(smooth, threshold: 0.8);
//     if (peaks.length < 2) return;

//     // tính khoảng thời gian giữa các đỉnh
//     final intervals = <double>[];
//     for (int i = 1; i < peaks.length; i++) {
//       final dt = (_buffer[peaks[i]].t - _buffer[peaks[i - 1]].t).toDouble();
//       if (dt > minPeakDistMs) intervals.add(dt);
//     }

//     if (intervals.isEmpty) return;

//     // tính trung bình khoảng cách đỉnh -> BPM
//     final avgInterval = intervals.reduce((a, b) => a + b) / intervals.length;
//     final bpm = (60000 / avgInterval).round();

//     // giới hạn BPM hợp lý
//     if (bpm > 40 && bpm < 180) {
//       _lastBpmTimeMs = timestampMs; // cập nhật mốc thời gian lần cuối
//       onBpmCalculated(bpm);
//     }
//   }

//   List<double> _smooth(List<double> data, int window) {
//     final res = <double>[];
//     for (int i = 0; i < data.length; i++) {
//       final start = max(0, i - window);
//       final end = min(data.length - 1, i + window);
//       final subset = data.sublist(start, end);
//       res.add(subset.reduce((a, b) => a + b) / subset.length);
//     }
//     return res;
//   }

//   List<int> _detectPeaks(List<double> data, {double threshold = 0.8}) {
//     final maxVal = data.reduce(max);
//     final minVal = data.reduce(min);
//     final th = minVal + (maxVal - minVal) * threshold;

//     final peaks = <int>[];
//     for (int i = 1; i < data.length - 1; i++) {
//       if (data[i] > data[i - 1] && data[i] > data[i + 1] && data[i] > th) {
//         peaks.add(i);
//       }
//     }
//     return peaks;
//   }
// }

// class _Sample {
//   final double v;
//   final int t;
//   _Sample(this.v, this.t);
// }

import 'dart:collection';
import 'dart:math';

typedef BpmCallback = void Function(double bpm);

class HeartRateAnalyzerConfig {
  /// FPS camera (tạm coi đều; sau này bạn có thể chuyển sang timestamp thật).
  final double fps;

  /// Độ dài cửa sổ tính BPM (giây).
  final double windowSec;

  /// Chu kỳ cập nhật kết quả (giây).
  final double stepSec;

  /// Dải lọc sinh lý (Hz): 0.7–4.0 → ~42–240 BPM.
  final double hpHz;
  final double lpHz;

  /// Làm mượt ngắn bằng moving average (số mẫu). Nếu < 0 sẽ lấy ~0.2 * fps.
  final int smoothSamples;

  /// Khoảng cách đỉnh tối thiểu (ms) để chống đếm trùng.
  final int minPeakDistMs;

  /// Kẹp BPM hiển thị.
  final int bpmMin;
  final int bpmMax;

  const HeartRateAnalyzerConfig({
    required this.fps,
    this.windowSec = 12.0,
    this.stepSec = 1.0,
    this.hpHz = 0.7,
    this.lpHz = 4.0,
    this.smoothSamples = -1, // auto
    this.minPeakDistMs = 300,
    this.bpmMin = 40,
    this.bpmMax = 180,
  });
}

class HeartRateAnalyzer {
  final HeartRateAnalyzerConfig cfg;
  final BpmCallback? onBpmCalculated;

  final ListQueue<double> _buffer = ListQueue<double>();
  final int _maxSamples;
  final int _stepSamples;
  final int _smoothK;
  final int _minPeakDistSamples;

  // Trạng thái filter để chạy liên tục nhiều khung.
  double? _lastSample;
  double? _lastHp;
  double? _lastLp;
  double? _lastBpm;
  int _sinceLastEmit = 0;

  HeartRateAnalyzer(this.cfg, {this.onBpmCalculated})
    : _maxSamples = (cfg.windowSec * cfg.fps).round(),
      _stepSamples = max(1, (cfg.stepSec * cfg.fps).round()),
      _smoothK = (cfg.smoothSamples > 0)
          ? cfg.smoothSamples
          : max(3, (0.20 * cfg.fps).round()), // ≈ 200 ms
      _minPeakDistSamples = max(
        1,
        ((cfg.minPeakDistMs / 1000.0) * cfg.fps).round(),
      );

  /// them mau
  void addSample(double v) {
    _buffer.add(v);
    if (_buffer.length > _maxSamples) _buffer.removeFirst();

    _sinceLastEmit++;
    if (_sinceLastEmit >= _stepSamples) {
      _sinceLastEmit = 0;
      final bpm = _processWindow();
      if (bpm != null) onBpmCalculated?.call(bpm);
    }
  }

  // ========== Core pipeline ==========
  double? _processWindow() {
    if (_buffer.length < max(8, (cfg.fps * 5).round())) return null;

    final raw = _buffer.toList(growable: false);
    final dt = 1.0 / cfg.fps;

    // 1) High-pass 1 pole (detrend chậm)
    final hpA = _alphaHighPass(cfg.hpHz, dt);
    final hp = List<double>.filled(raw.length, 0.0);
    double yhp = _lastHp ?? 0.0;
    double xprev = _lastSample ?? raw.first;
    for (int i = 0; i < raw.length; i++) {
      final x = raw[i];
      yhp = hpA * (yhp + x - xprev);
      hp[i] = yhp;
      xprev = x;
    }
    _lastHp = yhp;
    _lastSample = raw.last;

    // 2) Low-pass 1 pole (chặn trên 4 Hz)
    final lpA = _alphaLowPass(cfg.lpHz, dt);
    final bp = List<double>.filled(hp.length, 0.0);
    double ylp = _lastLp ?? 0.0;
    for (int i = 0; i < hp.length; i++) {
      final x = hp[i];
      ylp = ylp + lpA * (x - ylp);
      bp[i] = ylp;
    }
    _lastLp = ylp;

    // 3) Làm mượt ngắn (moving average ~200 ms)
    final sm = _movingAverage(bp, _smoothK);

    // 4) Chuẩn hoá theo cửa sổ (z-score)
    final m = _mean(sm);
    final s = _std(sm, m);
    final z = s > 1e-9
        ? sm.map((v) => (v - m) / s).toList(growable: false)
        : List<double>.filled(sm.length, 0.0);

    // 5) Phát hiện đỉnh (ngưỡng động + min distance)
    final thr = max(0.5, _percentile(z, 0.75));
    final peaks = _findPeaks(
      z,
      threshold: thr,
      minDistance: _minPeakDistSamples,
    );
    if (peaks.length < 2) return null;

    // 6) RR → BPM (median để chống outlier) + kẹp + EMA hiển thị
    final rr = <double>[];
    for (int i = 1; i < peaks.length; i++) {
      final sec = (peaks[i] - peaks[i - 1]) / cfg.fps;
      final tmpBpm = 60.0 / sec;
      if (tmpBpm >= cfg.bpmMin && tmpBpm <= cfg.bpmMax) rr.add(sec);
    }
    if (rr.isEmpty) return null;

    final rrMed = _median(rr);
    double bpm = 60.0 / rrMed;
    bpm = bpm.clamp(cfg.bpmMin.toDouble(), cfg.bpmMax.toDouble());

    final smoothed = (_lastBpm == null) ? bpm : 0.7 * _lastBpm! + 0.3 * bpm;
    _lastBpm = smoothed;
    return smoothed;
  }

  // ========== Helpers ==========
  static double _alphaHighPass(double fc, double dt) {
    final rc = 1.0 / (2 * pi * fc);
    return rc / (rc + dt);
  }

  static double _alphaLowPass(double fc, double dt) {
    final rc = 1.0 / (2 * pi * fc);
    return dt / (rc + dt);
  }

  static List<double> _movingAverage(List<double> x, int k) {
    if (k <= 1 || x.length < k) return List<double>.from(x);
    final out = List<double>.filled(x.length, 0.0);
    double sum = 0;
    for (int i = 0; i < x.length; i++) {
      sum += x[i];
      if (i >= k) sum -= x[i - k];
      out[i] = i >= k - 1 ? sum / k : x[i];
    }
    return out;
  }

  static double _mean(List<double> x) {
    if (x.isEmpty) return 0;
    var s = 0.0;
    for (final v in x) s += v;
    return s / x.length;
  }

  static double _std(List<double> x, double m) {
    if (x.isEmpty) return 0;
    var s = 0.0;
    for (final v in x) {
      final d = v - m;
      s += d * d;
    }
    return sqrt(s / x.length);
  }

  static double _percentile(List<double> x, double p) {
    if (x.isEmpty) return 0;
    final a = List<double>.from(x)..sort();
    final idx = p * (a.length - 1);
    final i = idx.floor();
    final f = idx - i;
    if (i >= a.length - 1) return a.last;
    return a[i] * (1 - f) + a[i + 1] * f;
  }

  static List<int> _findPeaks(
    List<double> x, {
    required double threshold,
    required int minDistance,
  }) {
    final peaks = <int>[];
    var last = -minDistance - 1;
    for (int i = 1; i < x.length - 1; i++) {
      if (x[i] > threshold && x[i] >= x[i - 1] && x[i] > x[i + 1]) {
        if (i - last >= minDistance) {
          peaks.add(i);
          last = i;
        }
      }
    }
    return peaks;
  }

  static double _median(List<double> x) {
    final a = List<double>.from(x)..sort();
    final n = a.length;
    return n.isOdd ? a[n ~/ 2] : 0.5 * (a[n ~/ 2 - 1] + a[n ~/ 2]);
  }
}
