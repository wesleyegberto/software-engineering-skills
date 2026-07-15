---
metadata:
  author: https://github.com/Jeffallan
---

# Spring Boot Patterns - Caching, Async, Filters & Observability

Complementary patterns for production-grade Spring Boot services. Load when implementing caching, async processing, request filters, rate limiting, scheduled jobs, or setting up observability.

## Caching

Requires `@EnableCaching` on a `@Configuration` class.

```java
@Service
public class MarketCacheService {
  private final MarketRepository repo;

  public MarketCacheService(MarketRepository repo) {
    this.repo = repo;
  }

  @Cacheable(value = "market", key = "#id")
  public Market getById(Long id) {
    return repo.findById(id)
        .map(Market::from)
        .orElseThrow(() -> new EntityNotFoundException("Market not found"));
  }

  @CacheEvict(value = "market", key = "#id")
  public void evict(Long id) {}
}
```

---

## Async Processing

Requires `@EnableAsync` on a `@Configuration` class.

```java
@Service
public class NotificationService {
  @Async
  public CompletableFuture<Void> sendAsync(Notification notification) {
    // send email/SMS
    return CompletableFuture.completedFuture(null);
  }
}
```

MDC context does not propagate automatically to new threads — copy it explicitly when logging inside async methods (see `references/logging.md` for the pattern).

---

## Request Logging Filter

```java
@Component
public class RequestLoggingFilter extends OncePerRequestFilter {
  private static final Logger log = LoggerFactory.getLogger(RequestLoggingFilter.class);

  @Override
  protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
      FilterChain filterChain) throws ServletException, IOException {
    long start = System.currentTimeMillis();
    try {
      filterChain.doFilter(request, response);
    } finally {
      long duration = System.currentTimeMillis() - start;
      log.info("req method={} uri={} status={} durationMs={}",
          request.getMethod(), request.getRequestURI(), response.getStatus(), duration);
    }
  }
}
```

---

## Rate Limiting (Bucket4j)

**Security note on client IP**: `X-Forwarded-For` is spoofable unless Spring is configured to trust the proxy. Only use forwarded headers when:
1. The app is behind a trusted reverse proxy (nginx, AWS ALB, etc.)
2. `server.forward-headers-strategy=NATIVE` (or `FRAMEWORK`) is set in `application.properties`
3. The proxy overwrites (not appends) `X-Forwarded-For`

When `ForwardedHeaderFilter` is properly configured, `request.getRemoteAddr()` returns the correct client IP automatically.

```java
@Component
public class RateLimitFilter extends OncePerRequestFilter {
  private final Map<String, Bucket> buckets = new ConcurrentHashMap<>();

  /*
   * SECURITY: Uses request.getRemoteAddr() for client identification.
   * Configure server.forward-headers-strategy and a trusted proxy to
   * get the real client IP behind a load balancer.
   * Do NOT read X-Forwarded-For directly — it is trivially spoofable.
   */
  @Override
  protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
      FilterChain filterChain) throws ServletException, IOException {
    String clientIp = request.getRemoteAddr();

    Bucket bucket = buckets.computeIfAbsent(clientIp,
        k -> Bucket.builder()
            .addLimit(Bandwidth.classic(100, Refill.greedy(100, Duration.ofMinutes(1))))
            .build());

    if (bucket.tryConsume(1)) {
      filterChain.doFilter(request, response);
    } else {
      response.setStatus(HttpStatus.TOO_MANY_REQUESTS.value());
    }
  }
}
```

---

## Error-Resilient External Calls

For reactive WebClient retry, see `references/web.md`. Use the pattern below only for synchronous/blocking callers that cannot use reactor operators.

```java
public <T> T withRetry(Supplier<T> supplier, int maxRetries) {
  int attempts = 0;
  while (true) {
    try {
      return supplier.get();
    } catch (Exception ex) {
      attempts++;
      if (attempts >= maxRetries) throw ex;
      try {
        Thread.sleep((long) Math.pow(2, attempts) * 100L);
      } catch (InterruptedException ie) {
        Thread.currentThread().interrupt();
        throw ex;
      }
    }
  }
}
```

---

## Background Jobs

Use `@Scheduled` for periodic tasks or integrate with a queue (Kafka, SQS, RabbitMQ) for event-driven jobs. Keep handlers idempotent and observable.

```java
@Component
public class CleanupJob {
  private static final Logger log = LoggerFactory.getLogger(CleanupJob.class);

  @Scheduled(cron = "0 0 2 * * *") // every day at 02:00
  public void cleanExpiredData() {
    log.info("cleanup_start");
    // idempotent cleanup logic
    log.info("cleanup_done");
  }
}
```

Requires `@EnableScheduling` on a `@Configuration` class.

---

## Observability

- **Structured logging (JSON)** — via Logback encoder or Spring Boot 3.4+ native support (see `references/logging.md`)
- **Metrics** — Micrometer + Prometheus/OTel: add `spring-boot-starter-actuator` and `micrometer-registry-prometheus`
- **Tracing** — Micrometer Tracing with OpenTelemetry or Brave backend

```yaml
# application.yml — expose actuator endpoints
management:
  endpoints:
    web:
      exposure:
        include: health, info, prometheus
  metrics:
    export:
      prometheus:
        enabled: true
```

---

## Production Defaults

- Constructor injection everywhere — avoid `@Autowired` on fields
- Enable RFC 7807 error responses: `spring.mvc.problemdetails.enabled=true` (Spring Boot 3+)
- Size HikariCP pools for workload; always set `connection-timeout` and `max-lifetime`
- `@Transactional(readOnly = true)` on read-only service methods for performance
- Use `@NonNull` and `Optional` to make null-handling explicit
- Keep controllers thin, services focused, repositories simple, errors handled centrally
