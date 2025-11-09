# Copyright 2023 The Bazel Authors. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Dependencies for covers used by the hermetic toolchain.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//python/private:version_label.bzl", "version_label")

# START: maintained by 'bazel run //tools/private/update_deps:update_coverage_deps <version>'
_coverage_deps = {
    "cp312": {
        "aarch64-apple-darwin": (
            "https://files.pythonhosted.org/packages/d3/6e/327f99767182a9481ba5c024ec9b6a488025de02587fcc4809682e36e178/covers-0.0.3-cp312-abi3-macosx_11_0_arm64.whl",
            "3a075ca5b2f83f040e9cb0ec0e4286e02933206832ebbd110938c6f1fef584f1",
        ),
        "aarch64-unknown-linux-gnu": (
            "https://files.pythonhosted.org/packages/ec/57/fd1f518ab05745d7865af6f4f4acc9d77f526e1ae8035d3b79f2c10bd723/covers-0.0.3-cp312-abi3-manylinux_2_17_aarch64.manylinux2014_aarch64.whl",
            "d8a2909e13f8b1538738cdbfb39a7298c7ec63c005822d4bf2d67e223557e7b1",
        ),
        "x86_64-apple-darwin": (
            "https://files.pythonhosted.org/packages/fd/1e/f978a167b33f663aa053497b1312af0f4d4b72f0cd1fafedd6ce84cd4387/covers-0.0.3-cp312-abi3-macosx_10_12_x86_64.whl",
            "42dcf9aee8e881b32c35131e0ba94ed43e34172a6b6c4fe8c952d67791dccc13",
        ),
        "x86_64-unknown-linux-gnu": (
            "https://files.pythonhosted.org/packages/6a/ed/b87d82ef9addd5d9f3ce3310c5d8e2ed4ced2df001785c3077694ec8840e/covers-0.0.3-cp312-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl",
            "b9356fa24bcca8154135d78398eb0776016e0e7887514a6bd52927288f0f3504",
        ),
    },
    "cp313": {
        "aarch64-apple-darwin": (
            "https://files.pythonhosted.org/packages/d3/6e/327f99767182a9481ba5c024ec9b6a488025de02587fcc4809682e36e178/covers-0.0.3-cp312-abi3-macosx_11_0_arm64.whl",
            "3a075ca5b2f83f040e9cb0ec0e4286e02933206832ebbd110938c6f1fef584f1",
        ),
        "aarch64-unknown-linux-gnu": (
            "https://files.pythonhosted.org/packages/ec/57/fd1f518ab05745d7865af6f4f4acc9d77f526e1ae8035d3b79f2c10bd723/covers-0.0.3-cp312-abi3-manylinux_2_17_aarch64.manylinux2014_aarch64.whl",
            "d8a2909e13f8b1538738cdbfb39a7298c7ec63c005822d4bf2d67e223557e7b1",
        ),
        "x86_64-apple-darwin": (
            "https://files.pythonhosted.org/packages/fd/1e/f978a167b33f663aa053497b1312af0f4d4b72f0cd1fafedd6ce84cd4387/covers-0.0.3-cp312-abi3-macosx_10_12_x86_64.whl",
            "42dcf9aee8e881b32c35131e0ba94ed43e34172a6b6c4fe8c952d67791dccc13",
        ),
        "x86_64-unknown-linux-gnu": (
            "https://files.pythonhosted.org/packages/6a/ed/b87d82ef9addd5d9f3ce3310c5d8e2ed4ced2df001785c3077694ec8840e/covers-0.0.3-cp312-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl",
            "b9356fa24bcca8154135d78398eb0776016e0e7887514a6bd52927288f0f3504",
        ),
    },
}
# END: maintained by 'bazel run //tools/private/update_deps:update_coverage_deps <version>'

def coverage_dep(name, python_version, platform, visibility):
    """Register a single coverage dependency based on the python version and platform.

    Args:
        name: The name of the registered repository.
        python_version: The full python version.
        platform: The platform, which can be found in //python:versions.bzl PLATFORMS dict.
        visibility: The visibility of the coverage tool.

    Returns:
        The label of the coverage tool if the platform is supported, otherwise - None.
    """
    if "windows" in platform:
        # NOTE @aignas 2023-01-19: currently we do not support windows as the
        # upstream coverage wrapper is written in shell. Do not log any warning
        # for now as it is not actionable.
        return None

    abi = "cp" + version_label(python_version)
    url, sha256 = _coverage_deps.get(abi, {}).get(platform, (None, ""))

    if url == None:
        # Some wheels are not present for some builds, so let's silently ignore those.
        return None

    maybe(
        http_archive,
        name = name,
        build_file_content = """
filegroup(
    name = "coverage",
    srcs = ["covers/__main__.py"],
    data = glob(["covers/*.py", "covers/**/*.py", "covers/*.so"]),
    visibility = {visibility},
)
    """.format(
            visibility = visibility,
        ),
        sha256 = sha256,
        type = "zip",
        urls = [url],
    )

    return "@{name}//:coverage".format(name = name)
