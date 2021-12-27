Patchwork
=========
2021, Eonil.

Minimal declarative layout library for UIKit.

[![CI](https://github.com/eonil/patchwork/actions/workflows/main.yml/badge.svg)](https://github.com/eonil/patchwork/actions/workflows/main.yml)


Why?
----
SwiftUI is working, but still has numerous problems. Especially with layout errors.
It also lacks too much features, I still need to depend on UIKit heavily.
Apple is going to fix them eventualy, but I can't wait for it.
I need something right now, that works flawlessly with UIKit and does not spit any layout error. 
`Patchwork` is for that needs.



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
- Once resolved subtree can be used for final layout/rendering.
- On layout (e.g. frame changed), `PieceView` produces `RenderingPieceLayout` tree from `ResolvedPiece` tree.
- `PieceView` updates in-place or rebuilds view subtree to render `RenderingPieceLayout` tree. 



To Do
------
- Overflow clipping support.
- Polish interface more.
