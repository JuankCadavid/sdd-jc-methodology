# GSAP ScrollTrigger

Read when implementing scroll-driven animation: triggering tweens/timelines on scroll, pinning, scrubbing, parallax, batching, horizontal scroll, or integrating a smooth-scroll library.

## Registering the Plugin

ScrollTrigger is a plugin — register once (see SKILL.md registration pattern):

```javascript
gsap.registerPlugin(ScrollTrigger);
```

## Basic Trigger

```javascript
gsap.to(".box", {
  x: 500,
  duration: 1,
  scrollTrigger: {
    trigger: ".box",
    start: "top center",   // when top of trigger hits center of viewport
    end: "bottom center",  // when the bottom of the trigger hits the center of the viewport
    toggleActions: "play reverse play reverse" // onEnter, onLeave, onEnterBack, onLeaveBack
  }
});
```

**start** / **end**: `"triggerPosition viewportPosition"`. Examples: `"top top"`, `"center center"`, `"bottom 80%"`, or a numeric pixel value like `500` (scroller scrolls 500px from top). Relative values: `"+=300"`, `"+=100%"` (scroller height past start), or `"max"`. Wrap in **clamp()** (3.12+) to keep within page bounds: `start: "clamp(top bottom)"`. Can also be a **function** returning a string/number (receives the ScrollTrigger instance); call **ScrollTrigger.refresh()** when layout changes.

## Key config options

