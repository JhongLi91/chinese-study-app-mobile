import sys

with open("Android/app/build.gradle.kts", "r") as f:
    content = f.read()

deps = """dependencies {
    implementation("androidx.compose.material:material-icons-extended:1.6.8")
}
"""

if "dependencies {" not in content:
    content += "\n" + deps

with open("Android/app/build.gradle.kts", "w") as f:
    f.write(content)
