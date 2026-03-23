# React 19 Features

## use() Hook

```tsx
import { use, Suspense } from 'react';

// Read promises in render
function Comments({ commentsPromise }: { commentsPromise: Promise<Comment[]> }) {
  const comments = use(commentsPromise);
  return (
    <ul>
      {comments.map(c => <li key={c.id}>{c.text}</li>)}
    </ul>
  );
}

// Parent creates promise, child reads it
function Post({ postId }: { postId: string }) {
  const commentsPromise = fetchComments(postId);

  return (
    <article>
      <PostContent id={postId} />
      <Suspense fallback={<CommentsSkeleton />}>
        <Comments commentsPromise={commentsPromise} />
      </Suspense>
    </article>
  );
}

// Read context conditionally
function Theme({ children }: { children: React.ReactNode }) {
  if (someCondition) {
    const theme = use(ThemeContext);
    return <div className={theme}>{children}</div>;
  }
  return children;
}
```

## useActionState

```tsx
'use client';
import { useActionState } from 'react';

interface FormState {
  error?: string;
  success?: boolean;
}

async function submitAction(prevState: FormState, formData: FormData): Promise<FormState> {
  'use server';
  const email = formData.get('email') as string;

  try {
    await subscribe(email);
    return { success: true };
  } catch {
    return { error: 'Failed to subscribe' };
  }
}

function NewsletterForm() {
  const [state, formAction, isPending] = useActionState(submitAction, {});

  return (
    <form action={formAction}>
      <input name="email" type="email" required disabled={isPending} />
      <button type="submit" disabled={isPending}>
        {isPending ? 'Subscribing...' : 'Subscribe'}
      </button>
      {state.error && <p className="error">{state.error}</p>}
      {state.success && <p className="success">Subscribed!</p>}
    </form>
  );
}
```

## useFormStatus

```tsx
'use client';
import { useFormStatus } from 'react-dom';

function SubmitButton() {
  const { pending, data, method, action } = useFormStatus();

  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Submitting...' : 'Submit'}
    </button>
  );
}

// Must be used inside a <form>
function ContactForm() {
  return (
    <form action={submitAction}>
      <input name="message" />
      <SubmitButton />
    </form>
  );
}
```

## useOptimistic

```tsx
'use client';
import { useOptimistic } from 'react';

function TodoList({ todos }: { todos: Todo[] }) {
  const [optimisticTodos, addOptimisticTodo] = useOptimistic(
    todos,
    (state, newTodo: Todo) => [...state, newTodo]
  );

  async function addTodo(formData: FormData) {
    const text = formData.get('text') as string;

    // Immediately update UI
    addOptimisticTodo({ id: 'temp', text, completed: false });

    // Then persist
    await createTodo(text);
  }

  return (
    <>
      <ul>
        {optimisticTodos.map(todo => (
          <li key={todo.id}>{todo.text}</li>
        ))}
      </ul>
      <form action={addTodo}>
        <input name="text" />
        <button>Add</button>
      </form>
    </>
  );
}
```

## ref as Prop (No forwardRef)

```tsx
// React 19: ref is just a prop
function Input({ ref, ...props }: { ref?: React.Ref<HTMLInputElement> }) {
  return <input ref={ref} {...props} />;
}

// No need for forwardRef anymore
function Form() {
  const inputRef = useRef<HTMLInputElement>(null);
  return <Input ref={inputRef} placeholder="Enter text" />;
}
```

## Quick Reference

| Hook | Purpose |
|------|---------|
| `use()` | Read promise/context in render |
| `useActionState()` | Form action state + pending |
| `useFormStatus()` | Form pending state (child) |
| `useOptimistic()` | Optimistic UI updates |

| Pattern | When |
|---------|------|
| `use(promise)` | Suspense data fetching |
| `use(context)` | Conditional context read |
| `useActionState` | Server Actions with state |

## React 19.2 Features

### `<Activity>` Component

Preserves UI state when hidden — replaces manual `display:none` hacks. Children are kept mounted but hidden; state survives tab switches.

```tsx
import { Activity, useState } from 'react';

export function TabPanel() {
  const [activeTab, setActiveTab] = useState<'home' | 'profile' | 'settings'>('home');

  return (
    <div>
      <nav>
        <button onClick={() => setActiveTab('home')}>Home</button>
        <button onClick={() => setActiveTab('profile')}>Profile</button>
        <button onClick={() => setActiveTab('settings')}>Settings</button>
      </nav>

      {/* Activity preserves UI and state when hidden */}
      <Activity mode={activeTab === 'home' ? 'visible' : 'hidden'}>
        <HomeTab />
      </Activity>
      <Activity mode={activeTab === 'profile' ? 'visible' : 'hidden'}>
        <ProfileTab />
      </Activity>
      <Activity mode={activeTab === 'settings' ? 'visible' : 'hidden'}>
        <SettingsTab />
      </Activity>
    </div>
  );
}

function HomeTab() {
  // State is preserved when tab is hidden and restored when visible
  const [count, setCount] = useState(0);
  return (
    <div>
      <p>Count: {count}</p>
      <button onClick={() => setCount(count + 1)}>Increment</button>
    </div>
  );
}
```

