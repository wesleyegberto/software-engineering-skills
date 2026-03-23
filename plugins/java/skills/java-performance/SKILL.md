---
name: java-performance
description: 'JVM performance tuning guide — heap size configuration, GC selection, Kubernetes CPU throttling, and Prometheus monitoring. Use when optimizing Java applications, configuring the JVM for containers or Kubernetes, choosing the right Garbage Collector (G1, ZGC, ParallelGC), diagnosing memory or latency issues, or understanding Spring Boot executor metrics.'
metadata:
  scope: optimization
  version: "1.0.0"
---

# JVM Performance

> Always configure the JVM — default settings were designed for 2000s-era environments.

## When to Use This Skill

- Configure JVM for Docker containers or Kubernetes
- Choose and tune the Garbage Collector (GC)
- Diagnose OutOfMemoryError, high pause times, or CPU throttling
- Interpret Prometheus executor metrics in Spring Boot
- Compare scale up vs scale out strategies for JVMs

---

## JVM Ergonomics

Use `-XX:+PrintFlagsFinal` to view all active JVM settings.

Aggressive flags (use with caution):
```
-XX:+AggressiveHeap
-XX:+AggressiveOpts
```

> The JVM does not know it is running in a container — configure explicitly to avoid inadequate defaults.

---

## Heap Size

### How the JVM calculates automatically

| Available Memory | Default Heap |
|------------------|--------------|
| Up to 256 MB     | 50%          |
| 256–512 MB       | 126 MB fixed |
| Above 512 MB     | 25%          |

### Configuration flags

```bash
# Fixed values
-Xms 50m          # minimum
-Xmx 1g           # maximum

# Container percentage (recommended)
-XX:MaxRAMPercentage=74
```

### Microsoft Recommendations

**Servers:**
- Set whatever value the application requires.

**Containers:**
- Respect the 75% limit of the container memory.
- Be careful with **off-heap** memory: JNI, FFMI, Spark, Pinot, Elasticsearch.
- `-Xmx`: good for well-sized, stable workloads.
- `-XX:MaxRAMPercentage`: better for workloads that scale.
- Consider `MinHeapSize == MaxHeapSize` (early research suggests this).
- `-XX:+AlwaysPreTouch`: locks the defined memory at startup (startup cost, but eliminates runtime memory checks).

---

## Garbage Collector

### Default by version

| Version   | Default GC                                   |
|-----------|----------------------------------------------|
| Java 8    | SerialGC or ParallelGC                       |
| Java 9+   | G1GC (real default)                          |
| Java 11+  | SerialGC (< 2 CPUs and < 1792 MB RAM)        |
| Java 11+  | G1GC or ParallelGC (with sufficient resources) |

### Processors visible to the JVM

**Outside container:** uses `Runtime.availableProcessors()`

**Inside container:** based on `cpu.period`, `cpu.quota` or `cpu.share`
- 1–1000m → 1 CPU
- 1001–2000m → 2 CPUs

### Recommendations by heap size

| Heap Size     | Recommended GC                          |
|---------------|-----------------------------------------|
| Up to 2 GB    | **ParallelGC** (best throughput)        |
| 2–4 GB        | ParallelGC or **G1GC**                  |
| Above 4 GB    | **G1GC** or **ZGC**                     |

> ParallelGC triggers Stop-the-World → impacts latency (tail latency).

### G1GC

- Pauses range from milliseconds to seconds.
- Divides memory into regions of 1–32 MB.
- Good balance between throughput and latency.

### ZGC

- Designed for **low latency** and **high scalability**.
- Does most of its work while application threads are still running.
- Maximum pause: **~1ms**.
- Supports heaps from hundreds of MB to TB.
- Requires sufficient resources (memory and CPU) to free memory faster than application threads consume it.

---

## Kubernetes

### CPU Throttling

> CPU requests in Kubernetes define the CPU time available per period.

- **1000m** = the application can use one full CPU per 100ms period.
- If multiple threads sum > 1000m in the period → **throttled** for up to 60ms.

