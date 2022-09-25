创建Android APK一些相关技巧

Settings.gradle

定义Android module, 并配置Android项目名称.

```
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        maven { url "https://plugins.gradle.org/m2/" }
        maven { url "https://www.jitpack.io" } // for com.github.chrisbanes:PhotoView

        maven {
            name "local linphone-sdk maven repository"
            url file(LinphoneSdkBuildDir + '/maven_repository/')
            content {
                includeGroup "org.linphone"
            }
        }

        maven {
            name "linphone.org maven repository"
            url "https://linphone.org/maven_repository"
            content {
                includeGroup "org.linphone"
            }
        }
    }
}
include ':app'
rootProject.name='Linphone'
```

