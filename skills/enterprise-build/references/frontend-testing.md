# Frontend Testing Reference

Companion to the enterprise-build skill. Backend TDD is covered in `SKILL.md` — this covers React component tests, hook tests, and E2E with Playwright.

---

## 1. React Component Testing (React Testing Library)

### Rendering

```jsx
import { render, screen } from '@testing-library/react';
import { OrderCard } from './OrderCard';

test('renders order number and customer name', () => {
  render(<OrderCard order={{ id: 1, orderNumber: 'ORD-100', customer: 'Jane' }} />);
  expect(screen.getByText('ORD-100')).toBeInTheDocument();
  expect(screen.getByText('Jane')).toBeInTheDocument();
});
```

### User Interaction

```jsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { Counter } from './Counter';

test('increments count on button click', async () => {
  const user = userEvent.setup();
  render(<Counter />);

  expect(screen.getByText('Count: 0')).toBeInTheDocument();
  await user.click(screen.getByRole('button', { name: /increment/i }));
  expect(screen.getByText('Count: 1')).toBeInTheDocument();
});

test('submits form with entered values', async () => {
  const onSubmit = jest.fn();
  const user = userEvent.setup();
  render(<ContactForm onSubmit={onSubmit} />);

  await user.type(screen.getByLabelText(/email/i), 'test@example.com');
  await user.click(screen.getByRole('button', { name: /submit/i }));

  expect(onSubmit).toHaveBeenCalledWith({ email: 'test@example.com' });
});
```

### Conditional Rendering

```jsx
test('shows error banner when error prop is set', () => {
  render(<Dashboard error="Something broke" />);
  expect(screen.getByRole('alert')).toHaveTextContent('Something broke');
});

test('hides admin controls for non-admin users', () => {
  render(<Dashboard user={{ role: 'viewer' }} />);
  expect(screen.queryByText('Delete All')).not.toBeInTheDocument();
});
```

### List Rendering

```jsx
test('renders a row for each order', () => {
  const orders = [
    { id: 1, number: 'ORD-1' },
    { id: 2, number: 'ORD-2' },
    { id: 3, number: 'ORD-3' },
  ];
  render(<OrderTable orders={orders} />);
  expect(screen.getAllByRole('row')).toHaveLength(4); // 3 data rows + 1 header
});
```

### Loading and Error States

```jsx
test('shows skeleton while loading', () => {
  render(<OrderList loading={true} orders={[]} />);
  expect(screen.getByTestId('skeleton-loader')).toBeInTheDocument();
  expect(screen.queryByRole('table')).not.toBeInTheDocument();
});

test('shows empty state when no orders exist', () => {
  render(<OrderList loading={false} orders={[]} />);
  expect(screen.getByText(/no orders found/i)).toBeInTheDocument();
});

test('shows error message on fetch failure', () => {
  render(<OrderList loading={false} orders={[]} error="Network error" />);
  expect(screen.getByRole('alert')).toHaveTextContent('Network error');
});
```

---

## 2. Hook Testing

### Basic Custom Hook

```jsx
import { renderHook, act } from '@testing-library/react';
import { useToggle } from './useToggle';

test('toggles between true and false', () => {
  const { result } = renderHook(() => useToggle(false));

  expect(result.current[0]).toBe(false);
  act(() => result.current[1]()); // call toggle
  expect(result.current[0]).toBe(true);
});
```

### Hook with API Call

```jsx
import { renderHook, waitFor } from '@testing-library/react';
import { useOrders } from './useOrders';

// Mock at module level
beforeEach(() => {
  global.fetch = jest.fn();
});
afterEach(() => {
  jest.restoreAllMocks();
});

test('fetches orders and exposes them', async () => {
  const mockOrders = [{ id: 1, number: 'ORD-1' }];
  global.fetch.mockResolvedValueOnce({
    ok: true,
    json: () => Promise.resolve(mockOrders),
  });

  const { result } = renderHook(() => useOrders());

  expect(result.current.loading).toBe(true);

  await waitFor(() => {
    expect(result.current.loading).toBe(false);
  });

  expect(result.current.orders).toEqual(mockOrders);
  expect(result.current.error).toBeNull();
});

test('exposes error when fetch fails', async () => {
  global.fetch.mockRejectedValueOnce(new Error('Network error'));

  const { result } = renderHook(() => useOrders());

  await waitFor(() => {
    expect(result.current.loading).toBe(false);
  });

  expect(result.current.error).toBe('Network error');
  expect(result.current.orders).toEqual([]);
});
```

