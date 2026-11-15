# Changelog
## [Unreleased](https://github.com/gilzoide/godot-dockable-container/compare/1.1.2...HEAD)
### Added
- `DockableContainer.hide_single_tab` exported property, passed down unchanged to managed `TabContainer`s

### Changed
- Dockable Container now targets Godot 4.X

### Removed
- Support for Godot 3.X

### Fixed
- Memory leak in layout nodes caused by a cyclic refence from children to parent node
- Fixed node icon scale in high DPI screens in editor


## [1.1.2](https://github.com/gilzoide/godot-dockable-container/releases/tag/1.1.2)
### Added
- New icon, made by [Nif-kun](https://github.com/Nif-kun). Licensed under [CC0](https://creativecommons.org/share-your-work/public-domain/cc0/).

### Fixed
- Fix Reference Control rects for styled panels


## [1.1.1](https://github.com/gilzoide/godot-dockable-container/releases/tag/1.1.1)
### Fixed
- Fix support for `_get_minimum_size` in reference controls


## [1.1.0](https://github.com/gilzoide/godot-dockable-container/releases/tag/1.1.0)
### Added
- Added support for moving tabs between multiple containers


## [1.0.0](https://github.com/gilzoide/godot-dockable-container/releases/tag/1.0.0)
### Added
- [DockableContainer](addons/dockable_container/dockable_container.gd) script: the container that supports tiling its children inside internally managed tab containers by dragging and dropping tabs inside the panels.
  When tiling panels, child Controls are only moved visually and maintain their child index and node paths.
- [DockableLayout](addons/dockable_container/layout.gd) Resource script: the Layout resource a container uses to keep information of how children are tiled.
  Can be easily persisted in disk.
- Dockable Container editor plugin that allows editing `DockableLayout`s in the inspector by dragging and dropping panels just like you would in runtime.