Shorthand `scrollTrigger: ".selector"` sets only `trigger`. Full list: [ScrollTrigger docs](https://gsap.com/docs/v3/Plugins/ScrollTrigger/).

| Property | Type | Description |
|----------|------|-------------|
| **trigger** | String \| Element | Element whose position defines where the ScrollTrigger starts. Required (or use shorthand). |
| **start** | String \| Number \| Function | When the trigger becomes active. Default `"top bottom"` (or `"top top"` if `pin: true`). |
| **end** | String \| Number \| Function | When the trigger ends. Default `"bottom top"`. Use `endTrigger` if end is based on a different element. |
| **endTrigger** | String \| Element | Element used for **end** when different from trigger. |
| **scrub** | Boolean \| Number | Link animation progress to scroll. `true` = direct; number = seconds for playhead to "catch up". |
| **toggleActions** | String | Four actions in order: **onEnter**, **onLeave**, **onEnterBack**, **onLeaveBack**. Each: `"play"`, `"pause"`, `"resume"`, `"reset"`, `"restart"`, `"complete"`, `"reverse"`, `"none"`. Default `"play none none none"`. |
| **pin** | Boolean \| String \| Element | Pin an element while active. `true` = pin the trigger. Don't animate the pinned element itself; animate children. |
| **pinSpacing** | Boolean \| String | Default `true` (adds spacer so layout doesn't collapse). `false` or `"margin"`. |
| **horizontal** | Boolean | `true` for horizontal scrolling. |
| **scroller** | String \| Element | Scroll container (default: viewport). |
| **markers** | Boolean \| Object | `true` for dev markers; or `{ startColor, endColor, fontSize, ... }`. Remove in production. |
| **once** | Boolean | If `true`, kills the ScrollTrigger after end is reached once (animation keeps running). |
| **id** | String | Unique id for **ScrollTrigger.getById(id)**. |
| **refreshPriority** | Number | Lower = refreshed first. Set when creating ScrollTriggers out of page order so they refresh in page order (first on page = lower number). |
| **toggleClass** | String \| Object | Add/remove class when active. String = on trigger; or `{ targets: ".x", className: "active" }`. |
| **snap** | Number \| Array \| Function \| "labels" \| Object | Snap to progress values. Number = increments (e.g. `0.25`); array = specific values; `"labels"` = timeline labels; object: `{ snapTo: 0.25, duration: 0.3, delay: 0.1, ease: "power1.inOut" }`. |
| **containerAnimation** | Tween \| Timeline | For "fake" horizontal scroll (see below). Pinning and snapping are not available on containerAnimation-based ScrollTriggers. |
| **onEnter**, **onLeave**, **onEnterBack**, **onLeaveBack** | Function | Callbacks when crossing start/end; receive the ScrollTrigger instance (`progress`, `direction`, `isActive`, `getVelocity()`). |
| **onUpdate**, **onToggle**, **onRefresh**, **onScrubComplete** | Function | **onUpdate** fires when progress changes; **onToggle** when active flips; **onRefresh** after recalc; **onScrubComplete** when numeric scrub finishes. |

**Standalone ScrollTrigger** (no linked tween): use **ScrollTrigger.create()** with the same config and callbacks for custom behavior.

```javascript
ScrollTrigger.create({
  trigger: "#id",
  start: "top top",
  end: "bottom 50%+=100px",
  onUpdate: (self) => console.log(self.progress.toFixed(3), self.direction)
});
```

## ScrollTrigger.batch()

**ScrollTrigger.batch(triggers, vars)** creates one ScrollTrigger per target and **batches** their callbacks (onEnter, onLeave, etc.) within a short interval — e.g. animate every element that just entered the viewport in one staggered go. Good alternative to IntersectionObserver. Returns an Array of ScrollTrigger instances.

- **triggers**: selector text (e.g. `".box"`) or Array of elements.
- **vars**: standard ScrollTrigger config (start, end, once, callbacks). Do **not** pass `trigger` or animation-related options: `animation`, `invalidateOnRefresh`, `onSnapComplete`, `onScrubComplete`, `scrub`, `snap`, `toggleActions`.

**Callback signature:** Batched callbacks receive **two** parameters (unlike normal callbacks):
1. **targets** — Array of trigger elements that fired this callback within the interval.
2. **scrollTriggers** — Array of the ScrollTrigger instances that fired.

**Batch options in vars:**
- **interval** (Number) — Max seconds to collect each batch. Default ≈ one requestAnimationFrame.
- **batchMax** (Number | Function) — Max elements per batch. Use a **function** returning a number for responsive layouts; it runs on refresh.

```javascript
ScrollTrigger.batch(".box", {
  onEnter: (elements, triggers) => {
    gsap.to(elements, { opacity: 1, y: 0, stagger: 0.15 });
  },
  onLeave: (elements, triggers) => {
    gsap.to(elements, { opacity: 0, y: 100 });
  },
  start: "top 80%",
  end: "bottom 20%"
});
```

```javascript
ScrollTrigger.batch(".card", {
  interval: 0.1,
  batchMax: 4,
  onEnter: (batch) => gsap.to(batch, { opacity: 1, y: 0, stagger: 0.1, overwrite: true }),
  onLeaveBack: (batch) => gsap.set(batch, { opacity: 0, y: 50, overwrite: true })
});
```

See [ScrollTrigger.batch()](https://gsap.com/docs/v3/Plugins/ScrollTrigger/static.batch/).

## ScrollTrigger.scrollerProxy()

**ScrollTrigger.scrollerProxy(scroller, vars)** overrides how ScrollTrigger reads/writes scroll position for a scroller. Use when integrating a third-party smooth-scroll (or custom scroll) library. GSAP's **ScrollSmoother** is the built-in option and needs no proxy.

- **scroller**: selector or element (e.g. `"body"`, `".container"`).
- **vars**: object with **scrollTop** and/or **scrollLeft** functions. Each is both getter and setter: called **with** an argument = setter; **with no** argument = getter. At least one is required.

**Optional in vars:**
- **getBoundingClientRect** — Function returning `{ top, left, width, height }` for the scroller.
- **scrollWidth** / **scrollHeight** — Getter/setter functions when the library exposes different dimensions.
- **fixedMarkers** (Boolean) — When `true`, markers are treated as `position: fixed` (useful when the scroller is translated).
- **pinType** — `"fixed"` or `"transform"`. Use `"fixed"` if pins jitter; `"transform"` if pins don't stick.

**Critical:** When the third-party scroller updates, notify ScrollTrigger — register **ScrollTrigger.update** as a listener (e.g. `smoothScroller.addListener(ScrollTrigger.update)`), else calculations go stale.

```javascript
ScrollTrigger.scrollerProxy(document.body, {
  scrollTop(value) {
    if (arguments.length) scrollbar.scrollTop = value;
    return scrollbar.scrollTop;
  },
  getBoundingClientRect() {
    return { top: 0, left: 0, width: window.innerWidth, height: window.innerHeight };
  }
});
scrollbar.addListener(ScrollTrigger.update);
```

See [ScrollTrigger.scrollerProxy()](https://gsap.com/docs/v3/Plugins/ScrollTrigger/static.scrollerProxy/).

## Scrub

Scrub ties animation progress to scroll. Use for the "scroll-driven" feel:

```javascript
gsap.to(".box", {
  x: 500,
  scrollTrigger: {
    trigger: ".box",
    start: "top center",
    end: "bottom center",
    scrub: true   // or a number (smoothness lag in seconds): 0.5 takes 0.5s to catch up
  }
});
```

## Pinning

```javascript
scrollTrigger: {
  trigger: ".section",
  start: "top top",
  end: "+=1000",   // pin for 1000px scroll
  pin: true,
  scrub: 1
}
```

**pinSpacing** — default `true`; adds a spacer so layout doesn't collapse when the pinned element becomes `position: fixed`. Set `pinSpacing: false` only when layout is handled separately.

## Markers (Development)

```javascript
scrollTrigger: { trigger: ".box", start: "top center", end: "bottom center", markers: true }
```

Remove or set **markers: false** for production.

## Timeline + ScrollTrigger

Drive a timeline with scroll and optional scrub — put ScrollTrigger on the **timeline**, not a child tween:

```javascript
const tl = gsap.timeline({
  scrollTrigger: { trigger: ".container", start: "top top", end: "+=2000", scrub: 1, pin: true }
});
tl.to(".a", { x: 100 }).to(".b", { y: 50 }).to(".c", { opacity: 0 });
```

## Horizontal scroll (containerAnimation)

Pin a section, then as the user scrolls **vertically**, content inside moves **horizontally** ("fake" horizontal scroll). Animate **x**/**xPercent** of an element *inside* the pinned trigger, tie it to vertical scroll, and use **containerAnimation** so ScrollTrigger monitors the horizontal animation's progress.

**Critical:** The horizontal tween/timeline **must** use **ease: "none"**, or scroll position and horizontal position won't line up — a very common mistake.

1. Pin the section (trigger = the full-viewport panel).
2. Build a tween animating inner content's **x**/**xPercent** with **ease: "none"**.
3. Attach ScrollTrigger to that tween with **pin: true**, **scrub: true**.
4. For things triggered by the horizontal movement, set **containerAnimation** to that tween.

```javascript
const scrollingEl = document.querySelector(".horizontal-el");
const scrollTween = gsap.to(scrollingEl, {
  xPercent: () => Math.max(0, window.innerWidth - scrollingEl.offsetWidth),
  ease: "none", // required
  scrollTrigger: {
    trigger: scrollingEl,
    pin: scrollingEl.parentNode, // wrapper so we're not animating the pinned element
    start: "top top",
    end: "+=1000"
  }
});

gsap.to(".nested-el-1", {
  y: 100,
  scrollTrigger: {
    containerAnimation: scrollTween, // IMPORTANT
    trigger: ".nested-wrapper-1",
    start: "left center", // based on horizontal movement
    toggleActions: "play none none reset"
  }
});
```

**Caveats:** Pinning and snapping are not available on containerAnimation ScrollTriggers. The container animation must use **ease: "none"**. Animate a child, not the trigger element itself. If the trigger is moved, offset **start**/**end** accordingly.

## Refresh and Cleanup

- **ScrollTrigger.refresh()** — recalculate positions after DOM/layout changes (new content, images, fonts). Auto-called on viewport resize (debounced 200ms). Refresh runs in creation order (or by **refreshPriority**); create ScrollTriggers top-to-bottom or set **refreshPriority** so they refresh in page order.
- When removing elements or changing pages (SPAs), **kill** stale ScrollTriggers:

```javascript
ScrollTrigger.getAll().forEach(t => t.kill());
ScrollTrigger.getById("my-id")?.kill();
```

In React, use `useGSAP()` (@gsap/react) for automatic cleanup, or kill manually in a cleanup — see `references/react.md`.

## Best practices

- ✅ **gsap.registerPlugin(ScrollTrigger)** once before any use.
- ✅ Call **ScrollTrigger.refresh()** after DOM/layout changes that affect trigger positions (viewport resize is auto-handled, debounced 200ms; dynamic content is not).
- ✅ In React, use `useGSAP()`; elsewhere use `gsap.context()` + revert in cleanup.
- ✅ Use **scrub** for scroll-linked progress OR **toggleActions** for discrete play/reverse — not both on the same trigger (scrub wins).
- ✅ For fake horizontal scroll with **containerAnimation**, use **ease: "none"**.
- ✅ Create ScrollTriggers top-to-bottom (scroll 0 → max), or set **refreshPriority** when created out of order.

## Do Not

- ❌ Put ScrollTrigger on a **child tween** of a timeline; put it on the **timeline** or a **top-level tween**. Wrong: `gsap.timeline().to(".a", { scrollTrigger: {...} })`. Correct: `gsap.timeline({ scrollTrigger: {...} }).to(".a", { x: 100 })`.
- ❌ Forget **ScrollTrigger.refresh()** after DOM/layout changes.
- ❌ Nest ScrollTriggered animations inside a parent timeline.
- ❌ Forget **gsap.registerPlugin(ScrollTrigger)**.
- ❌ Use **scrub** and **toggleActions** together on the same ScrollTrigger.
- ❌ Use an ease other than **"none"** on the horizontal animation with **containerAnimation**.
- ❌ Create ScrollTriggers in random/async order without setting **refreshPriority**.
- ❌ Leave **markers: true** in production.

### Learn More
https://gsap.com/docs/v3/Plugins/ScrollTrigger/
