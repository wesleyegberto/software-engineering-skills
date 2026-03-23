# Stress Testing — Thread Pool Starvation

To simulate and observe thread pool starvation:

1. **High concurrency:** Use 100+ simultaneous virtual threads in JMeter.
2. **Duration:** Configure for several minutes with enough loops to sustain pressure.
3. **Blocking endpoint:** The endpoint must have operations that keep threads busy (synchronous I/O, sleeps).
4. **Monitor metrics:** CPU, memory, response time, active threads, and thread pool queues via Actuator or JMX.
5. **Limited pool:** Configure a small pool (10–20 threads) to make starvation easier to observe.

---

## Micro-benchmarks with JMH

Add JMH only when you need benchmark data to justify an optimization decision.

```java
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.MICROSECONDS)
@State(Scope.Benchmark)
@Fork(value = 2, warmups = 1)
@Warmup(iterations = 3)
@Measurement(iterations = 5)
public class UserServiceBenchmark {

    private UserService userService;

    @Setup
    public void setup() {
        userService = new UserService(/* deps */);
    }

    @Benchmark
    public void benchmarkFindUser() {
        userService.findById(1L);
    }

    public static void main(String[] args) throws Exception {
        Options opt = new OptionsBuilder()
            .include(UserServiceBenchmark.class.getSimpleName())
            .build();
        new Runner(opt).run();
    }
}
```
