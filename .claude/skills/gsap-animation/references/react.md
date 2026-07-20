# GSAP with React

Read when writing or reviewing GSAP in React or Next.js: setup, cleanup on unmount, scoping, context-safe callbacks, and SSR. For Vue/Svelte see `references/frameworks.md`.

## Installation

```bash
npm install gsap
npm install @gsap/react
```

## Prefer the useGSAP() Hook

When **@gsap/react** is available, use **useGSAP()** instead of `useEffect()` for GSAP setup. It handles cleanup automatically and provides a scope and **contextSafe** for callbacks.

```javascript
import { useGSAP } from "@gsap/react";

gsap.registerPlugin(useGSAP); // register before running useGSAP or any GSAP code

const containerRef = useRef(null);

useGSAP(() => {
  gsap.to(".box", { x: 100 });
  gsap.from(".item", { opacity: 0, stagger: 0.1 });
}, { scope: containerRef });
```

- ✅ Pass a **scope** (ref or element) so selectors like `.box` are scoped to that root.
- ✅ Cleanup (reverting animations and ScrollTriggers) runs automatically on unmount.
- ✅ Use **contextSafe** from the hook's return value to wrap callbacks (e.g. onComplete) so they no-op after unmount and avoid React warnings.

## Refs for Targets

Use **refs** so GSAP targets the actual DOM nodes after render. Do not rely on selector strings that might match multiple or wrong elements across re-renders unless a `scope` is defined. With useGSAP, pass the ref as **scope**; with useEffect, pass it as the second argument to `gsap.context()`. For multiple elements, ref the container and query children, or use an array of refs.

## Dependency array, scope, and revertOnUpdate

By default, useGSAP() passes an empty dependency array to its internal effect so it doesn't run on every render. The 2nd argument is optional — a dependency array (like useEffect) or a config object:

```javascript
useGSAP(() => {
  // gsap code here, just like in a useEffect()
}, {
  dependencies: [endX], // dependency array (optional)
  scope: container,     // scope selector text (optional, recommended)
  revertOnUpdate: true  // revert the context and run cleanup every time the hook re-synchronizes (when any dependency changes)
});
```

## gsap.context() in useEffect (when useGSAP isn't used)

Use **gsap.context()** inside a regular **useEffect()** when @gsap/react is not available or you need the effect's dependency/trigger behavior. **Always** call **ctx.revert()** in the cleanup so animations and ScrollTriggers are killed and inline styles reverted — otherwise you leak and update detached nodes.

```javascript
useEffect(() => {
  const ctx = gsap.context(() => {
    gsap.to(".box", { x: 100 });
    gsap.from(".item", { opacity: 0, stagger: 0.1 });
  }, containerRef);
  return () => ctx.revert();
}, []);
```

- ✅ Pass a **scope** (ref or element) as the second argument so selectors are scoped to that node.
- ✅ **Always** return a cleanup that calls **ctx.revert()**.

## Context-Safe Callbacks

GSAP objects created inside functions that run AFTER useGSAP executes (e.g. pointer event handlers) are not in the context, so they won't be reverted on unmount/re-render. Wrap those functions in **contextSafe** (from useGSAP):

```javascript
const container = useRef();
const badRef = useRef();
const goodRef = useRef();

useGSAP((context, contextSafe) => {
  // ✅ safe, created during execution
  gsap.to(goodRef.current, { x: 100 });

  // ❌ DANGER! Created in an event handler that runs AFTER useGSAP(). Not added to
  // the context, so it won't be reverted. The listener isn't removed either, so it
  // persists between renders (bad).
  badRef.current.addEventListener('click', () => {
    gsap.to(badRef.current, { y: 100 });
  });

  // ✅ safe, wrapped in contextSafe()
  const onClickGood = contextSafe(() => {
    gsap.to(goodRef.current, { rotation: 180 });
  });
  goodRef.current.addEventListener('click', onClickGood);

  // 👍 remove the listener in cleanup
  return () => {
    goodRef.current.removeEventListener('click', onClickGood);
  };
}, { scope: container });
```

## Server-Side Rendering (Next.js, etc.)

GSAP runs in the browser. Do not call gsap or ScrollTrigger during SSR.

- Use **useGSAP** (or useEffect) so all GSAP code runs only on the client.
- If GSAP is imported at top level, ensure the app doesn't execute `gsap.*` or `ScrollTrigger.*` during server render. Dynamic import inside useEffect is an option if bundle size/tree-shaking matters.

## Best practices

- ✅ Prefer **useGSAP()** over `useEffect`/`useLayoutEffect`; use **gsap.context()** + **ctx.revert()** in `useEffect` when useGSAP isn't an option.
- ✅ Use refs for targets and pass a **scope** so selectors are limited to the component.
- ✅ Run GSAP only on the client; never call gsap or ScrollTrigger during SSR.

## Do Not

- ❌ Target by **selector without a scope**; always pass **scope** (ref or element) so selectors like `.box` are limited to that root.
- ❌ Animate using selector strings that can match elements outside the component unless a `scope` is defined.
- ❌ Skip cleanup; always revert context or kill tweens/ScrollTriggers in the effect return.
- ❌ Run GSAP or ScrollTrigger during SSR; keep all usage inside client-only lifecycle.

### Learn More
https://gsap.com/resources/React
