```bash
> zig build-exe Benchmark.zig -O ReleaseFast && poop -d 30000 './Benchmark german' './Benchmark normal'
Benchmark 1 (18 runs): ./Benchmark german
  measurement          mean ± σ            min … max           outliers         delta
  wall_time          1.76s  ± 54.8ms    1.62s  … 1.93s           3 (17%)        0%
  peak_rss            618KB ±  965       614KB …  618KB          1 ( 6%)        0%
  cpu_cycles          363M  ± 4.19M      355M  …  371M           0 ( 0%)        0%
  instructions        113M  ± 86.1K      113M  …  113M           2 (11%)        0%
  cache_references   1.08M  ± 97.7K      934K  … 1.27M           0 ( 0%)        0%
  cache_misses       7.94   ± 27.4         0   …  117            2 (11%)        0%
  branch_misses       798K  ± 10.3K      775K  …  829K           2 (11%)        0%
Benchmark 2 (14 runs): ./Benchmark normal
  measurement          mean ± σ            min … max           outliers         delta
  wall_time          2.22s  ± 50.6ms    2.05s  … 2.25s           1 ( 7%)        💩+ 26.2% ±  2.2%
  peak_rss            647KB ±    0       647KB …  647KB          0 ( 0%)        💩+  4.7% ±  0.1%
  cpu_cycles          435M  ± 2.66M      428M  …  440M           1 ( 7%)        💩+ 20.0% ±  0.7%
  instructions        124M  ± 79.9K      123M  …  124M           1 ( 7%)        💩+  9.2% ±  0.1%
  cache_references   1.22M  ± 51.0K     1.12M  … 1.31M           0 ( 0%)        💩+ 12.5% ±  5.4%
  cache_misses       0.93   ± 1.21         0   …    4            0 ( 0%)          - 88.3% ± 189.0%
  branch_misses       788K  ± 5.79K      772K  …  794K           1 ( 7%)          -  1.3% ±  0.8%
```