### Hook with State Transitions

```jsx
test('transitions through idle → loading → success', async () => {
  global.fetch.mockResolvedValueOnce({
    ok: true,
    json: () => Promise.resolve({ saved: true }),
  });

  const { result } = renderHook(() => useSaveOrder());

  // idle
  expect(result.current.status).toBe('idle');

  // trigger save
  act(() => { result.current.save({ number: 'ORD-1' }); });
  expect(result.current.status).toBe('loading');

  // success
  await waitFor(() => {
    expect(result.current.status).toBe('success');
  });
});
```

---

## 3. E2E Testing (Playwright)

### Page Navigation

```js
import { test, expect } from '@playwright/test';

test('navigates from dashboard to order detail', async ({ page }) => {
  await page.goto('/dashboard');
  await page.getByRole('link', { name: 'ORD-100' }).click();
  await expect(page).toHaveURL(/\/orders\/100/);
  await expect(page.getByRole('heading', { name: 'ORD-100' })).toBeVisible();
});
```

### Form Submission

```js
test('creates a new supplier', async ({ page }) => {
  await page.goto('/suppliers/new');
  await page.getByLabel('Name').fill('Acme Corp');
  await page.getByLabel('Email').fill('acme@example.com');
  await page.getByRole('button', { name: 'Save' }).click();

  // Verify success feedback
  await expect(page.getByText('Supplier created')).toBeVisible();
  // Verify redirect
  await expect(page).toHaveURL(/\/suppliers\/\d+/);
});
```

### Modal Interaction

```js
test('confirm dialog prevents accidental delete', async ({ page }) => {
  await page.goto('/orders/100');
  await page.getByRole('button', { name: 'Delete' }).click();

  // Modal appears
  const dialog = page.getByRole('dialog');
  await expect(dialog).toBeVisible();
  await expect(dialog).toContainText('cannot be undone');

  // Cancel keeps the order
  await dialog.getByRole('button', { name: 'Cancel' }).click();
  await expect(dialog).not.toBeVisible();
  await expect(page).toHaveURL('/orders/100');
});
```

### API Integration (Intercepting Requests)

```js
test('displays error when API returns 500', async ({ page }) => {
  await page.route('**/api/orders', (route) =>
    route.fulfill({ status: 500, body: JSON.stringify({ error: 'Server error' }) })
  );

  await page.goto('/orders');
  await expect(page.getByRole('alert')).toContainText('Server error');
});

test('shows loading state while fetching', async ({ page }) => {
  // Delay the response to observe loading state
  await page.route('**/api/orders', async (route) => {
    await new Promise((r) => setTimeout(r, 1000));
    await route.fulfill({ status: 200, body: JSON.stringify([]) });
  });

  await page.goto('/orders');
  await expect(page.getByTestId('skeleton-loader')).toBeVisible();
  await expect(page.getByTestId('skeleton-loader')).not.toBeVisible({ timeout: 5000 });
});
```

---

## 4. What NOT to Test

**Don't test library internals.** React renders correctly. MUI styles buttons. You don't need to verify that.

```jsx
// BAD — testing that React renders children
test('div contains span', () => {
  const { container } = render(<MyComponent />);
  expect(container.querySelector('div > span')).toBeTruthy();
});

// GOOD — testing YOUR behavior
test('shows customer name', () => {
  render(<MyComponent customer="Jane" />);
  expect(screen.getByText('Jane')).toBeInTheDocument();
});
```

**Don't test CSS values.** Visual regression tools exist for that. Component tests verify behavior.

```jsx
// BAD
expect(element).toHaveStyle('background-color: red');

// GOOD — test the semantic meaning
expect(screen.getByRole('alert')).toBeInTheDocument();
```

**Don't test implementation details.** State shape, internal method names, render counts — these are refactoring traps.

```jsx
// BAD — coupled to internal state shape
expect(component.state.isOpen).toBe(true);

// GOOD — test what the user sees
expect(screen.getByRole('dialog')).toBeVisible();
```

**Rule of thumb:** If a refactor that doesn't change behavior breaks your test, the test is bad.

---

## 5. Frontend TDD Sequence

The same RED-GREEN-REFACTOR cycle from enterprise-build, adapted for components.

### Example: Building a StatusBadge Component

