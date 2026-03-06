# Contributing to RobloxSnippets

Thank you for your interest in contributing to RobloxSnippets! We welcome contributions from the community to help make this collection of utility functions even better.

## How to Contribute

1. Fork the repository
2. Create a new branch for your feature (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Guidelines for New Snippets

When adding new snippets, please follow these guidelines:

1. Each snippet should be in its own `.luau` file
2. Use clear, descriptive names for functions and variables
3. Include type annotations for function parameters and return values
4. Add comments explaining complex logic or non-obvious behavior
5. Follow Roblox's Luau style guide
6. Test your code in Roblox Studio before submitting

## Code Style

- Use PascalCase for module names
- Use camelCase for function and variable names
- Include type annotations
- Keep functions focused and single-purpose
- Add appropriate comments for complex logic

Example:
```lua
local function calculateDistance(point1: Vector3, point2: Vector3): number
    -- Calculate Euclidean distance between two points
    return (point2 - point1).Magnitude
end
```

## Improving Existing Snippets

Feel free to improve existing snippets by:

- Optimizing performance
- Adding type safety
- Improving error handling
- Enhancing documentation
- Adding new features

When modifying existing code, please explain your changes in the pull request description.

## Documentation

When adding new snippets or making significant changes, please:

1. Update the README.md if necessary
2. Include example usage in comments
3. Document any dependencies or requirements
4. Explain any limitations or edge cases

## Licensing and Attribution

All contributions to this repository will be licensed under the MIT License with the additional attribution notice as specified in the LICENSE file. Please make sure you have read and understood the LICENSE file before contributing.

## Questions or Suggestions?

If you have questions or suggestions:

1. Open an Issue for discussion
2. Contact @DindinYT37 on Twitter
3. Message @dindinyt on Discord

## Code of Conduct

- Be respectful and constructive in discussions
- Help others learn and improve
- Give credit where credit is due
- Be open to feedback and suggestions

Thank you for contributing to making RobloxSnippets better for everyone! 