# GSAP with Vue, Svelte, and Other Frameworks

Read when writing or reviewing GSAP in Vue (or Nuxt), Svelte (or SvelteKit), or other component frameworks with a mounted/unmounted lifecycle. For **React** use `references/react.md` (useGSAP, contextSafe).

## Principles (All Frameworks)

- **Create** tweens and ScrollTriggers **after** the component's DOM is available (e.g. onMounted, onMount).
- **Kill or revert** them on **unmount** so nothing runs on detached nodes and there are no leaks.
- **Scope selectors** to the component root so `.box` matches only elements inside that component.

## Vue 3 (Composition API)

Use **onMounted** to run GSAP after the component is in the DOM; **onUnmounted** to clean up.

```javascript
import { onMounted, onUnmounted, ref } from "vue";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
gsap.registerPlugin(ScrollTrigger); // once per app, e.g. in main.js

export default {
  setup() {
    const container = ref(null);
    let ctx;

    onMounted(() => {
      if (!container.value) return;
      ctx = gsap.context(() => {
        gsap.to(".box", { x: 100, duration: 0.6 });
        gsap.from(".item", { autoAlpha: 0, y: 20, stagger: 0.1 });
      }, container.value);
    });

    onUnmounted(() => {
      ctx?.revert();
    });

    return { container };
  }
};
```

- ✅ **gsap.context(callback, scope)** — pass the container ref (`container.value`) so selectors like `.item` are scoped to that root. All animations and ScrollTriggers created inside are tracked and reverted on **ctx.revert()**.
- ✅ **onUnmounted** — always call **ctx.revert()**.

## Vue 3 (script setup)

```javascript
<script setup>
import { onMounted, onUnmounted, ref } from "vue";
import { gsap } from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

const container = ref(null);
let ctx;

onMounted(() => {
  if (!container.value) return;
  ctx = gsap.context(() => {
    gsap.to(".box", { x: 100 });
    gsap.from(".item", { autoAlpha: 0, stagger: 0.1 });
  }, container.value);
});

onUnmounted(() => {
  ctx?.revert();
});
</script>

<template>
  <div ref="container">
    <div class="box">Box</div>
    <div class="item">Item</div>
  </div>
</template>
```

## Svelte

Use **onMount** to run GSAP after the DOM is ready; return a cleanup that reverts. Svelte 5 uses a different lifecycle, but the principle is the same: create in "mounted", revert in "destroyed".

```javascript
<script>
  import { onMount } from "svelte";
  import { gsap } from "gsap";
  import { ScrollTrigger } from "gsap/ScrollTrigger";

  let container;

  onMount(() => {
    if (!container) return;
    const ctx = gsap.context(() => {
      gsap.to(".box", { x: 100 });
      gsap.from(".item", { autoAlpha: 0, stagger: 0.1 });
    }, container);
    return () => ctx.revert();
  });
</script>

<div bind:this={container}>
  <div class="box">Box</div>
  <div class="item">Item</div>
</div>
```

- ✅ **bind:this={container}** — reference the root element to pass to **gsap.context(scope)**.
- ✅ **return () => ctx.revert()** — onMount's returned cleanup runs when the component is destroyed.

## Scoping Selectors

Do not use global selectors that can match elements outside the current component. Always pass the **scope** (container element or ref) as the second argument to **gsap.context(callback, scope)**.

- ✅ **gsap.context(() => { gsap.to(".box", ...) }, containerRef)** — `.box` is only searched inside `containerRef`.
- ❌ Running **gsap.to(".box", ...)** without a context scope can affect other instances or the rest of the page.

## ScrollTrigger Cleanup

ScrollTrigger instances (via the `scrollTrigger` config on a tween/timeline or **ScrollTrigger.create()**) are **included** in **gsap.context()** and reverted on **ctx.revert()**. So:

- Create ScrollTriggers inside the same **gsap.context()** callback you use for tweens.
- Call **ScrollTrigger.refresh()** after layout changes that affect trigger positions — often after DOM updates (nextTick in Vue, tick in Svelte, or after async content load).

## When to Create vs Kill

| Lifecycle | Action |
|-----------|--------|
| **Mounted** | Create tweens and ScrollTriggers inside **gsap.context(scope)**. |
| **Unmount / Destroy** | Call **ctx.revert()** so all animations and ScrollTriggers in that context are killed and inline styles reverted. |

Do not create GSAP animations in setup or a synchronous top-level script that runs before the root element exists. Wait for **onMounted** / **onMount**.

## Do Not

- ❌ Create tweens or ScrollTriggers before the component is mounted; the DOM nodes may not exist yet.
- ❌ Use selector strings without a **scope** (pass the container to gsap.context()).
- ❌ Skip cleanup; always call **ctx.revert()** in onUnmounted / onMount's return.
- ❌ Register plugins inside a component body that runs every render (wasteful); register once at app level.