**Processors visible to the JVM in Kubernetes:**

| CPU Limit   | CPUs for JVM |
|-------------|--------------|
| 1–1000m     | 1 CPU        |
| 1001–2000m  | 2 CPUs       |
| 2001–3000m  | 3 CPUs       |

### Trick: Deceiving the JVM

```bash
-XX:ActiveProcessorCount=4
```

Useful for **IO-bound** applications in containers with 1–2 cores: the JVM increases its internal thread pool, improving the capacity to wait for IO in parallel.

### Recommendations for JVM on Kubernetes

- **Minimum recommended:** 1000m CPU limit with 2 CPUs declared for the JVM.
- **Ideal:** 2000m CPU limit + 2 CPUs for JVM + heap above 2 GB.
- JVM **performs better with scale up** (not scale out).
  - Scale up saves memory (single metaspace/non-heap).
  - Scale up uses only one GC for the entire heap.

### Recommended startup strategy

1. Start with **ParallelGC** for small heaps (avoid JVM default ergonomics).
2. Use **JFR (Java Flight Recorder)** and **GC logs** to understand bottlenecks.
3. Evolve to G1GC or ZGC based on collected data.

---

## Diagnostic Tools

```bash
# List Java processes
jps

# Memory histogram by object type
jmap -histo $PID

# ClassLoader statistics
jmap -clstats $PID
```

---

## Prometheus Metrics (Spring Boot)

### `executor_queued_tasks`

Shows how many tasks are waiting for execution in the executor queue.

- Value **0.0**: pool handles the demand — no backlog.
- Value increases when all threads are busy and new tasks arrive.

### `executor_queue_remaining_tasks`

Shows how many free slots remain in the queue.

- Value **100.0**: no tasks waiting — system not overloaded.
- Decreases when the pool is saturated and tasks are queued.

**Spring Boot configuration:**

```yaml
spring:
  task:
    execution:
      pool:
        queue-capacity: 100
```

---

## Customization by Java Version

### Java 8

```bash
-XX:+UseStringDeduplicationJVM  # reuse equal strings
-XX:+UseSerialGC                # single thread
-XX:+UseConcMarkSweepGC         # multiple threads
-XX:+UseG1GC                    # large heap
```

### Java 9

- G1GC as default.
- Divides memory into regions of 1–32 MB.

### Java 11

```bash
# Epsilon GC — does nothing (ideal for benchmarks and short-lived processes)
-XX:+UseEpsilonGC

# ZGC — low latency, experimental in this version
-XX:+UseZGC
```

### Java 12+

- Microbenchmark suite included.
- CDS Archives enabled by default.
- Ongoing improvements to G1GC.

---

## References

- [Java Memory Management — Datadog](https://www.datadoghq.com/blog/java-memory-management/)
- [Hunting Memory Leaks in Java — Toptal](https://www.toptal.com/java/hunting-memory-leaks-in-java)
- [Java Memory Leaks — Baeldung](https://www.baeldung.com/java-memory-leaks)
- [Spring Boot & JVM](https://medium.com/@jean_sossmeier/spring-boot-jvm-1eea422be930)
- [JVM Tuning — Uber Engineering](https://eng.uber.com/jvm-tuning-garbage-collection/)
- [HotSpot GC Tuning Guide — Oracle](https://docs.oracle.com/en/java/javase/17/gctuning/garbage-collector-implementation.html)
- Talks:
  - [Java Performance Tuning on Kubernetes — Bruno Borges](https://www.youtube.com/watch?v=uGt1WKZK__0)
  - [Secrets of Performance Tuning Java on Kubernetes](https://www.slideshare.net/brunoborges/secrets-of-performance-tuning-java-on-kubernetes-252885907)
  - [Optimizing Java Applications on Kubernetes: Beyond the Basics](https://www.infoq.com/presentations/optimizing-java-app-kubernetes/)
  - [JavaOne 25 — GC in Java: Performance Benefits of Upgrading](https://www.youtube.com/watch?v=0IuYYbXD-Hw)
