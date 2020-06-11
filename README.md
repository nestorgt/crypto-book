# crypto-book

## Overview

| Developer Menu | Order Book (Dark) |  Market History (Dark) | Order Book (Light) | Market History (Light) |
|---|---|---|---|---|
| ![](wiki/main-menu.png) | ![](wiki/order-book.png) | ![](wiki/market-history.png) | ![](wiki/order-book-light.png) | ![](wiki/market-history-light.png) |

| Order Book BTCUSDT | Order Book BNBUSDT | Market History BTCUSDT | Market History BNBUSDT |
|---|---|---|---|
| ![](wiki/order-book-btc.gif) | ![](wiki/order-book-bnb.gif) | ![](wiki/market-history-btc.gif) | ![](wiki/market-history-bnb.gif) |
| `UI Throttle` 500ms, `Update spped` 1000ms | `UI Throttle` 250ms, `Update spped` 100ms | `UI Throttle` 500ms, `Update spped` 1000ms | `UI Throttle` 250ms, `Update spped` 100ms |

| Order Book Stress Test | Market History Stress Test | Data recovery when going offline |
|---|---|---|
| ![](wiki/stress-test-order-book-btc.gif) | ![](wiki/stress-test-market-history.gif) | ![](wiki/data-recovery.gif) |
| `UI Throttle` 0ms, `Update spped` 100ms | `UI Throttle` 0ms, `Update spped` 100ms | `UI Throttle` 250ms, `Update spped` 100ms |

| Component: Page Controller | Component: Loading View | Component: Selector View |
|---|---|---|
| ![](wiki/component-page-controller.gif) | ![](wiki/component-loading-view.gif) | ![](wiki/component-selector-view.gif) |

## Requirements
* Xcode 11.5
* iOS 13+

## Tech Stack
* Architecture `MVVM`. Using `Services` for common implementations. The addition of a `Coordinator` was not really needed for this sample but would be consider if the number of screens increases.
* All `ViewModels` & `Services` use dependency injection to allow creation of mocks and make it more testable. 
* No 3rd party libraries (just a helper class for `Reachability`).
* FRP with `Combine`.
* WebSockets with `URLSessionWebSocketTask`.

![](wiki/class-tree.png)

## Tests
There are two different targets of test, `unit-tests` for mocked and non-network dependant tests, and `integration-tests` that performs network requests to verify the API endpoints.
