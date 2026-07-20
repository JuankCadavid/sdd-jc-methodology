# GSAP Plugins

Read when using any GSAP plugin: scroll-to, ScrollSmoother, Flip/FLIP, Draggable, Inertia, Observer, SplitText, ScrambleText, DrawSVG, MorphSVG, MotionPath, physics, easing plugins (CustomEase, EasePack, CustomWiggle, CustomBounce), GSDevTools, or Pixi. (ScrollTrigger has its own file: `references/scrolltrigger.md`.)

## Registering Plugins

Register each plugin once before first use (see SKILL.md for the shared pattern):

```javascript
import gsap from "gsap";
import { ScrollToPlugin } from "gsap/ScrollToPlugin";
import { Flip } from "gsap/Flip";
import { Draggable } from "gsap/Draggable";

gsap.registerPlugin(ScrollToPlugin, Flip, Draggable);
```

- ✅ Register before using the plugin in any tween or API call.
- ✅ In React, register at top level or once in the app (before first `useGSAP`); do not register inside a component that re-renders. `useGSAP` is itself a plugin that needs registration.

## Scroll

### ScrollToPlugin

Animates scroll position (window or a scrollable element). Use for "scroll to element/position" without ScrollTrigger.

```javascript
gsap.registerPlugin(ScrollToPlugin);

gsap.to(window, { duration: 1, scrollTo: { y: 500 } });
gsap.to(window, { duration: 1, scrollTo: { y: "#section", offsetY: 50 } });
gsap.to(scrollContainer, { duration: 1, scrollTo: { x: "max" } });
```

| Option | Description |
|--------|-------------|
| `x`, `y` | Target scroll position (number), or `"max"` for maximum |
| `element` | Selector or element to scroll to (scroll-into-view) |
| `offsetX`, `offsetY` | Offset in pixels from the target position |

### ScrollSmoother

Smooth scroll wrapper (smooths native scroll). Requires ScrollTrigger and a specific DOM structure. Register after ScrollTrigger.

```html
<body>
  <div id="smooth-wrapper">
    <div id="smooth-content">
      <!-- ALL YOUR CONTENT HERE -->
    </div>
  </div>
  <!-- position: fixed elements can go outside -->
</body>
```

## DOM / UI

### Flip

Capture state with `Flip.getState()`, change the DOM (layout/classes), then `Flip.from()` animates from the previous state to the new state (FLIP: First, Last, Invert, Play). Use when animating between two layout states (lists, grids, expand/collapse).

```javascript
gsap.registerPlugin(Flip);

const state = Flip.getState(".item");
// change DOM (reorder, add/remove, change classes)
Flip.from(state, { duration: 0.5, ease: "power2.inOut" });
```

| Option | Description |
|--------|-------------|
| `absolute` | Use `position: absolute` during the flip (default `false`) |
| `nested` | When true, only the first level of children is measured (better for nested transforms) |
| `scale` | When true, scale elements to fit (avoids stretch); default `true` |
| `simple` | When true, only position/scale animated (faster, less accurate) |
| `duration`, `ease` | Standard tween options |

Docs: https://gsap.com/docs/v3/Plugins/Flip

### Draggable

Makes elements draggable, spinnable, or throwable. Use for sliders, cards, reorderable lists, or any drag interaction.

```javascript
gsap.registerPlugin(Draggable, InertiaPlugin);

Draggable.create(".box", { type: "x,y", bounds: "#container", inertia: true });
Draggable.create(".knob", { type: "rotation" });
```

| Option | Description |
|--------|-------------|
| `type` | `"x"`, `"y"`, `"x,y"`, `"rotation"`, `"scroll"` |
| `bounds` | Element, selector, or `{ minX, maxX, minY, maxY }` to constrain drag |
| `inertia` | `true` for throw/momentum (requires InertiaPlugin) |
| `edgeResistance` | 0–1; resistance when dragging past bounds |
| `cursor` | CSS cursor during drag |
| `onDragStart`, `onDrag`, `onDragEnd` | Callbacks; receive event and target |
| `onThrowUpdate`, `onThrowComplete` | Callbacks when inertia is active |

### Inertia (InertiaPlugin)

Works with Draggable for momentum after release, or tracks the velocity of any property so it can glide to a stop. Register with Draggable when using `inertia: true`:

```javascript
gsap.registerPlugin(Draggable, InertiaPlugin);
Draggable.create(".box", { type: "x,y", inertia: true });
```

