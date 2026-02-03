# Homebrew Tap Setup

This directory contains the Homebrew formula for `who-ran-what`.

## Setting Up the Tap

To enable `brew install who-ran-what`, you need to create a separate repository for the Homebrew tap.

### Step 1: Create the Tap Repository

Create a new GitHub repository named `homebrew-tools` (the `homebrew-` prefix is required).

```
Repository: mylee04/homebrew-tools
```

### Step 2: Copy the Formula

Copy `Formula/who-ran-what.rb` to the new repository:

```
homebrew-tools/
└── Formula/
    └── who-ran-what.rb
```

### Step 3: Update the SHA256

When you create a release (e.g., v0.1.0), get the SHA256 of the tarball:

```bash
# Download the release tarball
curl -L -o who-ran-what.tar.gz https://github.com/mylee04/who-ran-what/archive/refs/tags/v0.1.0.tar.gz

# Calculate SHA256
shasum -a 256 who-ran-what.tar.gz
```

Update `PLACEHOLDER_SHA256_WILL_BE_UPDATED_ON_RELEASE` in the formula with the actual SHA256.

### Step 4: Commit and Push

```bash
cd homebrew-tools
git add Formula/who-ran-what.rb
git commit -m "Add who-ran-what formula"
git push
```

### Step 5: Users Can Now Install

```bash
brew tap mylee04/tools
brew install who-ran-what
```

## Updating the Formula

When releasing a new version:

1. Create a new release tag on `who-ran-what` repo
2. Get the new tarball URL and SHA256
3. Update the formula in `homebrew-tools` repo
4. Users can then run `brew upgrade who-ran-what`

## Testing Locally

```bash
# Test the formula locally before publishing
brew install --build-from-source ./Formula/who-ran-what.rb
```