### `useEffectEvent()` Hook

Extracts non-reactive logic from effects so theme/config changes don't cause reconnections. The event handler always sees the latest values without being listed as a dependency.

```tsx
import { useState, useEffect, useEffectEvent } from 'react';

interface ChatProps {
  roomId: string;
  theme: 'light' | 'dark';
}

export function ChatRoom({ roomId, theme }: ChatProps) {
  const [messages, setMessages] = useState<string[]>([]);

  // useEffectEvent extracts non-reactive logic from effects
  // theme changes won't cause reconnection
  const onMessage = useEffectEvent((message: string) => {
    console.log(`Received message in ${theme} theme:`, message);
    setMessages(prev => [...prev, message]);
  });

  useEffect(() => {
    // Only reconnect when roomId changes, not when theme changes
    const connection = createConnection(roomId);
    connection.on('message', onMessage);
    connection.connect();
    return () => connection.disconnect();
  }, [roomId]); // theme not in dependencies!

  return (
    <div className={theme}>
      {messages.map((msg, i) => <div key={i}>{msg}</div>)}
    </div>
  );
}
```

### `cacheSignal` in RSC

Listens for cache expiration to abort in-flight fetches. Use inside `cache()` wrapped RSC functions.

```tsx
import { cache, cacheSignal } from 'react';

const fetchUserData = cache(async (userId: string) => {
  const controller = new AbortController();
  const signal = cacheSignal();

  // Listen for cache expiration to abort the fetch
  signal.addEventListener('abort', () => {
    controller.abort();
  });

  const response = await fetch(`/api/users/${userId}`, {
    signal: controller.signal,
  });

  if (!response.ok) throw new Error('Failed to fetch user');
  return response.json();
});
```

### Context Without Provider

Render `<ThemeContext value={...}>` directly instead of `<ThemeContext.Provider>`.

```tsx
import { createContext, useContext, useState } from 'react';

interface ThemeContextType {
  theme: 'light' | 'dark';
  toggleTheme: () => void;
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined);

function App() {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');
  const value = { theme, toggleTheme: () => setTheme(p => p === 'light' ? 'dark' : 'light') };

  // React 19: render context directly, no .Provider needed
  return (
    <ThemeContext value={value}>
      <Header />
      <Main />
    </ThemeContext>
  );
}
```

### Ref Callback with Cleanup

Ref callbacks can now return a cleanup function, called when the element unmounts.

```tsx
function VideoPlayer() {
  // React 19: ref callback returns cleanup function
  const videoRef = (element: HTMLVideoElement | null) => {
    if (!element) return;

    const observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) element.play();
        else element.pause();
      });
    });

    observer.observe(element);

    // Cleanup called when element is removed
    return () => {
      observer.disconnect();
      element.pause();
    };
  };

  return <video ref={videoRef} src="/video.mp4" controls />;
}
```

### Document Metadata in Components

`<title>`, `<meta>`, and `<link>` placed inside components are automatically hoisted to `<head>`.

```tsx
function BlogPost({ post }: { post: Post }) {
  return (
    <article>
      {/* Hoisted to <head> automatically */}
      <title>{post.title} - My Blog</title>
      <meta name="description" content={post.excerpt} />
      <meta property="og:title" content={post.title} />
      <link rel="canonical" href={`https://myblog.com/posts/${post.slug}`} />

      <h1>{post.title}</h1>
      <div dangerouslySetInnerHTML={{ __html: post.content }} />
    </article>
  );
}
```

### `useDeferredValue` with Initial Value

New second parameter sets the initial deferred value before the first deferred render.

```tsx
import { useState, useDeferredValue } from 'react';

function SearchResults({ query }: { query: string }) {
  // React 19: second arg is the initial deferred value
  const deferredQuery = useDeferredValue(query, 'Loading...');

  const results = useSearchResults(deferredQuery);

  return (
    <div>
      <h3>Results for: {deferredQuery}</h3>
      {deferredQuery === 'Loading...' ? (
        <p>Preparing search...</p>
      ) : (
        <ul>{results.map(r => <li key={r.id}>{r.title}</li>)}</ul>
      )}
    </div>
  );
}
```

## React 19.2 Quick Reference

| Feature | Purpose |
|---------|---------|
| `<Activity mode="visible\|hidden">` | Preserve UI state across visibility changes |
| `useEffectEvent(fn)` | Non-reactive event handler inside effects |
| `cacheSignal()` | Abort fetch when RSC cache expires |
| `<Context value={...}>` | Context without `.Provider` |
| `ref={callback}` returning cleanup | Auto-cleanup on unmount |
| `<title>`, `<meta>` in components | Auto-hoisted to `<head>` |
| `useDeferredValue(val, initial)` | Initial value before first deferred render |