Track velocity of a property, then use `"auto"` to continue current velocity and glide to a stop:

```javascript
InertiaPlugin.track(".box", "x");
gsap.to(obj, { inertia: { x: "auto" } });
```

### Observer

Normalizes pointer and scroll input across devices. Use for swipe, scroll direction, or custom gesture logic without tying to scroll position.

```javascript
gsap.registerPlugin(Observer);

Observer.create({
  target: "#area",
  onUp: () => {},
  onDown: () => {},
  onLeft: () => {},
  onRight: () => {},
  tolerance: 10
});
```

| Option | Description |
|--------|-------------|
| `target` | Element or selector to observe |
| `onUp`, `onDown`, `onLeft`, `onRight` | Callbacks when swipe/scroll passes tolerance in that direction |
| `tolerance` | Pixels before direction is detected; default 10 |
| `type` | `"touch"`, `"pointer"`, or `"wheel"` (default `"touch,pointer"`) |

## Text

### SplitText

Splits an element's text into characters, words, and/or lines (each in its own element) for staggered animation. Returns an instance with **chars**, **words**, **lines** (and **masks** when `mask` is set). Restore original markup with **revert()** or let **gsap.context()** revert. Integrates with **gsap.context()**, **matchMedia()**, and **useGSAP()**. API: **SplitText.create(target, vars)**.

```javascript
gsap.registerPlugin(SplitText);

const split = SplitText.create(".heading", { type: "words, chars" });
gsap.from(split.chars, { opacity: 0, y: 20, stagger: 0.03, duration: 0.4 });
// later: split.revert() or let gsap.context() cleanup revert
```

With **onSplit()** (3.13.0+), animations run on each split and on re-split when **autoSplit** is used; returning a tween/timeline from **onSplit()** lets SplitText clean up and sync progress on re-split:

```javascript
SplitText.create(".split", {
  type: "lines",
  autoSplit: true,
  onSplit(self) {
    return gsap.from(self.lines, { y: 100, opacity: 0, stagger: 0.05, duration: 0.5 });
  }
});
```

| Option | Description |
|--------|-------------|
| **type** | Comma-separated: `"chars"`, `"words"`, `"lines"`. Default `"chars,words,lines"`. Split only what's needed for performance. Avoid chars-only without words/lines, or use **smartWrap: true**. |
| **charsClass**, **wordsClass**, **linesClass** | CSS class on each split element. Append `"++"` for an incremented class (e.g. `linesClass: "line++"` → `line1`, `line2`, …). |
| **aria** | `"auto"` (default), `"hidden"`, or `"none"`. `"auto"` adds `aria-label` on the element and `aria-hidden` on split units; `"hidden"` hides all from readers; `"none"` leaves aria unchanged. |
| **autoSplit** | When `true`, reverts and re-splits when fonts load or element width changes (lines split), avoiding wrong line breaks. **Animations must be created inside onSplit()**; **return** the animation for automatic cleanup and time-sync on re-split. |
| **onSplit(self)** | Callback when split completes (and on each re-split if **autoSplit**). Returning a tween/timeline enables automatic revert/sync on re-split. |
| **mask** | `"lines"`, `"words"`, or `"chars"`. Wraps each unit with `overflow: clip` for mask/reveal effects. Access wrappers on the instance's **masks** array. |
| **tag** | Wrapper tag; default `"div"`. Use `"span"` for inline (transforms like rotation/scale may not render on inline elements in some browsers). |
| **deepSlice** | When `true` (default), nested elements spanning multiple lines are subdivided so lines don't stretch vertically. Line-splitting only. |
| **ignore** | Selector or element(s) to leave unsplit (e.g. `ignore: "sup"`). |
| **smartWrap** | When splitting **chars** only, wraps words in `white-space: nowrap` to avoid mid-word breaks. Ignored if words/lines are split. Default `false`. |
| **wordDelimiter** | Word boundary: string (default `" "`), RegExp, or `{ delimiter: RegExp, replaceWith: string }`. |
| **prepareText(text, parent)** | Function returning modified text before splitting (e.g. insert break markers for languages without spaces). |
| **propIndex** | When `true`, adds a CSS variable with index on each split element (`--word: 1`, `--char: 2`). |
| **reduceWhiteSpace** | Collapse consecutive spaces; default `true`. From 3.13.0 also honors line breaks / `<pre>`. |
| **onRevert** | Callback when the instance is reverted. |