**Cycle 1 — Render**
```jsx
// RED: component doesn't exist yet
test('PC-1: renders status text', () => {
  render(<StatusBadge status="active" />);
  expect(screen.getByText('Active')).toBeInTheDocument();
});
// Run → FAIL (module not found)

// GREEN: create minimal component
export function StatusBadge({ status }) {
  return <span>{status.charAt(0).toUpperCase() + status.slice(1)}</span>;
}
// Run → PASS
```

**Cycle 2 — Variant styling**
```jsx
// RED: no role="status" yet
test('PC-2: applies semantic role for screen readers', () => {
  render(<StatusBadge status="active" />);
  expect(screen.getByRole('status')).toBeInTheDocument();
});
// Run → FAIL

// GREEN: add role
export function StatusBadge({ status }) {
  return <span role="status">{status.charAt(0).toUpperCase() + status.slice(1)}</span>;
}
// Run → PASS
```

**Cycle 3 — Click handler**
```jsx
// RED: no onClick handling
test('PC-3: calls onStatusClick when clicked', async () => {
  const handler = jest.fn();
  const user = userEvent.setup();
  render(<StatusBadge status="active" onStatusClick={handler} />);
  await user.click(screen.getByRole('status'));
  expect(handler).toHaveBeenCalledWith('active');
});
// Run → FAIL

// GREEN: add handler
export function StatusBadge({ status, onStatusClick }) {
  return (
    <span role="status" onClick={() => onStatusClick?.(status)}>
      {status.charAt(0).toUpperCase() + status.slice(1)}
    </span>
  );
}
// Run → PASS
```

Each cycle: one postcondition, one test, one piece of code. Commit after each green.

---

## 6. Common Gotchas

### act() Warnings

State updates outside `act()` mean something async happened that your test didn't wait for.

```jsx
// BAD — fires and forgets
test('loads data', () => {
  render(<OrderList />);
  expect(screen.getByText('ORD-1')).toBeInTheDocument(); // act() warning
});

// GOOD — wait for the async update
test('loads data', async () => {
  render(<OrderList />);
  expect(await screen.findByText('ORD-1')).toBeInTheDocument();
});
```

### Async State Updates

Use `findBy*` (waits) instead of `getBy*` (immediate) for anything that appears after an async operation.

```jsx
// getBy = synchronous, throws immediately if missing
// queryBy = synchronous, returns null if missing
// findBy = async, waits up to timeout (default 1000ms)

await screen.findByText('Order saved');       // waits
screen.getByText('Order saved');              // throws if not there NOW
screen.queryByText('Order saved');            // returns null if not there
```

### Mocking API Calls

Mock at the boundary (fetch/axios), not inside your hooks.

```jsx
// GOOD — mock the network boundary
beforeEach(() => {
  global.fetch = jest.fn().mockResolvedValue({
    ok: true,
    json: () => Promise.resolve([]),
  });
});
afterEach(() => jest.restoreAllMocks());

// BAD — mocking your own hook internals
jest.mock('./useOrders', () => ({ useOrders: () => ({ orders: [] }) }));
// This tests nothing — you just mocked away the thing you're testing
```

### Testing with Context Providers

Wrap components that consume context in a test utility.

```jsx
// test-utils.js
import { render } from '@testing-library/react';
import { AuthProvider } from './AuthContext';
import { ThemeProvider } from './ThemeContext';

export function renderWithProviders(ui, { user = { id: 1, role: 'admin' }, ...options } = {}) {
  function Wrapper({ children }) {
    return (
      <AuthProvider value={user}>
        <ThemeProvider>{children}</ThemeProvider>
      </AuthProvider>
    );
  }
  return render(ui, { wrapper: Wrapper, ...options });
}

// In tests:
import { renderWithProviders } from '../test-utils';

test('shows admin panel for admin users', () => {
  renderWithProviders(<Dashboard />, { user: { id: 1, role: 'admin' } });
  expect(screen.getByText('Admin Panel')).toBeInTheDocument();
});
```

### Cleanup Between Tests

React Testing Library auto-cleans up after each test (calls `cleanup()`). If you're seeing state leak:

1. Check that mocks are restored in `afterEach`
2. Check for module-level singletons (caches, stores)
3. Check for unresolved timers — use `jest.useFakeTimers()` and `jest.runAllTimers()`

```jsx
afterEach(() => {
  jest.restoreAllMocks();    // restore fetch, timers, etc.
  jest.clearAllTimers();     // if using fake timers
});
```
