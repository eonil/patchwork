Patchwork
=========
2021, Eonil.

Minimal & 100% compatible declarative layout library for UIKit.

[![CI](https://github.com/eonil/patchwork/actions/workflows/main.yml/badge.svg)](https://github.com/eonil/patchwork/actions/workflows/main.yml)



Why?
----
SwiftUI is working, but still has numerous problems. Especially with layout errors.
It also lacks too many features, I still need to depend on UIKit heavily.
Apple is going to fix them eventualy, but I can't wait for it.
I need something right now, that works flawlessly with UIKit and does not produce any AutoLayout error. 
`Patchwork` is made to fill that needs.



Manual Layout
-------------
Due to global effect of AutoLayout, it's difficult to manage them clean.
 


Data Flow
---------

    Piece   ->   ResolvedPiece   ->   RenderingPieceLayout   ->   UIView/NSView

- You build `Piece` tree.
- You pass the `Piece` tree to a `PieceView`.
- `PieceView` resolves `Piece` tree into `ResolvedPiece` tree.
  - This tree exists only to support version-based resolution skipping.
  - `ResolvedPiece` also stores "fitting size" and extra cached data.
- Once resolved subtree can be used for final layout/rendering.
- On layout (e.g. frame changed), `PieceView` produces `RenderingPieceLayout` tree from `ResolvedPiece` tree.
- `PieceView` updates in-place or rebuilds view subtree to render `RenderingPieceLayout` tree. 



Design Choices
--------------
- A piece is a static snapshot.
  - You need to re-render piece tree if thier content changed, so layout need to be changed.
  - Layout will be cached for same input. Input includes layout target bounds.
- Patchwork cannot track changes in embedded views. 
  - You need to re-render same piece to measure embedded views again.
- Same piece topology keeps same view tree.
  - No unnecessary expensive view tree update.
  
  
  
Piece Functions
---------------
- SwiftUI-like declarative functions.
- Fill-content by default.
- You can override layout mode to fit-content by wrapping them with `fitX`, `fitY` or `fitXY` function.




To Do
------
- Overflow clipping support.
- Polish interface more.
