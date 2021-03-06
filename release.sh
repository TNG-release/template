#!/bin/bash

set -e

while [ $# -gt 0 ]; do
  case "$1" in
    --sonatypePassword=*)
      SONATYPE_PASSWORD="${1#*=}"
      ;;
    --sonatypeUsername=*)
      SONATYPE_USERNAME="${1#*=}"
      ;;
    --signingPassword=*)
      SIGNING_PASSWORD="${1#*=}"
      ;;
    --signingKey=*)
      SIGNING_KEY="${1#*=}"
      ;;
    --version=*)
      VERSION="${1#*=}"
      VERSION_PREFIXED="v${1#*=}"
      ;;
    *)
      printf "***************************\n"
      printf "* Error: Invalid argument.*\n"
      printf "***************************\n"
      exit 1
  esac
  shift
done

if [[ ! $VERSION =~ ^[0-9]*\.[0-9]*\.[0-9]*(-[A-Z0-9]*)?$ ]]; then
    echo "You have to provide a version as first parameter (without v-prefix, e.g. 0.14.0)"
    exit 1
fi

echo Releasing version "$VERSION"

echo Updating version in build.gradle...
sed -i -e s/version\ =.*/version\ =\ \"$VERSION\"/ build.gradle

if [ -n "$(git status --porcelain)" ]; then
    echo Commiting version change
    git add build.gradle
    git commit -m "Update version to $VERSION"
fi

echo Building, Testing, and Uploading Archives...
./gradlew --no-parallel clean test install uploadArchives

echo Creating Tag...
git tag -a -m "$VERSION_PREFIXED" "$VERSION_PREFIXED"

echo Closing the repository...
./gradlew closeRepository

echo Releasing the repository...
./gradlew releaseRepository

echo Publishing Gradle Plugin to Gradle Plugin repository...
./gradlew -b gradle-plugin/build.gradle publishPlugins -PsonatypeUsername="$SONATYPE_USERNAME" -PsonatypePassword="$SONATYPE_PASSWORD" -PsigningKey="$SIGNING_KEY" -PsigningPassword="$SIGNING_PASSWORD"

echo Pushing version and tag to GitHub repository...
git push
git push "$(git config --get remote.origin.url)" "$VERSION_PREFIXED"

