# React Code Examples

## Custom Hook with TypeScript Generics

Generic data-fetching hook with cancellation, error handling, and refetch support.

```tsx
import { useState, useEffect } from 'react';

interface UseFetchResult<T> {
  data: T | null;
  loading: boolean;
  error: Error | null;
  refetch: () => void;
}

export function useFetch<T>(url: string): UseFetchResult<T> {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);
  const [refetchCounter, setRefetchCounter] = useState(0);

  useEffect(() => {
    let cancelled = false;

    const fetchData = async () => {
      try {
        setLoading(true);
        setError(null);

        const response = await fetch(url);
        if (!response.ok) throw new Error(`HTTP error ${response.status}`);

        const json = await response.json();
        if (!cancelled) setData(json);
      } catch (err) {
        if (!cancelled) setError(err instanceof Error ? err : new Error('Unknown error'));
      } finally {
        if (!cancelled) setLoading(false);
      }
    };

    fetchData();
    return () => { cancelled = true; };
  }, [url, refetchCounter]);

  return { data, loading, error, refetch: () => setRefetchCounter(p => p + 1) };
}

// Usage
function UserList() {
  const { data, loading, error } = useFetch<User[]>('/api/users');

  if (loading) return <div>Loading...</div>;
  if (error) return <div>Error: {error.message}</div>;
  if (!data) return null;

  return (
    <ul>
      {data.map(user => <li key={user.id}>{user.name}</li>)}
    </ul>
  );
}
```

## Error Boundary with TypeScript

Class component required for error boundaries — wrap async/data-dependent subtrees.

```tsx
import { Component, ErrorInfo, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
}

interface State {
  hasError: boolean;
  error: Error | null;
}

export class ErrorBoundary extends Component<Props, State> {
  state: State = { hasError: false, error: null };

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, info: ErrorInfo) {
    console.error('ErrorBoundary caught:', error, info);
    // reportToErrorService(error, info);
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback ?? (
        <div role="alert">
          <h2>Something went wrong</h2>
          <details>
            <summary>Error details</summary>
            <pre>{this.state.error?.message}</pre>
          </details>
          <button onClick={() => this.setState({ hasError: false, error: null })}>
            Try again
          </button>
        </div>
      );
    }
    return this.props.children;
  }
}
```

## Form with Actions and useFormStatus (React 19)

```tsx
import { useFormStatus } from 'react-dom';
import { useActionState } from 'react';

function SubmitButton() {
  const { pending } = useFormStatus();
  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Submitting...' : 'Submit'}
    </button>
  );
}

interface FormState { error?: string; success?: boolean; }

async function createPost(prevState: FormState, formData: FormData): Promise<FormState> {
  const title = formData.get('title') as string;
  const content = formData.get('content') as string;

  if (!title || !content) return { error: 'Title and content are required' };

  try {
    const res = await fetch('/api/posts', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title, content }),
    });
    if (!res.ok) throw new Error('Failed to create post');
    return { success: true };
  } catch {
    return { error: 'Failed to create post' };
  }
}

export function CreatePostForm() {
  const [state, formAction] = useActionState(createPost, {});

  return (
    <form action={formAction}>
      <input name="title" placeholder="Title" required />
      <textarea name="content" placeholder="Content" required />
      {state.error && <p className="error">{state.error}</p>}
      {state.success && <p className="success">Post created!</p>}
      <SubmitButton />
    </form>
  );
}
```

## Optimistic Updates with useOptimistic (React 19)

```tsx
import { useState, useOptimistic, useTransition } from 'react';

interface Message { id: string; text: string; sending?: boolean; }

export function MessageList({ initialMessages }: { initialMessages: Message[] }) {
  const [messages, setMessages] = useState<Message[]>(initialMessages);
  const [optimisticMessages, addOptimisticMessage] = useOptimistic(
    messages,
    (state, newMessage: Message) => [...state, newMessage]
  );
  const [, startTransition] = useTransition();

  const handleSend = (text: string) => {
    addOptimisticMessage({ id: `temp-${Date.now()}`, text, sending: true });

    startTransition(async () => {
      const res = await fetch('/api/messages', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ text }),
      });
      const saved = await res.json();
      setMessages(prev => [...prev, saved]);
    });
  };

  return (
    <div>
      {optimisticMessages.map(msg => (
        <div key={msg.id} className={msg.sending ? 'opacity-50' : ''}>
          {msg.text}
        </div>
      ))}
      <MessageInput onSend={handleSend} />
    </div>
  );
}
```
