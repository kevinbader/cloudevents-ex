# Contributing to cloudevents-ex

Thank you for contributing! Feel free to open an issue if you have any questions or if there is something you'd like to discuss.

## Release

Creating a release is mostly automated:

1. With the working copy in a clean state, use [`release.sh (major|minor|patch)`](./release.sh) to create a new major/minor/patch release (requires [semver]). The script increases the package version accordingly, and also creates a Git tag.
2. Push the Git tag onto master. The [release workflow](./.github/workflows/release.yml) will take care of the rest, which includes
   - publishing the release to Hex.pm
   - creating a GitHub release

[semver]: https://www.npmjs.com/package/semver