**Tips:** Split only what is animated. For custom fonts, split after they load (`document.fonts.ready.then(...)`) or use **autoSplit: true** with **onSplit()**. To avoid kerning shift when splitting chars, use CSS `font-kerning: none; text-rendering: optimizeSpeed;`. Avoid `text-wrap: balance`. SplitText does not support SVG `<text>`.

Docs: [SplitText](https://gsap.com/docs/v3/Plugins/SplitText/)

### ScrambleText

Animates text with a scramble/glitch effect.

```javascript
gsap.registerPlugin(ScrambleTextPlugin);

gsap.to(".text", {
  duration: 1,
  scrambleText: { text: "New message", chars: "01", revealDelay: 0.5 }
});
```

## SVG

### DrawSVG (DrawSVGPlugin)

Reveals/hides the stroke of SVG elements by animating `stroke-dashoffset` / `stroke-dasharray`. Works on `<path>`, `<line>`, `<polyline>`, `<polygon>`, `<rect>`, `<ellipse>`. Use for "drawing"/"erasing" strokes.

**drawSVG value:** Describes the **visible segment** of the stroke (`"start end"` in percent or length), not "A to B over time." `"0% 100%"` = full stroke; `"20% 80%"` = stroke only between 20% and 80%. The tween animates from the element's **current** segment to the **target** segment. Single value (e.g. `0`, `"100%"`) means start is 0.

**Required:** The element must have a visible stroke (`stroke` + `stroke-width`), else nothing draws.

```javascript
gsap.registerPlugin(DrawSVGPlugin);

gsap.from("#path", { duration: 1, drawSVG: 0 });                       // nothing → full stroke
gsap.fromTo("#path", { drawSVG: "0% 0%" }, { drawSVG: "0% 100%", duration: 1 });
gsap.to("#path", { duration: 1, drawSVG: "20% 80%" });                 // middle only
```

**Caveats:** Only affects stroke (not fill). Prefer single-segment `<path>` elements. Contents of `<use>` cannot be visually changed. **DrawSVGPlugin.getLength(element)** and **DrawSVGPlugin.getPosition(element)** return stroke length/position.

Docs: [DrawSVG](https://gsap.com/docs/v3/Plugins/DrawSVGPlugin)

### MorphSVG (MorphSVGPlugin)

Morphs one SVG shape into another by animating the `d` attribute. Start/end shapes need not share point counts. Works on `<path>`, `<polyline>`, `<polygon>`; primitives are converted internally or via **MorphSVGPlugin.convertToPath()**.

**morphSVG value:** a **selector**, **element**, **raw path data**, or (for polygon/polyline) a **points string**. Full config uses the **object form** with **shape** required.

```javascript
gsap.registerPlugin(MorphSVGPlugin);

MorphSVGPlugin.convertToPath("circle, rect, ellipse, line"); // if needed

gsap.to("#diamond", { duration: 1, morphSVG: "#lightning", ease: "power2.inOut" });
gsap.to("#diamond", {
  duration: 1,
  morphSVG: { shape: "#lightning", type: "rotational", shapeIndex: 2 }
});
```

| Option | Description |
|--------|-------------|
| **shape** | _(Required.)_ Target shape: selector, element, or raw path string. |
| **type** | `"linear"` (default) or `"rotational"`. Rotational uses angle/length interpolation and can avoid mid-morph kinks. |
| **map** | Segment matching: `"size"` (default), `"position"`, or `"complexity"`. |
| **shapeIndex** | Offsets which start point maps to the first end point (avoids crossing/inverting). Number for single-segment; **array** for multi-segment (negative reverses that segment). Use **shapeIndex: "log"** once to log the auto value; **findShapeIndex(start, end)** gives an interactive UI. Closed paths only. |
| **smooth** | (3.14+). Smoothing points. Number, `"auto"`, or object `{ points, redraw, persist }`. `redraw: false` keeps original anchors; `persist: false` removes added points on end. |
| **curveMode** | Boolean (3.14+). Interpolates control-handle angle/length instead of raw x/y to avoid kinks. |
| **origin** | Rotation origin for **type: "rotational"**. `"50% 50%"` (default) or `"20% 60%, 35% 90%"` for different start/end origins. |
| **precision** | Decimal places for output path data; default `2`. |
| **precompile** | Array of precomputed path strings (or `"log"` once, copy from console). Skips startup calc for complex morphs; `<path>` only. |
| **render** | Function(rawPath, target) each update — e.g. draw to canvas. |
| **updateTarget** | Set `false` (with **render**, e.g. canvas-only) so the original `<path>` isn't updated. |

**Utilities:** **convertToPath(selector | element)**, **rawPathToString(rawPath)**, **stringToRawPath(d)**. The plugin stores the original `d` for tweening back.

**Tips:** For twisted/inverted morphs set **shapeIndex** (`"log"` or findShapeIndex()). Precompile only when the first frame is slow; it doesn't fix jank during the tween.

Docs: [MorphSVG](https://gsap.com/docs/v3/Plugins/MorphSVGPlugin)

### MotionPath (MotionPathPlugin)

Animates an element along an SVG path.

```javascript
gsap.registerPlugin(MotionPathPlugin);

gsap.to(".dot", {
  duration: 2,
  motionPath: { path: "#path", align: "#path", alignOrigin: [0.5, 0.5] }
});
```

| Option | Description |
|--------|-------------|
| `path` | SVG path element, selector, or path data string |
| `align` | Path element or selector to align the target to |
| `alignOrigin` | `[x, y]` origin (0–1); default `[0.5, 0.5]` |
| `autoRotate` | Rotate element to follow path tangent |
| `curviness` | 0–2; path smoothing |

### MotionPathHelper

Visual editor for MotionPath (alignment, offset). Development only.

```javascript
gsap.registerPlugin(MotionPathPlugin, MotionPathHelperPlugin);

const helper = MotionPathHelper.create(".dot", "#path", { end: 0.5 });
```

## Easing

### CustomEase

Custom easing curves (cubic-bezier or SVG path) — use when a built-in ease is not enough. Register when using:

```javascript
gsap.registerPlugin(CustomEase);

// Simple cubic-bezier (same values as CSS cubic-bezier())
const myEase = CustomEase.create("my-ease", ".17,.67,.83,.67");
gsap.to(".item", { x: 100, ease: myEase, duration: 1 });

// Complex curve with any number of control points, as normalized SVG path data
const hop = CustomEase.create("hop", "M0,0 C0,0 0.056,0.442 0.175,0.442 0.294,0.442 0.332,0 0.332,0 0.332,0 0.414,1 0.671,1 0.991,1 1,0 1,0");
gsap.to(".item", { x: 100, ease: hop, duration: 1 });
```

### EasePack

Adds more named eases (SlowMo, RoughEase, ExpoScaleEase). Register and use by name in tweens.

### CustomWiggle

Wiggle/shake easing — a value oscillates multiple times.

### CustomBounce

Bounce-style easing with configurable strength.

## Physics

### Physics2D (Physics2DPlugin)

2D physics (velocity, angle, gravity). Use for projectiles, bouncing.

```javascript
gsap.registerPlugin(Physics2DPlugin);

gsap.to(".ball", {
  duration: 2,
  physics2D: { velocity: 250, angle: 80, gravity: 500 }
});
```

### PhysicsProps (PhysicsPropsPlugin)

Applies physics to property values.

```javascript
gsap.registerPlugin(PhysicsPropsPlugin);

gsap.to(".obj", {
  duration: 2,
  physicsProps: {
    x: { velocity: 100, end: 300 },
    y: { velocity: -50, acceleration: 200 }
  }
});
```

## Development

### GSDevTools

UI for scrubbing timelines, toggling, and debugging. **Development only — do not ship.**

```javascript
gsap.registerPlugin(GSDevTools);
GSDevTools.create({ animation: tl });
```

## Other

### Pixi (PixiPlugin)

Integrates GSAP with PixiJS for animating Pixi display objects.

```javascript
gsap.registerPlugin(PixiPlugin);

const sprite = new PIXI.Sprite(texture);
gsap.to(sprite, { pixi: { x: 200, y: 100, scale: 1.5 }, duration: 1 });
```

## Best practices

- ✅ Register every plugin used with **gsap.registerPlugin()** before first use.
- ✅ Use **Flip.getState()** → DOM change → **Flip.from()** for layout transitions; use **Draggable** + **InertiaPlugin** for drag with momentum.
- ✅ Revert plugin instances (e.g. `splitInstance.revert()`) when components unmount or elements are removed.

## Do Not

- ❌ Use a plugin in a tween or API without registering it first.
- ❌ Ship GSDevTools or development-only plugins to production.

### Learn More
https://gsap.com/docs/v3/Plugins/
