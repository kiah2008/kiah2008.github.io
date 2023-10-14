---
layout: post
title: Android读写SDCard
categories: [storage]
tags: [android storage]
description: Android storage read/write
keywords: Android storage
dashang: true
topmost: false
mermaid: true
date: 2023-03-10 23:00:00 +0800
---

Android 读写sdcard文件

<!-- more -->

Android version R and above.

# manifest声明
read/write external permission
```xml
    <uses-permission
        android:name="android.permission.MANAGE_EXTERNAL_STORAGE"
        android:minSdkVersion="30" />
    <uses-permission
        android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="29" />
```
# 检查权限
onResume检查是否是storagemanager，如果是， 则进行目录遍历， 否则申请权限；

```kotlin
 adapter = ArrayAdapter(this, android.R.layout.simple_list_item_1, mutableListOf<String>())
        binding.filesTreeView.adapter = adapter
        binding.filesTreeView.setOnItemClickListener { _, _, position, _ ->
            val selectedItem = filesList[position]
            open(selectedItem)
        }

private fun open(selectedItem: File) {
        if (selectedItem.isFile) {
            return openFile(this, selectedItem)
        }

        currentDirectory = selectedItem
        filesList = getFilesList(currentDirectory)

        adapter.clear()
        adapter.addAll(filesList.map {
            if (it.path == selectedItem.parentFile.path) {
                renderParentLink(this)
            } else {
                renderItem(this, it)
            }
        })

        adapter.notifyDataSetChanged()
    }
```
# 申请权限

```kotlin
// AppOpsManager.OPSTR_MANAGE_EXTERNAL_STORAGE is a @SystemAPI at the moment
// We should remove the annotation for applications to avoid hardcoded value
const val MANAGE_EXTERNAL_STORAGE_PERMISSION = "android:manage_external_storage"
const val NOT_APPLICABLE = "N/A"

fun getStoragePermissionName(): String {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        MANAGE_EXTERNAL_STORAGE_PERMISSION
    } else {
        Manifest.permission.READ_EXTERNAL_STORAGE
    }
}

fun openPermissionSettings(activity: AppCompatActivity) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        requestStoragePermissionApi30(activity)
    }
    else {
        activity.startActivity(
            Intent(
                Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                Uri.fromParts("package", activity.packageName, null)
            )
        )
    }
}

fun getLegacyStorageStatus(): String {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        Environment.isExternalStorageLegacy().toString()
    } else {
        NOT_APPLICABLE
    }
}

fun getPermissionStatus(activity: AppCompatActivity): String {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        checkStoragePermissionApi30(activity).toString()
    } else {
        checkStoragePermissionApi19(activity).toString()
    }
}

fun checkStoragePermission(activity: AppCompatActivity): Boolean {
    return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        checkStoragePermissionApi30(activity)
    } else {
        checkStoragePermissionApi19(activity)
    }
}

fun requestStoragePermission(activity: AppCompatActivity) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        requestStoragePermissionApi30(activity)
    }
    // If you want to see the default storage behavior on Android Q once the permission is granted
    // Set the "requestLegacyExternalStorage" flag in the AndroidManifest.xml file to false
    else {
        requestStoragePermissionApi19(activity)
    }
}

@RequiresApi(30)
fun checkStoragePermissionApi30(activity: AppCompatActivity): Boolean {
    val appOps = activity.getSystemService(AppOpsManager::class.java)
    val mode = appOps.unsafeCheckOpNoThrow(
        MANAGE_EXTERNAL_STORAGE_PERMISSION,
        activity.applicationInfo.uid,
        activity.packageName
    )

    return mode == AppOpsManager.MODE_ALLOWED
}

@RequiresApi(30)
fun requestStoragePermissionApi30(activity: AppCompatActivity) {
    val intent = Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION)

    activity.startActivityForResult(intent, MANAGE_EXTERNAL_STORAGE_PERMISSION_REQUEST)
}

@RequiresApi(19)
fun checkStoragePermissionApi19(activity: AppCompatActivity): Boolean {
    val status =
        ContextCompat.checkSelfPermission(activity, Manifest.permission.READ_EXTERNAL_STORAGE)

    return status == PackageManager.PERMISSION_GRANTED
}

@RequiresApi(19)
fun requestStoragePermissionApi19(activity: AppCompatActivity) {
    val permissions = arrayOf(Manifest.permission.READ_EXTERNAL_STORAGE)
    ActivityCompat.requestPermissions(
        activity,
        permissions,
        READ_EXTERNAL_STORAGE_PERMISSION_REQUEST
    )
}
```