# roblox-utils

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Stars](https://img.shields.io/github/stars/DindinYT37/roblox-utils?style=social)](https://github.com/DindinYT37/roblox-utils/stargazers)
[![Twitter](https://img.shields.io/twitter/follow/DindinYT37?style=social)](https://twitter.com/DindinYT37)
[![Discord](https://img.shields.io/badge/Discord-@dindinyt-7289DA?logo=discord&logoColor=white)](https://discord.com)

A curated collection of high-performance Roblox utility functions, featuring optimized snippets for number manipulation, string operations, cryptography, and more. Each module is thoroughly tested and ready for production use.

[Installation](#installation) • [Features](#features) • [Usage](#usage) • [Contributing](#contributing) • [License](#license)

</div>

## Features

This repository includes various modules for:

- Number formatting and manipulation
- Color manipulation and transitions
- Mathematical operations
- String operations
- Cryptographic functions
- Model manipulation
- Interpolation functions
- Random generation utilities

## Usage

Each module is self-contained and can be required independently. Here's a quick overview of available modules:

### Number Utilities
- `Abbreviate` - Converts numbers to abbreviated string format (e.g., 1000 -> "1K")
- `AddZeroes` - Pads numbers with leading zeros
- `FormatNumber` - Formats numbers with comma separators
- `Grid` - Snaps numbers to a grid
- `NearestMultiple` - Rounds numbers to nearest multiple
- `Map` - Maps a number from one range to another

### Color Utilities
- `ColorHSL` - HSL color conversion and manipulation
- `GammaColorTransition` - Color transitions with gamma correction

### Interpolation
- `CosineInterpolation` - Smooth interpolation using cosine
- `CubicInterpolation` - Cubic curve interpolation
- `HermiteInterpolation` - Hermite curve interpolation
- `LinearInterpolation` - Linear interpolation between values

### Cryptography
- `Base64` - Base64 encoding and decoding
- `MD5` - MD5 hash generation
- `HexCode` - Random hex code generation

### String Operations
- `Acronym` - Generates acronyms from strings
- `Grammar` - Basic grammar correction
- `Levenshtein` - Calculates Levenshtein distance between strings

### Vector/Model Operations
- `AngleBetween` - Calculates angle between vectors
- `ModelMover` - Utility for moving models
- `Reflection` - Calculates reflection vectors

### Random Generation
- `Chance` - Probability and random number utilities
- `GenerateRarity` - Weighted random rarity generation

### Misc
- `ClassifyScript` - Identifies script types
- `isWithin` - Range checking utility

## Installation

1. Clone this repository or download the desired modules
2. Place the modules as `ModuleScript` instances in Roblox Studio
3. Require the modules as needed

## Example

```lua
local Abbreviate = require(game:GetService("ReplicatedStorage").Abbreviate)
local formatted = Abbreviate(1500) -- Returns "1.5K"

local Map = require(game:GetService("ReplicatedStorage").Map)
local mapped = Map(50, 0, 100, 0, 1) -- Maps 50 from range 0-100 to range 0-1
```

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to submit pull requests, add new snippets, and improve existing ones.

## License

This project is licensed under the MIT License with an additional attribution notice - see the [LICENSE](LICENSE) file for details. While attribution is appreciated, it is not required for using these snippets in your projects.

<span style="font-size:80%;opacity:0.7;font-weight:500;">*All by @DindinYT37 on Twitter or @dindinyt on Discord.</span>