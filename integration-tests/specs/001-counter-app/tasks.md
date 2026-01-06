---
feature_branch: 001-counter-app
created: 2026-01-06
status: Ready
---

# Tasks: Counter Application

## Legend

- `[P]` = Can run in parallel with other [P] tasks
- `[US#]` = Implements User Story #
- Tasks without [P] must be done sequentially

---

## Phase 1: Project Setup

- [ ] **T001** [P] Initialize npm project with `npm init -y`
- [ ] **T002** [P] Install jest and jest-environment-jsdom as dev dependencies
- [ ] **T003** Configure package.json:
  - Add `"type": "module"` for ES modules
  - Add `"test": "node --experimental-vm-modules node_modules/jest/bin/jest.js"` script
  - Add jest config with `testEnvironment: "jsdom"`
- [ ] **T004** Create `src/` directory
- [ ] **T005** Create `src/index.html` with basic HTML5 structure

**Checkpoint**: Run `npm test` - should report "no tests found"

---

## Phase 2: Counter Class (TDD)

### T006-T007: Initialize Counter [US1]

- [ ] **T006** [US1] Write test in `src/counter.test.js`:
  ```
  test('Counter initializes with value 0', () => {
    const counter = new Counter();
    expect(counter.value).toBe(0);
  });
  ```
- [ ] **T007** [US1] Implement Counter class in `src/counter.js`:
  - Constructor with `_value = 0`
  - Getter `value` returns `_value`
  - Export class

**Checkpoint**: `npm test` - 1 test should pass

### T008-T009: Increment [US2]

- [ ] **T008** [US2] Write test:
  ```
  test('increment() increases value by 1', () => {
    const counter = new Counter();
    counter.increment();
    expect(counter.value).toBe(1);
  });
  ```
- [ ] **T009** [US2] Implement `increment()` method

**Checkpoint**: `npm test` - 2 tests should pass

### T010-T011: Decrement [US3]

- [ ] **T010** [US3] Write test:
  ```
  test('decrement() decreases value by 1', () => {
    const counter = new Counter();
    counter.decrement();
    expect(counter.value).toBe(-1);
  });
  ```
- [ ] **T011** [US3] Implement `decrement()` method

**Checkpoint**: `npm test` - 3 tests should pass

### T012-T013: Reset [US4]

- [ ] **T012** [US4] Write test:
  ```
  test('reset() sets value to 0', () => {
    const counter = new Counter();
    counter.increment();
    counter.increment();
    counter.reset();
    expect(counter.value).toBe(0);
  });
  ```
- [ ] **T013** [US4] Implement `reset()` method

**Checkpoint**: `npm test` - 4 tests should pass

### T014-T017: Persistence [US5]

- [ ] **T014** [US5] Write test for save():
  ```
  test('save() persists value to localStorage', () => {
    const counter = new Counter('test-key');
    counter.increment();
    counter.save();
    expect(localStorage.getItem('test-key')).toBe('1');
  });
  ```
- [ ] **T015** [US5] Implement `save()` method
- [ ] **T016** [US5] Write test for load():
  ```
  test('load() retrieves value from localStorage', () => {
    localStorage.setItem('test-key', '42');
    const counter = new Counter('test-key');
    counter.load();
    expect(counter.value).toBe(42);
  });
  ```
- [ ] **T017** [US5] Implement `load()` method

**Checkpoint**: `npm test` - 6 tests should pass

---

## Phase 3: UI Integration

- [ ] **T018** Update `src/index.html`:
  - Add `<span id="counter-display">0</span>`
  - Add `<button id="increment-btn">+</button>`
  - Add `<button id="decrement-btn">-</button>`
  - Add `<button id="reset-btn">Reset</button>`
  - Add `<script type="module">` that imports Counter

- [ ] **T019** Wire up UI in the script:
  - Create Counter instance with storageKey 'counter-value'
  - Load from localStorage on startup
  - Update display on load
  - Add click handlers for all buttons
  - Save to localStorage on every change
  - Update display after every action

---

## Phase 4: Final Validation

- [ ] **T020** Run `npm test` and verify ALL tests pass
- [ ] **T021** Open `src/index.html` in browser and verify:
  - Counter displays 0 on first load
  - Increment/decrement/reset buttons work
  - Value persists after page refresh

---

## Completion

When ALL tasks are complete and `npm test` shows all tests passing:

Output exactly: `<promise>ALL_TESTS_PASSING</promise>`

**IMPORTANT**: Only output the promise when tests actually pass. Verify with `npm test` first.
