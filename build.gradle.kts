// This example only shows how the environment variables provided by the GitHub action
// are used for the different plugins related to the publishing process.
// Thus, the configuration of the project is clearly incomplete!
plugins {
    id 'io.codearte.nexus-staging' version '0.21.1'
    id 'maven-publish'
    id 'signing'
}

val version = "1.0.0"
val isReleaseVersion by extra(version.endsWith("-SNAPSHOT"))
val sonatypeUsername by extra(System.getenv().getOrDefault("SONATYPE_USERNAME", ""))
val sonatypePassword by extra(System.getenv().getOrDefault("SONATYPE_PASSWORD", ""))

// see https://github.com/Codearte/gradle-nexus-staging-plugin
nexusStaging {
    stagingProfileId = stagingProfileId
    packageGroup = 'com.tngtech'
    username = sonatypeUsername
    password = sonatypePassword
    numberOfRetries = 30 // Sonatype can be a bit slow in closing the repository
}

publishing {
    // see https://docs.gradle.org/current/userguide/publishing_maven.html
    publications {
        create<MavenPublication>("mavenJava") {
            // ...
        }
    }

    repositories {
        maven {
            val releasesRepoUrl = uri("https://oss.sonatype.org/service/local/staging/deploy/maven2/")
            val snapshotRepoUrl = uri("https://oss.sonatype.org/content/repositories/snapshots/")
            url = if (isReleaseVersion) releasesRepoUrl else snapshotRepoUrl

            credentials {
                username = sonatypeUsername
                password = sonatypePassword
            }

            metadataSources {
                gradleMetadata()
            }
        }
    }
}

// signing plugin, see http://www.gradle.org/docs/current/userguide/signing_plugin.html
configure<SigningExtension> {
    setRequired({ isReleaseVersion && gradle.taskGraph.hasTask("publish") })
    val signingKey: String? by project
    val signingPassword: String? by project
    useInMemoryPgpKeys(signingKey, signingPassword)
    sign(the<PublishingExtension>().publications["mavenJava"])
}
