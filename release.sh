#!/bin/bash

set -e

if [[ ! $1 =~ ^[0-9]*\.[0-9]*\.[0-9]*(-[A-Z0-9]*)?$ ]]; then
    echo "You have to provide a version as first parameter (without v-prefix, e.g. 0.14.0)"
    exit 1
fi

VERSION=$1
VERSION_PREFIXED="v$1"

echo Releasing version $VERSION

echo Updating version in gradle.properties...
sed -i -e s/version\ =.*/version\ =\ \"$VERSION\"/ build.gradle

if [ -n "$(git status --porcelain)" ]; then
    echo Commiting version change
    git add gradle.properties
    git commit -m "Update version to $VERSION"
fi

echo Building, Testing, and Uploading Archives...
./gradlew --no-parallel clean test install uploadArchives

echo Creating Tag...
git tag -a -m $VERSION_PREFIXED $VERSION_PREFIXED

echo Closing the repository...
./gradlew closeRepository

echo Releasing the repository...
./gradlew releaseRepository

echo Publishing Gradle Plugin to Gradle Plugin repository...
./gradlew -b gradle-plugin/build.gradle publishPlugins -Dgradle.publish.key=$GRADLE_PLUGIN_RELEASE_KEY -Dgradle.publish.secret=$GRADLE_PLUGIN_RELEASE_SECRET

echo Pushing version and tag to GitHub repository...
git push
git push $(git config --get remote.origin.url) $VERSION_PREFIXED

