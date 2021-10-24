# Template

This template shows examples of GitHub Actions, release scripts and build tool configurations that can be helptful to release your OSS at TNG.

Please also visit our [Confluence page](https://confluence.tngtech.com/pages/viewpage.action?pageId=424940325) for further
information on how to release OSS at TNG.

## Maven project
You should be interested in the following files
* pom.xml
* settings.xml
* releaseMavenProject.yaml

####The pom.xml
contains the parts that define the necessary plugins and commands for releasing your project. 
This should be the [nexus-maven-plugins](https://github.com/sonatype/nexus-maven-plugins/tree/master/staging/maven-plugin)
to upload artifacts to Sonatype and then Maven Central and the
[maven-gpg-plugin](https://github.com/apache/maven-gpg-plugin) to sign your artifacts. 
You probably want to copy-paste these parts into the pom.xml file of your project and may adjust it accordingly. 

####The settings.xml
contains the necessary references to credentials for signing artifacts and uploading them to sonatype. 
All credentials are replaced by placeholders.
You probably want to copy-paste this file into your release repository and leave it as it is.

####The releaseMavenProject.yaml
defines a GitHub Action that 
- checks out the source code of the project to be released
- replaces the placeholders in the settings.xml with the actual credentials retrieved from the secrets
- setups gnupg and add the GPG from the secret to allow signing of artifacts
- executes the maven command to build and release the project
You probably want to use this as a starting point for you own custom GitHub Action.

## Gradle project
You should be interested in the following files
* release.sh
* build.gradle or build.gradle.kts
* releaseGradleProject.yaml

####The build.gradle
contains the parts that define the necessary plugins and commands for releasing your project.
This should be the [gradle-nexus.publish-plugin](https://github.com/gradle-nexus/publish-plugin) to upload artifacts to Sonatype and then Maven Central
and the [signing-plugin](https://docs.gradle.org/current/userguide/signing_plugin.html) to sign your artifacts.
You probably want to copy-paste these parts into the build.gradle file of your project and may adjust it accordingly.

####The release.sh
contains all commands you need to execute during your release process. 
This can include executing tests, building the artifact, committing tags as well as signing and releasing the artifacts
You probably want to copy-paste this script into the repository of your project and may adjust it accordingly.
This setup has the advantage that every developer of your project can work on the release process while 
only some people have access to the release repository and thus the right to release the project. 

####The releaseGradleProject.yaml
defines a GitHub Action that
- checks out the source code of the project to be released
- setups GitHub to use executor of action as username for commits you might want to do during the release process
- executes release.sh script. All necessary credentials are handed over to the script via variables.
